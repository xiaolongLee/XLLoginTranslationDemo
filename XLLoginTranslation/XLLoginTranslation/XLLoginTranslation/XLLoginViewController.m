//
//  XLLoginViewController.m
//  XLLoginTranslation
//
//  Created by Mac-Qke on 2018/12/28.
//  Copyright © 2018 Mac-Qke. All rights reserved.
//

#import "XLLoginViewController.h"
#import "UIView+XLExtension.h"
#import "POP.h"
#import "Masonry.h"
#import "XLLoginTranslation.h"
#import "XLFirstViewViewController.h"

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define BG_COLOR UIColorFromRGB(0xefeff4)

#define XLScreenW [UIScreen mainScreen].bounds.size.width
#define XLScreenH [UIScreen mainScreen].bounds.size.height

#define ButtonColor [UIColor colorWithRed:156/255.0 green:197/255.0 blue:251/255.0 alpha:1.0]

static CGFloat const XLSpringSpeed = 6.0;
static CGFloat const XLSpringBounciness = 16.0;
@interface XLLoginViewController ()<CAAnimationDelegate,UIViewControllerTransitioningDelegate>
/**
 *  由于很多控件在转场时需要暴露出去，以用于做动画，所以控件我统一写在.h文件
 */

//转场动画管理对象()
@property (nonatomic, strong) XLLoginTranslation *loginTranslation;
@end

@implementation XLLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self SetupUIComponent];
}

/** 初始化UI */
- (void)SetupUIComponent {
    //背景颜色
    self.view.backgroundColor = BG_COLOR;
    //文字布局
    self.LoginWord.xl_centerX = self.view.xl_centerX;
    self.LoginWord.xl_y = self.view.xl_centerY - self.LoginWord.xl_height;
    //logo布局
    CGFloat LoginImageWH = XLScreenW * 0.25;
    self.LoginImage.frame = CGRectMake((XLScreenW - LoginImageWH)*0.5, CGRectGetMinY(self.LoginWord.frame) - 40 - LoginImageWH, LoginImageWH, LoginImageWH);
    //按钮布局
    CGFloat GetButtonW = XLScreenW * 0.4;
    CGFloat GetButtonH = 44;
    self.GetButton.frame = CGRectMake((XLScreenW - GetButtonW) * 0.5, XLScreenH * 0.7, GetButtonW, GetButtonH);
}

/** 移除并置空所有控件，重新生成控件，对于防止内存泄漏有好处 */
- (void)reloadView {
    int i = [[NSString stringWithFormat:@"%lu",(self.view.subviews.count - 1)] intValue];
    
    for (;i >= 0; i--) {
        UIView *subView = self.view.subviews[i];
        [subView removeFromSuperview];
        subView = nil;
    }
    
    self.LoginImage = nil;
    self.LoginWord = nil;
    self.GetButton = nil;
    self.LoginButton = nil;
    self.HUDView = nil;
    self.LoginAnimView = nil;
    self.shapeLayer = nil;
    self.animView = nil;
    self.userTextField = nil;
    self.passwordTextField = nil;
    
    [self SetupUIComponent];
    
}


