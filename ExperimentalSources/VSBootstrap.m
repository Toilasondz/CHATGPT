#import <UIKit/UIKit.h>
#import "VSToolOverlay.h"

static __weak VSToolOverlay *gVSOverlay;
static BOOL gVSInstallScheduled = NO;

static UIWindow *VSActiveWindow(void) {
    UIApplication *app = UIApplication.sharedApplication;
    if (@available(iOS 13.0, *)) {
        for (UIScene *scene in app.connectedScenes) {
            if (![scene isKindOfClass:UIWindowScene.class] || scene.activationState != UISceneActivationStateForegroundActive) continue;
            for (UIWindow *window in ((UIWindowScene *)scene).windows) if (window.isKeyWindow) return window;
        }
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return app.keyWindow;
#pragma clang diagnostic pop
}

static void VSInstallOverlay(void) {
    if (!NSThread.isMainThread) { dispatch_async(dispatch_get_main_queue(), ^{ VSInstallOverlay(); }); return; }
    // Avoid attaching this library to unrelated applications.
    if (!NSClassFromString(@"VideoReviewEditVC") && !NSClassFromString(@"QRCodeManager")) return;
    UIWindow *window = VSActiveWindow();
    if (!window || !window.rootViewController || gVSOverlay) return;
    VSToolOverlay *overlay = [[VSToolOverlay alloc] initWithFrame:window.bounds];
    overlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    overlay.backgroundColor = UIColor.clearColor;
    [window addSubview:overlay];
    [window bringSubviewToFront:overlay];
    gVSOverlay = overlay;
}

static void VSAttemptInstall(void) {
    if (gVSInstallScheduled) return;
    gVSInstallScheduled = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        VSInstallOverlay();
        if (!gVSOverlay) {
            static NSUInteger attempts = 0;
            if (++attempts < 80) dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ gVSInstallScheduled = NO; VSAttemptInstall(); });
        }
    });
}

__attribute__((constructor)) static void VSBootstrap(void) {
    @autoreleasepool {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(__unused NSNotification *note) { VSAttemptInstall(); }];
            VSAttemptInstall();
        });
    }
}
