//
//  XLFirstViewViewController.h
//  XLLoginTranslation
//
//  Created by Mac-Qke on 2018/12/28.
//  Copyright © 2018 Mac-Qke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XLAddView.h"
NS_ASSUME_NONNULL_BEGIN

@interface XLFirstViewViewController : UIViewController
//导航栏
@property (nonatomic, strong) UIView *navView;
//导航栏上面的文字
@property (nonatomic, strong) UILabel *navWord;
//加号按钮
@property (nonatomic, strong) XLAddView *addView;
//背景
@property (nonatomic, strong) UIImageView *backImage;
@end

NS_ASSUME_NONNULL_END
