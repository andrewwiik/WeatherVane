


CGFloat seperatorHeight = 1.0;

@interface WFAirportViewController : UIViewController
@property (nonatomic, retain) UITableView *tableView;
- (void)powerStateDidChange:(BOOL)didChange;
- (void)viewWillAppear:(BOOL)willAppear;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
@end

@interface WFAssociationStateView : UIView

@property (nonatomic,retain) UIActivityIndicatorView* activityIndicator;           //@synthesize activityIndicator=_activityIndicator - In the implementation block
@property (nonatomic,retain) UIImageView* imageView;
@end

@interface WFNetworkListCell : UITableViewCell
@property (assign,nonatomic) UIImageView* signalImageView;                                  //@synthesize signalImageView=_signalImageView - In the implementation block
@property (assign,nonatomic) UIImageView* lockImageView;                                    //@synthesize lockImageView=_lockImageView - In the implementation block
@property (assign,nonatomic) UILabel* nameLabel;                                            //@synthesize nameLabel=_nameLabel - In the implementation block
@property (assign,nonatomic) UILabel* subtitleLabel;
@property (assign,nonatomic) WFAssociationStateView* associationStateView;
-(UIImage *)imageFromSignalBars:(NSInteger)numofBars;
@property (nonatomic, retain) UIView *seperatorView;
@property (nonatomic, assign) BOOL showSeparator;
- (void)setShouldShowSeperator:(BOOL)shouldShow;
- (void)setSelectionTintColor:(UIColor *)color;
@end

@interface APNetworksController : UIViewController
@property (nonatomic, retain) WFAirportViewController *settingsViewController;
- (id)initWithNibName:(id)name bundle:(id)bundle;
- (void)didWake;
- (void)viewDidAppear:(BOOL)didAppear;
- (void)willBecomeActive;
+ (APNetworksController *)sharedInstance;
@end

@interface SBIconController : UIViewController
+ (SBIconController *)sharedInstance;
@end

@interface CCUIMenuModuleViewController : UIViewController
- (CGFloat)_menuItemsHeightForWidth:(CGFloat)width;
- (void)_setupMenuItems;
@property (nonatomic,readonly) UIView* contentView;
@property (nonatomic, retain) APNetworksController *networksController;
- (void)setShouldProvideOwnPlatter:(BOOL)should;
- (CGFloat)_separatorHeight;

@end

@interface WFXWifiMenuModuleViewController : CCUIMenuModuleViewController
@property (nonatomic, retain) APNetworksController *networksController;
@end

@interface CCUIConnectivityWifiViewController : UIViewController
@property (nonatomic, retain) UILongPressGestureRecognizer *longPressRecognizer;
@property (nonatomic, retain) UIButton *button;
@end

@interface MTVibrantStylingProvider : NSObject
+ (id)_controlCenterPrimaryVibrantStyling;
+ (id)_controlCenterKeyLineOnDarkVibrantStyling;
@end

@interface UIView ()
- (void)mt_applyVibrantStyling:(id)styling;
@end

@interface FunnyLayer : CALayer
@property (assign) BOOL continuousCorners; 
@end

@interface CCUIMenuModuleTransitioningDelegate : NSObject
@end



%group ConnectivityModule
%hook CCUIConnectivityWifiViewController
%property (nonatomic, retain) UILongPressGestureRecognizer *longPressRecognizer;

%new
- (void)longPressRecognized:(UILongPressGestureRecognizer *)gesture {
	if (gesture.state == UIGestureRecognizerStateBegan) {
		if ([self valueForKey:@"_parentViewController"]) {
			if ([[self valueForKey:@"_parentViewController"] valueForKey:@"_expanded"]) {
				if ([[[self valueForKey:@"_parentViewController"] valueForKey:@"_expanded"] boolValue] == YES) {
					WFXWifiMenuModuleViewController *controller = [[NSClassFromString(@"WFXWifiMenuModuleViewController") alloc] init];
					[controller setModalPresentationStyle:UIModalPresentationCustom];
					[controller setTransitioningDelegate:(id<UIViewControllerTransitioningDelegate>)[NSClassFromString(@"CCUIMenuModuleTransitioningDelegate") new]];
					[controller setShouldProvideOwnPlatter:YES];
					[self presentViewController:controller animated:YES completion:nil];
				}
			}
		}
	}
}

