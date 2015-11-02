#import "SpotitObject.h"
#import "SpotitTableViewController.h"
#import "BDSettingsManager.h"

SpotitTableViewController *vc;
UITableView *tv;

BOOL didPullToRefresh;

void fetchFeed() {
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
        fetchFeed();
    });
}

void refreshFeed(CFNotificationCenterRef center, void * observer, CFStringRef name, const void * object, CFDictionaryRef userInfo){
    didPullToRefresh = YES;
    fetchFeed();
}
//////////////////////////////////////////
%group iOS9
//////////////////////////////////////////
%hook SpringBoard

-(void)applicationDidFinishLaunching:(id)application {
    %orig;
    fetchFeed();
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
%end
//////////////////////////////////////////
%ctor {
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                NULL,
                                refreshFeed,
                                CFSTR("com.brycedev.spotit.pulltorefresh"),
                                NULL,
                                CFNotificationSuspensionBehaviorCoalesce);
    [BDSettingsManager sharedManager];
    if([[BDSettingsManager sharedManager] enabled]){
        %init(iOS9);
    }
}
