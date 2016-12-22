//
//  JnPopMenuView.m
//  JnPopMenuView
//
//  Created by Jn_Kindle on 2016/10/19.
//  Copyright © 2016年 HuaDa. All rights reserved.
//

#import "JnPopMenuView.h"
#import "UIColor+ImageGetColor.h"
#import <AudioToolbox/AudioToolbox.h>
#import <pop/POP.h>

#define Duration 0.2
#define KeyPath @"transform.scale"
#define CancelStrImgaeName @"tabbar_compose_background_icon_add"
#define kW [UIScreen mainScreen].bounds.size.width
#define kH [UIScreen mainScreen].bounds.size.height

@interface JnPopMenuView () {
@private
    UIWindow* window;
}

@property (nonatomic, weak) UIView* backgroundView;
@property (nonatomic, weak) UIButton* disappearButton;
@property (nonatomic, weak) UIView* bottomView;
@property (nonatomic, assign) BOOL isOpen;

@end

@implementation JnPopMenuView

static JnPopMenuView* _popMenuObject;

+ (instancetype)allocWithZone:(struct _NSZone*)zone
{

    _popMenuObject = [super allocWithZone:zone];

    return _popMenuObject;
}

+ (instancetype)sharedPopMenuManager
{
    _popMenuObject = [[self alloc] sharedPopMenuManager];
    return _popMenuObject;
}

- (id)copyWithZone:(NSZone*)zone
{
    return _popMenuObject;
}

- (instancetype)sharedPopMenuManager
{
    if (self == [super init]) {
        [self setFrame:[UIScreen mainScreen].bounds];
        _animationType = JnPopMenuViewAnimationTypeSina;
        _backgroundType = JnPopMenuViewBackgroundTypeLightBlur;
        _automaticIdentificationColor = false;
        _popMenuSpeed = 10.f;
    }
    return self;
}

- (void)initUIsize
{
    [[UIButton appearance] setExclusiveTouch:true];
    UIView* bottomView = [_backgroundView viewWithTag:2];
    if (!bottomView) {
        bottomView = [UIView new];
        [_backgroundView addSubview:bottomView];
        [bottomView setTag:2];
        _bottomView = bottomView;
    }
    bottomView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    bottomView.frame = CGRectMake(0, CGRectGetMaxY(self.bounds) - 52, kW, 52);
    [bottomView setBackgroundColor:[UIColor colorWithWhite:1.f alpha:0.90f]];

    if (_backgroundType == JnPopMenuViewBackgroundTypeDarkBlur || _backgroundType == JnPopMenuViewBackgroundTypeDarkTranslucent || _backgroundType == JnPopMenuViewBackgroundTypeGradient) {
        [bottomView setBackgroundColor:[UIColor colorWithRed:90.f / 225.f green:90.f / 225.f blue:90.f / 225.f alpha:0.9f]];
    }

    UIButton* disappearButton = [_backgroundView viewWithTag:3];
    if (!disappearButton) {
        disappearButton = [UIButton buttonWithType:UIButtonTypeCustom];
        disappearButton.adjustsImageWhenHighlighted = NO;
        [_backgroundView addSubview:disappearButton];
        disappearButton.tag = 3;
        _disappearButton = disappearButton;
    }
    [disappearButton setBackgroundImage:[UIImage imageNamed:CancelStrImgaeName] forState:UIControlStateNormal];
    [disappearButton addTarget:self  action:@selector(closeMenu) forControlEvents:UIControlEventTouchUpInside];
    CGFloat CANCELw = 28;
    disappearButton.bounds = CGRectMake(0, 0, CANCELw, CANCELw);
    disappearButton.center = bottomView.center;
}

- (void)openMenu
{
    [self addNotificationAtNotificationName:JnPopMenuViewWillShowNotification];
    _delegate = (id)[self currentViewController];
    UIView* backgroundView = [self effectsViewWithType:_backgroundType];
    _backgroundView = backgroundView;
    if (_topView) {
        [_backgroundView addSubview:_topView];
    }
    [self addSubview:_backgroundView];
    [self initUIsize];
    [self backgroundAnimate];
    [self show];
}

