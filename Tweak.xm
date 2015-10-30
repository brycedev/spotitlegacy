#import "Interfaces.h"
#import "SpotitObject.h"
#import "SpotitTableViewController.h"

SpotitTableViewController *vc;
UITableView *tv;
BOOL hideSearch = YES;
BOOL removeBlur = YES;
NSMutableArray *objs;
BOOL firstInitialization = YES;

%hook SpringBoard

-(void)applicationDidFinishLaunching:(id)application {
    %orig;
    objs = [[NSMutableArray alloc] init];
    HBLogInfo(@"downloading json");
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://www.reddit.com/r/jailbreak/new.json?sort=new"]];
    __block NSDictionary *json;
    [NSURLConnection sendAsynchronousRequest:request
        queue:[NSOperationQueue mainQueue]
        completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
           json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
           HBLogInfo(@"json dictionary class: %@", [json class]);
           for(id key in [[json valueForKey:@"data"] valueForKey:@"children"]){
               SpotitObject *nSo = [[SpotitObject alloc] init];
               [nSo setThreadTitle: [[key valueForKey:@"data"] valueForKey:@"title"]];
               [nSo setThreadDescription: [[key valueForKey:@"data"] valueForKey:@"selftext"]];
               [nSo setThreadUrl: [[key valueForKey:@"data"] valueForKey:@"url"]];
               [objs addObject: nSo];
           }
           HBLogInfo(@"reddit objects: %@", objs);
           [vc setItems: [[NSArray alloc] initWithArray: objs]];
           [tv reloadData];
    }];

}

%end

%hook SBSearchBlurEffectView

- (void)layoutSubviews {
    %orig;
    if(removeBlur){
        HBLogInfo(@"removing blur");
        [self setHidden: YES];
    }
}

%end

%hook SPUINavigationBar

- (void)layoutSubviews {
    %orig;
    if(hideSearch){
        HBLogInfo(@"removing spuinavigationbar");
        [self setHidden: YES];
    }
}

%end

%hook SPUINavigationController

- (id)initWithRootViewController:(id)arg1 {

	return %orig(vc);

}

%end

%ctor{

    vc = [[SpotitTableViewController alloc] init];
    [vc.view setBackgroundColor: [UIColor clearColor]];
    tv = [vc tableView];
    [tv setSeparatorStyle: UITableViewCellSeparatorStyleNone];
    [tv setDataSource: vc];
    [tv setDelegate: vc];

}
