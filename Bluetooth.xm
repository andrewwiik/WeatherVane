@interface BTSDevicesController : UIViewController
@property (nonatomic, retain, readonly) UITableView *table;
- (id)init;
- (void)viewWillAppear:(BOOL)willAppear;
- (void)viewDidAppear:(BOOL)didAppear;
- (UITableView *)table;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
+ (BTSDevicesController *)sharedInstance;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface BTTableCell : UITableViewCell
@property (nonatomic, retain) UILabel *textLabel;
@property (nonatomic, retain) UILabel *detailTextLabel;
@property (nonatomic, retain) UIView *seperatorView;
@property (nonatomic, assign) BOOL showSeparator;
@property (nonatomic, retain) UIView *spinner;
- (void)setShouldShowSeperator:(BOOL)shouldShow;
- (void)setSelectionTintColor:(UIColor *)color;
- (void)_setAccessoryViewsHidden:(BOOL)hidden;
- (int)state;
- (id)specifier;
@end

@interface BTSDeviceClassic : NSObject
- (BOOL)connected;
- (void)disconnect;
@end

@interface MTVibrantStylingProvider : NSObject
+ (id)_controlCenterPrimaryVibrantStyling;
+ (id)_controlCenterKeyLineOnDarkVibrantStyling;
@end

@interface UIView ()
- (void)mt_applyVibrantStyling:(id)styling;
@end

@interface UITableView ()
- (UITableViewCell *)_existingCellForRowAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface FunnyLayer : CALayer
@property (assign) BOOL continuousCorners; 
@end

@interface CCUIMenuModuleViewController : UIViewController
- (CGFloat)_menuItemsHeightForWidth:(CGFloat)width;
- (void)_setupMenuItems;
@property (nonatomic,readonly) UIView* contentView;
- (void)setShouldProvideOwnPlatter:(BOOL)should;
- (CGFloat)_separatorHeight;

@end

@interface WFXBluetoothMenuModuleViewController : CCUIMenuModuleViewController
@property (nonatomic, retain) BTSDevicesController *bluetoothController;
@end

@interface CCUIConnectivityBluetoothViewController : UIViewController
@property (nonatomic, retain) UILongPressGestureRecognizer *longPressRecognizer;
@property (nonatomic, retain) UIButton *button;
@end

CGFloat seperatorHeight1 = 0.5;

%hook UIView
%new
- (void)addBluetooth {
	BTSDevicesController *controller = [[NSClassFromString(@"BTSDevicesController") alloc] init];
	[self addSubview:controller.view];
	controller.view.frame = CGRectMake(0,0,self.frame.size.width,self.frame.size.height);
	[self bringSubviewToFront:controller.view];
	[controller viewWillAppear:YES];
	[controller viewDidAppear:YES];
}
%end

%hook BTSDevicesController

%new
+ (id)sharedInstance {
	static BTSDevicesController *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[NSClassFromString(@"BTSDevicesController") alloc] init];
    });
    return _sharedInstance;
}

- (void)viewDidLoad {
	%orig;
	self.view.backgroundColor = nil;
	if (self.table) {
		self.table.backgroundColor = nil;
	}
}

