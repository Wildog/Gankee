//
//  FirstViewController.m
//  Gankee
//
//  Created by Wildog on 1/23/17.
//  Copyright © 2017 Wildog. All rights reserved.
//

#import "GKHomeViewController.h"
#import "GKHomeViewModel.h"
#import "GKSafariViewController.h"
#import "DIDatepicker.h"
#import "SDCycleScrollView.h"
#import "GKPieView.h"
#import "UIRefreshControl+UITableView.h"
#import "GKFavoriteHelper.h"
#import <RACEXTScope.h>
#import <RKDropdownAlert.h>
#import <Masonry.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface GKHomeViewController () <UITableViewDelegate, UIViewControllerPreviewingDelegate, SDCycleScrollViewDelegate>

@property (nonatomic, strong) GKHomeViewModel *viewModel;
@property (nonatomic, strong) RACCommand *refreshControlCommand;
@property (nonatomic, strong) RACCommand *toggleCalendarCommand;
@property (nonatomic, strong) RACCommand *showSearchCommand;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSDateFormatter *dateFormatterForBanner;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UIImageView *titleImageView;
@property (weak, nonatomic) IBOutlet UILabel *currentDayLabel;
@property (weak, nonatomic) IBOutlet DIDatepicker *datepicker;
@property (weak, nonatomic) IBOutlet UIButton *barButton;
@property (strong, nonatomic) IBOutlet UIButton *searchButton;
@property (nonatomic, strong) GKPieView *pieView;
@property (nonatomic, strong) SDCycleScrollView *cycleView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation GKHomeViewController

#pragma mark Lazy Init

- (GKHomeViewModel *)viewModel {
    if (!_viewModel) {
        @weakify(self)
        _viewModel = [[GKHomeViewModel alloc] initWithCellIdentifier:@"home_cell" configureCellBlock:^(UITableViewCell *cell, GKItem *item) {
            @strongify(self)
            UILabel *descLabel = (UILabel *)[cell viewWithTag:1];
            UILabel *authorLabel = (UILabel *)[cell viewWithTag:2];
            UILabel *timeLabel = (UILabel *)[cell viewWithTag:3];
            UIImageView *imageView = (UIImageView *)[cell viewWithTag:4];
            UIImageView *indicator = (UIImageView *)[cell viewWithTag:5];
            
            [descLabel setText:item.desc];
            [authorLabel setText:item.author];
            if (!item.created) {
                [timeLabel setText:@"未知日期"];
            } else {
                [timeLabel setText:[self.dateFormatter stringFromDate:item.created]];
            }
            
            [imageView sd_setImageWithURL:item.images[0] placeholderImage:[UIImage imageNamed:@"placeholder"] options:SDWebImageProgressiveDownload];
            
            GKFavoriteItem *favoriteItem = [GKFavoriteHelper fetchFavoriteItemFromItem:item];
            if (favoriteItem) {
                indicator.hidden = NO;
            } else {
                indicator.hidden = YES;
            }
        } altCellIdentifier:@"home_cell_no_img" altConfigureCellBlock:^(UITableViewCell *cell, GKItem *item) {
            @strongify(self)
            UILabel *descLabel = (UILabel *)[cell viewWithTag:1];
            UILabel *authorLabel = (UILabel *)[cell viewWithTag:2];
            UILabel *timeLabel = (UILabel *)[cell viewWithTag:3];
            UIImageView *indicator = (UIImageView *)[cell viewWithTag:4];
            
            [descLabel setText:item.desc];
            [authorLabel setText:item.author];
            if (!item.created) {
                [timeLabel setText:@"未知日期"];
            } else {
                [timeLabel setText:[self.dateFormatter stringFromDate:item.created]];
            }
            
            GKFavoriteItem *favoriteItem = [GKFavoriteHelper fetchFavoriteItemFromItem:item];
            if (favoriteItem) {
                indicator.hidden = NO;
            } else {
                indicator.hidden = YES;
            }
        }];
    }
    return _viewModel;
}

