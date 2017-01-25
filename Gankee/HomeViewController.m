//
//  FirstViewController.m
//  Gankee
//
//  Created by Wildog on 1/23/17.
//  Copyright © 2017 Wildog. All rights reserved.
//

#import "HomeViewController.h"
#import "GKHomeViewModel.h"
#import "DIDatepicker.h"
#import <RKDropdownAlert.h>
#import "RACEXTScope.h"

@interface HomeViewController ()

@property (nonatomic, strong) GKHomeViewModel *viewModel;
@property (nonatomic, strong) RACCommand *refreshControlCommand;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UIImageView *titleImageView;
@property (weak, nonatomic) IBOutlet UILabel *currentDayLabel;
@property (weak, nonatomic) IBOutlet DIDatepicker *datepicker;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation HomeViewController

#pragma mark Lazy Init

- (GKHomeViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[GKHomeViewModel alloc] initWithCellIdentifier:@"home_cell" configureCellBlock:^(UITableViewCell *cell, GKItem *item) {
            cell.textLabel.text = item.desc;
        }];
    }
    return _viewModel;
}

- (RACCommand *)refreshControlCommand {
    if (!_refreshControlCommand) {
        _refreshControlCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            [[[RACSignal combineLatest:@[self.viewModel.availableDaysSignal, self.viewModel.itemsForCurrentDaySignal]] deliverOnMainThread] subscribeNext:^(id  _Nullable x) {
            } error:^(NSError * _Nullable error) {
                [RKDropdownAlert title:@"出错了！" message:[error localizedDescription]];
            } completed:^{
                [_refreshControl endRefreshing];
                [self.tableView reloadData];
            }];
            
            return [RACSignal empty];
        }];
    }
    
    return _refreshControlCommand;
}

#pragma mark View Controller

- (void)viewDidLoad {
    [super viewDidLoad];
    // set navigation titleView
    self.tabBarController.navigationItem.titleView = self.titleView;
    
    // setup tableView data source
    self.tableView.dataSource = self.viewModel.dataSource;
    
    // get availableDays
    [[self.viewModel.availableDaysSignal deliverOnMainThread] subscribeNext:^(id x) {
    } error:^(NSError * _Nullable error) {
        [RKDropdownAlert title:@"出错了！" message:[error localizedDescription]];
    } completed:^{
    }];
    
    // update dataSource if has valid currentDay
    [[[RACObserve(self.viewModel, currentDay) filter:^BOOL(NSString *value) {
        return (value.length > 0);
    }] deliverOnMainThread] subscribeNext:^(id x) {
        [[[self.viewModel itemsForCurrentDaySignal] deliverOnMainThread] subscribeNext:^(id _Nullable x) {
        } error:^(NSError * _Nullable error) {
            [RKDropdownAlert title:@"出错了！" message:[error localizedDescription]];
        } completed:^{
        }];
    }];
    
    // setup RefreshControl
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor colorWithRed:0.08 green:0.58 blue:0.53 alpha:0.6];
    self.refreshControl.rac_command = self.refreshControlCommand;
    self.tableView.refreshControl = _refreshControl;
    
    // observe data source change
    [[RACObserve(self.viewModel.dataSource, dict) deliverOnMainThread] subscribeNext:^(NSDictionary *x) {
        [self.tableView reloadData];
    }];
    
    // animate titleView when currentDay changes for the first time
    RAC(self.currentDayLabel, text) = [[[RACObserve(self.viewModel, currentDay)
                                        filter:^BOOL(NSString *value) {
                                            return (value.length > 0);
                                        }] deliverOnMainThread]
                                        doNext:^(id x) {
                                           if (self.currentDayLabel.alpha == 0) {
                                               [UIView animateWithDuration:0.5 animations:^{
                                                   self.titleImageView.transform = CGAffineTransformMakeTranslation(0, -11);
                                                    self.currentDayLabel.alpha = 1.0;
                                               }];
                                           }
                                       }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
