#import "VSQRCaptureProxy.h"
@implementation VSQRCaptureProxy
- (BOOL)respondsToSelector:(SEL)selector {
    return [super respondsToSelector:selector] || [self.target respondsToSelector:selector];
}
- (id)forwardingTargetForSelector:(SEL)selector {
    return [self.target respondsToSelector:selector] ? self.target : [super forwardingTargetForSelector:selector];
}
- (id)dataToShare { return [self.target respondsToSelector:@selector(dataToShare)] ? [self.target dataToShare] : nil; }
- (void)setActivityiPadPopup:(id)value { if ([self.target respondsToSelector:@selector(setActivityiPadPopup:)]) [self.target setActivityiPadPopup:value]; }
- (NSString *)codePrefix { return [self.target respondsToSelector:@selector(codePrefix)] ? ([self.target codePrefix] ?: @"") : @""; }
- (NSString *)qrLabel { return [self.target respondsToSelector:@selector(qrLabel)] ? ([self.target qrLabel] ?: @"") : @""; }
- (NSString *)qrSetupLabel { return [self.target respondsToSelector:@selector(qrSetupLabel)] ? ([self.target qrSetupLabel] ?: @"") : @""; }
- (id)qrImage { return [self.target respondsToSelector:@selector(qrImage)] ? [self.target qrImage] : nil; }
- (id)qrIcon { return [self.target respondsToSelector:@selector(qrIcon)] ? [self.target qrIcon] : nil; }
- (BOOL)validCode:(id)code { return [self.target respondsToSelector:@selector(validCode:)] ? (BOOL)[self.target validCode:code] : NO; }
- (void)importedData:(id)imageData code:(id)code { if (self.captured) self.captured(imageData, code); }
@end
