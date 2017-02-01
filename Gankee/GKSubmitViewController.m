//
//  GKSubmitViewController.m
//  Gankee
//
//  Created by Wildog on 1/30/17.
//  Copyright © 2017 Wildog. All rights reserved.
//

#import "GKSubmitViewController.h"
#import "WDHoshiTextField.h"
#import "GKClient.h"
#import <ReactiveObjC.h>
#import <RKDropdownAlert.h>

@interface GKSubmitViewController () <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet WDHoshiTextField *urlField;
@property (weak, nonatomic) IBOutlet WDHoshiTextField *descField;
@property (weak, nonatomic) IBOutlet WDHoshiTextField *authorField;
@property (weak, nonatomic) IBOutlet UIPickerView *categoryPicker;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIView *wholeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@property (strong, nonatomic) NSArray *categories;

@end

@implementation GKSubmitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.indicator stopAnimating];
    self.wholeView.transform = CGAffineTransformMakeTranslation(0, 600);
    self.categories = @[@"瞎推荐", @"iOS", @"Android", @"App", @"前端", @"拓展资源", @"福利"];
    RAC(self.submitButton, enabled) = [[RACSignal combineLatest:@[[self validTextSignalForTextField:self.urlField],
                                                                  [self validTextSignalForTextField:self.descField],
                                                                  [self validTextSignalForTextField:self.authorField]]]
                                       map:^id _Nullable(RACTuple *tuple) {
                                           BOOL allYes = [tuple.rac_sequence all:^BOOL(NSNumber *value) {
                                               return value.boolValue;
                                           }];
                                           return @(allYes);
                                       }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:5 options:0 animations:^{
        self.wholeView.transform = CGAffineTransformIdentity;
    } completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (RACSignal *)validTextSignalForTextField:(UITextField *)textField {
    return [textField.rac_textSignal map:^id _Nullable(NSString * _Nullable value) {
        return @(value.length > 0);
    }];
}

- (IBAction)dismissButtonDidPress:(id)sender {
    [self.view endEditing:YES];
    [UIView animateWithDuration:0.3 animations:^{
        self.wholeView.transform = CGAffineTransformMakeTranslation(0, 600);
    }];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)submitButtonDidPress {
    [self.view endEditing:YES];
    self.submitButton.enabled = NO;
    self.view.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.mainView.alpha = 0;
        [self.indicator startAnimating];
    }];
    [UIView animateWithDuration:0.4 animations:^{
        self.heightConstraint.constant = 100;
        [self.view layoutIfNeeded];
    }];
    [[[[GKClient client] submitURL:self.urlField.text desc:self.descField.text category:self.categories[[self.categoryPicker selectedRowInComponent:0]] author:self.authorField.text] deliverOnMainThread] subscribeNext:^(id  _Nullable x) {
    } error:^(NSError * _Nullable error) {
        [RKDropdownAlert title:@"提交失败" message:[error localizedDescription]];
        [UIView animateWithDuration:0.5 animations:^{
            self.mainView.alpha = 1;
            [self.indicator stopAnimating];
        }];
        [UIView animateWithDuration:0.3 animations:^{
            self.heightConstraint.constant = 280;
            [self.view layoutIfNeeded];
        }];
        self.view.userInteractionEnabled = YES;
        self.submitButton.enabled = YES;
    } completed:^{
        [RKDropdownAlert title:@"提交成功" message:@"等待编辑们的审核哦~" backgroundColor:GOSSAMER textColor:[UIColor whiteColor]];
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }];
}

#pragma mark TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    NSInteger nextTag = textField.tag + 1;
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        [nextResponder becomeFirstResponder];
    } else {
        [self submitButtonDidPress];
    }
    return NO;
}

#pragma mark PickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.categories.count;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 30.0;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel* pickerLabel = (UILabel*)view;
    
    if (!pickerLabel) {
        pickerLabel = [[UILabel alloc] init];
        pickerLabel.font = [UIFont systemFontOfSize:18];
        pickerLabel.textColor = [UIColor colorWithRed:0.18 green:0.24 blue:0.31 alpha:1];
        pickerLabel.textAlignment=NSTextAlignmentCenter;
    }
    [pickerLabel setText:self.categories[row]];
    
    return pickerLabel;
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