- (void)closeMenu
{
    [self addNotificationAtNotificationName:JnPopMenuViewWillHideNotification];
    __weak JnPopMenuView* weakView = self;
    [self disappearPopMenuViewAnimate];
    [UIView animateWithDuration:0.3 animations:^{
        weakView.bottomView.backgroundColor = [UIColor clearColor];
        weakView.disappearButton.transform = CGAffineTransformMakeRotation(0);
        [weakView.disappearButton setAlpha:0.1f];
    }];
    double d = (weakView.dataSource.count * 0.04) + 0.3;
    [UIView animateKeyframesWithDuration:Duration delay:d options:0 animations:^{
        weakView.backgroundView.alpha = 0.0;
    }
        completion:^(BOOL finished) {
            [weakView addNotificationAtNotificationName:JnPopMenuViewDidHideNotification];
            [weakView.backgroundView removeFromSuperview];
            [window setHidden:finished];
            weakView.isOpen = false;
        }];
}

- (void)backgroundAnimate
{
    __weak JnPopMenuView* weakView = self;
    [UIView animateWithDuration:Duration animations:^{
        [weakView.backgroundView setAlpha:1];
        weakView.disappearButton.transform = CGAffineTransformMakeRotation((M_PI / 2) / 2);
    }];
    [self showItemAnimate];
}

- (void)showItemAnimate
{
    __weak JnPopMenuView* weakView = self;
    double d = (self.dataSource.count * 0.04) + 0.3;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(d * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakView addNotificationAtNotificationName:JnPopMenuViewDidShowNotification];
    });
    [_dataSource enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL* _Nonnull stop) {
        PopMenuModel* model = obj;
        model.automaticIdentificationColor = weakView.automaticIdentificationColor;
        [model.customView removeFromSuperview];
        model.customView.alpha = 0.0f;
        [weakView.backgroundView addSubview:model.customView];

        CGRect toRect;
        CGRect fromRect;
        double dy = idx * 0.035f;
        CFTimeInterval delay = dy + CACurrentMediaTime();

        switch (_animationType) {
        case JnPopMenuViewAnimationTypeSina:
            toRect = [weakView getFrameAtIndex:idx];
            fromRect = CGRectMake(CGRectGetMinX(toRect),
                CGRectGetMinY(toRect) + 130,
                toRect.size.width,
                toRect.size.height);
            break;
        case JnPopMenuViewAnimationTypeCenter:
            toRect = [weakView getFrameAtIndex:idx];
            fromRect = CGRectMake(CGRectGetMidX(weakView.frame) - CGRectGetWidth(fromRect) / 2,
                (CGRectGetMinY(toRect) + (kH - CGRectGetMinY(toRect))) - 25,
                toRect.size.width,
                toRect.size.height);
            break;
        case JnPopMenuViewAnimationTypeViscous:
            toRect = [weakView getFrameAtIndex:idx];
            fromRect = CGRectMake(CGRectGetMinX(toRect),
                CGRectGetMinY(toRect) + (kH - CGRectGetMinY(toRect)),
                toRect.size.width,
                toRect.size.height);
            break;
        case JnPopMenuViewAnimationTypeLeftAndRight:
            toRect = [weakView getFrameAtIndex:idx];
            CGFloat d = (idx % 2) == 0 ? 0:CGRectGetWidth(toRect);
            CGFloat x = ((idx % 2) * kW) - d;
            fromRect = CGRectMake(x,
                                  CGRectGetMinY(toRect) + (kH - CGRectGetMinY(toRect)),
                                  toRect.size.width,
                                  toRect.size.height);
            break;
        }
        [self classAnimationWithfromRect:fromRect
                                  toRect:toRect
                                  deleay:delay
                                   views:model.customView
                                  isHidd:false];

        PopMenuButton* button = (id)model.customView;
        [button addTarget:self action:@selector(selectedFunc:) forControlEvents:UIControlEventTouchUpInside];
    }];
}

