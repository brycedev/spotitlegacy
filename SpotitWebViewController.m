#import "SpotitWebViewController.h"

@implementation SpotitWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //hi
}

- (NSArray *)previewActionItems {

    UIPreviewAction *action1 = [UIPreviewAction actionWithTitle:@"Visit Source" style: UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        //NSString *url = [[self urls] objectAtIndex: 0];
    }];

    UIPreviewAction *action2 = [UIPreviewAction actionWithTitle:@"Visit Thread" style: UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        //NSString *url = [[self urls] objectAtIndex: 1];
    }];

    return @[action1, action2];

}

@end
