//
//  UIRefreshControl+UITableView.h
//  UIRefreshControl+UITableView
//
//  Created by Daniel Cohen Gindi on 5/28/14.
//  Copyright (c) 2013 Daniel Cohen Gindi. All rights reserved.
//
//  https://github.com/danielgindi/UIRefreshControl-UITableView
//
// When adding a UIRefreshControl directly to a UITableView, the UITableView does not know of it,
//   and is not able to handle it's scroll-dragging correctly when the UIRefreshControl changes
//   the scroll insets. This category tries to tell UITableView about it so the scrolling and
//   background color bugs are avoided.
//

#import <UIKit/UIKit.h>

@interface UIRefreshControl (UITableView)

- (void)addToTableView:(UITableView *)tableView;

@end
