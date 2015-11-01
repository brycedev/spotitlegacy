@interface BDSettingsManager : NSObject

@property (nonatomic, copy) NSDictionary *settings;

@property (nonatomic, readonly, getter=enabled) BOOL enabled;
@property (nonatomic, readonly, getter=subreddit) NSString * subreddit;
@property (nonatomic, readonly, getter=sort) NSString *sort;
@property (nonatomic, readonly, getter=count) NSInteger count;
@property (nonatomic, readonly, getter=refresh) NSInteger refresh;
@property (nonatomic, readonly, getter=removeBlur) BOOL removeBlur;
@property (nonatomic, readonly, getter=animationStyle) NSInteger animationStyle;

+ (instancetype)sharedManager;
- (void)updateSettings;

@end
