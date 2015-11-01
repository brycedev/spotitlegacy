@interface SpotitTableViewController : UITableViewController < UITableViewDataSource, UITableViewDelegate, UIViewControllerPreviewingDelegate>

@property(retain, nonatomic) NSArray *items;
@property(nonatomic, strong) id previewingContext;

@end