- (id)init {
	CCUIConnectivityWifiViewController *controller = %orig;
	if (controller) {
		controller.longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressRecognized:)];
    	controller.longPressRecognizer.minimumPressDuration = 1.0;
    	// controller.longPressRecognizer.cancelsTouchesInView = NO;
	}
	return controller;

}

- (void)viewDidLoad {
	%orig;
	if (self.longPressRecognizer && self.button) {
		[self.button addGestureRecognizer:self.longPressRecognizer];
	}
}

// - (void)buttonTapped:(UIButton *)button {


// 	WFXWifiMenuModuleViewController *controller = [[NSClassFromString(@"WFXWifiMenuModuleViewController") alloc] init];

// 	// UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:_networksListController];
// 	// navigationController.navigationBarHidden = YES;

// 	[controller setModalPresentationStyle:UIModalPresentationCustom];
// 	[controller setTransitioningDelegate:(id<UIViewControllerTransitioningDelegate>)[self valueForKey:@"_menuTransitioningDelegate"]];
// 	[controller setShouldProvideOwnPlatter:YES];
// 	[self presentViewController:controller animated:YES completion:nil];

// }
%end
%end
// %subclass WFXWifiMenuModuleViewController : CCUIMenuModuleViewController
%subclass WFXWifiMenuModuleViewController : CCUIMenuModuleViewController
%property (nonatomic, retain) APNetworksController *networksController;
- (void)viewDidLoad {
	%orig;
	seperatorHeight = [self _separatorHeight];
	if (self.contentView) {
		self.contentView.hidden = YES;
		self.contentView.alpha = 0;
	}

	if ([self valueForKey:@"_headerSeparatorView"]) {
		UIView *headerSeparatorView = (UIView *)[self valueForKey:@"_headerSeparatorView"];
		headerSeparatorView.hidden = YES;
		headerSeparatorView.alpha = 0;
	}

	if ([self valueForKey:@"_darkeningBackgroundView"]) {
		UIView *darkeningBackgroundView = [self valueForKey:@"_darkeningBackgroundView"];
		darkeningBackgroundView.hidden = YES;
		darkeningBackgroundView.alpha = 0;
	}
	if (self.view) {
		if (!self.networksController) {
			self.networksController =  [NSClassFromString(@"APNetworksController") sharedInstance];
			if (self.contentView) {
				// [self addChildViewController:self.networksController];
				// [self.networksController didMoveToParentViewController:self];
				if ([self.networksController.view superview]) {
					[self.networksController removeFromParentViewController];
				}
				[self.view addSubview:self.networksController.view];
				self.networksController.view.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
				[self.view bringSubviewToFront:self.networksController.view];
				[self addChildViewController:self.networksController];
				[self.networksController didMoveToParentViewController:self];
			}
		}
	}
}

- (void)viewWillLayoutSubviews {
	%orig;
	if (self.contentView && self.networksController) {
		if (![self.networksController.view superview]) {

			[self.view addSubview:self.networksController.view];
			self.networksController.view.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
			[self.view bringSubviewToFront:self.networksController.view];
			[self addChildViewController:self.networksController];
			[self.networksController didMoveToParentViewController:self];
		}
		[self.view bringSubviewToFront:self.networksController.view];
		self.networksController.view.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
		self.networksController.view.layer.cornerRadius = ((UIView *)[[self valueForKey:@"_platterMaterialView"] valueForKey:@"_backdropView"]).layer.cornerRadius;
		((FunnyLayer *)self.networksController.view.layer).continuousCorners = ((FunnyLayer *)((UIView *)[[self valueForKey:@"_platterMaterialView"] valueForKey:@"_backdropView"]).layer).continuousCorners;
		self.networksController.view.clipsToBounds = YES;
	}
}


