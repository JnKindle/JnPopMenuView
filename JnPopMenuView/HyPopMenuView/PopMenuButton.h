//
//  PopMenuButton.h
//  JnPopMenuView
//
//  Created by Jn_Kindle on 2016/10/19.
//  Copyright © 2016年 HuaDa. All rights reserved.
//

#import "JnPopMenuView.h"
#import <UIKit/UIKit.h>

typedef void (^completionAnimation)();

@interface PopMenuButton : UIButton

@property (nonatomic, nonnull, strong) PopMenuModel* model;

@property (nonatomic, nonnull, strong) completionAnimation block;

- (instancetype __nonnull)init;
- (void)selectdAnimation;
- (void)cancelAnimation;

@end
