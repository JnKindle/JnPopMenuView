//
//  popMenvTopView.m
//  JnPopMenuView
//
//  Created by Jn_Kindle on 2016/10/19.
//  Copyright © 2016年 HuaDa. All rights reserved.
//

#import "popMenvTopView.h"
#import "JnPopMenuView.h"

#define RGB(r, g, b)    [UIColor colorWithRed:r/255.f green:g/255.f blue:b/255.f alpha:1]
#define drakColor RGB(60, 60, 60)
#define lightColor RGB(249, 247, 234)


@interface popMenvTopView ()
@property (strong, nonatomic) NSArray *datas;
@property (nonatomic, assign) NSUInteger idx;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) JnPopMenuView* menu;
@end

@implementation popMenvTopView

+ (instancetype)popMenvTopView
{
    return [[[NSBundle mainBundle]loadNibNamed:@"popMenvTopView" owner:self options:nil] firstObject];
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        _idx = 0;
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    _timer = [NSTimer scheduledTimerWithTimeInterval:2.4f target:self selector:@selector(changeImage) userInfo:nil repeats:true];
    [self changeImage];
    
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(JnPopMenuViewWillShowNotification:) name:JnPopMenuViewWillShowNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(JnPopMenuViewWillHideNotification:) name:JnPopMenuViewWillHideNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(JnPopMenuViewDidShowNotification:) name:JnPopMenuViewDidShowNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(JnPopMenuViewDidHideNotification:) name:JnPopMenuViewDidHideNotification object:nil];
}

- (void)JnPopMenuViewWillShowNotification:(NSNotification *)notification
{
    _menu = [notification object];
    if (_menu.backgroundType == JnPopMenuViewBackgroundTypeDarkBlur ||
        _menu.backgroundType == JnPopMenuViewBackgroundTypeDarkTranslucent) {
        self.label1.textColor = lightColor;
        self.label2.textColor = lightColor;
        self.label3.textColor = lightColor;
        self.label4.textColor = lightColor;
    } else {
        self.label1.textColor = drakColor;
        self.label2.textColor = drakColor;
        self.label3.textColor = drakColor;
        self.label4.textColor = drakColor;
    }
}

- (void)JnPopMenuViewWillHideNotification:(NSNotification *)notification
{
//...
}

- (void)JnPopMenuViewDidShowNotification:(NSNotification *)notification
{
//...
}

- (void)JnPopMenuViewDidHideNotification:(NSNotification *)notification
{
//...
}

- (void)changeImage
{
    if (![_menu isOpenMenu]) return ;
    
    _idx ++;
    if (_idx > 6) {
        _idx = 1;
    }
    __weak popMenvTopView *weak = self;
    [UIView animateWithDuration:0.2 animations:^{
        
        weak.imageView.alpha = 0;
        
    } completion:^(BOOL finished) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"img-%zd",weak.idx]];
        weak.imageView.image = image;
        [UIView animateWithDuration:0.2 animations:^{
            weak.imageView.alpha = 1;
        }];
    }];
}

- (void)removeFromSuperview
{
    [super removeFromSuperview];
}

- (void)dealloc
{
    
}

@end