#pragma mark - get按钮点击事件——执行动画
- (void)GetButtonClick {
    /**
     *  动画的思路：
     *  1、造一个view来执行动画，看上去就像get按钮本身在形变移动，其实是这个view
     *  2、改变动画view的背景颜色，变色的过程是整个动画效果执行的过程
     *  3、让按钮变宽
     *  4、变宽完成后，变高
     *  5、变高完成后，同步执行以下四步
     *      5.0、让账号密码按钮出现
     *      5.1、让Login按钮出现
     *      5.2、移动这个view，带弹簧效果
     *      5.3、移动logo图片，带弹簧效果
     *      5.4、移动logo文字，带弹簧效果
     */
    
    //1、get按钮动画的view
    UIView *animView = [UIView new];
    self.animView = animView;
    animView = [[UIView alloc] initWithFrame:self.GetButton.frame];
    animView.layer.cornerRadius = 10;
    animView.frame = self.GetButton.frame;
    animView.backgroundColor = self.GetButton.backgroundColor;
    [self.view addSubview:animView];
    self.GetButton.hidden = YES;
    self.LoginButton.hidden = NO;
    
    //2.get背景颜色
    CABasicAnimation *changeColor1 = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    changeColor1.fromValue = (__bridge id)ButtonColor.CGColor;
    changeColor1.toValue = (__bridge id)[UIColor whiteColor].CGColor;
    changeColor1.duration = 0.8f;
    changeColor1.beginTime = CACurrentMediaTime();
    changeColor1.fillMode = kCAFillModeForwards;
    changeColor1.removedOnCompletion = false;
    [animView.layer addAnimation:changeColor1 forKey:changeColor1.keyPath];
    
    //3、get按钮变宽
    CABasicAnimation *anim1 = [CABasicAnimation animationWithKeyPath:@"bounds.size.width"];
    anim1.fromValue = @(CGRectGetWidth(animView.bounds));
    anim1.toValue = @(XLScreenW * 0.8);
    anim1.duration = 0.1;
    anim1.beginTime = CACurrentMediaTime();
    anim1.fillMode = kCAFillModeForwards;
    anim1.removedOnCompletion = false;
    [animView.layer addAnimation:anim1 forKey:anim1.keyPath];
    
    //4、get按钮变高
    CABasicAnimation *anim2 = [CABasicAnimation animationWithKeyPath:@"bounds.size.height"];
    anim2.fromValue = @(CGRectGetHeight(animView.bounds));
    anim2.toValue = @(XLScreenH * 0.3);
    anim2.duration  = 0.1;
    anim2.beginTime = CACurrentMediaTime();
    anim2.fillMode = kCAFillModeForwards;
    anim2.removedOnCompletion =false;
    anim2.delegate = self;//变高完成，给它加个阴影
    [animView.layer addAnimation:anim2 forKey:anim2.keyPath];
    
    //5.0、账号密码按钮出现
    self.userTextField.alpha = 0.0;
    self.passwordTextField.alpha = 0.0;
    [UIView animateWithDuration:0.4 delay:0.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.userTextField.alpha = 1.0;
        self.passwordTextField.alpha = 1.0;
    } completion:^(BOOL finished) {
        
    }];
    
    //5.1、login按钮出现动画
    self.LoginButton.xl_centerX = XLScreenW * 0.5;
    self.LoginButton.xl_centerY = XLScreenH * 0.7+44+(XLScreenH*0.3-44)*0.5-75;
    CABasicAnimation *animLoginBtn = [CABasicAnimation animationWithKeyPath:@"bounds.size"];
    animLoginBtn.fromValue = [NSValue valueWithCGSize:CGSizeMake(0, 0)];
    animLoginBtn.toValue = [NSValue valueWithCGSize:CGSizeMake(XLScreenW*0.5, 44)];
    animLoginBtn.duration = 0.4;
    animLoginBtn.beginTime = CACurrentMediaTime()+0.2;
    animLoginBtn.fillMode = kCAFillModeForwards;
    animLoginBtn.removedOnCompletion = false;
    animLoginBtn.delegate = self;//在代理方法(动画完成回调)里，让按钮真正的宽高改变，而不仅仅是它的layer,否则看得到点不到
    [self.LoginButton.layer addAnimation:animLoginBtn forKey:animLoginBtn.keyPath];
    
    //5.2、按钮移动动画
    POPSpringAnimation *anim3 = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
    anim3.fromValue = [NSValue valueWithCGRect:CGRectMake(animView.xl_centerX, animView.xl_centerY, animView.xl_width, animView.xl_height)];
    anim3.beginTime = CACurrentMediaTime() + 0.2;
    anim3.springBounciness = XLSpringBounciness;
    anim3.springSpeed = XLSpringSpeed;
    [animView pop_addAnimation:anim3 forKey:nil];
    
    //5.3、图片移动动画
    POPSpringAnimation *anim4 = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
    anim4.fromValue = [NSValue valueWithCGRect:CGRectMake(self.LoginImage.xl_x, self.LoginImage.xl_y, self.LoginImage.xl_width, self.LoginImage.xl_height)];
    anim4.toValue = [NSValue valueWithCGRect:CGRectMake(self.LoginImage.xl_x, self.LoginImage.xl_y-75, self.LoginImage.xl_width, self.LoginImage.xl_height)];
    anim4.beginTime = CACurrentMediaTime() + 0.2;
    anim4.springBounciness = XLSpringBounciness;
    anim4.springSpeed = XLSpringSpeed;
    [self.LoginImage pop_addAnimation:anim4 forKey:nil];
    
     //5.4、文字移动动画
    POPSpringAnimation *anim5 = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
    anim5.fromValue = [NSValue valueWithCGRect:CGRectMake(self.LoginWord.xl_x, self.LoginWord.xl_y, self.LoginWord.xl_width, self.LoginWord.xl_height)];
    anim5.toValue = [NSValue valueWithCGRect:CGRectMake(self.LoginWord.xl_x, self.LoginWord.xl_y-75, self.LoginWord.xl_width, self.LoginWord.xl_height)];
    anim5.beginTime = CACurrentMediaTime()+0.2;
    anim5.springBounciness = XLSpringBounciness;
    anim5.springSpeed = XLSpringSpeed;
    [self.LoginWord pop_addAnimation:anim5 forKey:nil];
    
}

