//
//  SecondViewController.m
//  Gankee
//
//  Created by Wildog on 1/23/17.
//  Copyright © 2017 Wildog. All rights reserved.
//

#import "GKCategoriesViewController.h"
#import "GKCategoryTableViewController.h"
#import "WDScrollableSegmentedControl.h"
#import <YTPageController.h>

@interface GKCategoriesViewController () <WDScrollableSegmentedControlDelegate, YTPageControllerDataSource, YTPageControllerDelegate>

@property (weak, nonatomic) YTPageController *pageController;
@property (weak, nonatomic) IBOutlet WDScrollableSegmentedControl *scrollSegment;
@property (strong, nonatomic) IBOutlet UIView *titleView;
@property (strong, nonatomic) NSArray *categories;
@property (strong, nonatomic) NSMutableDictionary *viewControllers;

@end

@implementation GKCategoriesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationItem.titleView = self.titleView;
    
    self.viewControllers = [NSMutableDictionary dictionary];
    self.categories = @[@"全部", @"iOS", @"Android", @"App", @"前端", @"瞎推荐", @"拓展资源", @"休息视频", @"福利"];
    self.scrollSegment.buttons = self.categories;
    self.scrollSegment.delegate = self;
    
    self.pageController.dataSource = self;
    self.pageController.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"embed_page_controller"]) {
        _pageController = segue.destinationViewController;
    }
}

#pragma mark pageController dataSource

- (NSInteger)numberOfPagesInPageController:(YTPageController *)pageController {
    return self.categories.count;
}

- (UIViewController *)pageController:(YTPageController *)pageController pageAtIndex:(NSInteger)index {
    if (!self.viewControllers[@(index)]) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        GKCategoryTableViewController *vc = [sb instantiateViewControllerWithIdentifier:@"category_table_vc"];
        vc.category = index;
        self.viewControllers[@(index)] = vc;
        return vc;
    }
    return self.viewControllers[@(index)];
}

#pragma mark pageController delegate

- (void)pageController:(YTPageController *)pageController willStartTransition:(id<YTPageTransitionContext>)context {
    [pageController.pageCoordinator animateAlongsidePagingInView:self.scrollSegment animation:^(id<YTPageTransitionContext>  _Nonnull context) {
        // update segmented control
        self.scrollSegment.userInteractionEnabled = NO;
        self.scrollSegment.selectedIndex = [context toIndex];
    } completion:^(id<YTPageTransitionContext>  _Nonnull context) {
        if ([context isCanceled]) {
            // if transition canceled, restore to the previous state
            self.scrollSegment.selectedIndex = [context fromIndex];
        }
        self.scrollSegment.userInteractionEnabled = YES;
    }];
}

#pragma mark segmentedControl delegate

- (void)didSelectButtonAtIndex:(NSInteger)index {
    [self.pageController setCurrentIndex:index animated:NO];
}

@end
