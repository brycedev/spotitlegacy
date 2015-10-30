#import "SpotitTableViewController.h"
#import "SpotitObject.h"

@implementation SpotitTableViewController

- (void)viewDidLoad {

    _items = nil;

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    HBLogInfo(@"there are now %i items", (int)[_items count]);
    return [_items count];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    SpotitObject *obj = [_items objectAtIndex: indexPath.row];

    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    [cell setBackgroundColor: [UIColor clearColor]];
    [cell setSelectionStyle: UITableViewCellSelectionStyleNone];

    [[cell.contentView layer] setCornerRadius: 10];
    [[cell.contentView layer] setMasksToBounds: YES];
    [[cell contentView] setFrame: CGRectMake(0, 0, tableView.frame.size.width * .8 / 2, 140 - 20)];
    [[cell contentView] setBackgroundColor: [UIColor whiteColor]];

    [[cell textLabel] setText: [obj threadTitle]];

    [cell setTag: indexPath.row];

    return cell;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {

    cell.alpha = 0;
    [UIView beginAnimations:@"fade" context:NULL];
    [UIView setAnimationDuration: .5];
    cell.alpha = 1;
    cell.layer.shadowOffset = CGSizeMake(0, 0);
    [UIView commitAnimations];

}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {

    return NO;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return 140;

}

@end