#pragma mark - login按钮点击事件——执行动画
- (void)LoginButtonClick{
    //HUDView，盖住view，以屏蔽掉点击事件
    self.HUDView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, XLScreenW, XLScreenH)];
    [[UIApplication  sharedApplication].keyWindow addSubview:self.HUDView];
    self.HUDView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.0];
    
    //执行登录按钮转圈动画的view
    self.LoginAnimView = [[UIView alloc] initWithFrame:self.LoginButton.frame];
    self.LoginAnimView.layer.cornerRadius = 10;
    self.LoginAnimView.layer.masksToBounds = YES;
    self.LoginAnimView.frame = self.LoginButton.frame;
    self.LoginAnimView.backgroundColor = self.LoginButton.backgroundColor;
    [self.view addSubview:self.LoginAnimView];
    self.LoginButton.hidden = YES;
    
    //把view从宽的样子变圆
    CGPoint centerPoint = self.LoginAnimView.center;
    CGFloat radius = MIN(self.LoginButton.frame.size.width, self.LoginButton.frame.size.height);
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.LoginAnimView.frame = CGRectMake(0, 0, radius, radius);
        self.LoginAnimView.center = centerPoint ;
        self.LoginAnimView.layer.cornerRadius = radius/2;
        self.LoginAnimView.layer.masksToBounds = YES;
    } completion:^(BOOL finished) {
        //给圆加一条不封闭的白色曲线
        UIBezierPath *path = [[UIBezierPath alloc] init];
        [path addArcWithCenter:CGPointMake(radius/2, radius/2) radius:(radius/2 - 5) startAngle:0 endAngle:M_PI_2 clockwise:YES];
        self.shapeLayer = [[CAShapeLayer alloc] init];
        self.shapeLayer.lineWidth = 1.5;
        self.shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
        self.shapeLayer.fillColor = self.LoginButton.backgroundColor.CGColor;
        self.shapeLayer.frame = CGRectMake(0, 0, radius, radius);
        self.shapeLayer.path = path.CGPath;
        [self.LoginAnimView.layer addSublayer:self.shapeLayer];
        
        //让圆转圈，实现"加载中"的效果
        CABasicAnimation *baseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        baseAnimation.duration = 0.4;
        baseAnimation.fromValue = @(0);
        baseAnimation.toValue = @(2 * M_PI);
        baseAnimation.repeatCount = MAXFLOAT;
        [self.LoginAnimView.layer addAnimation:baseAnimation forKey:nil];
        
        //开始登录
        [self doLogin];
        
    }];
    
}

