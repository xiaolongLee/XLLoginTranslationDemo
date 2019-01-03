//
//  XLLoginTranslation.h
//  XLLoginTranslation
//
//  Created by Mac-Qke on 2018/12/28.
//  Copyright © 2018 Mac-Qke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface XLLoginTranslation : NSObject <UIViewControllerAnimatedTransitioning>
/** 登录或注销 YES:登录 */
@property (nonatomic, assign) BOOL doLogin;
@end

NS_ASSUME_NONNULL_END
