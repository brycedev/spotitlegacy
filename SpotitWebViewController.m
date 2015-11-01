#import "SpotitWebViewController.h"

@implementation SpotitWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //hi
}

- (NSArray *)previewActionItems {

    UIPreviewAction *action1 = [UIPreviewAction actionWithTitle:@"this does nothing yet" style: UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {

    }];

    return @[action1];

}

@end