/** 模拟登录 */
- (void)doLogin{
    //延时，模拟网络请求的延时
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([self.userTextField.text isEqualToString:@""] || [self.passwordTextField.text isEqualToString:@""]) {
            
            //登录失败
            [self loginFail];
        }else{
            //登录成功
            [self loginSuccess];
        }
    });
}

/** 登录失败 */
- (void)loginFail{
    
    //把蒙版、动画view等隐藏，把真正的login按钮显示出来
    self.LoginButton.hidden = NO;
    [self.HUDView removeFromSuperview];
    [self.LoginAnimView removeFromSuperview];
    [self.LoginAnimView.layer removeAllAnimations];
    
    //给按钮添加左右摆动的效果(路径动画)
    CAKeyframeAnimation *keyFrame = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    CGPoint point = self.LoginAnimView.layer.position;
    keyFrame.values = @[[NSValue valueWithCGPoint:CGPointMake(point.x, point.y)],
                        
                         [NSValue valueWithCGPoint:CGPointMake(point.x - 10, point.y)],
                        
                         [NSValue valueWithCGPoint:CGPointMake(point.x + 10, point.y)],
                        
                        [NSValue valueWithCGPoint:CGPointMake(point.x - 10, point.y)],
                        
                        [NSValue valueWithCGPoint:CGPointMake(point.x + 10, point.y)],
                        
                        [NSValue valueWithCGPoint:CGPointMake(point.x - 10, point.y)],
                        
                        [NSValue valueWithCGPoint:CGPointMake(point.x + 10, point.y)],
                        
                        [NSValue valueWithCGPoint:point]];
    
    keyFrame.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    keyFrame.duration = 0.5f;
    [self.LoginButton.layer addAnimation:keyFrame forKey:keyFrame.keyPath];
    
}

/** 登录成功 */
- (void)loginSuccess{
    //移除蒙版
    [self.HUDView removeFromSuperview];
    //跳转到另一个控制器
    XLFirstViewViewController *vc = [XLFirstViewViewController new];
    vc.transitioningDelegate = self;
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - 动画代理
/** 动画执行结束回调 */

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if ([((CABasicAnimation *)anim).keyPath isEqualToString:@"bounds.size.height"]) {
        //阴影颜色
        self.animView.layer.shadowColor = [UIColor redColor].CGColor;
        //阴影的透明度
        self.animView.layer.shadowOpacity = 0.8f;
        //阴影的圆角
        self.animView.layer.shadowRadius = 5.0f;
        //阴影偏移量
        self.animView.layer.shadowOffset = CGSizeMake(1, 1);
        
        self.userTextField.alpha = 1.0;
        
        self.passwordTextField.alpha = 1.0;
    }else if ([((CABasicAnimation *)anim).keyPath isEqualToString:@"bounds.size"]){
        self.LoginButton.bounds = CGRectMake(XLScreenW*0.5, XLScreenH*0.7+44+(XLScreenH*0.3-44)*0.5-75, XLScreenW*0.5, 44);
    }
}

/** 点击退回键盘 */
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark UIViewControllerTransitioningDelegate(转场动画代理)
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    self.loginTranslation.doLogin = NO;
    return self.loginTranslation;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    self.loginTranslation.doLogin = YES;
    return self.loginTranslation;
}

#pragma mark - 懒加载
- (UIImageView *)LoginImage {
    if (!_LoginImage) {
        _LoginImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]];
        [self.view addSubview:_LoginImage];
    }
    return _LoginImage;
}

- (UILabel *)LoginWord {
    if (!_LoginWord) {
        _LoginWord = [UILabel new];
        [self.view addSubview:_LoginWord];
        _LoginWord.font = [UIFont fontWithName:@"TimesNewRomanPS-ItalicMT" size:34.0f];
        _LoginWord.textColor = [UIColor blackColor];
        _LoginWord.text = @"XL Anim Demo";
        [_LoginWord sizeToFit];
    }
    
    return _LoginWord;
}

