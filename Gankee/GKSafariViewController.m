//
//  GKSafariViewController.m
//  Gankee
//
//  Created by Wildog on 1/29/17.
//  Copyright © 2017 Wildog. All rights reserved.
//

#import "GKSafariViewController.h"
#import "GKReportActivity.h"
#import "AppDelegate.h"

@interface GKSafariViewController () <SFSafariViewControllerDelegate>

@property (nonatomic, strong) UIPreviewAction *shareAction;

@end

@implementation GKSafariViewController

- (instancetype)initWithItem:(GKItem *)item {
    _item = item;
    if (!item.url) {
        // sometimes gank.io backend provides null url
        item.url = [NSURL URLWithString:@"http://gank.io/404"];
    }
    return [super initWithURL:item.url];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.preferredControlTintColor = [UIColor colorWithRed:0.08 green:0.58 blue:0.53 alpha:1];
    self.delegate = self;
}

- (UIPreviewAction *)shareAction {
    if (!_shareAction) {
        _shareAction = [UIPreviewAction actionWithTitle:@"分享" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
            
            NSArray *objectsToShare = @[_item.desc, _item.url];
            
            UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
            
            NSArray *excludeActivities = @[UIActivityTypePrint,
                                           UIActivityTypeAssignToContact,
                                           UIActivityTypeSaveToCameraRoll,
                                           UIActivityTypePostToFlickr,
                                           UIActivityTypePostToVimeo];
            
            activityVC.excludedActivityTypes = excludeActivities;
            
            [[(AppDelegate *)[[UIApplication sharedApplication] delegate] window].rootViewController presentViewController:activityVC animated:YES completion:nil];
        }];
    }
    return _shareAction;
}

- (NSArray<id<UIPreviewActionItem>> *)previewActionItems {
    return @[self.shareAction];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray<UIActivity *> *)safariViewController:(SFSafariViewController *)controller activityItemsForURL:(NSURL *)URL title:(NSString *)title {
    GKReportActivity *activity = [[GKReportActivity alloc] initWithURL:URL];
    return @[activity];
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
