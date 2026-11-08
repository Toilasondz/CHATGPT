#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
@interface VSQRCaptureProxy : NSObject
@property (nonatomic, weak, nullable) id target;
@property (nonatomic, copy, nullable) void (^captured)(id _Nullable imageData, id _Nullable code);
- (void)importedData:(id)imageData code:(id)code;
- (BOOL)validCode:(id)code;
@end
NS_ASSUME_NONNULL_END
