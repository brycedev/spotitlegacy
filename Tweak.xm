#import "SpotitObject.h"
#import "SpotitTableViewController.h"
#import "BDSettingsManager.h"
#import <SafariServices/SafariServices.h>
#import <objc/runtime.h>

@interface SPSearchResult : NSObject
@property (assign) NSString *title;
@property (assign) NSString *summary;
@property (assign) NSString *subtitle;
@property (assign) NSString *footnote;
@property (assign) NSString *url;
@property (assign) NSUInteger score;
@property (assign, readonly) NSMutableDictionary *additionalPropertyDict;
@end

@interface SPSearchResult (TB)
- (NSString *)body;
- (void)setBody:(id)body;
@end

SpotitTableViewController *vc;
UITableView *tv;

BOOL didPullToRefresh;

void fetchFeedSpotitOnly() {
    NSMutableArray *objs = [[NSMutableArray alloc] init];
    NSString *subreddit = [[[BDSettingsManager sharedManager] subreddit] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *sort = [[BDSettingsManager sharedManager] sort];
    NSInteger count = [[BDSettingsManager sharedManager] count];
    NSString *theUrl = [NSString stringWithFormat: @"https://www.reddit.com/r/%@/%@.json?limit=%ld", subreddit, sort, (long)count];
    HBLogInfo(@"attempting to download spotit json feed");
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL: [NSURL URLWithString: theUrl]];
    __block NSDictionary *json;
    [NSURLConnection sendAsynchronousRequest:request
    queue:[NSOperationQueue mainQueue]
    completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if(error == nil){
            HBLogInfo(@"successfully retrieved spotit json feed");
            json = [NSJSONSerialization JSONObjectWithData: data options: 0 error: nil];
            for(id key in [[json valueForKey: @"data"] valueForKey: @"children"]){
                SpotitObject *nSo = [[SpotitObject alloc] init];
                [nSo setThreadScore: [NSString stringWithFormat: @"%@", (NSString*)[[key valueForKey:@"data"] valueForKey:@"score"]]];
                [nSo setThreadTitle: [[key valueForKey:@"data"] valueForKey:@"title"]];
                [nSo setThreadDescription: [[key valueForKey:@"data"] valueForKey:@"selftext"]];
                [nSo setPreviewUrl: [[key valueForKey:@"data"] valueForKey:@"url"]];
                [nSo setThreadUrl: [[key valueForKey:@"data"] valueForKey:@"permalink"]];
                [nSo setThreadThumbnail: [[key valueForKey:@"data"] valueForKey:@"thumbnail"]];
                [nSo setThreadFooter: [NSString stringWithFormat:@"%@ // %@", [[key valueForKey:@"data"] valueForKey:@"subreddit"], [[key valueForKey:@"data"] valueForKey:@"author"]]];
                [objs addObject: nSo];
            }
            [vc setItems: [[NSArray alloc] initWithArray: objs]];
            [tv reloadData];
            if(didPullToRefresh){
                tv.alpha = 0;
                [UIView beginAnimations:@"fade" context:NULL];
                [UIView setAnimationDuration: .5];
                tv.alpha = 1;
                tv.layer.shadowOffset = CGSizeMake(0, 0);
                [UIView commitAnimations];
                didPullToRefresh = NO;
            }
        } else {
            HBLogError(@"could not fetch spotit feed. check your internet connection or your subreddit settings: %@", error);
        }
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, [[BDSettingsManager sharedManager] refresh] * NSEC_PER_SEC * 60), dispatch_get_main_queue(), ^{
        fetchFeedSpotitOnly();
    });
}

void refreshFeed(CFNotificationCenterRef center, void * observer, CFStringRef name, const void * object, CFDictionaryRef userInfo){
    didPullToRefresh = YES;
    fetchFeedSpotitOnly();
}
//////////////////////////////////////////
%group iOS9SpotitOnly
//////////////////////////////////////////
%hook SpringBoard

-(void)applicationDidFinishLaunching:(id)application {
    %orig;
    fetchFeedSpotitOnly();
}

%end

%hook SBSearchBlurEffectView

