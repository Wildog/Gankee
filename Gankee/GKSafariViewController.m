//
//  GKSafariViewController.m
//  Gankee
//
//  Created by Wildog on 1/29/17.
//  Copyright © 2017 Wildog. All rights reserved.
//

#import <RKDropdownAlert.h>
#import "GKSafariViewController.h"
#import "GKReportActivity.h"
#import "GKFavoriteActivity.h"
#import "GKUnfavoriteActivity.h"
#import "AppDelegate.h"
#import "GKFavoriteHelper.h"

@interface GKSafariViewController () <SFSafariViewControllerDelegate>

@property (nonatomic, strong) UIPreviewAction *shareAction;
@property (nonatomic, strong) UIPreviewAction *favoriteAction;
@property (nonatomic, strong) UIPreviewAction *unfavoriteAction;

@end

@implementation GKSafariViewController

- (instancetype)initWithItem:(GKItem *)item {
    if (!item.url) {
        // sometimes gank.io backend provides null url
        item.url = [NSURL URLWithString:@"http://gank.io/404"];
    }
    _item = item;
    return [super initWithURL:_item.url];
}

- (instancetype)initWithFavoriteItem:(GKFavoriteItem *)item {
    _item = [[GKItem alloc] init];
    _item.itemID = item.itemID;
    _item.created = item.created;
    _item.published = item.published;
    _item.url = (NSURL *)item.url;
    _item.desc = item.desc;
    _item.author = item.author;
    _item.images = (NSArray *)item.images;
    _item.category = item.category;
    _item.source = item.source;
    return [super initWithURL:_item.url];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    if ([self respondsToSelector:NSSelectorFromString(@"setPreferredControlTintColor:")]) {
        // iOS 10+ only
        self.preferredControlTintColor = [UIColor colorWithRed:0.08 green:0.58 blue:0.53 alpha:1];
    }
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

- (UIPreviewAction *)favoriteAction {
    if (!_favoriteAction) {
        _favoriteAction = [UIPreviewAction actionWithTitle:@"收藏" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
            [GKFavoriteHelper createFavoriteItemFromItem:_item];
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
                if (error) {
                    [RKDropdownAlert title:@"收藏失败" message:error.localizedDescription];
                } else {
                    [RKDropdownAlert title:@"已收藏" backgroundColor:[UIColor colorWithRed:0.16 green:0.73 blue:0.61 alpha:1] textColor:[UIColor whiteColor] time:1];
                }
            }];
        }];
    }
    return _favoriteAction;
}

- (UIPreviewAction *)unfavoriteAction {
    if (!_unfavoriteAction) {
        _unfavoriteAction = [UIPreviewAction actionWithTitle:@"取消收藏" style:UIPreviewActionStyleDestructive handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
            GKFavoriteItem *favorite = [GKFavoriteHelper fetchFavoriteItemFromItem:_item];
            [favorite MR_deleteEntity];
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
                if (error) {
                    [RKDropdownAlert title:@"未能取消收藏" message:error.localizedDescription];
                } else {
                    [RKDropdownAlert title:@"已取消收藏" backgroundColor:[UIColor colorWithRed:0.2 green:0.27 blue:0.35 alpha:1] textColor:[UIColor whiteColor] time:1];
                }
            }];
        }];
    }
    return _unfavoriteAction;
}

- (NSArray<id<UIPreviewActionItem>> *)previewActionItems {
    if ([GKFavoriteHelper fetchFavoriteItemFromItem:_item]) {
        return @[self.unfavoriteAction, self.shareAction];
    }
    return @[self.favoriteAction, self.shareAction];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray<UIActivity *> *)safariViewController:(SFSafariViewController *)controller activityItemsForURL:(NSURL *)URL title:(NSString *)title {
    GKReportActivity *reportActivity = [[GKReportActivity alloc] initWithURL:URL];
    UIActivity *favoriteActivity = nil;
    if ([GKFavoriteHelper fetchFavoriteItemFromItem:_item]) {
        favoriteActivity = [[GKUnfavoriteActivity alloc] initWithItem:_item];
    } else {
        favoriteActivity = [[GKFavoriteActivity alloc] initWithItem:_item];
    }
    return @[favoriteActivity, reportActivity];
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
