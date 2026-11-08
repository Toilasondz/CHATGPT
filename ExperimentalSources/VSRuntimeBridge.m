#import "VSRuntimeBridge.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation VSRuntimeBridge

+ (UIViewController *)unwrapController:(UIViewController *)controller {
    UIViewController *current = controller;
    for (NSUInteger i = 0; current && i < 16; i++) {
        if (current.presentedViewController) { current = current.presentedViewController; continue; }
        if ([current isKindOfClass:UINavigationController.class]) {
            UIViewController *next = ((UINavigationController *)current).visibleViewController;
            if (next) { current = next; continue; }
        }
        if ([current isKindOfClass:UITabBarController.class]) {
            UIViewController *next = ((UITabBarController *)current).selectedViewController;
            if (next) { current = next; continue; }
        }
        break;
    }
    return current;
}

+ (UIViewController *)topViewController {
    UIApplication *app = UIApplication.sharedApplication;
    UIWindow *keyWindow = nil;
    if (@available(iOS 13.0, *)) {
        for (UIScene *scene in app.connectedScenes) {
            if (![scene isKindOfClass:UIWindowScene.class] || scene.activationState != UISceneActivationStateForegroundActive) continue;
            for (UIWindow *window in ((UIWindowScene *)scene).windows) {
                if (window.isKeyWindow) { keyWindow = window; break; }
            }
            if (keyWindow) break;
        }
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if (!keyWindow) keyWindow = app.keyWindow;
#pragma clang diagnostic pop
    return [self unwrapController:keyWindow.rootViewController];
}

+ (UIViewController *)videoReviewController {
    UIViewController *top = [self topViewController];
    Class target = NSClassFromString(@"VideoReviewEditVC");
    if (!target) return nil;
    UIViewController *candidate = top;
    for (NSUInteger depth = 0; candidate && depth < 20; depth++) {
        if ([candidate isKindOfClass:target]) return candidate;
        UIViewController *next = candidate.presentedViewController;
        if (!next && [candidate isKindOfClass:UINavigationController.class]) next = ((UINavigationController *)candidate).visibleViewController;
        if (!next && [candidate isKindOfClass:UITabBarController.class]) next = ((UITabBarController *)candidate).selectedViewController;
        candidate = next;
    }
    return nil;
}

+ (UIView *)findViewOfClassNamed:(NSString *)className inView:(UIView *)root {
    Class target = NSClassFromString(className);
    if (!target || !root) return nil;
    if ([root isKindOfClass:target]) return root;
    for (UIView *child in root.subviews.reverseObjectEnumerator) {
        UIView *found = [self findViewOfClassNamed:className inView:child];
        if (found) return found;
    }
    return nil;
}

+ (id)valueForObject:(id)object key:(NSString *)key {
    if (!object || key.length == 0) return nil;
    @try {
        id value = [object valueForKey:key];
        if (value) return value;
    } @catch (__unused NSException *exception) {}
    Class cls = object_getClass(object);
    NSString *ivarName = [key hasPrefix:@"_"] ? key : [@"_" stringByAppendingString:key];
    Ivar ivar = class_getInstanceVariable(cls, ivarName.UTF8String);
    if (!ivar) ivar = class_getInstanceVariable(cls, key.UTF8String);
    return ivar ? object_getIvar(object, ivar) : nil;
}

+ (BOOL)sendControlAction:(NSString *)action toButtonNamed:(NSString *)buttonName owner:(id)owner {
    id button = [self valueForObject:owner key:buttonName];
    if (![button isKindOfClass:UIButton.class]) return NO;
    SEL selector = NSSelectorFromString(action);
    if (![button respondsToSelector:selector]) return NO;
    @try {
        [button sendActionsForControlEvents:UIControlEventTouchUpInside];
        return YES;
    } @catch (__unused NSException *exception) { return NO; }
}

+ (BOOL)sendNoArgumentSelector:(SEL)selector toObject:(id)object {
    if (!object || !selector || ![object respondsToSelector:selector]) return NO;
    @try { ((void (*)(id, SEL))objc_msgSend)(object, selector); return YES; }
    @catch (__unused NSException *exception) { return NO; }
}

+ (BOOL)classNamed:(NSString *)className isKindOfObject:(id)object {
    Class target = NSClassFromString(className);
    return target && object && [object isKindOfClass:target];
}
@end
