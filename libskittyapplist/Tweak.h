// Tweak.h

CFNotificationCenterRef CFNotificationCenterGetDistributedCenter(void);

@interface UIImage (Spectrum)
+ (id)_applicationIconImageForBundleIdentifier:(id)arg1 format:(int)arg2 scale:(double)arg3;
@end

@interface SBApplication : NSObject
@property (nonatomic, retain) NSString *displayName;
@property (nonatomic, retain) NSString *bundleIdentifier;
@end

@interface SBApplicationController : NSObject
+ (id)sharedInstance;
- (id)allApplications;
- (id)allBundleIdentifiers;
- (id)runningApplications;
@end

@interface SBIconView : UIView
@end
