//
//  GKCategoryTableViewController.m
//  Gankee
//
//  Created by Wildog on 1/28/17.
//  Copyright © 2017 Wildog. All rights reserved.
//

#import <RKDropdownAlert.h>
#import <Masonry.h>
#import <UIScrollView+InfiniteScroll.h>
#import "UIRefreshControl+UITableView.h"
#import "GKCategoryTableViewController.h"
#import "GKSafariViewController.h"
#import "GKPieView.h"

@interface GKCategoryTableViewController () <UITableViewDelegate, UIViewControllerPreviewingDelegate>

@property (nonatomic, strong) GKPieView *pieView;
@property (nonatomic, strong) GKResultTableViewModel *viewModel;
@property (nonatomic, strong) RACCommand *refreshControlCommand;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation GKCategoryTableViewController

#pragma mark lazy init

- (GKResultTableViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[GKResultTableViewModel alloc] initWithItems:@[] category:self.category pageSize:15 cellIdentifier:@"result_cell_with_tag" configureCellBlock:^(id cell, GKItem *item) {
            UILabel *descLabel = (UILabel *)[cell viewWithTag:1];
            UILabel *authorLabel = (UILabel *)[cell viewWithTag:2];
            UILabel *timeLabel = (UILabel *)[cell viewWithTag:3];
            UILabel *categoryLabel = (UILabel *)[cell viewWithTag:4];
            
            [descLabel setText:item.desc];
            [authorLabel setText:item.author];
            [categoryLabel setText:item.category];
            if (!item.created) {
                [timeLabel setText:@"未知日期"];
            } else {
                [timeLabel setText:[self.dateFormatter stringFromDate:item.created]];
            }
        } altCellIdentifier:@"result_cell" altConfigureCellBlock:^(id cell, GKItem *item) {
            UILabel *descLabel = (UILabel *)[cell viewWithTag:1];
            UILabel *authorLabel = (UILabel *)[cell viewWithTag:2];
            UILabel *timeLabel = (UILabel *)[cell viewWithTag:3];
            
            [descLabel setText:item.desc];
            [authorLabel setText:item.author];
            if (!item.created) {
                [timeLabel setText:@"未知日期"];
            } else {
                [timeLabel setText:[self.dateFormatter stringFromDate:item.created]];
            }
        }];
    }
    return _viewModel;
}

- (RACCommand *)refreshControlCommand {
    if (!_refreshControlCommand) {
        _refreshControlCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                self.viewModel.currentPage = 1;
                [[[self.viewModel moreItemsSignal] deliverOnMainThread] subscribeNext:^(id  _Nullable x) {
                } error:^(NSError * _Nullable error) {
                    [subscriber sendCompleted];
                    [self displayAlertWithError:error];
                } completed:^{
                    [subscriber sendCompleted];
                    [self.tableView reloadData];
                }];
                return nil;
            }];
        }];
    }
    
    return _refreshControlCommand;
}

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"M-d"];
    }
    return _dateFormatter;
}

#pragma mark life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupLoadingView];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 80;
    self.tableView.dataSource = self.viewModel;
    self.tableView.delegate = self;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor colorWithRed:0.078 green:0.580 blue:0.529 alpha:0.600];
    self.refreshControl.rac_command = self.refreshControlCommand;
    [self.refreshControl addToTableView:self.tableView];
    self.tableView.infiniteScrollIndicatorMargin = 22;
    
    @weakify(self)
    [self.tableView addInfiniteScrollWithHandler:^(UITableView * _Nonnull tableView) {
        @strongify(self)
        self.viewModel.currentPage += 1;
        //NSUInteger previousItemsCount = self.viewModel.items.count;
        
        [[self.viewModel.moreItemsSignal deliverOnMainThread] subscribeNext:^(id  _Nullable x) {
        } error:^(NSError * _Nullable error) {
            [tableView finishInfiniteScroll];
            [self displayAlertWithError:error];
        } completed:^{
            // buggy animation with self-sizing tableView,
            // insertRowsAtIndexPaths: doesn't recalculate contentSize, #31
            // use reloadData at the moment
            
            // NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:self.viewModel.pageSize];
            // NSUInteger indexPathsCount = self.viewModel.items.count - previousItemsCount;
            // for (NSUInteger i = 0; i < indexPathsCount; i++) {
            //     [indexPaths addObject:[NSIndexPath indexPathForRow:previousItemsCount+i inSection:0]];
            // }
            //[tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
            
            [tableView reloadData];
            [tableView finishInfiniteScroll];
        }];
    }];
    
    [self.tableView setShouldShowInfiniteScrollHandler:^BOOL(UITableView * _Nonnull tableView) {
        return !self.refreshControl.refreshing && !self.viewModel.noMoreResults;
    }];
    
    [[[self.viewModel moreItemsSignal] deliverOnMainThread] subscribeNext:^(id  _Nullable x) {
    } error:^(NSError * _Nullable error) {
        [self displayAlertWithError:error];
    } completed:^{
        [self.pieView.pieLayer removeAllAnimations];
        [self.pieView removeFromSuperview];
        self.tableView.hidden = NO;
        [self.tableView reloadData];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self check3DTouch];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupLoadingView {
    // setup loading view
    self.tableView.hidden = YES;
    if (!_pieView) {
        _pieView = [[GKPieView alloc] initWithFrame:CGRectMake(0, 0, 60, 60) startAngle:0 endAngle:270 fillColor:[UIColor clearColor] strokeColor:[UIColor colorWithRed:0.08 green:0.58 blue:0.53 alpha:1] strokeWidth:2];
    }
    [self.view addSubview:_pieView];
    [_pieView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.height.equalTo(@(60));
        make.width.equalTo(@(60));
    }];
    [_pieView startAnimating];
}

- (void)displayAlertWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error.code == -42 && [error.domain isEqualToString:@"GKErrorDomain"]) {
            [RKDropdownAlert title:@"解锁成就" message:[error localizedDescription] backgroundColor:[UIColor colorWithRed:0.16 green:0.73 blue:0.61 alpha:1] textColor:[UIColor whiteColor]];
        } else {
            [RKDropdownAlert title:@"出错了，刷新试试" message:[error localizedDescription]];
        }
        [self.pieView.pieLayer removeAllAnimations];
        [self.pieView removeFromSuperview];
        self.tableView.hidden = NO;
    });
}

#pragma mark TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GKSafariViewController *viewController = [[GKSafariViewController alloc] initWithItem:self.viewModel.items[indexPath.row]];
    [self presentViewController:viewController animated:YES completion:nil];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
        
        GKSafariViewController *viewController = [[GKSafariViewController alloc] initWithItem:self.viewModel.items[path.row]];
        
        return viewController;
    }
    return nil;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    [self presentViewController:viewControllerToCommit animated:YES completion:nil];
}

@end
