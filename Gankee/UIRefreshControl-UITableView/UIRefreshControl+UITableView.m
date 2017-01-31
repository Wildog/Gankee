//
//  UIRefreshControl+UITableView.m
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

#import "UIRefreshControl+UITableView.h"

@implementation UIRefreshControl (UITableView)

- (void)addToTableView:(UITableView *)tableView
{
    if (self.superview != tableView)
    {
        SEL _setRefreshControl = sel_registerName("_setRefreshControl:");
        
        if (self.superview)
        {
            UIView *oldTableView = self.superview;
            if ([oldTableView isKindOfClass:UITableView.class])
            {
                if ([tableView respondsToSelector:_setRefreshControl])
                { // UITableView has a _setRefreshControl method
                    ((void (*)(id, SEL, __strong UIRefreshControl *))[tableView methodForSelector:_setRefreshControl])(oldTableView, _setRefreshControl, nil);
                }
                else
                { // Some future version, UITableView does not have a _setRefreshControl method. So hack it using a UITableViewController
                    UIView *superview = oldTableView.superview;
                    UITableViewController *tvc = [[UITableViewController alloc] init];
                    tvc.tableView = (UITableView *)oldTableView;
                    tvc.refreshControl = nil;
                    tvc.tableView = nil;
                    [superview addSubview:oldTableView];
                }
            }
            
            [self removeFromSuperview];
        }
        if (tableView)
        {
            [tableView addSubview:self];
            
            if ([tableView respondsToSelector:_setRefreshControl])
            { // UITableView has a _setRefreshControl method
                ((void (*)(id, SEL, __strong UIRefreshControl *))[tableView methodForSelector:_setRefreshControl])(tableView, _setRefreshControl, self);
            }
            else
            { // Some future version, UITableView does not have a _setRefreshControl method. So hack it using a UITableViewController
                UIView *superview = tableView.superview;
                UITableViewController *tvc = [[UITableViewController alloc] init];
                tvc.tableView = tableView;
                tvc.refreshControl = self;
                tvc.tableView = nil;
                [superview addSubview:tableView];
            }
        }
    }
}

@end
