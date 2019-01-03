//
//  XLFirstViewViewController.m
//  XLLoginTranslation
//
//  Created by Mac-Qke on 2018/12/28.
//  Copyright © 2018 Mac-Qke. All rights reserved.
//

#import "XLFirstViewViewController.h"
#import "UIView+XLExtension.h"

#define XLScreenW [UIScreen mainScreen].bounds.size.width
#define XLScreenH [UIScreen mainScreen].bounds.size.height
@interface XLFirstViewViewController ()



@end

@implementation XLFirstViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUIComponent];
}

/** 初始化UI */
- (void)setupUIComponent {
    self.backImage.hidden = NO;
    self.navView.hidden = NO;
    self.addView.hidden = NO;
    
    [self.navView addSubview:self.navWord];
    self.navWord.xl_centerX = self.navView.xl_centerX;
    self.navWord.xl_centerY = self.navView.xl_centerY + 10;
}

/** 点击加号按钮 */
- (void)addViewClick{
    //退回登录页面
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 懒加载
- (UIImageView *)backImage {
    if (!_backImage) {
        _backImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"backImg.jpg"]];
        [self.view addSubview:_backImage];
        _backImage.frame = CGRectMake(0, 0, XLScreenW, XLScreenH);
        
    }
    return _backImage;
}

- (UIView *)navView {
    if (!_navView) {
        _navView = [[UIView alloc] init];
        [self.view addSubview:_navView];
        _navView.backgroundColor = [UIColor whiteColor];
        _navView.frame = CGRectMake(0, 0, XLScreenW, 64);
        
    }
    return _navView;
}

- (UILabel *)navWord {
    if (!_navWord) {
        _navWord = [[UILabel alloc] init];
        _navWord.font = [UIFont fontWithName:@"TimesNewRomanPS-ItalicMT" size:24.0f];
        _navWord.textColor = [UIColor blueColor];
        _navWord.text = @"XL Anim Demo";
        _navWord.hidden = NO;
        [_navWord sizeToFit];
    }
    
    return _navWord;
}

- (XLAddView *)addView {
    if (!_addView) {
        CGFloat bntSize = 44;
        _addView = [[XLAddView alloc] initWithFrame:CGRectMake(0, 0, bntSize, bntSize)];
        [self.view addSubview:_addView];
        _addView.userInteractionEnabled = YES;
        [_addView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addViewClick)]];
        _addView.frame = CGRectMake(XLScreenW-15-bntSize, XLScreenH-15-49-bntSize, bntSize, bntSize);
       
    }
    
    return _addView;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
