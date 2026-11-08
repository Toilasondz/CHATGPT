#import <UIKit/UIKit.h>
#import <CoreMedia/CoreMedia.h>

NS_ASSUME_NONNULL_BEGIN

@interface VSRuntimeBridge : NSObject
+ (nullable UIViewController *)topViewController;
+ (nullable UIViewController *)videoReviewController;
+ (nullable UIView *)findViewOfClassNamed:(NSString *)className inView:(UIView *)root;
+ (nullable id)valueForObject:(id)object key:(NSString *)key;
+ (BOOL)sendControlAction:(NSString *)action toButtonNamed:(NSString *)buttonName owner:(id)owner;
+ (BOOL)sendNoArgumentSelector:(SEL)selector toObject:(id)object;
+ (BOOL)classNamed:(NSString *)className isKindOfObject:(id)object;
@end

NS_ASSUME_NONNULL_END