- (RACCommand *)refreshControlCommand {
    if (!_refreshControlCommand) {
        @weakify(self)
        _refreshControlCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            @strongify(self)
            // only update availableDays here
            [self.viewModel.availableDaysSignal subscribeNext:^(id  _Nullable x) {
            } error:^(NSError * _Nullable error) {
                [self.viewModel.allDataLoadedSignal sendCompleted];
                [self displayAlertWithError:error];
            } completed:^{
                // this will trigger subsequent signals to update the dataSource
                if (!self.viewModel.currentDay
                    || self.datepicker.dates.count != self.viewModel.availableDays.count) {
                    self.viewModel.currentDay = self.viewModel.availableDays[0];
                } else {
                    self.viewModel.currentDay = self.viewModel.currentDay;
                }
                [self.datepicker fillDatesFromArray:self.viewModel.availableDays];
            }];

            return self.viewModel.allDataLoadedSignal;
        }];
    }
    
    return _refreshControlCommand;
}

- (RACCommand *)toggleCalendarCommand {
    if (!_toggleCalendarCommand) {
        @weakify(self)
        _toggleCalendarCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            @strongify(self)
            if (self.datepicker.superview.hidden) {
                self.datepicker.superview.hidden = NO;
                [UIView animateWithDuration:0.3 animations:^{
                    self.datepicker.transform = CGAffineTransformMakeTranslation(0, self.datepicker.frame.size.height);
                } completion:^(BOOL finished) {
                }];
            } else {
                [UIView animateWithDuration:0.3 animations:^{
                    self.datepicker.transform = CGAffineTransformMakeTranslation(0, -self.datepicker.frame.size.height);
                } completion:^(BOOL finished) {
                    self.datepicker.superview.hidden = YES;
                }];
            }
            
            return [RACSignal empty];
        }];
    }
    
    return _toggleCalendarCommand;
}

- (RACCommand *)showSearchCommand {
    if (!_showSearchCommand) {
        @weakify(self)
        _showSearchCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            @strongify(self)
            [self.navigationController performSegueWithIdentifier:@"search_segue" sender:nil];
            return [RACSignal empty];
        }];
    }
    return _showSearchCommand;
}

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"M-d  H:mm"];
    }
    return _dateFormatter;
}

- (NSDateFormatter *)dateFormatterForBanner {
    if (!_dateFormatterForBanner) {
        _dateFormatterForBanner = [[NSDateFormatter alloc] init];
        [_dateFormatterForBanner setDateFormat:@"yyyy-M-d"];
    }
    return _dateFormatterForBanner;
}

