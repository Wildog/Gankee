//
//  GKSearchViewController.m
//  Gankee
//
//  Created by Wildog on 1/30/17.
//  Copyright © 2017 Wildog. All rights reserved.
//

#import <MKDropdownMenu.h>
#import <Masonry.h>
#import <RKDropdownAlert.h>
#import <UIScrollView+InfiniteScroll.h>
#import "GKSearchViewController.h"
#import "GKResultTableViewModel.h"
#import "GKSafariViewController.h"
#import "GKPieView.h"

@interface GKSearchViewController () <MKDropdownMenuDataSource, MKDropdownMenuDelegate, UITableViewDelegate, UIViewControllerPreviewingDelegate>

@property (strong, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet MKDropdownMenu *menu;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *noResultLabel;

@property (strong, nonatomic) GKResultTableViewModel *viewModel;
@property (strong, nonatomic) GKPieView *pieView;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSArray *categories;

@end

@implementation GKSearchViewController

- (GKResultTableViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[GKResultTableViewModel alloc] initWithItems:@[] category:GKCategoryAll pageSize:15 cellIdentifier:@"result_cell_with_tag" configureCellBlock:^(id cell, GKItem *item) {
            UILabel *descLabel = (UILabel *)[cell viewWithTag:1];
            UILabel *authorLabel = (UILabel *)[cell viewWithTag:2];
            UILabel *timeLabel = (UILabel *)[cell viewWithTag:3];
            UILabel *categoryLabel = (UILabel *)[cell viewWithTag:4];
            
            [descLabel setText:item.desc];
            [authorLabel setText:item.author];
            [categoryLabel setText:item.category];
            if (!item.published) {
                [timeLabel setText:@"未知日期"];
            } else {
                [timeLabel setText:[self.dateFormatter stringFromDate:item.published]];
            }
        } altCellIdentifier:@"result_cell" altConfigureCellBlock:^(id cell, GKItem *item) {
            UILabel *descLabel = (UILabel *)[cell viewWithTag:1];
            UILabel *authorLabel = (UILabel *)[cell viewWithTag:2];
            UILabel *timeLabel = (UILabel *)[cell viewWithTag:3];
            
            [descLabel setText:item.desc];
            [authorLabel setText:item.author];
            if (!item.published) {
                [timeLabel setText:@"未知日期"];
            } else {
                [timeLabel setText:[self.dateFormatter stringFromDate:item.published]];
            }
        }];
    }
    return _viewModel;
}

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"M-d"];
    }
    return _dateFormatter;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.titleView = self.titleView;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.categories = @[@"全部分类", @"iOS", @"Android", @"App", @"前端", @"瞎推荐", @"拓展资源", @"休息视频", @"福利"];
    self.menu.dataSource = self;
    self.menu.delegate = self;
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 80;
    self.tableView.dataSource = self.viewModel;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.infiniteScrollIndicatorMargin = 22;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.tabBarController.tabBar.transform = CGAffineTransformMakeTranslation(0, self.tabBarController.tabBar.frame.size.height);
    }];
    self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.textField becomeFirstResponder];
    
    @weakify(self)
    [[[[[[[self.textField.rac_textSignal deliverOnMainThread] distinctUntilChanged] doNext:^(NSString * _Nullable x) {
        if (x.length == 0) {
            self.noResultLabel.hidden = YES;
            self.tableView.hidden = YES;
            [self.pieView.pieLayer removeAllAnimations];
            [self.pieView removeFromSuperview];
        } else {
            if (![_pieView isDescendantOfView:self.view]) {
                [self setupLoadingView];
            }
        }
    }] throttle:0.5] filter:^BOOL(NSString * _Nullable value) {
        return value.length > 0;
    }] deliverOnMainThread] subscribeNext:^(NSString * _Nullable x) {
        @strongify(self)
        self.viewModel.search = x;
        self.viewModel.currentPage = 1;
        [[[self.viewModel moreItemsSignal] deliverOnMainThread] subscribeNext:^(id  _Nullable x) {
        } error:^(NSError * _Nullable error) {
            [self displayAlertWithError:error];
        } completed:^{
            [self.pieView.pieLayer removeAllAnimations];
            [self.pieView removeFromSuperview];
            self.tableView.hidden = NO;
            [self.tableView reloadData];
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }];
    }];
    
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
        //return !tableView.refreshControl.refreshing;
        return !self.viewModel.noMoreResults && self.viewModel.items.count >= self.viewModel.pageSize;
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.textField resignFirstResponder];
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
    self.noResultLabel.hidden = YES;
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
        BOOL shouldHidden = NO;
        
        if (error.code == -42 && [error.domain isEqualToString:@"GKErrorDomain"]) {
            [RKDropdownAlert title:@"提示" message:@"没有更多结果了" backgroundColor:[UIColor colorWithRed:0.08 green:0.58 blue:0.53 alpha:1] textColor:[UIColor whiteColor]];
        } else if (error.code == -43 && [error.domain isEqualToString:@"GKErrorDomain"]) {
            shouldHidden = YES;
            self.noResultLabel.text = [NSString stringWithFormat:@"没有找到关于“%@”的结果", self.viewModel.search];
            self.noResultLabel.hidden = NO;
        } else {
            [RKDropdownAlert title:@"出错了，刷新试试" message:[error localizedDescription]];
        }
        
        [self.pieView.pieLayer removeAllAnimations];
        [self.pieView removeFromSuperview];
        self.tableView.hidden = shouldHidden;
    });
}

#pragma mark Dropdown Menu DataSource

- (NSInteger)numberOfComponentsInDropdownMenu:(MKDropdownMenu *)dropdownMenu {
    return 1;
}

- (NSInteger)dropdownMenu:(MKDropdownMenu *)dropdownMenu numberOfRowsInComponent:(NSInteger)component {
    return self.categories.count;
}

- (NSAttributedString *)dropdownMenu:(MKDropdownMenu *)dropdownMenu attributedTitleForComponent:(NSInteger)component {
    NSString *title = self.categories[self.viewModel.category];
    return [[NSAttributedString alloc] initWithString:title
                                           attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17],
                                                        NSForegroundColorAttributeName: self.navigationController.navigationBar.tintColor}];
}

- (NSAttributedString *)dropdownMenu:(MKDropdownMenu *)dropdownMenu attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    UIColor *color = nil;
    if (row == self.viewModel.category) {
        color = self.navigationController.navigationBar.tintColor;
    } else {
        color = [UIColor blackColor];
    }
    
    NSString *title = self.categories[row];
    return [[NSAttributedString alloc] initWithString:title
                                           attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15],
                                                        NSForegroundColorAttributeName: color}];
}

- (void)dropdownMenu:(MKDropdownMenu *)dropdownMenu didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (self.viewModel.category == row) {
        [dropdownMenu closeAllComponentsAnimated:YES];
        return;
    }
    self.viewModel.category = row;
    [dropdownMenu reloadAllComponents];
    [dropdownMenu closeAllComponentsAnimated:YES];
    if (self.viewModel.search.length > 0) {
        [self setupLoadingView];
        self.viewModel.currentPage = 1;
        [[[self.viewModel moreItemsSignal] deliverOnMainThread] subscribeNext:^(id  _Nullable x) {
        } error:^(NSError * _Nullable error) {
            [self displayAlertWithError:error];
        } completed:^{
            [self.pieView.pieLayer removeAllAnimations];
            [self.pieView removeFromSuperview];
            self.tableView.hidden = NO;
            [self.tableView reloadData];
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }];
    }
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