- (CGFloat)_menuItemsHeightForWidth:(CGFloat)width {
	return 200;
}
%end

%hook APNetworksController

%new
+ (id)sharedInstance {
	static APNetworksController *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[NSClassFromString(@"APNetworksController") alloc] initWithNibName:nil bundle:nil];
    });
    return _sharedInstance;
}

- (void)viewDidAppear:(BOOL)didAppear {
	%orig;
	if (self.settingsViewController) {
		[self.settingsViewController viewWillAppear:TRUE];
	}
}

- (void)viewWillLayoutSubviews {
	%orig;
	if (self.settingsViewController) {
		CGRect frame = self.settingsViewController.view.frame;
		frame.origin.y = -35;
		frame.size.height = self.view.frame.size.height + 35;
		self.settingsViewController.view.frame = frame;
	}
}
%end


%hook UIView


%new
- (void)addWiFiSubview {
	APNetworksController *controller = [[NSClassFromString(@"APNetworksController") alloc] initWithNibName:nil bundle:nil];
	[self addSubview:controller.view];
	controller.view.frame = CGRectMake(0,0,self.frame.size.width,self.frame.size.height);
	[self bringSubviewToFront:controller.view];
	[controller willBecomeActive];
	[controller viewDidAppear:YES];
	[controller didWake];

}
%end

%hook WFAirportViewController
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return %orig;
	NSInteger orig = %orig;
	if (orig >= 2) return 2;
	else return orig;
}

-(void)viewDidLoad {
	%orig;
	self.view.backgroundColor = nil;
	self.tableView.backgroundColor = [UIColor clearColor];
	// [self powerStateDidChange:TRUE];
}

%new
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([indexPath section] == 1) return 42.5;
	else if ([indexPath section] == 0 && [indexPath row] == 1) return 42.5;
	else return 0;
}

%new
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 0;
}

%new
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return [[UIView alloc] initWithFrame:CGRectZero];
}

%new
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	return [[UIView alloc] initWithFrame:CGRectZero];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return %orig;
	// if (section == 1) {
	// 	return %orig - 1;
	// } else return %orig;
}



- (void)viewWillLayoutSubviews {
	%orig;
	self.view.backgroundColor = [UIColor clearColor];
	if (self.tableView) {
		[self.tableView setBackgroundColor:[UIColor clearColor]];
		[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
		self.tableView.sectionHeaderHeight = 0.0;
		self.tableView.sectionFooterHeight = 0.0;
		self.tableView.clipsToBounds = YES;
	}
}

%new
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)tableCell forRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([tableCell isKindOfClass:NSClassFromString(@"WFNetworkListCell")]) {
		WFNetworkListCell *cell = (WFNetworkListCell *)tableCell;
		if ([indexPath section] == 0) {
			[cell setShouldShowSeperator:YES];
			cell.separatorInset = UIEdgeInsetsMake(0,40,0,0);
		} else {
			[cell setShouldShowSeperator:([self tableView:tableView numberOfRowsInSection:[indexPath section]] - 1 != [indexPath row])];
		}
		[cell layoutSubviews];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *orig = %orig;
	if (orig && [orig isKindOfClass:NSClassFromString(@"WFNetworkListCell")]) {
		WFNetworkListCell *cell = (WFNetworkListCell *)orig;
		orig.hidden = NO;
		orig.alpha = 1.0;
		[orig setAccessoryType:UITableViewCellAccessoryNone];

		if ([indexPath section] == 0) {
			[cell setShouldShowSeperator:YES];
			cell.separatorInset = UIEdgeInsetsMake(0,40,0,0);
		} else {
			[cell setShouldShowSeperator:([self tableView:tableView numberOfRowsInSection:[indexPath section]] - 1 != [indexPath row])];
		}
	} else {
		orig.hidden = YES;
		orig.alpha = 0.0;
	}
	return orig;
}
%end