#pragma mark Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // setup navigation item
    self.navigationItem.titleView = self.titleView;
    self.barButton.rac_command = self.toggleCalendarCommand;
    self.searchButton.rac_command = self.showSearchCommand;
    
    // setup tableView
    self.tableView.dataSource = self.viewModel.dataSource;
    self.tableView.delegate = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 80;
    [self setupLoadingView];
    
    // setup refreshControl
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor colorWithRed:0.078 green:0.580 blue:0.529 alpha:0.600];
    self.refreshControl.rac_command = self.refreshControlCommand;
    [self.refreshControl addToTableView:self.tableView];
    
    // setup banner cycleView
    self.cycleView = [[SDCycleScrollView alloc] initWithFrame:CGRectMake(0, 0, 0, 150)];
    self.cycleView.placeholderImage = [UIImage imageNamed:@"banner-placeholder"];
    self.cycleView.bannerImageViewContentMode = UIViewContentModeScaleAspectFill;
    self.cycleView.autoScrollTimeInterval = 4.0;
    self.cycleView.pageDotColor = [UIColor colorWithRed:0.25 green:0.39 blue:0.53 alpha:1];
    self.cycleView.currentPageDotColor = [UIColor colorWithRed:0.16 green:0.73 blue:0.61 alpha:1];
    self.cycleView.delegate = self;
    self.tableView.tableHeaderView = self.cycleView;
    
    // get availableDays
    [self.viewModel.availableDaysSignal subscribeNext:^(id x) {
    } error:^(NSError * _Nullable error) {
        [self displayAlertWithError:error];
    } completed:^{
        [self.datepicker fillDatesFromArray:self.viewModel.availableDays];
        self.viewModel.currentDay = self.viewModel.availableDays[0];
    }];
    
    // update dataSource and randomItems if currentDay changes and is valid
    @weakify(self)
    [[RACObserve(self.viewModel, currentDay) filter:^BOOL(NSString *value) {
        return (value.length > 0);
    }] subscribeNext:^(id x) {
        @strongify(self)
        [[[self.viewModel itemsForCurrentDaySignal] combineLatestWith:self.viewModel.randomItemsSignal] subscribeNext:^(id _Nullable x) {
        } error:^(NSError * _Nullable error) {
            [self.viewModel.allDataLoadedSignal sendCompleted];
            [self displayAlertWithError:error];
        } completed:^{
            // check if enough data
            if (self.viewModel.randomItems.count > 1) {
                NSMutableArray *imageURLStringsArray = [NSMutableArray arrayWithCapacity:5];
                NSMutableArray *descsArray = [NSMutableArray arrayWithCapacity:5];
                NSMutableArray *datesArray = [NSMutableArray arrayWithCapacity:5];
                NSMutableArray *categoriesArray = [NSMutableArray arrayWithCapacity:5];
                for (GKItem *item in self.viewModel.randomItems) {
                    NSString *urlString = [item imageURLStringForBanner];
                    [imageURLStringsArray addObject:urlString];
                    
                    NSString *desc = item.desc;
                    [descsArray addObject:desc];
                    
                    NSString *category = item.category ? item.category : @"未知分类";
                    [categoriesArray addObject:category];
                    
                    NSString *date = item.created ? [self.dateFormatterForBanner stringFromDate:item.created] : @"未知日期";
                    [datesArray addObject:date];
                }
                // reload tableView and cycleView
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.cycleView.descs = descsArray;
                    self.cycleView.categories = categoriesArray;
                    self.cycleView.dates = datesArray;
                    self.cycleView.imageURLStringsGroup = imageURLStringsArray;
                    [self.viewModel.allDataLoadedSignal sendCompleted];
                    [self.tableView reloadData];
                    [UIView animateWithDuration:0.1 animations:^{
                        self.pieView.alpha = 0;
                    } completion:^(BOOL finished) {
                        [self.pieView.pieLayer removeAllAnimations];
                        [self.pieView removeFromSuperview];
                    }];
                    [UIView animateWithDuration:0.2 animations:^{
                        self.tableView.alpha = 1;
                    } completion:nil];
                });
            } else {
                // if not enough randomItems to display, trigger signal to make an another request
                self.viewModel.currentDay = self.viewModel.currentDay;
            }
        }];
    }];
    
    // when datepicker's selectedDate changes, update currentDay to the corresponding string
    RAC(self.viewModel, currentDay) = [[[[self.datepicker rac_signalForControlEvents:UIControlEventValueChanged] map:^id _Nullable(__kindof UIControl * _Nullable value) {
        @strongify(self)
        return [[self.datepicker dateFormatter] stringFromDate:self.datepicker.selectedDate];
    }] filter:^BOOL(id  _Nullable value) {
        return (value) ? YES : NO;
    }] doNext:^(id  _Nullable x) {
        [self setupLoadingView];
    }];
    
    // animate titleView when currentDay changes for the first time
    RAC(self.currentDayLabel, text) = [[[RACObserve(self.viewModel, currentDay)
                                        filter:^BOOL(NSString *value) {
                                            return (value.length > 0);
                                        }] deliverOnMainThread]
                                        doNext:^(id x) {
                                            @strongify(self)
                                            if (self.currentDayLabel.alpha == 0) {
                                                // set datepicker's selected date,
                                                // this will not trigger control event
                                                [self.datepicker selectDateFromString:self.viewModel.currentDay];
                                                
                                                // add datepicker button
                                                self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.barButton];
                                                self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.searchButton];
                                                self.barButton.transform = self.searchButton.transform = CGAffineTransformMakeScale(0, 0);
                                                
                                                // animate button
                                                [UIView animateWithDuration:0.4 delay:0.3 usingSpringWithDamping:0.75 initialSpringVelocity:3 options:0 animations:^{
                                                    self.barButton.transform = self.searchButton.transform = CGAffineTransformIdentity;
                                                } completion:nil];
                                                
                                                // animate title
                                                [UIView animateWithDuration:0.5 animations:^{
                                                    self.titleImageView.transform = CGAffineTransformMakeTranslation(0, -11);
                                                    self.currentDayLabel.alpha = 1.0;
                                                }];
                                            }
                                        }];
    
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kTableViewUpdateNotif object:nil] takeUntil:[self rac_willDeallocSignal]] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        [self.tableView reloadData];
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [UIView animateWithDuration:0.2 animations:^{
        self.tabBarController.tabBar.transform = CGAffineTransformIdentity;
    } completion:nil];
    [self check3DTouch];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupLoadingView {
    // setup loading view
    self.tableView.alpha = 0;
    if (!_pieView) {
        _pieView = [[GKPieView alloc] initWithFrame:CGRectMake(0, 0, 60, 60) startAngle:0 endAngle:270 fillColor:[UIColor clearColor] strokeColor:GOSSAMER strokeWidth:2];
    }
    _pieView.alpha = 1;
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
        [RKDropdownAlert title:@"出错了，刷新试试" message:[error localizedDescription]];
        [UIView animateWithDuration:0.1 animations:^{
            self.pieView.alpha = 0;
        } completion:^(BOOL finished) {
            [self.pieView.pieLayer removeAllAnimations];
            [self.pieView removeFromSuperview];
        }];
        [UIView animateWithDuration:0.2 animations:^{
            self.tableView.alpha = 1;
        } completion:nil];
    });
}

