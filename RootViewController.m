//BundleIDs Originally created by @NoahSaso
//Updated in 2018 by @TD_Advocate
//Huge thanks to @TheTomMetzger and @Skittyblock for their massive amounts of help with updating and adding new features
//Shoutout to @xerusdesign for making the new icon and @EthanWhited for helping resolve an iOS 13 crash w/app icons in the table view

#import "SkittyAppListViewController.h"

SkittyAppListViewController *controller;

//Set showID alert to nil for auto dismiss
UIAlertController *showID = nil;

//Set copyAllAlert alert to nil for auto dismiss
UIAlertController *copyAllAlert = nil;

//Create array of bundleIDs to be used for copyAllButton
NSMutableArray *bundleIDs;

static void setAppList(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    if ([(__bridge NSDictionary *)userInfo count] < 2) { // people must have at least two apps, right?
        return;
    }
    NSLog(@"[SPEC] setAppList: %@", userInfo);
    [controller recieveAppList:(__bridge NSDictionary *)userInfo];
}

static void post() {
    NSLog(@"[SPEC] post");
    CFNotificationCenterPostNotification(CFNotificationCenterGetDistributedCenter(), CFSTR("xyz.skitty.skittyapplist.getapps"), nil, nil, true);
}

@implementation SkittyAppListViewController

- (NSArray *)specifiers {
    return nil;
}

- (id)init {
    self = [super init];
    if (self) {
        
        self.title = @"Bundle IDs";

        CFNotificationCenterAddObserver(CFNotificationCenterGetDistributedCenter(), NULL, setAppList, CFSTR("xyz.skitty.skittyapplist.setapps"), nil, CFNotificationSuspensionBehaviorDeliverImmediately);

        [self getAppList];
        
        NSString *prefPath = @"/var/mobile/Library/Preferences/xyz.skitty.skittyapplist.apps.plist";
        NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:prefPath];
        NSArray *apps;
        if ([[NSFileManager defaultManager] fileExistsAtPath:prefPath]) {
            apps = [prefs objectForKey:@"Disabled"];
        } else {
            apps = @[];
        }
        self.preferencesAppList = apps;
        
        self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
        self.searchController.dimsBackgroundDuringPresentation = NO;
        self.searchController.delegate = self;
        self.searchController.searchBar.delegate = self;
        self.searchController.searchBar.placeholder = @"Search";

        self.navigationItem.searchController = self.searchController;
        self.navigationItem.hidesSearchBarWhenScrolling = NO; // unfortunatly, this is required.
        
        if(@available(iOS 13.0, *)) {
        self.blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemChromeMaterial];
        self.navigationBar.backgroundView.effectView1.effect = self.blurEffect;
        } else {
        self.navigationBar.backgroundView.effectView1.effect = nil;
        }

        self.tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        self.view.frame = [UIScreen mainScreen].bounds;
        
        if(@available(iOS 13.0, *)) {
        self.tableDynamicColor = [UIColor colorWithDynamicProvider:^UIColor *(UITraitCollection *traitCollection) {
        BOOL isDarkMode = traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark;
        BOOL isLightMode = traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight;
        BOOL isUnspecified = traitCollection.userInterfaceStyle == UIUserInterfaceStyleUnspecified;
            if (isDarkMode) {
                return [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:1.0f];
            } if (isLightMode) {
                return [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1.0f];
                }
            if (isUnspecified) {
               return [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1.0f];
               }
            return [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1.0f];
        }];
        
        self.tableView.backgroundColor = self.tableDynamicColor;
        } else {
        self.tableView.backgroundColor = [UIColor whiteColor];
        }
        
        if(@available(iOS 13.0, *)) {
        self.backgroundDynamicColor = [UIColor colorWithDynamicProvider:^UIColor *(UITraitCollection *traitCollection) {
        BOOL isDarkMode = traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark;
        BOOL isLightMode = traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight;
        BOOL isUnspecified = traitCollection.userInterfaceStyle == UIUserInterfaceStyleUnspecified;
            if (isDarkMode) {
                return [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:1.0f];
            } if (isLightMode) {
                return [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1.0f];
                }
            if (isUnspecified) {
               return [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1.0f];
               }
            return [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1.0f];
        }];
        
        self.view.backgroundColor = self.backgroundDynamicColor;
        } else {
        self.view.backgroundColor = [UIColor whiteColor];
        }
        
        [self.view addSubview:self.tableView];

        // This is probably a terrible way to do it.
        controller = self;
    }
    return self;
}

