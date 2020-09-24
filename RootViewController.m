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

        self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SkittyAppCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:3 reuseIdentifier:@"SkittyAppCell"];
    }

    cell.detailTextLabel.textColor = [UIColor grayColor];
    
    if (![self.preferencesAppList containsObject:self.identifiers[indexPath.row]]) {
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
    for (int i=0; i < _appList.count; i ++) {
        //Create the string of all application names
        NSString *allNames = [NSString stringWithFormat:@"%@\n", [self.fullAppList objectForKey:self.fullAppList][i]];
        //Add the string of application names to the copied all string
        copiedAllString = [copiedAllString stringByAppendingString:allNames];
        //Create the string of all application bundle IDs
        NSString *allBundles = [NSString stringWithFormat:@"%@\n", self.identifiers[i]];
        //Add the string of application bundle IDs to the copied all string
        copiedAllString = [copiedAllString stringByAppendingString:allBundles];
    }
    
    //copy all bundle IDs to clipboard
    [UIPasteboard generalPasteboard].string = copiedAllString;

}

@end
