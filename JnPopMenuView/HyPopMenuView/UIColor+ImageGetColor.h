//
//  UIColor+ImageGetColor.h
//  JnPopMenuView
//
//  Created by Jn_Kindle on 2016/10/19.
//  Copyright © 2016年 HuaDa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/ES1/glext.h>

@interface UIView (GetImgae)

-(UIImage *)imageRepresentation;

@end

@interface UIColor (ImageGetColor)

+ (UIColor*) getPixelColorAtLocation:(CGPoint)point inImage:(UIImage *)image;

@end


@interface UIImage (Tint)

- (UIImage *) imageWithTintColor:(UIColor *)tintColor;

@end
