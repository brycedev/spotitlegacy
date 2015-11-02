#import "BDSettingsManager.h"

@implementation BDSettingsManager

+ (instancetype)sharedManager {
    static dispatch_once_t p = 0;
    __strong static id _sharedSelf = nil;
    dispatch_once(&p, ^{
        _sharedSelf = [[self alloc] init];
    });
    return _sharedSelf;
}

void prefschanged(CFNotificationCenterRef center, void * observer, CFStringRef name, const void * object, CFDictionaryRef userInfo) {
    [[BDSettingsManager sharedManager] updateSettings];
}

- (id)init {
    if (self = [super init]) {
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, prefschanged, CFSTR("com.brycedev.spotit/prefschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
        [self updateSettings];
    }
    return self;
}

- (void)updateSettings {
    self.settings = nil;
    CFPreferencesAppSynchronize(CFSTR("com.brycedev.spotit"));
    CFStringRef appID = CFSTR("com.brycedev.spotit");
    CFArrayRef keyList = CFPreferencesCopyKeyList(appID , kCFPreferencesCurrentUser, kCFPreferencesAnyHost) ?: CFArrayCreate(NULL, NULL, 0, NULL);
    self.settings = (NSDictionary *)CFPreferencesCopyMultiple(keyList, appID , kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    CFRelease(keyList);
}

- (BOOL)enabled {
    return self.settings[@"enabled"] ? [self.settings[@"enabled"] boolValue] : YES;
}

- (BOOL)removeApple {
    return self.settings[@"removeApple"] ? [self.settings[@"removeApple"] boolValue] : YES;
}

- (NSString *)subreddit {
    return self.settings[@"subreddit"] ? self.settings[@"subreddit"] : @"jailbreak";
}

- (NSString *)sort {
    NSInteger val = self.settings[@"sort"] ? [self.settings[@"sort"] integerValue] : 0;
    if(val == 0){
        return @"hot";
    }
    if(val == 1){
        return @"top";
    }
    if(val == 2){
        return @"new";
    }
    return @"hot";
}

- (NSInteger)count {
    return self.settings[@"count"] ? [self.settings[@"count"] integerValue] : 25;
}

- (NSInteger)refresh {
    return self.settings[@"refresh"] ? [self.settings[@"refresh"] integerValue] : 15;
}

- (BOOL)removeBlur {
    return self.settings[@"removeBlur"] ? [self.settings[@"removeBlur"] boolValue] : NO;
}

- (NSInteger)animationStyle {
    return self.settings[@"animationStyle"] ? [self.settings[@"animationStyle"] integerValue] : 25;
}

@end
