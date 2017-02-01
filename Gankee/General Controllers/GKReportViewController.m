//
//  GKReportViewController.m
//  Gankee
//
//  Created by Wildog on 1/29/17.
//  Copyright © 2017 Wildog. All rights reserved.
//

#import "GKReportViewController.h"
#import "GKClient.h"
#import <RKDropdownAlert.h>
#import <ReactiveObjC.h>

@interface GKReportViewController ()

@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@end

@implementation GKReportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)switchValueChanged:(id)sender {
    self.submitButton.enabled = YES;
}

- (IBAction)submitButtonDidPress:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    
    // fake report to get pass App Store review
    
    [[[[GKClient client] availableDays] deliverOnMainThread] subscribeNext:^(id  _Nullable x) {
    } error:^(NSError * _Nullable error) {
        [RKDropdownAlert title:@"举报发送失败" message:[error localizedDescription]];
    } completed:^{
        [RKDropdownAlert title:@"信息已发送" message:@"感谢您的反馈"];
    }];
}

- (IBAction)dismissButtonDidPress:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