- (UIButton *)GetButton {
    if (!_GetButton) {
        _GetButton  = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.view addSubview:_GetButton];
        [_GetButton.layer setMasksToBounds:YES];
        [_GetButton.layer setCornerRadius:22.0];
        [_GetButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_GetButton setTitle:@"GET" forState:UIControlStateNormal];
        _GetButton.backgroundColor = ButtonColor;
        [_GetButton addTarget:self action:@selector(GetButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _GetButton;
}

- (UIButton *)LoginButton
{
    if (!_LoginButton)
    {
        _LoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.view addSubview:_LoginButton];
        _LoginButton.frame = CGRectMake(0, 0, 0, 0);
        _LoginButton.hidden = YES;
        [_LoginButton.layer setMasksToBounds:YES];
        [_LoginButton.layer setCornerRadius:5.0];
        [_LoginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_LoginButton setTitle:@"LOGIN" forState:UIControlStateNormal];
        _LoginButton.backgroundColor = ButtonColor;
        [_LoginButton addTarget:self action:@selector(LoginButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _LoginButton;
}

- (UITextField *)userTextField {
    if (_userTextField == nil) {
        
        _userTextField = [[UITextField alloc] init];
        _userTextField.font = [UIFont systemFontOfSize:15];
        _userTextField.placeholder = @"Username";
        _userTextField.alpha = 0.0;
        [_userTextField setValue:UIColorFromRGB(0xcccccc)  forKeyPath:@"_placeholderLabel.textColor"];
        [_userTextField setValue:[UIFont systemFontOfSize:15.0] forKeyPath:@"_placeholderLabel.font"];
        _userTextField.textAlignment = NSTextAlignmentCenter;
        _userTextField.keyboardType = UIKeyboardTypePhonePad;
        _userTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _userTextField.tintColor = ButtonColor;
        
        UIView *seperatorLine = [[UIView alloc] init];
        [_userTextField addSubview:seperatorLine];
        seperatorLine.backgroundColor = UIColorFromRGB(0xe1e1e1);
        [seperatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.mas_equalTo(self->_userTextField);
            make.height.mas_equalTo(1.5);
        }];
        
        [self.view addSubview:_userTextField];
        _userTextField.frame = CGRectMake(XLScreenW * 0.2, XLScreenH * 0.7 - (XLScreenH*0.3 - 44)*0.5-75+25, XLScreenW*0.6, 50);
    }
    
    return _userTextField;
}

- (UITextField *)passwordTextField
{
    if(_passwordTextField == nil)
    {
        _passwordTextField = [[UITextField alloc] init];
        _passwordTextField.font = [UIFont systemFontOfSize:15];
        _passwordTextField.borderStyle = UITextBorderStyleNone;
        _passwordTextField.placeholder = @"Password";
        _passwordTextField.alpha = 0.0;
        [_passwordTextField setValue:UIColorFromRGB(0xcccccc) forKeyPath:@"_placeholderLabel.textColor"];
        [_passwordTextField setValue:[UIFont systemFontOfSize:15.0] forKeyPath:@"_placeholderLabel.font"];
        _passwordTextField.textAlignment = NSTextAlignmentCenter;
        _passwordTextField.secureTextEntry = YES;
        _passwordTextField.tintColor = ButtonColor;
        
        UIView *seperatorLine = [[UIView alloc] init];
        [_passwordTextField addSubview:seperatorLine];
        seperatorLine.backgroundColor = UIColorFromRGB(0xe1e1e1);
        [seperatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.mas_equalTo(_passwordTextField);
            make.height.mas_equalTo(1.5);
        }];
        
        [self.view addSubview:_passwordTextField];
        _passwordTextField.frame = CGRectMake(XLScreenW*0.2, XLScreenH*0.7-(XLScreenH*0.3-44)*0.5-75+10+50+25, XLScreenW*0.6, 50);
    }
    return _passwordTextField;
}

- (XLLoginTranslation *)loginTranslation {
    if (!_loginTranslation) {
        _loginTranslation = [[XLLoginTranslation alloc] init];
    }
    return _loginTranslation;
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