- (void)classAnimationWithfromRect:(CGRect)age1
                            toRect:(CGRect)age2
                            deleay:(CFTimeInterval)age3
                             views:(UIView*)age4
                            isHidd:(BOOL)age5
{
    __weak JnPopMenuView* weakView = self;
    if (_animationType == JnPopMenuViewAnimationTypeSina) {

        [self startSinaAnimationfromValue:age1
                                  toValue:age2
                                    delay:age3
                                   object:age4
                          completionBlock:^(BOOL CompletionBlock) {
                              [weakView addTap];
                          }
                              hideDisplay:age5];
    }
    else if (_animationType == JnPopMenuViewAnimationTypeViscous) {

        [self startViscousAnimationFormValue:age1
                                     ToValue:age2
                                       Delay:age3
                                      Object:age4
                             CompletionBlock:^(BOOL CompletionBlock) {
                                 [weakView addTap];
                             }
                                 HideDisplay:age5];
    }
    else if (_animationType == JnPopMenuViewAnimationTypeCenter) {

        [self startSinaAnimationfromValue:age1
                                  toValue:age2
                                    delay:age3
                                   object:age4
                          completionBlock:^(BOOL CompletionBlock) {
                              [weakView addTap];
                          }
                              hideDisplay:age5];
    } else if (_animationType == JnPopMenuViewAnimationTypeLeftAndRight) {
        [self startSinaAnimationfromValue:age1
                                  toValue:age2
                                    delay:age3
                                   object:age4
                          completionBlock:^(BOOL CompletionBlock) {
                              [weakView addTap];
                          }
                              hideDisplay:age5];
    }
}

- (void)addTap
{
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(closeMenu)];
    [_backgroundView addGestureRecognizer:tap];
    _isOpen = true;
}

- (CGFloat)maxItemsMinY
{
    CGRect rect = [self getFrameAtIndex:0];
    return CGRectGetMinY(rect);
}

- (CGRect)getFrameAtIndex:(NSUInteger)index;
{
    NSInteger column = 3;
    CGFloat buttonViewWidth = MIN(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)) / column;
    CGFloat buttonViewHeight = (buttonViewWidth - 10);
    CGFloat margin = (self.frame.size.width - column * buttonViewWidth) / (column + 1);
    NSInteger colnumIndex = index % column;
    NSInteger rowIndex = index / column;
    NSUInteger toRows = (_dataSource.count / column);

    CGFloat toHeight = toRows * buttonViewHeight;

    CGFloat buttonViewX = (colnumIndex + 1) * margin + colnumIndex * buttonViewWidth;
    CGFloat buttonViewY = ((rowIndex + 1) * margin + rowIndex * buttonViewHeight) + (kH - toHeight) - 150;
    CGRect rect = CGRectMake(buttonViewX, buttonViewY, buttonViewWidth, buttonViewHeight);
    return rect;
}

- (void)disappearPopMenuViewAnimate
{
    __weak JnPopMenuView* weakView = self;
    [_dataSource enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL* _Nonnull stop) {
        double d = weakView.dataSource.count * 0.04;
        double dy = d - idx * 0.04;
        PopMenuModel* model = obj;
        CFTimeInterval delay = dy + CACurrentMediaTime();

        CGRect toRect;
        CGRect fromRect;

        switch (_animationType) {
        case JnPopMenuViewAnimationTypeSina:

            fromRect = [weakView getFrameAtIndex:idx];
            toRect = CGRectMake(CGRectGetMinX(fromRect),
                kH,
                CGRectGetWidth(fromRect),
                CGRectGetHeight(fromRect));

            break;
        case JnPopMenuViewAnimationTypeCenter:

            fromRect = [weakView getFrameAtIndex:idx];
            toRect = CGRectMake(CGRectGetMidX(weakView.frame) - CGRectGetWidth(fromRect) / 2,
                (CGRectGetMinY(toRect) + (kH - CGRectGetMinY(toRect))) - 25,
                fromRect.size.width,
                fromRect.size.height);

            break;
        case JnPopMenuViewAnimationTypeViscous:

            fromRect = [weakView getFrameAtIndex:idx];
            toRect = CGRectMake(CGRectGetMinX(fromRect),
                CGRectGetMinY(fromRect) + (kH - CGRectGetMinY(fromRect)),
                fromRect.size.width,
                fromRect.size.height);

            break;
        case JnPopMenuViewAnimationTypeLeftAndRight:
                fromRect = [weakView getFrameAtIndex:idx];
                CGFloat d = (idx % 2) == 0 ? 0:CGRectGetWidth(fromRect);
                CGFloat x = ((idx % 2) * kW) - d;

                toRect = CGRectMake(x,
                                    CGRectGetMinY(fromRect) + (kH - CGRectGetMinY(fromRect)),
                                    fromRect.size.width,
                                    fromRect.size.height);
                break;
        }
        [self classAnimationWithfromRect:fromRect
                                  toRect:toRect
                                  deleay:delay
                                   views:model.customView
                                  isHidd:true];
    }];
}

