//
//  FirstViewController.m
//  Gankee
//
//  Created by Wildog on 1/23/17.
//  Copyright © 2017 Wildog. All rights reserved.
//

#import "GKHomeViewController.h"
#import "GKHomeViewModel.h"
#import "DIDatepicker.h"
#import "SDCycleScrollView.h"
#import <RACEXTScope.h>
#import <RKDropdownAlert.h>
#import <Masonry.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <SafariServices/SafariServices.h>

@interface GKHomeViewController () <UITableViewDelegate, UIViewControllerPreviewingDelegate, SDCycleScrollViewDelegate>

@property (nonatomic, strong) GKHomeViewModel *viewModel;
@property (nonatomic, strong) RACCommand *refreshControlCommand;
@property (nonatomic, strong) RACCommand *toggleCalendarCommand;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSDateFormatter *dateFormatterForBanner;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UIImageView *titleImageView;
@property (weak, nonatomic) IBOutlet UILabel *currentDayLabel;
@property (weak, nonatomic) IBOutlet DIDatepicker *datepicker;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationItem;
@property (weak, nonatomic) IBOutlet UIButton *barButton;
@property (nonatomic, strong) SDCycleScrollView *cycleView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation GKHomeViewController

#pragma mark Lazy Init

- (GKHomeViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[GKHomeViewModel alloc] initWithCellIdentifier:@"home_cell" configureCellBlock:^(UITableViewCell *cell, GKItem *item) {
            UILabel *descLabel = (UILabel *)[cell viewWithTag:1];
            UILabel *authorLabel = (UILabel *)[cell viewWithTag:2];
            UILabel *timeLabel = (UILabel *)[cell viewWithTag:3];
            UIImageView *imageView = (UIImageView *)[cell viewWithTag:4];
            
            [descLabel setText:item.desc];
            [authorLabel setText:item.author];
            if (!item.created) {
                [timeLabel setText:@"未知日期"];
            } else {
                [timeLabel setText:[self.dateFormatter stringFromDate:item.created]];
            }
            
            [imageView sd_setImageWithURL:item.images[0] placeholderImage:[UIImage imageNamed:@"placeholder"] options:SDWebImageProgressiveDownload];
        } altCellIdentifier:@"home_cell_no_img" altConfigureCellBlock:^(UITableViewCell *cell, GKItem *item) {
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
            [[self.viewModel.availableDaysSignal deliverOnMainThread] subscribeNext:^(id  _Nullable x) {
            } error:^(NSError * _Nullable error) {
                [_refreshControl endRefreshing];
                [RKDropdownAlert title:@"出错了！" message:[error localizedDescription]];
            } completed:^{
                // after filling dates, datepicker's setSelectedDate will send control event triggering change of currentDay, finally leads to update the dataSource and reload data
                [self.datepicker fillDatesFromArray:self.viewModel.availableDays];
            }];
            
            return [RACSignal empty];
        }];
    }
    
    return _refreshControlCommand;
}

