#import "VSBeatSplitEngine.h"
#import "VSRuntimeBridge.h"
#import <CoreMedia/CoreMedia.h>
#import <objc/message.h>

@interface VSBeatSplitEngine ()
@property (nonatomic, weak) id splitView;
@property (nonatomic, weak) id project;
@property (nonatomic, weak) UIViewController *reviewController;
@property (nonatomic, copy) void (^completion)(BOOL, NSString *);
@property (nonatomic) BOOL running;
@property (nonatomic) NSUInteger queuedSplits;
@property (nonatomic) NSUInteger guardCount;
@property (nonatomic) NSUInteger sceneCountBefore;
@property (nonatomic) NSUInteger sceneIndex;
@property (nonatomic) NSUInteger noAdvanceRetries;
@property (nonatomic) CMTime lastTime;
@end

@implementation VSBeatSplitEngine
+ (instancetype)shared { static VSBeatSplitEngine *engine; static dispatch_once_t once; dispatch_once(&once, ^{ engine = [self new]; }); return engine; }

- (BOOL)startWithCompletion:(void (^)(BOOL, NSString *))completion {
    if (self.running) { if (completion) completion(NO, @"Đang có tiến trình chia beat."); return NO; }
    UIViewController *review = [VSRuntimeBridge videoReviewController];
    UIView *split = [VSRuntimeBridge findViewOfClassNamed:@"MultiSplitView" inView:review.isViewLoaded ? review.view : nil];
    id project = [VSRuntimeBridge valueForObject:review key:@"project"];
    if (!review || !split || !project) {
        if (completion) completion(NO, @"Không tìm thấy màn hình VideoReviewEditVC, MultiSplitView hoặc project. Hãy mở màn hình Chia phân cảnh trước.");
        return NO;
    }
    NSUInteger sceneIndex = [[VSRuntimeBridge valueForObject:review key:@"sceneIndex"] respondsToSelector:@selector(unsignedIntegerValue)] ? [[VSRuntimeBridge valueForObject:review key:@"sceneIndex"] unsignedIntegerValue] : 0;
    SEL enoughSel = NSSelectorFromString(@"isEnoughStorageAvailableForSplit");
    if ([split respondsToSelector:enoughSel] && !((BOOL (*)(id, SEL))objc_msgSend)(split, enoughSel)) {
        if (completion) completion(NO, @"Video Star báo không đủ dung lượng để chia phân cảnh.");
        return NO;
    }
    id beatMode = [VSRuntimeBridge valueForObject:split key:@"beatModeOn"];
    if (![beatMode respondsToSelector:@selector(boolValue)] || ![beatMode boolValue]) {
        [VSRuntimeBridge sendNoArgumentSelector:NSSelectorFromString(@"toggleBeatMode") toObject:split];
    }
    NSUInteger before = 0;
    if ([project respondsToSelector:NSSelectorFromString(@"sceneCount")]) before = ((NSUInteger (*)(id, SEL))objc_msgSend)(project, NSSelectorFromString(@"sceneCount"));
    self.reviewController = review; self.splitView = split; self.project = project;
    self.sceneIndex = sceneIndex; self.sceneCountBefore = before; self.queuedSplits = 0;
    self.guardCount = 0; self.noAdvanceRetries = 0; self.completion = [completion copy];
    self.running = YES; self.lastTime = [self currentSplitTime];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ [self advanceBeat]; });
    return YES;
}

- (CMTime)currentSplitTime {
    id view = self.splitView; SEL selector = NSSelectorFromString(@"currentTime");
    if (view && [view respondsToSelector:selector]) return ((CMTime (*)(id, SEL))objc_msgSend)(view, selector);
    return kCMTimeInvalid;
}