- (__kindof UIView*)effectsViewWithType:(JnPopMenuViewBackgroundType)type
{
    if (_backgroundView) {
        [_backgroundView removeFromSuperview];
        _backgroundView = nil;
    }

    UIView* effectView = nil;
    UIBlurEffect* effectBlur = nil;
    CAGradientLayer* gradientLayer = nil;
    switch (type) {
    case JnPopMenuViewBackgroundTypeDarkBlur:
        effectBlur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        break;
    case JnPopMenuViewBackgroundTypeDarkTranslucent:

        break;
    case JnPopMenuViewBackgroundTypeLightBlur:
        effectBlur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        break;
    case JnPopMenuViewBackgroundTypeLightTranslucent:

        break;
    case JnPopMenuViewBackgroundTypeGradient:
        gradientLayer = [self gradientLayerWithColor1:[UIColor colorWithWhite:1 alpha:0.1f] AtColor2:[UIColor colorWithWhite:0.0f alpha:1.0f]];
        break;
    }

    if (effectBlur) {
        effectView = [[UIVisualEffectView alloc] initWithEffect:effectBlur];
    }
    else {
        effectView = [UIView new];
        if (gradientLayer) {
            [effectView.layer addSublayer:gradientLayer];
        }
        else {
            effectView.backgroundColor = [UIColor colorWithWhite:(CGFloat)(type == JnPopMenuViewBackgroundTypeLightTranslucent) alpha:0.7];
        }
    }
    effectView.frame = self.bounds;
    effectView.alpha = 0.0f;

    return effectView;
}

- (CAGradientLayer*)gradientLayerWithColor1:(UIColor*)color1 AtColor2:(UIColor*)color2
{
    CAGradientLayer* layer = [CAGradientLayer new];
    layer.colors = @[ (__bridge id)color1.CGColor, (__bridge id)color2.CGColor ];
    layer.startPoint = CGPointMake(0.5f, -0.5);
    layer.endPoint = CGPointMake(0.5, 1);
    layer.frame = self.bounds;
    return layer;
}

- (void)selectedFunc:(PopMenuButton*)sender
{
    __weak JnPopMenuView* weakView = self;
    [_dataSource enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL* _Nonnull stop) {
        PopMenuModel* model = obj;
        PopMenuButton* button = (id)model.customView;
        if (sender == button) {
            [sender selectdAnimation];
        }
        else {
            [button cancelAnimation];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [model performSelector:@selector(_obj)];
        });
    }];
    NSUInteger idx = [_dataSource indexOfObject:sender.model];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([weakView.delegate respondsToSelector:@selector(popMenuView:didSelectItemAtIndex:)]) {
            [weakView.delegate popMenuView:weakView didSelectItemAtIndex:idx];
        }
    });
    [UIView animateWithDuration:0.2 animations:^{
        weakView.bottomView.backgroundColor = [UIColor clearColor];
        weakView.disappearButton.transform = CGAffineTransformMakeRotation(0);
        [weakView.disappearButton setAlpha:0.1f];
    }];

    [UIView animateKeyframesWithDuration:0.5 delay:0.2f options:0 animations:^{
        weakView.backgroundView.alpha = 0.0;
    }
        completion:^(BOOL finished) {

            [weakView.backgroundView removeFromSuperview];
            [window setHidden:finished];
        }];
}

- (UIViewController*)appRootViewController
{
    UIViewController* appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController* topVC = appRootVC;
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    return topVC;
}