- (void)viewDidLoad {
    
    //Create copyAllButton on right side of the navbar
    UIBarButtonItem *copyAllButton = [[UIBarButtonItem alloc]
                                      initWithTitle:@"Copy All"
                                      style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(copyAllButton:)];
    self.navigationItem.rightBarButtonItem = copyAllButton;
    
    [super viewDidLoad];
}

// App List

- (void)getAppList {
    if (self.appList.count == 0) {
        self.appList = @{@"Loading!": @"Loading..."};
    }
    
    post();
}

- (void)recieveAppList:(NSDictionary *)appList {
    if ([appList count] < 2) {
        return;
    }
    self.fullAppList = appList;
    [self updateAppList:appList];
}

- (void)updateAppList:(NSDictionary *)appList {
    NSArray *ids = [appList keysSortedByValueUsingComparator:^(NSString *obj1, NSString *obj2) {
        return [obj1 compare:obj2];
    }];

    self.appList = appList;
    self.identifiers = ids;

    [self.tableView reloadData];
}

// Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)viewWillLayoutSubviews {
    self.tableView.frame = [UIScreen mainScreen].bounds;
    self.view.frame = [UIScreen mainScreen].bounds;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SkittyAppCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:3 reuseIdentifier:@"SkittyAppCell"];
    }
    
    if(@available(iOS 13.0, *)) {
    cell.detailTextLabel.textColor = [UIColor systemGray2Color];
    } else {
    cell.detailTextLabel.textColor = [UIColor grayColor];
    }
    
    if (![self.preferencesAppList containsObject:self.identifiers[indexPath.row]]) {
    }
    
    if(@available(iOS 13.0, *)) {
        
    self.labelDynamicColor = [UIColor colorWithDynamicProvider:^UIColor *(UITraitCollection *traitCollection) {
    BOOL isDarkMode = traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark;
    BOOL isLightMode = traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight;
    BOOL isUnspecified = traitCollection.userInterfaceStyle == UIUserInterfaceStyleUnspecified;
        if (isDarkMode) {
            return [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1.0f];
        } if (isLightMode) {
            return [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:1.0f];
            }
        if (isUnspecified) {
           return [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:1.0f];
           }
        return [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:1.0f];
    }];
    
    cell.textLabel.textColor = self.labelDynamicColor;
    } else {
    cell.textLabel.textColor = [UIColor blackColor];
    }
    cell.textLabel.text = [self.fullAppList objectForKey:self.identifiers[indexPath.row]];
    cell.detailTextLabel.text = self.identifiers[indexPath.row];
    
    cell.imageView.image = [UIImage _applicationIconImageForBundleIdentifier:self.identifiers[indexPath.row] format:0 scale:[UIScreen mainScreen].scale];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //copy single selected application bundle ID to clipboard
    [UIPasteboard generalPasteboard].string = self.identifiers[indexPath.row];
    
    if(@available(iOS 13.0, *)) {
    self.bundleidController = [[OBWelcomeController alloc] initWithTitle:self.identifiers[indexPath.row] detailText:@"" icon:[UIImage _applicationIconImageForBundleIdentifier:self.identifiers[indexPath.row] format:0 scale:[UIScreen mainScreen].scale]];
    
    [self.bundleidController addBulletedListItemWithTitle:@"Copied" description:@"Bundle ID copied to ClipBoard" image:[UIImage systemImageNamed:@"doc.on.doc.fill"]];
        
    OBBoldTrayButton* continueButtonTint = [OBBoldTrayButton buttonWithType:1];
    [continueButtonTint addTarget:self action:@selector(dismissVCTint) forControlEvents:UIControlEventTouchUpInside];
    [continueButtonTint setTitle:@"Swipe To Dismiss" forState:UIControlStateNormal];
    [continueButtonTint setClipsToBounds:YES];
    [continueButtonTint setTitleColor:[UIColor systemPinkColor] forState:UIControlStateNormal];
    continueButtonTint.tintColor = [UIColor clearColor];
    [continueButtonTint.layer setCornerRadius:15];
    [self.bundleidController.buttonTray addButton:continueButtonTint];

    self.bundleidController.buttonTray.effectView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemChromeMaterial];
    
    UIVisualEffectView *effectWelcomeView = [[UIVisualEffectView alloc] initWithFrame:self.bundleidController.viewIfLoaded.bounds];
    
    effectWelcomeView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemChromeMaterial];
    
    [self.bundleidController.viewIfLoaded insertSubview:effectWelcomeView atIndex:0];
    
    self.bundleidController.viewIfLoaded.backgroundColor = [UIColor clearColor];

    //[self.bundleidController.buttonTray addCaptionText:@"BundleIDsXi"];

    self.bundleidController.modalPresentationStyle = UIModalPresentationPageSheet;
    self.bundleidController.modalInPresentation = NO;
    self.bundleidController.view.tintColor = [UIColor systemPinkColor];
    [self presentViewController:self.bundleidController animated:YES completion:nil];
    } else {
        //show single bundle ID alert
            showID = [UIAlertController alertControllerWithTitle:self.identifiers[indexPath.row] message:@"Copied to the clipboard" preferredStyle:UIAlertControllerStyleAlert];
            
            //The manual dismissal prompt for the UIAlertView
            UIAlertAction *actionOK = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^ (UIAlertAction *_Nonnull action) {
            NSLog(@"OK button is pressed");
            }];
            [showID addAction:actionOK];
            
            //Allowing the alert to actually be displayed
            [self presentViewController:showID animated:YES completion:nil];
    }
}

