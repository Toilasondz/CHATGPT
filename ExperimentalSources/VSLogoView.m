#import "VSLogoView.h"
@implementation VSLogoView
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    return CGRectContainsPoint(self.bounds, point);
}
@end
