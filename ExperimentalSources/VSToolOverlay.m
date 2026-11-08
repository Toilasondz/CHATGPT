#import "VSToolOverlay.h"
#import "VSLogoView.h"
#import "VSBeatSplitEngine.h"

@interface VSToolOverlay ()
@property (nonatomic, strong) VSLogoView *logoControl;
@property (nonatomic, strong) UIView *panel;
@property (nonatomic, strong) UIScrollView *contentScrollView;
@property (nonatomic, strong) NSArray<UIButton *> *tabButtons;
@property (nonatomic, strong) NSMutableArray<UISwitch *> *featureSwitches;
@property (nonatomic) NSInteger selectedTab;
@property (nonatomic) NSInteger activeFeature;
@property (nonatomic) CGPoint logoStartCenter;
@property (nonatomic) CGPoint panelStartCenter;
@end

@implementation VSToolOverlay
- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = UIColor.clearColor;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.activeFeature = -1;
        self.featureSwitches = [NSMutableArray array];
        self.logoControl = [[VSLogoView alloc] initWithFrame:CGRectMake(0, 0, 56, 56)];
        self.logoControl.backgroundColor = [UIColor colorWithRed:0.12 green:0.45 blue:1 alpha:1];
        self.logoControl.layer.cornerRadius = 28;
        self.logoControl.layer.shadowColor = UIColor.systemBlueColor.CGColor;
        self.logoControl.layer.shadowOpacity = .45;
        self.logoControl.layer.shadowRadius = 12;
        UILabel *mark = [[UILabel alloc] initWithFrame:self.logoControl.bounds];
        mark.text = @"VS"; mark.textColor = UIColor.whiteColor; mark.font = [UIFont boldSystemFontOfSize:19]; mark.textAlignment = NSTextAlignmentCenter;
        [self.logoControl addSubview:mark];
        [self addSubview:self.logoControl];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleLogoTap:)];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleLogoPan:)];
        pan.delegate = self; [tap requireGestureRecognizerToFail:pan];
        [self.logoControl addGestureRecognizer:tap]; [self.logoControl addGestureRecognizer:pan];
    }
    return self;
}
- (BOOL)pointInside:(CGPoint)p withEvent:(UIEvent *)event {
    if (self.panel && !self.panel.hidden && CGRectContainsPoint(self.panel.frame, p)) return YES;
    if (CGRectContainsPoint(CGRectInset(self.logoControl.frame, -8, -8), p)) return YES;
    return NO;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    if (CGRectIsEmpty(self.bounds)) return;
    if (CGRectIsEmpty(self.logoControl.frame) || self.logoControl.center.x == 0) self.logoControl.center = CGPointMake(42, MAX(80, self.bounds.size.height * .25));
    [self clampLogoPosition];
    if (self.panel) { if (CGRectIsEmpty(self.panel.frame)) self.panel.frame = [self defaultPanelFrame]; [self clampPanelPosition]; }
}
- (CGRect)defaultPanelFrame {
    CGFloat width = MIN(360, self.bounds.size.width - 28), height = MIN(500, self.bounds.size.height - 80);
    return CGRectMake((self.bounds.size.width-width)/2, (self.bounds.size.height-height)/2, width, height);
}
- (void)clampLogoPosition {
    CGFloat x = MIN(MAX(self.logoControl.center.x, 32), self.bounds.size.width-32);
    CGFloat y = MIN(MAX(self.logoControl.center.y, 32), self.bounds.size.height-32);
    self.logoControl.center = CGPointMake(x,y);
}
- (void)clampPanelPosition {
    if (!self.panel) return;
    CGFloat halfW = self.panel.bounds.size.width/2, halfH = self.panel.bounds.size.height/2;
    self.panel.center = CGPointMake(MIN(MAX(self.panel.center.x, halfW+6), self.bounds.size.width-halfW-6), MIN(MAX(self.panel.center.y, halfH+6), self.bounds.size.height-halfH-6));
}
- (void)handleLogoTap:(UITapGestureRecognizer *)gesture { if (gesture.state == UIGestureRecognizerStateEnded) [self togglePanel]; }
- (void)handleLogoPan:(UIPanGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) self.logoStartCenter = self.logoControl.center;
    else if (gesture.state == UIGestureRecognizerStateChanged) { CGPoint t=[gesture translationInView:self]; self.logoControl.center=CGPointMake(self.logoStartCenter.x+t.x,self.logoStartCenter.y+t.y); [self clampLogoPosition]; }
}
- (void)togglePanel { self.panel ? [self closePanel] : [self openPanel]; }
- (void)openPanel {
    if (self.panel) return;
    self.panel = [[UIView alloc] initWithFrame:self.bounds];
    self.panel.frame = [self defaultPanelFrame]; self.panel.backgroundColor = [UIColor colorWithRed:.055 green:.075 blue:.13 alpha:.97];
    self.panel.layer.cornerRadius = 20; self.panel.layer.borderWidth = 1.5; self.panel.layer.borderColor = UIColor.systemBlueColor.CGColor;
    self.panel.layer.shadowColor = UIColor.blackColor.CGColor; self.panel.layer.shadowOpacity = .35; self.panel.layer.shadowRadius = 16;
    [self addSubview:self.panel];
    UILabel *brand=[[UILabel alloc] initWithFrame:CGRectMake(18,14,220,30)]; brand.text=@"★  VideoStar Tool"; brand.textColor=UIColor.whiteColor; brand.font=[UIFont boldSystemFontOfSize:21]; [self.panel addSubview:brand];
    UIButton *close=[UIButton buttonWithType:UIButtonTypeSystem]; close.frame=CGRectMake(self.panel.bounds.size.width-48,12,36,36); close.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin; [close setTitle:@"✕" forState:UIControlStateNormal]; close.tintColor=UIColor.whiteColor; [close addTarget:self action:@selector(closePanel) forControlEvents:UIControlEventTouchUpInside]; [self.panel addSubview:close];
    NSArray *names=@[@"Home",@"Function",@"Dev"]; NSMutableArray *tabs=[NSMutableArray array];
    CGFloat tabW=(self.panel.bounds.size.width-24)/3;
    for (NSInteger i=0;i<3;i++) { UIButton *b=[UIButton buttonWithType:UIButtonTypeSystem]; b.frame=CGRectMake(12+i*tabW,58,tabW,38); b.tag=i; [b setTitle:names[i] forState:UIControlStateNormal]; [b addTarget:self action:@selector(selectTab:) forControlEvents:UIControlEventTouchUpInside]; [self.panel addSubview:b]; [tabs addObject:b]; }
    self.tabButtons=tabs;
    self.contentScrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(12,104,self.panel.bounds.size.width-24,self.panel.bounds.size.height-126)]; self.contentScrollView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight; [self.panel addSubview:self.contentScrollView];
    UIPanGestureRecognizer *drag=[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanelPan:)]; [self.panel addGestureRecognizer:drag];
    self.selectedTab=0; [self renderSelectedTab]; [self updateTabAppearance]; [self clampPanelPosition];
    self.panel.alpha=0; self.panel.transform=CGAffineTransformMakeScale(.96,.96); [UIView animateWithDuration:.2 animations:^{ self.panel.alpha=1; self.panel.transform=CGAffineTransformIdentity; }];
    [self bringSubviewToFront:self.logoControl];
}
- (void)closePanel { if (!self.panel) return; UIView *old=self.panel; self.panel=nil; [UIView animateWithDuration:.18 animations:^{ old.alpha=0; old.transform=CGAffineTransformMakeScale(.96,.96); } completion:^(__unused BOOL done){ [old removeFromSuperview]; }]; }
- (void)handlePanelPan:(UIPanGestureRecognizer *)g { if (g.state==UIGestureRecognizerStateBegan) self.panelStartCenter=self.panel.center; else if(g.state==UIGestureRecognizerStateChanged){CGPoint t=[g translationInView:self]; self.panel.center=CGPointMake(self.panelStartCenter.x+t.x,self.panelStartCenter.y+t.y); [self clampPanelPosition];} }
- (void)selectTab:(UIButton *)sender { self.selectedTab=sender.tag; [self renderSelectedTab]; [self updateTabAppearance]; }
- (void)updateTabAppearance { [self.tabButtons enumerateObjectsUsingBlock:^(UIButton *b, NSUInteger idx, BOOL *stop){ b.tintColor=(idx==self.selectedTab)?UIColor.systemBlueColor:UIColor.lightGrayColor; b.titleLabel.font=[UIFont systemFontOfSize:14 weight:(idx==self.selectedTab?UIFontWeightBold:UIFontWeightMedium)]; }]; }
- (void)renderSelectedTab {
    [self.contentScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)]; [self.featureSwitches removeAllObjects];
    CGFloat width=self.contentScrollView.bounds.size.width ?: self.panel.bounds.size.width-48; CGFloat y=12;
    if(self.selectedTab==0){ UILabel *hello=[self label:@"Xin chào!" size:24 color:UIColor.whiteColor]; hello.frame=CGRectMake(8,y,width-16,38); [self.contentScrollView addSubview:hello]; y+=52; UILabel *desc=[self label:@"Đây là VideoStar Tool, một công cụ hỗ trợ thao tác trong Video Star. Bản tái dựng cần kết nối adapter với API nội bộ của ứng dụng gốc." size:15 color:UIColor.lightGrayColor]; desc.numberOfLines=0; desc.frame=CGRectMake(8,y,width-16,100); [self.contentScrollView addSubview:desc]; y+=120; }
    else if(self.selectedTab==1){ NSArray *features=@[@"Auto nhập ảnh vào các lớp hình ảnh",@"Hiển thị code gần nhất từng nhập",@"Auto chia beat",@"Auto nhập code và ảnh vào các phân cảnh"]; for(NSString *name in features){ UILabel *l=[self label:name size:14 color:UIColor.whiteColor]; l.numberOfLines=2; l.frame=CGRectMake(8,y,width-76,48); [self.contentScrollView addSubview:l]; UISwitch *sw=[[UISwitch alloc] init]; sw.frame=CGRectMake(width-58,y+5,50,32); sw.tag=self.featureSwitches.count; [sw addTarget:self action:@selector(featureSwitchChanged:) forControlEvents:UIControlEventValueChanged]; [self.contentScrollView addSubview:sw]; [self.featureSwitches addObject:sw]; y+=62; } }
    else { UILabel *info=[self label:@"Developer / Reverse Engineering" size:18 color:UIColor.whiteColor]; info.frame=CGRectMake(8,y,width-16,32); [self.contentScrollView addSubview:info]; y+=42; UILabel *details=[self label:@"Binary: Mach-O arm64\nRecovered classes: VSLogoView, VSQRCaptureProxy, VSToolOverlay, VSPassthroughWindow, VSOverlayViewController\nOriginal IMP offsets and pseudocode are stored in the ReverseEngineering folder." size:13 color:UIColor.lightGrayColor]; details.numberOfLines=0; details.frame=CGRectMake(8,y,width-16,150); [self.contentScrollView addSubview:details]; y+=160; }
    self.contentScrollView.contentSize=CGSizeMake(width,y+12);
}
- (UILabel *)label:(NSString *)text size:(CGFloat)size color:(UIColor *)color { UILabel *l=[UILabel new]; l.text=text; l.font=[UIFont systemFontOfSize:size]; l.textColor=color; return l; }
- (void)featureSwitchChanged:(UISwitch *)sender { if(!sender.on){ if(self.activeFeature==sender.tag) { if(sender.tag==2) [[VSBeatSplitEngine shared] cancel]; self.activeFeature=-1; } return; } for(UISwitch *s in self.featureSwitches) if(s!=sender) [s setOn:NO animated:YES]; self.activeFeature=sender.tag; switch(sender.tag){case 0:[self startFeatureReplaceMedia];break;case 1:[self startFeatureLastCode];break;case 2:[self startFeatureBeatSplit];break;case 3:[self startFeatureMultiSceneApply];break;} }
- (void)showSimpleAlert:(NSString *)title message:(NSString *)message index:(NSInteger)index { UIWindow *w=self.window; UIViewController *vc=w.rootViewController; while(vc.presentedViewController) vc=vc.presentedViewController; if(!vc)return; UIAlertController *a=[UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert]; [a addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]]; [vc presentViewController:a animated:YES completion:nil]; }
- (void)startFeatureReplaceMedia { [self showSimpleAlert:@"Chưa đủ API host" message:@"Đã khôi phục quy trình chọn layer và xác minh trạng thái media từ pseudocode. Phần gọi media picker và commit ảnh vào layer cần được kiểm thử với đúng phiên bản Video Star trước khi bật để tránh thay nhầm layer hoặc hỏng project." index:0]; }
- (void)startFeatureBeatSplit {
    __weak typeof(self) weakSelf = self;
    BOOL started = [[VSBeatSplitEngine shared] startWithCompletion:^(BOOL success, NSString *message) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) return;
        [self showSimpleAlert:(success ? @"Chia beat hoàn tất" : @"Chia beat chưa hoàn tất") message:message index:2];
        self.activeFeature = -1;
        for (UISwitch *sw in self.featureSwitches) [sw setOn:NO animated:YES];
    }];
    if (!started && self.activeFeature == 2) {
        // startWithCompletion reports the reason synchronously when setup fails.
    }
}
- (void)startFeatureLastCode { [self showSimpleAlert:@"Chưa xác minh nguồn code" message:@"Bản pseudocode có quét cache, Application Support và Documents để tìm code gần nhất. Cần xác minh định dạng file/cache của đúng phiên bản Video Star trước khi đọc và hiển thị." index:1]; }
- (void)startFeatureMultiSceneApply { [self showSimpleAlert:@"Chưa đủ API host" message:@"Đã khôi phục luồng chọn phạm vi scene, thu code/ảnh và điều phối QR import. Việc áp code, mở multi-layer editor và xác nhận native import phụ thuộc các class/selector riêng của Video Star; chưa thể bật an toàn khi chưa chạy kiểm thử trong app." index:3]; }
- (void)cancelActiveFlow { if(self.activeFeature==2) [[VSBeatSplitEngine shared] cancel]; self.activeFeature=-1; for(UISwitch *s in self.featureSwitches) [s setOn:NO animated:YES]; }
@end