- (UIViewController*)currentViewController
{
    UIViewController* vc = [self appRootViewController];
    if ([vc isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tab = (UITabBarController*)vc;
        if ([tab.selectedViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController* nav = (UINavigationController*)tab.selectedViewController;
            return [nav.viewControllers lastObject];
        }
        else {
            return tab.selectedViewController;
        }
    }
    else if ([vc isKindOfClass:[UINavigationController class]]) {
        UINavigationController* nav = (UINavigationController*)vc;
        return [nav.viewControllers lastObject];
    }
    else {
        return vc;
    }
    return nil;
}

- (void)setDataSource:(NSArray*)dataSource
{
    NSMutableArray* tepmArr = [NSMutableArray arrayWithCapacity:MIN(9, dataSource.count)];
    [dataSource enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL* _Nonnull stop) {
        if (idx == 9) {
            *stop = true;
            return;
        }
        [tepmArr addObject:obj];
    }];
    _dataSource = [NSArray arrayWithArray:tepmArr];
}

- (void)startViscousAnimationFormValue:(CGRect)fromValue
                               ToValue:(CGRect)toValue
                                 Delay:(CFTimeInterval)delay
                                Object:(UIView*)obj
                       CompletionBlock:(void (^)(BOOL CompletionBlock))completionBlock
                           HideDisplay:(BOOL)hideDisplay
{
    CGFloat toV, fromV;
    CGFloat springBounciness = 8.f;
    toV = !hideDisplay;
    fromV = hideDisplay;

    if (hideDisplay) {
        POPBasicAnimation* basicAnimationCenter = [POPBasicAnimation animationWithPropertyNamed:kPOPViewCenter];
        basicAnimationCenter.toValue = [NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX(toValue), CGRectGetMidY(toValue))];
        basicAnimationCenter.fromValue = [NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX(fromValue), CGRectGetMidY(fromValue))];
        basicAnimationCenter.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        basicAnimationCenter.beginTime = delay;
        basicAnimationCenter.duration = 0.18;
        [obj pop_addAnimation:basicAnimationCenter forKey:basicAnimationCenter.name];

        POPBasicAnimation* basicAnimationScale = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleX];
        basicAnimationScale.removedOnCompletion = YES;
        basicAnimationScale.beginTime = delay;
        basicAnimationScale.toValue = @(0.7);
        basicAnimationScale.fromValue = @(1);
        basicAnimationScale.duration = 0.18;
        basicAnimationScale.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        [obj.layer pop_addAnimation:basicAnimationScale forKey:basicAnimationScale.name];
    }
    else {
        POPSpringAnimation* basicAnimationCenter = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
        basicAnimationCenter.beginTime = delay;
        basicAnimationCenter.springSpeed = _popMenuSpeed;
        basicAnimationCenter.springBounciness = springBounciness;
        basicAnimationCenter.toValue = [NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX(toValue), CGRectGetMidY(toValue))];
        basicAnimationCenter.fromValue = [NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX(fromValue), CGRectGetMidY(fromValue))];

        POPBasicAnimation* basicAnimationScale = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleX];
        basicAnimationScale.beginTime = delay;
        basicAnimationScale.toValue = @(1);
        basicAnimationScale.fromValue = @(0.7);
        basicAnimationScale.duration = 0.3f;
        basicAnimationScale.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        [obj.layer pop_addAnimation:basicAnimationScale forKey:basicAnimationScale.name];

        POPBasicAnimation* basicAnimationAlpha = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
        basicAnimationAlpha.removedOnCompletion = YES;
        basicAnimationAlpha.duration = 0.1f;
        basicAnimationAlpha.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        basicAnimationAlpha.beginTime = delay;
        basicAnimationAlpha.toValue = @(toV);
        basicAnimationAlpha.fromValue = @(fromV);

        [obj pop_addAnimation:basicAnimationAlpha forKey:basicAnimationAlpha.name];
        [obj pop_addAnimation:basicAnimationCenter forKey:basicAnimationCenter.name];
        [basicAnimationCenter setCompletionBlock:^(POPAnimation* spring, BOOL Completion) {
            if (!completionBlock) {
                return;
            }
            if (Completion) {
                completionBlock(Completion);
            }
        }];
    }
}

