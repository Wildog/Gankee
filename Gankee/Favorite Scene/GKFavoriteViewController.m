//
//  GKFavoriteViewController.m
//  Gankee
//
//  Created by Wildog on 1/31/17.
//  Copyright © 2017 Wildog. All rights reserved.
//

#import <RKDropdownAlert.h>
#import <SDImageCache.h>
#import "GKFavoriteViewController.h"
#import "GKFavoriteItem+CoreDataClass.h"
#import "GKSafariViewController.h"
#import "AppDelegate.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface GKFavoriteViewController () <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UISearchResultsUpdating>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *titleView;
@property (strong, nonatomic) IBOutlet UIButton *settingButton;
@property (weak, nonatomic) IBOutlet UILabel *noResultLabel;
@property (weak, nonatomic) IBOutlet UIView *alertView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *extendedTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *extendedBottomContraint;

@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@end

@implementation GKFavoriteViewController

#pragma mark Lazy Init

- (NSFetchedResultsController *)fetchedResultsController {
    if (!_fetchedResultsController) {
        _fetchedResultsController = [GKFavoriteItem MR_fetchAllSortedBy:@"added" ascending:NO withPredicate:nil groupBy:nil delegate:self];
    }
    return _fetchedResultsController;
}

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yy-M-d"];
    }
    return _dateFormatter;
}

#pragma mark Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.titleView = self.titleView;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.settingButton];
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.placeholder = @"搜索本地收藏";
    self.searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchController.searchBar.tintColor = [UIColor colorWithRed:0.08 green:0.58 blue:0.53 alpha:0.9];
    self.searchController.searchResultsUpdater = self;
    if (@available(iOS 11.0, *)) {
        self.navigationItem.searchController = self.searchController;
        self.topConstraint.active = self.bottomConstraint.active = NO;
        self.extendedTopConstraint.active = self.extendedBottomContraint.active = YES;
    } else {
        self.tableView.tableHeaderView = self.searchController.searchBar;
        self.searchController.searchBar.backgroundColor = [UIColor whiteColor];
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.topConstraint.active = self.bottomConstraint.active = YES;
        self.extendedTopConstraint.active = self.extendedBottomContraint.active = NO;
    }
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 80;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [NSFetchedResultsController deleteCacheWithName:nil];
    NSError *error;
    if (![self.fetchedResultsController performFetch:&error]) {
        [RKDropdownAlert title:@"出错了" message:error.localizedDescription];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self check3DTouch];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)unwindSceneViewController:(UIStoryboardSegue *)segue {
}

- (IBAction)settingButtonDidPress:(id)sender {
    UIAlertController *menu = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *rebuildSpotlight = [UIAlertAction actionWithTitle:@"重建 Spotlight 索引" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [[(AppDelegate *)[UIApplication sharedApplication].delegate indexer] indexExistingObjects:[GKFavoriteItem MR_findAll]];
    }];
    
    UIAlertAction *clearCache = [UIAlertAction actionWithTitle:@"清除图片缓存" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
            [RKDropdownAlert title:@"缓存清理完毕" backgroundColor:GOSSAMER textColor:[UIColor whiteColor]];
        }];
    }];
    
    UIAlertAction *review = [UIAlertAction actionWithTitle:@"给个评价" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSURL *url = [NSURL URLWithString:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1201113401&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software"];
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {}];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [menu addAction:rebuildSpotlight];
    [menu addAction:clearCache];
    [menu addAction:review];
    [menu addAction:cancel];
    [self presentViewController:menu animated:YES completion:nil];
}

#pragma mark TableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = [self.fetchedResultsController.sections[section] numberOfObjects];
    if (!self.fetchedResultsController.fetchRequest.predicate && count == 0) {
        self.alertView.hidden = NO;
    } else {
        self.alertView.hidden = YES;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GKFavoriteItem *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
    UITableViewCell *cell;
    if ([(NSArray *)item.images count] > 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"favorite_cell" forIndexPath:indexPath];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"favorite_cell_no_img" forIndexPath:indexPath];
    }
    [self configureCell:cell atIndexPath:indexPath];
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.94 alpha:1];
    cell.selectedBackgroundView = bgView;
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    GKFavoriteItem *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    UILabel *descLabel = (UILabel *)[cell viewWithTag:1];
    UILabel *authorLabel = (UILabel *)[cell viewWithTag:2];
    UILabel *timeLabel = (UILabel *)[cell viewWithTag:3];
    UILabel *categoryLabel = (UILabel *)[cell viewWithTag:4];
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:5];
    NSArray *images = (NSArray *)item.images;
    if (imageView && images.count > 0) {
        [imageView sd_setImageWithURL:images[0] placeholderImage:[UIImage imageNamed:@"placeholder"] options:SDWebImageProgressiveDownload];
    }
    
    [descLabel setText:item.desc];
    [authorLabel setText:item.author];
    [categoryLabel setText:item.category];
    if (!item.created) {
        [timeLabel setText:@"未知日期"];
    } else {
        [timeLabel setText:[self.dateFormatter stringFromDate:item.created]];
    }
}

#pragma mark TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GKSafariViewController *viewController = [[GKSafariViewController alloc] initWithFavoriteItem:[self.fetchedResultsController objectAtIndexPath:indexPath]];
    [self presentViewController:viewController animated:YES completion:nil];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"取消收藏" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        GKFavoriteItem *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
        /*
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            GKFavoriteItem *localItem = [item MR_inContext:localContext];
            [localItem MR_deleteEntity];
        }];
         */
        [item MR_deleteEntity];
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kTableViewUpdateNotif object:nil];
    }];
    return @[delete];
}

#pragma mark SearchResults Updater

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    [NSFetchedResultsController deleteCacheWithName:nil];
    NSPredicate *predicate = nil;
    if (searchController.searchBar.text.length > 0) {
        predicate = [NSPredicate predicateWithFormat:@"desc CONTAINS[cd] %@", searchController.searchBar.text];
    }
    self.fetchedResultsController.fetchRequest.predicate = predicate;
    NSError *error;
    if (![self.fetchedResultsController performFetch:&error]) {
        [RKDropdownAlert title:@"出错了" message:error.localizedDescription];
    } else {
        [self.tableView reloadData];
        if ([self.fetchedResultsController.sections[0] numberOfObjects] == 0
            && searchController.searchBar.text.length > 0) {
            self.noResultLabel.text = [NSString stringWithFormat:@"没有找到关于“%@”的结果", searchController.searchBar.text];
            self.noResultLabel.hidden = NO;
        } else {
            self.noResultLabel.hidden = YES;
        }
    }
}

#pragma mark FetchedResultsController Delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath]
                    atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

#pragma mark Previewing Delegate

- (void)check3DTouch {
    // register for 3d touch if available
    if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
        [self registerForPreviewingWithDelegate:(id)self sourceView:self.view];
    }
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    // 3d touch availability changed
    [self check3DTouch];
}

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    if ([self.presentationController isKindOfClass:[GKSafariViewController class]]) {
        return nil;
    }
    
    CGPoint cellPosition = [self.tableView convertPoint:location fromView:self.view];
    NSIndexPath *path = [self.tableView indexPathForRowAtPoint:cellPosition];
    
    if (path) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:path];
        previewingContext.sourceRect = [self.view convertRect:cell.frame fromView:self.tableView];
        
        GKSafariViewController *viewController = [[GKSafariViewController alloc] initWithFavoriteItem:[self.fetchedResultsController objectAtIndexPath:path]];
        
        return viewController;
    }
    return nil;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    [self presentViewController:viewControllerToCommit animated:YES completion:nil];
}

@end