#pragma mark tableView delegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *header = [[[NSBundle mainBundle] loadNibNamed:@"GKHomeSectionHeader" owner:self options:nil] objectAtIndex:0];
    [(UILabel *)[header viewWithTag:2] setText:self.viewModel.dataSource.dict[@"categories"][section]];
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 60.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GKSafariViewController *viewController = [[GKSafariViewController alloc] initWithItem:[self.viewModel.dataSource itemAtIndexPath:indexPath]];
    [self presentViewController:viewController animated:YES completion:nil];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark CycleView Delegate

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index {
    GKSafariViewController *viewController = [[GKSafariViewController alloc] initWithItem:self.viewModel.randomItems[index]];
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didScrollToIndex:(NSInteger)index {
    self.viewModel.currentRandomItemIndex = index;
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
    
    CGPoint cellPosition = [_tableView convertPoint:location fromView:self.view];
    
    if (CGRectContainsPoint(_cycleView.frame, cellPosition)) {
        
        previewingContext.sourceRect = [self.view convertRect:_cycleView.frame fromView:_tableView];
        
        GKSafariViewController *viewController = [[GKSafariViewController alloc] initWithItem:self.viewModel.randomItems[self.viewModel.currentRandomItemIndex]];
        
        return viewController;
        
    } else {
        
        NSIndexPath *path = [_tableView indexPathForRowAtPoint:cellPosition];
        
        if (path) {
            UITableViewCell *cell = [_tableView cellForRowAtIndexPath:path];
            previewingContext.sourceRect = [self.view convertRect:cell.frame fromView:_tableView];
            
            GKSafariViewController *viewController = [[GKSafariViewController alloc] initWithItem:[self.viewModel.dataSource itemAtIndexPath:path]];
            
            return viewController;
        }
        
        return nil;
    }
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    [self presentViewController:viewControllerToCommit animated:YES completion:nil];
}


@end