- (void)startSinaAnimationfromValue:(CGRect)fromValue
                            toValue:(CGRect)toValue
                              delay:(CFTimeInterval)delay
                             object:(UIView*)obj
                    completionBlock:(void (^)(BOOL CompletionBlock))completionBlock
                        hideDisplay:(BOOL)hideDisplay
{

    CGFloat toV, fromV;
    CGFloat springBounciness = 10.f;
    toV = !hideDisplay;
    fromV = hideDisplay;

    if (hideDisplay) {
        POPBasicAnimation* basicAnimationCenter = [POPBasicAnimation animationWithPropertyNamed:kPOPViewCenter];
        basicAnimationCenter.toValue = [NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX(toValue), CGRectGetMidY(toValue))];
        basicAnimationCenter.fromValue = [NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX(fromValue), CGRectGetMidY(fromValue))];
        basicAnimationCenter.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        basicAnimationCenter.beginTime = delay;
        basicAnimationCenter.duration = 0.18;
        [obj pop_addAnimation:basicAnimationCenter forKey:basicAnimationCenter.name];

        POPBasicAnimation* basicAnimationScale = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
        basicAnimationScale.removedOnCompletion = YES;
        basicAnimationScale.beginTime = delay;
        basicAnimationScale.toValue = [NSValue valueWithCGPoint:CGPointMake(0.7, 0.7)];
        basicAnimationScale.fromValue = [NSValue valueWithCGPoint:CGPointMake(1, 1)];
        basicAnimationScale.duration = 0.18;
        basicAnimationScale.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        [obj.layer pop_addAnimation:basicAnimationScale forKey:basicAnimationScale.name];
        [basicAnimationScale setCompletionBlock:^(POPAnimation* s, BOOL b) {
            PopMenuButton* btn = (id)obj;
            [btn.model performSelector:@selector(_obj)];
        }];
    }
    else {
        POPSpringAnimation* springAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
        springAnimation.removedOnCompletion = YES;
        springAnimation.beginTime = delay;
        springAnimation.springBounciness = springBounciness; // value between 0-20
        springAnimation.springSpeed = _popMenuSpeed; // value between 0-20
        springAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX(toValue), CGRectGetMidY(toValue))];
        springAnimation.fromValue = [NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX(fromValue), CGRectGetMidY(fromValue))];

        POPBasicAnimation* basicAnimationAlpha = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
        basicAnimationAlpha.removedOnCompletion = YES;
        basicAnimationAlpha.duration = 0.2;
        basicAnimationAlpha.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        basicAnimationAlpha.beginTime = delay;
        basicAnimationAlpha.toValue = @(toV);
        basicAnimationAlpha.fromValue = @(fromV);
        [obj pop_addAnimation:basicAnimationAlpha forKey:basicAnimationAlpha.name];
        [obj pop_addAnimation:springAnimation forKey:springAnimation.name];
        [springAnimation setCompletionBlock:^(POPAnimation* spring, BOOL Completion) {
            if (!completionBlock) {
                return;
            }
            if (Completion) {
                completionBlock(Completion);
            }
        }];
    }
}

- (void)animationDidStop:(CAAnimation*)anim finished:(BOOL)flag
{

    CABasicAnimation* cab = (CABasicAnimation*)anim;
    if ([cab.keyPath isEqualToString:@"transform.scale"]) {
    }
}

- (void)playSoundName:(NSString*)name
              ForType:(NSString*)type

{
    NSString* AudioName = [NSString stringWithFormat:@"%@.%@", name, type];
    NSURL* url = [[NSBundle mainBundle] URLForResource:AudioName withExtension:nil];

    SystemSoundID soundID = 0;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &soundID);
    AudioServicesPlaySystemSound(soundID);
}

- (void)show
{
    if (!window) {
        window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }
    window.windowLevel = UIWindowLevelAlert;
    window.backgroundColor = [UIColor clearColor];
    window.alpha = 1;
    window.hidden = false;
    [window addSubview:self];
}

- (BOOL)isOpenMenu
{
    return _isOpen;
}

- (void)addNotificationAtNotificationName:(NSString*)notificationNmae
{
    //NSNotification* broadcastMessage = [NSNotification notificationWithName:notificationNmae object:nil];
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:notificationNmae object:self];
}

- (void)setTopView:(UIView*)topView
{
    if (_topView) {
        [_topView removeFromSuperview];
    }
    _topView = topView;
}

- (void)_obj {}
@end

NSString* const JnPopMenuViewWillShowNotification = @"JnPopMenuViewWillShowNotification";
NSString* const JnPopMenuViewDidShowNotification = @"JnPopMenuViewDidShowNotification";
NSString* const JnPopMenuViewWillHideNotification = @"JnPopMenuViewWillHideNotification";
NSString* const JnPopMenuViewDidHideNotification = @"JnPopMenuViewDidHideNotification";
