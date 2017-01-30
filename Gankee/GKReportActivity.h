//
//  GKReportActivity.h
//  Gankee
//
//  Created by Wildog on 1/29/17.
//  Copyright © 2017 Wildog. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GKReportActivity : UIActivity {
    UIViewController *activityViewController;
}

- (id)initWithURL:(NSURL *)url;

@end