-(void)dismissVCTint {
    [self.bundleidController dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.identifiers.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return nil;
}

// Search Bar

- (void)searchWithText:(NSString *)text {
    NSDictionary *newAppList;
    if (text.length == 0) {
        newAppList = self.fullAppList;
    } else {
        NSMutableDictionary *mutableList = [[NSMutableDictionary alloc] init];
        NSArray *ids = [self.fullAppList keysSortedByValueUsingComparator:^(NSString *obj1, NSString *obj2) {
            return [obj1 compare:obj2];
        }];
        NSArray<NSString *> *names = [[self.fullAppList allValues] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj1 compare:obj2 options:NSNumericSearch];
        }];
        for (int i = 0; i < names.count; i++) {
            if ([names[i].lowercaseString rangeOfString:text.lowercaseString].location != NSNotFound) {
                [mutableList setObject:names[i] forKey:ids[i]];
            }
        }
        newAppList = [mutableList copy];
    }
    [self updateAppList:newAppList];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)text {
    [self searchWithText:text];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [self searchWithText:searchBar.text];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
    [self searchWithText:nil];
}

//How the Copy All button works
-(void)copyAllButton:(id)sender {
    
    NSString* copiedAllString = @"";
    for (int i=0; i < self.appList.count; i ++) {
        //Create the string of all application names
        NSString *allNames = [NSString stringWithFormat:@"%@~", [self.fullAppList objectForKey:self.identifiers[i]]];
        //NSString *allNames = [NSString stringWithFormat:@"%@\n", [self.fullAppList objectForKey:self.fullAppList][i]];
        //Add the string of application names to the copied all string
        copiedAllString = [copiedAllString stringByAppendingString:allNames];
        //Create the string of all application bundle IDs
        NSString *allBundles = [NSString stringWithFormat:@"%@%@", self.identifiers[i], @" "];
        //Add the string of application bundle IDs to the copied all string
        copiedAllString = [copiedAllString stringByAppendingString:allBundles];
    }
    
    //copy all bundle IDs to clipboard
    [UIPasteboard generalPasteboard].string = copiedAllString;
    
    if(@available(iOS 13.0, *)) {
        self.copyallController = [[OBWelcomeController alloc] initWithTitle:@"BundleIDsXI" detailText:@"" icon:nil];
    
    [self.copyallController addBulletedListItemWithTitle:@"Copied" description:@"All Bundle IDs copied to ClipBoard" image:[UIImage systemImageNamed:@"doc.on.doc.fill"]];
        
    OBBoldTrayButton* continueButtonTint2 = [OBBoldTrayButton buttonWithType:1];
    [continueButtonTint2 addTarget:self action:@selector(dismissVCTint2) forControlEvents:UIControlEventTouchUpInside];
    [continueButtonTint2 setTitle:@"Swipe To Dismiss" forState:UIControlStateNormal];
    [continueButtonTint2 setClipsToBounds:YES];
    [continueButtonTint2 setTitleColor:[UIColor systemPinkColor] forState:UIControlStateNormal];
    continueButtonTint2.tintColor = [UIColor clearColor];
    [continueButtonTint2.layer setCornerRadius:15];
    [self.copyallController.buttonTray addButton:continueButtonTint2];

    self.copyallController.buttonTray.effectView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemChromeMaterial];
    
    UIVisualEffectView *effectWelcomeView2 = [[UIVisualEffectView alloc] initWithFrame:self.copyallController.viewIfLoaded.bounds];
    
    effectWelcomeView2.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemChromeMaterial];
    
    [self.copyallController.viewIfLoaded insertSubview:effectWelcomeView2 atIndex:0];
    
    self.copyallController.viewIfLoaded.backgroundColor = [UIColor clearColor];

    //[self.copyallController.buttonTray addCaptionText:@"BundleIDsXi"];

    self.copyallController.modalPresentationStyle = UIModalPresentationPageSheet;
    self.copyallController.modalInPresentation = NO;
    self.copyallController.view.tintColor = [UIColor systemPinkColor];
    [self presentViewController:self.copyallController animated:YES completion:nil];
    } else {

    //show copy all bundle IDs alert
    copyAllAlert = [UIAlertController alertControllerWithTitle:@"All Bundle IDs" message:@"Copied to the clipboard" preferredStyle:UIAlertControllerStyleAlert];
        
    //Allowing the alert to actually be displayed
    [self presentViewController:copyAllAlert animated:YES completion:nil];

    UIAlertAction *actionOK = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^ (UIAlertAction *_Nonnull action) {
    NSLog(@"OK button is pressed");
    }];
    [copyAllAlert addAction:actionOK];
    
    //All non-hidden bundle IDs to be copied
    NSString* copiedAllString = @"";
    for (int i=0; i < self.appList.count; i ++) {
        //Create the string of all application names
        NSString *allNames = [NSString stringWithFormat:@"%@~", [self.fullAppList objectForKey:self.identifiers[i]]];
        //NSString *allNames = [NSString stringWithFormat:@"%@\n", [self.fullAppList objectForKey:self.fullAppList][i]];
        //Add the string of application names to the copied all string
        copiedAllString = [copiedAllString stringByAppendingString:allNames];
        //Create the string of all application bundle IDs
        NSString *allBundles = [NSString stringWithFormat:@"%@%@", self.identifiers[i], @" "];
        //Add the string of application bundle IDs to the copied all string
        copiedAllString = [copiedAllString stringByAppendingString:allBundles];
    }
    
    //copy all bundle IDs to clipboard
    [UIPasteboard generalPasteboard].string = copiedAllString;

    }
    
}

-(void)dismissVCTint2 {
    [self.copyallController dismissViewControllerAnimated:YES completion:nil];
}

@end
