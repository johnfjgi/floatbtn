#import <UIKit/UIKit.h>

@interface FloatBtn : NSObject
+ (void)setup;
@end

@implementation FloatBtn

+ (UIWindow *)keyWindow {
    for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
        if (![scene isKindOfClass:UIWindowScene.class]) continue;
        UIWindowScene *ws = (UIWindowScene *)scene;
        if (ws.activationState != UISceneActivationStateForegroundActive) continue;
        for (UIWindow *w in ws.windows) {
            if (w.isKeyWindow) return w;
        }
        if (ws.windows.firstObject) return ws.windows.firstObject;
    }
    return nil;
}

+ (UIViewController *)topVC {
    UIViewController *vc = [self keyWindow].rootViewController;
    while (vc.presentedViewController) vc = vc.presentedViewController;
    return vc;
}

+ (void)setup {
    UIWindow *win = [self keyWindow];
    if (!win) {
        // 遊戲還沒準備好，1 秒後再試
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{ [self setup]; });
        return;
    }

    CGFloat size = 50;
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(20, 120, size, size);
    btn.layer.cornerRadius = size / 2;
    btn.clipsToBounds = YES;
    btn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    btn.layer.borderWidth = 1.5;
    btn.layer.borderColor = UIColor.whiteColor.CGColor;
    [btn setTitle:@"改" forState:UIControlStateNormal];
    [btn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:20];

    [btn addTarget:self action:@selector(onTap) forControlEvents:UIControlEventTouchUpInside];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPan:)];
    [btn addGestureRecognizer:pan];

    [win addSubview:btn];
}

+ (void)onTap {
    UIAlertController *a = [UIAlertController alertControllerWithTitle:@"改"
                                                              message:@"功能尚未加入"
                                                       preferredStyle:UIAlertControllerStyleAlert];
    [a addAction:[UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:nil]];
    [[self topVC] presentViewController:a animated:YES completion:nil];
}

+ (void)onPan:(UIPanGestureRecognizer *)g {
    UIView *v = g.view;
    UIView *sv = v.superview;
    CGPoint t = [g translationInView:sv];
    CGPoint c = CGPointMake(v.center.x + t.x, v.center.y + t.y);
    CGFloat r = v.bounds.size.width / 2;
    c.x = MAX(r, MIN(sv.bounds.size.width - r, c.x));
    c.y = MAX(r, MIN(sv.bounds.size.height - r, c.y));
    v.center = c;
    [g setTranslation:CGPointZero inView:sv];
    [sv bringSubviewToFront:v];
}

@end

__attribute__((constructor))
static void init(void) {
    // 等遊戲啟動、畫面出現後再建立浮窗
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{ [FloatBtn setup]; });
}