%hook WFNetworkListCell
%property (nonatomic, retain) UIView *seperatorView;
%property (nonatomic, assign) BOOL showSeparator;

%new
- (void)setShouldShowSeperator:(BOOL)shouldShow {
	if (self.showSeparator != shouldShow) {
		self.showSeparator = shouldShow;
		[self layoutSubviews];
	}
}

- (UIColor *)backgroundColor {
	return nil;
}

- (void)setBackgroundColor:(UIColor *)color {
	%orig(nil);
}

- (void)layoutSubviews {
	%orig;
	[self setValue:[UIColor colorWithWhite:1.0 alpha:0.35] forKey:@"_selectionTintColor"];

	self.clipsToBounds = NO;

	if (!self.seperatorView) {
		self.seperatorView = [[UIView alloc] initWithFrame:CGRectMake(self.separatorInset.left,self.frame.size.height - seperatorHeight,0 + self.frame.size.width - self.separatorInset.left,seperatorHeight)];
		[self.seperatorView mt_applyVibrantStyling:[NSClassFromString(@"MTVibrantStylingProvider") _controlCenterKeyLineOnDarkVibrantStyling]];
		[self addSubview:self.seperatorView];
	}

	if (self.seperatorView) {
		self.seperatorView.frame = CGRectMake(self.separatorInset.left,self.frame.size.height - seperatorHeight,0 + self.frame.size.width - self.separatorInset.left,seperatorHeight);
		self.seperatorView.hidden = !self.showSeparator;
	}
	if (self.nameLabel) {
		self.nameLabel.textColor = [UIColor whiteColor];
	}

	if (self.subtitleLabel) {
		self.subtitleLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.6];
	}

	if (self.lockImageView) {
		self.lockImageView.tintColor = [UIColor whiteColor];
		if (self.lockImageView.image) {
			self.lockImageView.image = [self.lockImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
		}
	}

	if (self.signalImageView) {
		self.signalImageView.tintColor = [UIColor whiteColor];
	}

	if (self.associationStateView) {
		self.associationStateView.backgroundColor = nil;
	}
}

- (UIEdgeInsets)safeAreaInsets {
	return UIEdgeInsetsMake(0,0,0,16);
}

- (UIColor *)selectionTintColor {
	return [UIColor colorWithWhite:1 alpha:0.35];
}

- (void)setSelectionTintColor:(UIColor *)color {

	%orig([UIColor colorWithWhite:1 alpha:0.35]);
}

- (UITableViewCellAccessoryType)accessoryType {
	return UITableViewCellAccessoryNone;
}

-(UIImage *)imageFromSignalBars:(NSInteger)numofBars {
	UIImage *orig = %orig;
	if (orig) {
		orig  = [orig imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	}
	return orig;
}

%end

static BOOL didHook = NO;
static void notificationCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	if ([((__bridge NSDictionary *)userInfo)[NSLoadedClasses] containsObject:@"CCUIConnectivityAirDropViewController"]) { // The Network Bundle is Loaded
		if (!didHook) {
			didHook = YES;
			%init(ConnectivityModule);
		}
	}
}

%ctor {
	BOOL shouldInit = NO;
	if (!NSClassFromString(@"APTableCell")) {
		NSString *fullPath = [NSString stringWithFormat:@"/System/Library/PreferenceBundles/AirPortSettings.bundle"];
		NSBundle *bundle;
		bundle = [NSBundle bundleWithPath:fullPath];
		BOOL didLoad = [bundle load];
		if (didLoad) {
			shouldInit = YES;
		}
	} else {
		shouldInit = YES;
	}

	if (shouldInit) {
		%init;
		CFNotificationCenterAddObserver(
			CFNotificationCenterGetLocalCenter(), NULL,
			notificationCallback,
			(CFStringRef)NSBundleDidLoadNotification,
			NULL, CFNotificationSuspensionBehaviorCoalesce);
	}
}