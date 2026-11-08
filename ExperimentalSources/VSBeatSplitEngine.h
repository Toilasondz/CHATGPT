#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface VSBeatSplitEngine : NSObject
+ (instancetype)shared;
- (BOOL)startWithCompletion:(void (^)(BOOL success, NSString *message))completion;
- (void)cancel;
@end
NS_ASSUME_NONNULL_END
