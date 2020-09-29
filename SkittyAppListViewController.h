// SkittyAppListViewController.h

#import <Preferences/PSViewController.h>
#import <UIKit/UIKit.h>

CFNotificationCenterRef CFNotificationCenterGetDistributedCenter(void);

@interface OBButtonTray : UIView
@property (nonatomic,retain) UIVisualEffectView * effectView;
- (void)addButton:(id)arg1;
- (void)addCaptionText:(id)arg1;;
@end

@interface OBBoldTrayButton : UIButton
-(void)setTitle:(id)arg1 forState:(unsigned long long)arg2;
+(id)buttonWithType:(long long)arg1;
@end

@interface OBWelcomeController : UIViewController
@property (nonatomic,retain) UIView * viewIfLoaded;
@property (nonatomic,strong) UIColor * backgroundColor;
-(void)set_shouldInlineButtontray:(BOOL)arg1 ;
- (OBButtonTray *)buttonTray;
- (id)initWithTitle:(id)arg1 detailText:(id)arg2 icon:(id)arg3;
- (void)addBulletedListItemWithTitle:(id)arg1 description:(id)arg2 image:(id)arg3;
@end

@interface UIView (Private)
@property (nonatomic, retain) UIVisualEffectView *effectView1;
@end

@interface UINavigationBar (Private)
@property (nonatomic, retain) UIView *backgroundView;
@end

@interface SkittyAppListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate, UISearchBarDelegate>
@property (nonatomic, retain) UIColor *labelDynamicColor;
@property (nonatomic, retain) UIColor *backgroundDynamicColor;
@property (nonatomic, retain) OBWelcomeController *bundleidController;
@property (nonatomic, retain) OBWelcomeController *copyallController;
@property (nonatomic, retain) OBBoldTrayButton* continueButtonTint;
@property (nonatomic, retain) OBBoldTrayButton* continueButtonTint2;
@property (nonatomic, retain) UIColor *tableDynamicColor;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) UISearchController *searchController;
@property (nonatomic, retain) UINavigationBar *navigationBar;
@property (nonatomic, retain) UIVisualEffect *blurEffect;
@property (nonatomic, retain) NSDictionary *fullAppList;
@property (nonatomic, retain) NSDictionary *appList;
@property (nonatomic, retain) NSArray *preferencesAppList;
@property (nonatomic, retain) NSArray *supportedIdentifiers;
@property (nonatomic, retain) NSArray *unsupportedIdentifiers;
@property (nonatomic, retain) NSArray *identifiers;
@property (nonatomic, retain) NSArray *supportedApps;
- (void)recieveAppList:(NSDictionary *)appList;

@end

@interface UIImage (Private)
+ (id)_applicationIconImageForBundleIdentifier:(id)identifier format:(int)format scale:(int)scale;
@end
