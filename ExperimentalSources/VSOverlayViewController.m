#import "VSOverlayViewController.h"
#import "VSToolOverlay.h"
@implementation VSOverlayViewController
- (void)loadView { self.view=[[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds]; self.view.backgroundColor=[UIColor colorWithRed:.035 green:.045 blue:.075 alpha:1]; VSToolOverlay *overlay=[[VSToolOverlay alloc] initWithFrame:self.view.bounds]; overlay.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight; [self.view addSubview:overlay]; }
- (BOOL)shouldAutorotate { return YES; }
- (UIInterfaceOrientationMask)supportedInterfaceOrientations { return UIInterfaceOrientationMaskAll; }
@end
