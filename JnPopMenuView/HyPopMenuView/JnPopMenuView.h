//
//  JnPopMenuView.h
//  JnPopMenuView
//
//  Created by Jn_Kindle on 2016/10/19.
//  Copyright © 2016年 HuaDa. All rights reserved.
//

#import "JnPopMenuViewDelegate.h"
#import "PopMenuButton.h"
#import "PopMenuModel.h"
#import <UIKit/UIKit.h>

/**
 *  弹出动画类型
 *  animation Type
 */
typedef NS_ENUM(NSUInteger, JnPopMenuViewAnimationType) {
    /**
     *  仿新浪App弹出菜单。
     *  Sina App fake pop-up menu
     */
    JnPopMenuViewAnimationTypeSina,
    /**
     *  带有粘性的动画
     *  Animation with viscous
     */
    JnPopMenuViewAnimationTypeViscous,
    /**
     *  底部中心点弹出动画
     *  The bottom of the pop-up animation center
     */
    JnPopMenuViewAnimationTypeCenter,
    
    /**
     *  左和右弹出动画
     *  Left and right pop Anime
     */
    JnPopMenuViewAnimationTypeLeftAndRight,
};

typedef enum : NSUInteger {
    /**
     *  light模糊背景类型。
     *  light blurred background type.
     */
    JnPopMenuViewBackgroundTypeLightBlur,

    /**
     *  dark模糊背景类型。
     *  dark blurred background type.
     */
    JnPopMenuViewBackgroundTypeDarkBlur,

    /**
     *  偏白半透明背景类型。
     *  Partial white translucent background type.
     */
    JnPopMenuViewBackgroundTypeLightTranslucent,

    /**
     *  偏黑半透明背景类型。
     *  Partial translucent black background type.
     */
    JnPopMenuViewBackgroundTypeDarkTranslucent,

    /**
     *  白~黑渐变色。
     *  Gradient color.
     */
    JnPopMenuViewBackgroundTypeGradient,

} JnPopMenuViewBackgroundType; //背景类型
//Background type

@interface JnPopMenuView : UIView

/*=====================================================================================*/

@property (nonatomic, retain) NSArray<PopMenuModel*>* dataSource;

/**
 *  背景类型默认为 'JnPopMenuViewBackgroundTypeLightBlur'
 *  The default is 'JnPopMenuViewBackgroundTypeLightBlur'
*/
@property (nonatomic, assign) JnPopMenuViewBackgroundType backgroundType;

/**
 *  动画类型
 *  animation Type
 */
@property (nonatomic, assign) JnPopMenuViewAnimationType animationType;

/**
 *  自动识别颜色主题，默认为关闭。
 *  The default is false.
 */
@property (nonatomic, assign) BOOL automaticIdentificationColor;

/**
 *  JnPopMenuViewDelegate
 */
@property (nonatomic, assign) id<JnPopMenuViewDelegate> delegate;

/**
 *  默认为 10.0f         取值范围: 0.0f ~ 20.0f
 *  default is 10.0f    Range: 0 ~ 20
 */
@property (nonatomic, assign) CGFloat popMenuSpeed;

/**
 *  顶部自定义View
 */
@property (nonatomic, strong) UIView* topView;

+ (instancetype)sharedPopMenuManager;

- (void)openMenu;

- (void)closeMenu;

- (BOOL)isOpenMenu;

@end

UIKIT_EXTERN NSString* const JnPopMenuViewWillShowNotification;
UIKIT_EXTERN NSString* const JnPopMenuViewDidShowNotification;
UIKIT_EXTERN NSString* const JnPopMenuViewWillHideNotification;
UIKIT_EXTERN NSString* const JnPopMenuViewDidHideNotification;