- (void)layoutSubviews {
    %orig;
    if([[BDSettingsManager sharedManager] removeBlur]){
        [self setHidden: YES];
    }
}

%end

%hook SPUINavigationBar

- (void)layoutSubviews {
    %orig;
    [self setHidden: YES];
}

%end

%hook SPUINavigationController

- (id)initWithRootViewController:(id)arg1 {
    vc = [[SpotitTableViewController alloc] init];
    [vc.view setBackgroundColor: [UIColor clearColor]];
    tv = [vc tableView];
    [tv setSeparatorStyle: UITableViewCellSeparatorStyleNone];
    [tv setDataSource: vc];
    [tv setDelegate: vc];
    [tv setShowsVerticalScrollIndicator: NO];
	return %orig(vc);
}

%end
//////////////////////////////////////////
%end //iOS9SpotitOnly
//////////////////////////////////////////

//////////////////////////////////////////
%group iOS9Spotit
//////////////////////////////////////////


NSMutableArray *objs;
id previewingContext;

@interface SearchUISingleResultTableViewCell : NSObject
- (id)initWithResult:(id)result style:(unsigned long)style;
- (void)updateWithResult:(id)result;
@property (assign) id result;
@end



@implementation SPSearchResult (TB)
- (NSString *)body {
    return [self additionalPropertyDict][@"descriptions"][0][@"formatted_text"][0][@"text"];
}
- (void)setBody:(id)body {
    if ([self additionalPropertyDict][@"descriptions"][0][@"formatted_text"][0])
        [self additionalPropertyDict][@"descriptions"][0][@"formatted_text"][0][@"text"] = body;
    else {
        NSMutableDictionary *dict = [@{@"descriptions": @[@{@"formatted_text": @[[NSMutableDictionary new]]}]} mutableCopy];
        dict[@"descriptions"][0][@"formatted_text"][0][@"text"] = body;
        [self setValue:dict forKey:@"additionalPropertyDict"];
    }
}
@end

@interface SPUISearchViewController : UIViewController <UIViewControllerPreviewingDelegate>
- (id)searchTableView;
- (BOOL)_isPullDownSpotlight;
@end
@interface SPUISearchViewController (TB)
- (NSArray *)links;
- (void)setLinks:(NSArray *)links;
@end
@implementation SPUISearchViewController (TB)
- (NSArray *)links {
return objc_getAssociatedObject(self, @selector(links));
}
- (void)setLinks:(NSArray *)links {
objc_setAssociatedObject(self, @selector(links), links, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)loadRedditData {
	objs = [[NSMutableArray alloc] init];
    NSString *subreddit = [[[BDSettingsManager sharedManager] subreddit] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *sort = [[BDSettingsManager sharedManager] sort];
    NSInteger count = [[BDSettingsManager sharedManager] count];
    NSString *theUrl = [NSString stringWithFormat: @"https://www.reddit.com/r/%@/%@.json?limit=%ld", subreddit, sort, (long)count];
    HBLogInfo(@"attempting to download spotit json feed");
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL: [NSURL URLWithString: theUrl]];
    __block NSDictionary *json;
    [NSURLConnection sendAsynchronousRequest:request
    queue:[NSOperationQueue mainQueue]
    completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if(error == nil){
            HBLogInfo(@"successfully retrieved spotit json feed");
            json = [NSJSONSerialization JSONObjectWithData: data options: 0 error: nil];
            for(id key in [[json valueForKey: @"data"] valueForKey: @"children"]){
                SPSearchResult *nSo = [SPSearchResult new];
                //[nSo setThreadScore: [NSString stringWithFormat: @"%@", (NSString*)[[key valueForKey:@"data"] valueForKey:@"score"]]];
                [nSo setTitle: [[key valueForKey:@"data"] valueForKey:@"title"]];
				if([[[key valueForKey:@"data"] valueForKey:@"selftext"] length] > 140){
					[nSo setBody: [[[key valueForKey:@"data"] valueForKey:@"selftext"] substringToIndex: 140]];
				}else{
					[nSo setBody: [[key valueForKey:@"data"] valueForKey:@"selftext"]];
				}
				if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"alienblue:"]]){
			        [nSo setUrl: [NSString stringWithFormat: @"alienblue://thread/https://reddit.com%@", [[key valueForKey:@"data"] valueForKey:@"permalink"]]];
					HBLogInfo(@"cna open alienblue");
			    }else{
			        [nSo setUrl: [NSString stringWithFormat: @"https://reddit.com%@", [[key valueForKey:@"data"] valueForKey:@"permalink"]]];
			    }
                //[nSo setUrl: [NSString stringWithFormat: @"%@", [[key valueForKey:@"data"] valueForKey:@"url"]]];
                //[nSo setUrl: [[key valueForKey:@"data"] valueForKey:@"permalink"]];
                //[nSo setThreadThumbnail: [[key valueForKey:@"data"] valueForKey:@"thumbnail"]];
                [nSo setFootnote: [NSString stringWithFormat:@"%@ // %@", [[key valueForKey:@"data"] valueForKey:@"subreddit"], [[key valueForKey:@"data"] valueForKey:@"author"]]];
                [objs addObject: nSo];
            }
			[self setLinks: [objs copy]];
			[[self searchTableView] reloadData];
        } else {
            HBLogError(@"could not fetch spotit feed. check your internet connection or your subreddit settings: %@", error);
        }
    }];
}
@end

