//
//  JnPopMenuViewDelegate.h
//  JnPopMenuView
//
//  Created by Jn_Kindle on 2016/10/19.
//  Copyright © 2016年 HuaDa. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JnPopMenuView, PopMenuModel, PopMenuButton;

@protocol JnPopMenuViewDelegate <NSObject>

- (void)popMenuView:(JnPopMenuView*)popMenuView didSelectItemAtIndex:(NSUInteger)index;

//....
@end