- (void)viewWillLayoutSubviews {
	%orig;
	self.view.backgroundColor = nil;
	if (self.table) {
		[self.table setBackgroundColor:nil];
		[self.table setSeparatorStyle:UITableViewCellSeparatorStyleNone];
		self.table.sectionHeaderHeight = 0.0;
		self.table.sectionFooterHeight = 0.0;
		self.table.clipsToBounds = YES;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return [[UIView alloc] initWithFrame:CGRectZero];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	return [[UIView alloc] initWithFrame:CGRectZero];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([indexPath section] == 1) return 42.5;
	else if ([indexPath section] == 2) return 42.5;
	else return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *orig = %orig;
	if (orig && [orig isKindOfClass:NSClassFromString(@"BTTableCell")]) {
		BTTableCell *cell = (BTTableCell *)orig;
		cell.separatorInset = UIEdgeInsetsMake(0,15,0,0);
		[orig setAccessoryType:UITableViewCellAccessoryNone];
		[cell setShouldShowSeperator:YES];
	} else {
		orig.hidden = YES;
		orig.alpha = 0.0;
	}
	return orig;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([indexPath section] == 1) {
		BTTableCell *cell = (BTTableCell *)[tableView cellForRowAtIndexPath:indexPath];
		HBLogInfo(@"Got Cell: %@", cell);
		if (cell && [cell isKindOfClass:NSClassFromString(@"BTTableCell")]) {
			//if ([cell state] == 4) {
			//	HBLogInfo(@"Cell State was 4 for: %@", cell);
				BTSDeviceClassic *device = (BTSDeviceClassic *)[(NSDictionary *)[[cell valueForKey:@"_specifier"] valueForKey:@"_userInfo"] objectForKey:@"bt-device"];
				HBLogInfo(@"Got Device: %@", device);
				if (device && [device connected]) {
					[tableView deselectRowAtIndexPath:indexPath animated:YES];
					[device disconnect];
					return;
				}
			//}
		}
	}
	%orig;
}

%end

%hook BTTableCell
%property (nonatomic, retain) UIView *seperatorView;
%property (nonatomic, assign) BOOL showSeparator;

- (BOOL)isHidden {
	if ([self specifier]) {
		if ([[[self specifier] valueForKey:@"_userInfo"] valueForKey:@"bt-device"]) return NO;
	}
	return YES;
	// if (self.spinner) {
	// 	if (self.spinner.hidden) return NO;
	// 	else return YES;
	// }
	// return %orig;
	// if (self.showSeparator) return FALSE;
	// return TRUE;
}

- (void)setSpinner:(UIView *)spinner {
	%orig;
	if (spinner) {
		spinner.alpha = 0.0;
		spinner.hidden = YES;
		if ([spinner superview]) {
			[spinner removeFromSuperview];
		}
	}
}
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
	// [self _setAccessoryViewsHidden:TRUE];

	// self.clipsToBounds = NO;

	if (!self.seperatorView) {
		self.seperatorView = [[UIView alloc] initWithFrame:CGRectMake(self.separatorInset.left,self.frame.size.height - seperatorHeight1,0 + self.frame.size.width - self.separatorInset.left,seperatorHeight1)];
		[self.seperatorView mt_applyVibrantStyling:[NSClassFromString(@"MTVibrantStylingProvider") _controlCenterKeyLineOnDarkVibrantStyling]];
		[self addSubview:self.seperatorView];
	}

	if (self.seperatorView) {
		self.seperatorView.frame = CGRectMake(self.separatorInset.left,self.frame.size.height - seperatorHeight1,0 + self.frame.size.width - self.separatorInset.left,seperatorHeight1);
		self.seperatorView.hidden = !self.showSeparator;
	}

	if (self.spinner) {
		self.spinner.hidden = YES;
		self.spinner.alpha = 0;
		if ([self.spinner superview]) {
			[self.spinner removeFromSuperview];
		}
	}

	if (self.textLabel) {

		self.textLabel.textColor = self.showSeparator ? [UIColor whiteColor] : [UIColor clearColor];
	}

	if (self.detailTextLabel) {
		self.detailTextLabel.textColor = self.showSeparator ? [UIColor colorWithWhite:1 alpha:0.65] : [UIColor clearColor];
	}
}

- (UITableViewCellAccessoryType)accessoryType {
	return UITableViewCellAccessoryNone;
}

- (void)setAccessoryType:(UITableViewCellAccessoryType)type {
	%orig(UITableViewCellAccessoryNone);
	// [self _setAccessoryViewsHidden:TRUE];
}

- (UIEdgeInsets)safeAreaInsets {
	return UIEdgeInsetsMake(0,0,0,16);
}

// - (void)setSpecifier:(id)specifier {
// 	%orig;
// 	if (specifier) self.hidden = NO;
// 	else self.hidden = YES;
// }
%end




%group ConnectivityModule
%hook CCUIConnectivityBluetoothViewController
%property (nonatomic, retain) UILongPressGestureRecognizer *longPressRecognizer;

