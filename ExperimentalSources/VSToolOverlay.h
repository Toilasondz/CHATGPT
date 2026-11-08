#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
@interface VSToolOverlay : UIView <UIGestureRecognizerDelegate>
@property (nonatomic, readonly) NSInteger selectedTab;
@property (nonatomic, readonly) NSInteger activeFeature;
- (void)togglePanel;
- (void)openPanel;
- (void)closePanel;
- (void)cancelActiveFlow;
- (void)showSimpleAlert:(NSString *)title message:(NSString *)message index:(NSInteger)index;
- (void)startFeatureReplaceMedia;
- (void)startFeatureBeatSplit;
- (void)startFeatureLastCode;
- (void)startFeatureMultiSceneApply;
@end
NS_ASSUME_NONNULL_END
