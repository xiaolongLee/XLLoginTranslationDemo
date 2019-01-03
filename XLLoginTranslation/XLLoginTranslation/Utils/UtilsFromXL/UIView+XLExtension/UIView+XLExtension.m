//
//  UIView+XLExtension.m
//  XLLoginTranslation
//
//  Created by Mac-Qke on 2018/12/28.
//  Copyright © 2018 Mac-Qke. All rights reserved.
//

#import "UIView+XLExtension.h"

@implementation UIView (XLExtension)
- (void)setXl_size:(CGSize)xl_size{
    CGRect frame = self.frame;
    frame.size = xl_size;
    self.frame = frame;
}

- (CGSize)xl_size{
    return self.frame.size;
}

- (void)setXl_width:(CGFloat)xl_width{
    if (isnan(xl_width)) {
        return;
    }
    
    CGRect frame = self.frame;
    frame.size.width = xl_width;
    self.frame = frame;
}

- (void)setXl_height:(CGFloat)xl_height {
    if (isnan(xl_height)) {
        return;
    }
    
    CGRect frame = self.frame;
    frame.size.height = xl_height;
    self.frame = frame;
}

- (void)setXl_x:(CGFloat)xl_x {
    if (isnan(xl_x)) {
        return;
    }
    
    CGRect frame = self.frame;
    frame.origin.x = xl_x;
    self.frame = frame;
    
}

- (void)setXl_y:(CGFloat)xl_y {
    CGRect frame = self.frame;
    frame.origin.y = xl_y;
    self.frame = frame;
    
}

- (void)setXl_centerX:(CGFloat)xl_centerX {
    CGPoint center = self.center;
    center.x = xl_centerX;
    self.center = center;
}

- (void)setXl_centerY:(CGFloat)xl_centerY {
    CGPoint center = self.center;
    center.y = xl_centerY;
    self.center = center;
}

- (CGFloat)xl_centerY {
    
    return self.center.y;
}

- (CGFloat)xl_centerX {
    return self.center.x;
}

- (CGFloat)xl_width {
    return self.frame.size.width;
}

- (CGFloat)xl_height {
    return self.frame.size.height;
}

- (CGFloat)xl_x{
    return self.frame.origin.x;
}

- (CGFloat)xl_y{
    return self.frame.origin.y;
}
@end