%new
- (void)longPressRecognized:(UILongPressGestureRecognizer *)gesture {
	if (gesture.state == UIGestureRecognizerStateBegan) {
		if ([self valueForKey:@"_parentViewController"]) {
			if ([[self valueForKey:@"_parentViewController"] valueForKey:@"_expanded"]) {
				if ([[[self valueForKey:@"_parentViewController"] valueForKey:@"_expanded"] boolValue] == YES) {
					WFXBluetoothMenuModuleViewController *controller = [[NSClassFromString(@"WFXBluetoothMenuModuleViewController") alloc] init];
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
	CCUIConnectivityBluetoothViewController *controller = %orig;
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


// 	WFXBluetoothMenuModuleViewController *controller = [[NSClassFromString(@"WFXBluetoothMenuModuleViewController") alloc] init];

// 	// UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:_networksListController];
// 	// navigationController.navigationBarHidden = YES;

// 	[controller setModalPresentationStyle:UIModalPresentationCustom];
// 	[controller setTransitioningDelegate:(id<UIViewControllerTransitioningDelegate>)[self valueForKey:@"_menuTransitioningDelegate"]];
// 	[controller setShouldProvideOwnPlatter:YES];
// 	[self presentViewController:controller animated:YES completion:nil];

// }
%end
%end
// %subclass WFXBluetoothMenuModuleViewController : CCUIMenuModuleViewController
%subclass WFXBluetoothMenuModuleViewController : CCUIMenuModuleViewController
%property (nonatomic, retain) BTSDevicesController *bluetoothController;
- (void)viewDidLoad {
	%orig;
	seperatorHeight1 = [self _separatorHeight];
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
		if (!self.bluetoothController) {
			self.bluetoothController =  [NSClassFromString(@"BTSDevicesController") sharedInstance];
			if (self.contentView) {
				// [self addChildViewController:self.bluetoothController];
				// [self.bluetoothController didMoveToParentViewController:self];
				if ([self.bluetoothController.view superview]) {
					[self.bluetoothController removeFromParentViewController];
				}
				[self.view addSubview:self.bluetoothController.view];
				self.bluetoothController.view.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
				[self.view bringSubviewToFront:self.bluetoothController.view];
				[self addChildViewController:self.bluetoothController];
				[self.bluetoothController didMoveToParentViewController:self];
			}
		}
	}
}

- (void)viewWillLayoutSubviews {
	%orig;
	if (self.contentView && self.bluetoothController) {
		if (![self.bluetoothController.view superview]) {

			[self.view addSubview:self.bluetoothController.view];
			self.bluetoothController.view.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
			[self.view bringSubviewToFront:self.bluetoothController.view];
			[self addChildViewController:self.bluetoothController];
			[self.bluetoothController didMoveToParentViewController:self];
		}
		[self.view bringSubviewToFront:self.bluetoothController.view];
		self.bluetoothController.view.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
		self.bluetoothController.view.layer.cornerRadius = ((UIView *)[[self valueForKey:@"_platterMaterialView"] valueForKey:@"_backdropView"]).layer.cornerRadius;
		((FunnyLayer *)self.bluetoothController.view.layer).continuousCorners = ((FunnyLayer *)((UIView *)[[self valueForKey:@"_platterMaterialView"] valueForKey:@"_backdropView"]).layer).continuousCorners;
		self.bluetoothController.view.clipsToBounds = YES;
	}
}


- (CGFloat)_menuItemsHeightForWidth:(CGFloat)width {
	return 200;
}
%end

static BOOL didHook = NO;
static void notificationCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	if ([((__bridge NSDictionary *)userInfo)[NSLoadedClasses] containsObject:@"CCUIConnectivityBluetoothViewController"]) { // The Network Bundle is Loaded
		if (!didHook) {
			didHook = YES;
			%init(ConnectivityModule);
		}
	}
}

%ctor {
	BOOL shouldInit = NO;
	if (!NSClassFromString(@"BTTableCell")) {
		NSString *fullPath = [NSString stringWithFormat:@"/System/Library/PreferenceBundles/BluetoothSettings.bundle"];
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