#import "BDSettingsManager.h"
#import "SpotitTableViewController.h"
#import "SpotitWebViewController.h"
#import "SpotitObject.h"
#import <SafariServices/SafariServices.h>

UIImageOrientation scrollOrientation;
CGPoint lastPos;

@implementation SpotitTableViewController

- (void)viewDidLoad {
    _items = nil;
    if([self.traitCollection respondsToSelector:@selector(forceTouchCapability)]) {
        _previewingContext = [self registerForPreviewingWithDelegate: self sourceView: self.view];
    }
}

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location{
    CGPoint position = [self.tableView convertPoint: location fromView: self.view];
    NSIndexPath *path = [self.tableView indexPathForRowAtPoint: position];
    if (path) {
        SpotitWebViewController *sfvc = [[SpotitWebViewController alloc] initWithURL: [NSURL URLWithString: [[_items objectAtIndex: path.row] valueForKey: @"threadUrl"]]];
    	return sfvc;
    }
    return nil;
}

- (void)previewingContext:(id )previewingContext commitViewController: (UIViewController *)viewControllerToCommit {
    [self presentViewController: viewControllerToCommit animated: YES completion: nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SpotitObject *obj = [_items objectAtIndex: indexPath.row];
    CGFloat rowWidth = [[UIScreen mainScreen] bounds].size.width * .9;
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: @"Cell"];
    [cell setBackgroundColor: [UIColor clearColor]];
    [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
    UIView *cview = [[UIView alloc] initWithFrame: CGRectMake(([[UIScreen mainScreen] bounds].size.width - rowWidth) / 2, 0, rowWidth, 100)];
    [[cview layer] setMasksToBounds: YES];
    [[cview layer] setCornerRadius: 10];
    [cell.contentView addSubview: cview];
    UIBlurEffect * effect = [UIBlurEffect effectWithStyle: [[BDSettingsManager sharedManager] removeBlur] ? UIBlurEffectStyleDark : UIBlurEffectStyleLight];
    UIVisualEffectView * ev = [[UIVisualEffectView alloc] initWithEffect: effect];
    [ev setFrame: [cview bounds]];
    [cview addSubview: ev];
    UIImageView *thumbnailView = [[UIImageView alloc] initWithFrame: CGRectMake(10, 10, 80, 80)];
    [[thumbnailView layer] setMasksToBounds: YES];
    [[thumbnailView layer] setCornerRadius: 10];
    [cview addSubview: thumbnailView];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSURL *url = [NSURL URLWithString: [obj valueForKey: @"threadThumbnail"]];
        NSData *data = [NSData dataWithContentsOfURL: url];
        UIImage *img = [[UIImage alloc] initWithData: data];
        UIGraphicsBeginImageContext(CGSizeMake(1,1));
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), [img CGImage]);
        UIGraphicsEndImageContext();
        dispatch_sync(dispatch_get_main_queue(), ^{
            [thumbnailView setImage: img];
        });
    });
    UILabel *titleLabel = [[UILabel alloc] initWithFrame: CGRectMake(100, 10, rowWidth - 150, 65)];
    [titleLabel setNumberOfLines: 3];
    [titleLabel setTextColor: [UIColor whiteColor]];
    [titleLabel setFont: [UIFont systemFontOfSize: 14]];
    [titleLabel setText: [obj valueForKey: @"threadTitle"]];
    [titleLabel sizeToFit];
    [ev addSubview: titleLabel];
    UILabel *footerLabel = [[UILabel alloc] initWithFrame: CGRectMake(100, 70, rowWidth - 150, 20)];
    [footerLabel setNumberOfLines: 1];
    [footerLabel setTextColor: [UIColor whiteColor]];
    [footerLabel setFont: [UIFont systemFontOfSize: 12]];
    [footerLabel setText: [obj valueForKey: @"threadFooter"]];
    [footerLabel sizeToFit];
    [ev addSubview: footerLabel];
    UILabel *scoreLabel = [[UILabel alloc] initWithFrame: CGRectMake(rowWidth - 40, ev.center.y - 10, rowWidth - 165, 20)];
    [scoreLabel setNumberOfLines: 1];
    [scoreLabel setTextColor: [UIColor whiteColor]];
    [scoreLabel setFont: [UIFont systemFontOfSize: 12]];
    [scoreLabel setText: [obj valueForKey: @"threadScore"]];
    [scoreLabel sizeToFit];
    [ev addSubview: scoreLabel];
    [cell setTag: indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if([[BDSettingsManager sharedManager] animationStyle] > 0){
        if([[BDSettingsManager sharedManager] animationStyle] == 1){
            // animation style #1 || credit to ths gist : https://gist.github.com/RebornSoul/8123997
            if (tableView.isDragging) {
                UIView *myView = cell.contentView;
                CALayer *layer = myView.layer;
                CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
                rotationAndPerspectiveTransform.m34 = 1.0 / -1000;
                if (scrollOrientation == UIImageOrientationDown) {
                    rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, M_PI*0.5, 1.0f, 0.0f, 0.0f);
                } else {
                    rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, -M_PI*0.5, 1.0f, 0.0f, 0.0f);
                }
                layer.transform = rotationAndPerspectiveTransform;
                [UIView animateWithDuration: .4 animations:^{
                    layer.transform = CATransform3DIdentity;
                }];
            }
        } else if([[BDSettingsManager sharedManager] animationStyle] == 2){
            cell.alpha = 0;
            [UIView beginAnimations:@"fade" context:NULL];
            [UIView setAnimationDuration: .5];
            cell.alpha = 1;
            cell.layer.shadowOffset = CGSizeMake(0, 0);
            [UIView commitAnimations];
        }
    }
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    if([[BDSettingsManager sharedManager] animationStyle] == 1){
        scrollOrientation = scrollView.contentOffset.y > lastPos.y?UIImageOrientationDown:UIImageOrientationUp;
        lastPos = scrollView.contentOffset;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120;
}

@end