%hook SPUISearchViewController

- (void)viewDidLoad {
    if([self.traitCollection respondsToSelector:@selector(forceTouchCapability)]) {
        [self registerForPreviewingWithDelegate: self sourceView: self.view];
    }
}

- (void)setTableViewShown:(BOOL)v {
    %orig(v);
    if (v) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self loadRedditData];
            });
        });
    }
}

- (NSArray *)resultsForRow:(NSInteger)row inSection:(NSInteger)section {
	if(section == 1){HBLogInfo(@"results : %@", %orig);}
    if (section != 2) return %orig(row, section);
    return @[[self links][row]];
}

- (NSInteger)numberOfSectionsInTableView:(id)tv {
    return [self _isPullDownSpotlight] && [[self links] count] > 0 ? %orig(tv) : 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 2) return [[self links] count];
    return %orig(tableView, section);
}

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location{
    CGPoint position = [[self searchTableView] convertPoint: location fromView: self.view];
    NSIndexPath *path = [[self searchTableView] indexPathForRowAtPoint: position];
	HBLogInfo(@"cell attempted was : %@", [objs objectAtIndex: path.row]);
    if (path) {
        SFSafariViewController *sfvc = [[SFSafariViewController alloc] initWithURL: [NSURL URLWithString: [[objs objectAtIndex: path.row] valueForKey: @"previewUrl"]]];
    	return sfvc;
    }
    return nil;
}

- (void)previewingContext:(id )previewingContext commitViewController: (UIViewController *)viewControllerToCommit {
    [self presentViewController: viewControllerToCommit animated: YES completion: nil];
}

%end


%hook SearchUITextAreaView

- (BOOL)updateWithResult:(SPSearchResult *)result formatter:(id)f {
    BOOL ret = %orig(result, f);
    UILabel *body = [[self valueForKey:@"secondToLastView"] valueForKey:@"textLabel"];
    [body setText:[result body]];
    return ret;
}

%end


//////////////////////////////////////////
%end //iOS9Spotit
//////////////////////////////////////////
%ctor {
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                NULL,
                                refreshFeed,
                                CFSTR("com.brycedev.spotit.pulltorefresh"),
                                NULL,
                                CFNotificationSuspensionBehaviorCoalesce);
    [BDSettingsManager sharedManager];
    //HBLogInfo(@"dumping the settings : %@", [[BDSettingsManager sharedManager] settings]);
    if([[BDSettingsManager sharedManager] enabled]){
        //HBLogInfo(@"spotit is enabled");
        if([[BDSettingsManager sharedManager] removeApple]){
            //HBLogInfo(@"spotit will use only mode");
            %init(iOS9SpotitOnly);
        } else {
            //HBLogInfo(@"spotit will keep apple features");
            %init(iOS9Spotit);
        }
    }
}