- (void)advanceBeat {
    if (!self.running) return;
    if (++self.guardCount > 4096) { [self finishAndSplit]; return; }
    id split = self.splitView;
    if (!split) { [self finishWithSuccess:NO message:@"Màn hình chia beat đã đóng giữa chừng."]; return; }
    id nextButton = [VSRuntimeBridge valueForObject:split key:@"nextButton"];
    if (![nextButton isKindOfClass:UIButton.class]) { [self finishWithSuccess:NO message:@"Không tìm thấy nút chuyển beat (nextButton)."]; return; }
    [nextButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    CMTime start = self.lastTime;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.20 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self waitForAdvanceFrom:start attempt:0];
    });
}

- (void)waitForAdvanceFrom:(CMTime)start attempt:(NSUInteger)attempt {
    if (!self.running) return;
    CMTime now = [self currentSplitTime];
    BOOL advanced = CMTIME_IS_VALID(start) && CMTIME_IS_VALID(now) && CMTimeCompare(now, start) > 0;
    if (!advanced && attempt < 20) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.12 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ [self waitForAdvanceFrom:start attempt:attempt + 1]; });
        return;
    }
    if (advanced) {
        id setButton = [VSRuntimeBridge valueForObject:self.splitView key:@"setButton"];
        if ([setButton isKindOfClass:UIButton.class]) {
            [setButton sendActionsForControlEvents:UIControlEventTouchUpInside];
            self.queuedSplits++;
            self.lastTime = now;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.18 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ [self advanceBeat]; });
            return;
        }
        [self finishWithSuccess:NO message:@"Không tìm thấy nút đặt điểm chia (setButton)."];
        return;
    }
    SEL hasNext = NSSelectorFromString(@"hasNextBeat");
    BOOL more = [self.splitView respondsToSelector:hasNext] && ((BOOL (*)(id, SEL))objc_msgSend)(self.splitView, hasNext);
    if (!more || self.noAdvanceRetries >= 1) { [self finishAndSplit]; return; }
    self.noAdvanceRetries++;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.20 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ [self advanceBeat]; });
}

- (void)finishAndSplit {
    if (!self.running) return;
    if (self.queuedSplits == 0) { [self finishWithSuccess:NO message:@"Không tìm thấy beat mới để chia trong phân cảnh hiện tại."]; return; }
    id splitButton = [VSRuntimeBridge valueForObject:self.splitView key:@"splitButton"];
    if (![splitButton isKindOfClass:UIButton.class]) { [self finishWithSuccess:NO message:@"Không tìm thấy nút Chia (splitButton). Thao tác chưa được áp dụng."]; return; }
    [splitButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    [self pollProjectCompletion:0];
}

- (void)pollProjectCompletion:(NSUInteger)attempt {
    if (!self.running) return;
    id project = self.project; SEL countSel = NSSelectorFromString(@"sceneCount");
    NSUInteger count = [project respondsToSelector:countSel] ? ((NSUInteger (*)(id, SEL))objc_msgSend)(project, countSel) : self.sceneCountBefore;
    if (count > self.sceneCountBefore) {
        [self finishWithSuccess:YES message:[NSString stringWithFormat:@"Video Star đã tạo thêm %lu phân cảnh.", (unsigned long)(count - self.sceneCountBefore)]];
        return;
    }
    if (attempt >= 120) { [self finishWithSuccess:NO message:@"Đã gửi thao tác Chia, nhưng chưa xác nhận được sceneCount tăng. Hãy kiểm tra project trước khi chạy lại."]; return; }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ [self pollProjectCompletion:attempt + 1]; });
}

- (void)cancel { if (self.running) [self finishWithSuccess:NO message:@"Đã hủy tiến trình chia beat."]; }
- (void)finishWithSuccess:(BOOL)success message:(NSString *)message {
    if (!self.running) return;
    self.running = NO; self.splitView = nil; self.project = nil; self.reviewController = nil;
    void (^completion)(BOOL, NSString *) = self.completion; self.completion = nil;
    if (completion) completion(success, message);
}
@end