- (RACCommand *)toggleCalendarCommand {
    if (!_toggleCalendarCommand) {
        _toggleCalendarCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
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
    // set navigation item
    self.navigationItem.titleView = self.titleView;
    self.barButton.rac_command = self.toggleCalendarCommand;
    
    // setup tableView
    self.tableView.dataSource = self.viewModel.dataSource;
    self.tableView.delegate = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 80;
    
    self.cycleView = [[SDCycleScrollView alloc] initWithFrame:CGRectMake(0, 0, 0, 150)];
    self.cycleView.placeholderImage = [UIImage imageNamed:@"banner-placeholder"];
    self.cycleView.bannerImageViewContentMode = UIViewContentModeScaleAspectFill;
    self.cycleView.autoScrollTimeInterval = 4.0;
    self.cycleView.pageDotColor = [UIColor colorWithRed:0.25 green:0.39 blue:0.53 alpha:1];
    self.cycleView.currentPageDotColor = [UIColor colorWithRed:0.16 green:0.73 blue:0.61 alpha:1];
    self.cycleView.delegate = self;
    self.tableView.tableHeaderView = self.cycleView;
    
    // get availableDays
    [[self.viewModel.availableDaysSignal deliverOnMainThread] subscribeNext:^(id x) {
    } error:^(NSError * _Nullable error) {
        [RKDropdownAlert title:@"出错了！" message:[error localizedDescription]];
    } completed:^{
        [self.datepicker fillDatesFromArray:self.viewModel.availableDays];
    }];
    
    // update dataSource if currentDay changes and is valid
    @weakify(self)
    [[[RACObserve(self.viewModel, currentDay) filter:^BOOL(NSString *value) {
        return (value.length > 0);
    }] deliverOnMainThread] subscribeNext:^(id x) {
        @strongify(self)
        [[[self.viewModel itemsForCurrentDaySignal] deliverOnMainThread] subscribeNext:^(id _Nullable x) {
            [[self.viewModel randomItemsSignal] subscribeNext:^(id  _Nullable x) {
            }];
        } error:^(NSError * _Nullable error) {
            [RKDropdownAlert title:@"出错了！" message:[error localizedDescription]];
        } completed:^{
            // this will not trigger control event sending
            [self.datepicker selectDateFromString:x];
        }];
    }];
    
    // update cycleView when randomItems update
    [RACObserve(self.viewModel, randomItems) subscribeNext:^(NSArray *randomItems) {
        @strongify(self)
        if (randomItems.count > 1) {
            NSMutableArray *imageURLStringsArray = [NSMutableArray arrayWithCapacity:5];
            NSMutableArray *descsArray = [NSMutableArray arrayWithCapacity:5];
            NSMutableArray *datesArray = [NSMutableArray arrayWithCapacity:5];
            NSMutableArray *categoriesArray = [NSMutableArray arrayWithCapacity:5];
            for (GKItem *item in randomItems) {
                NSString *urlString = [item imageURLStringForBanner];
                [imageURLStringsArray addObject:urlString];
                
                NSString *desc = item.desc;
                [descsArray addObject:desc];
                
                NSString *category = item.category ? item.category : @"未知分类";
                [categoriesArray addObject:category];
                
                NSString *date = item.created ? [self.dateFormatterForBanner stringFromDate:item.created] : @"未知日期";
                [datesArray addObject:date];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                self.cycleView.descs = descsArray;
                self.cycleView.categories = categoriesArray;
                self.cycleView.dates = datesArray;
                self.cycleView.imageURLStringsGroup = imageURLStringsArray;
            });
        } else if (randomItems) {
            [[self.viewModel randomItemsSignal] subscribeNext:^(id  _Nullable x) {
            }];
        }
    } error:^(NSError * _Nullable error) {
        [RKDropdownAlert title:@"出错了！" message:[error localizedDescription]];
    }];
    
    // reload data when dataSource updates
    [[RACObserve(self.viewModel.dataSource, dict) deliverOnMainThread] subscribeNext:^(NSDictionary *x) {
        @strongify(self)
        [self.refreshControl endRefreshing];
        [self.tableView reloadData];
    }];
    
    // when datepicker's selectedDate changes, update currentDay to the corresponding string
    RAC(self.viewModel, currentDay) = [[[self.datepicker rac_signalForControlEvents:UIControlEventValueChanged] map:^id _Nullable(__kindof UIControl * _Nullable value) {
        @strongify(self)
        return [[self.datepicker dateFormatter] stringFromDate:self.datepicker.selectedDate];
    }] filter:^BOOL(id  _Nullable value) {
        return (value) ? YES : NO;
    }];
    
    // setup RefreshControl
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor colorWithRed:0.08 green:0.58 blue:0.53 alpha:0.6];
    self.refreshControl.rac_command = self.refreshControlCommand;
    self.tableView.refreshControl = _refreshControl;
    
    
    // animate titleView when currentDay changes for the first time
    RAC(self.currentDayLabel, text) = [[[RACObserve(self.viewModel, currentDay)
                                        filter:^BOOL(NSString *value) {
                                            return (value.length > 0);
                                        }] deliverOnMainThread]
                                        doNext:^(id x) {
                                            @strongify(self)
                                            if (self.currentDayLabel.alpha == 0) {
                                                self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.barButton];
                                                self.barButton.transform = CGAffineTransformMakeScale(0, 0);
                                                
                                                [UIView animateWithDuration:0.35 delay:0.3 usingSpringWithDamping:0.75 initialSpringVelocity:3 options:0 animations:^{
                                                    self.barButton.transform = CGAffineTransformIdentity;
                                                } completion:nil];
                                                
                                                [UIView animateWithDuration:0.5 animations:^{
                                                    self.titleImageView.transform = CGAffineTransformMakeTranslation(0, -11);
                                                    self.currentDayLabel.alpha = 1.0;
                                                }];
                                            }
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
    SFSafariViewController *viewController = [[SFSafariViewController alloc] initWithURL:[self.viewModel.dataSource itemAtIndexPath:indexPath].url];
    viewController.preferredControlTintColor = [UIColor colorWithRed:0.08 green:0.58 blue:0.53 alpha:1];
    [self presentViewController:viewController animated:YES completion:nil];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark CycleView Delegate

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index {
    SFSafariViewController *viewController = [[SFSafariViewController alloc] initWithURL:self.viewModel.randomItems[index].url];
    viewController.preferredControlTintColor = [UIColor colorWithRed:0.08 green:0.58 blue:0.53 alpha:1];
    [self presentViewController:viewController animated:YES completion:nil];
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
    if ([self.presentationController isKindOfClass:[SFSafariViewController class]]) {
        return nil;
    }
    
    CGPoint cellPosition = [_tableView convertPoint:location fromView:self.view];
    NSIndexPath *path = [_tableView indexPathForRowAtPoint:cellPosition];
    
    if (path) {
        UITableViewCell *cell = [_tableView cellForRowAtIndexPath:path];
        previewingContext.sourceRect = [self.view convertRect:cell.frame fromView:_tableView];
        
        SFSafariViewController *viewController = [[SFSafariViewController alloc] initWithURL:[self.viewModel.dataSource itemAtIndexPath:path].url];
        viewController.preferredControlTintColor = [UIColor colorWithRed:0.08 green:0.58 blue:0.53 alpha:1];
        
        return viewController;
    }
    return nil;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    [self presentViewController:viewControllerToCommit animated:YES completion:nil];
}


@end
