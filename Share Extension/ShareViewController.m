//
//  ShareViewController.m
//  Share Extension
//
//  Created by Wildog on 1/31/17.
//  Copyright © 2017 Wildog. All rights reserved.
//

#import "ShareViewController.h"
#import "WDHoshiTextField.h"
#import "GKClient.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface ShareViewController () <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate> {
    NSString *_url;
}

@property (weak, nonatomic) IBOutlet WDHoshiTextField *descField;
@property (weak, nonatomic) IBOutlet WDHoshiTextField *authorField;
@property (weak, nonatomic) IBOutlet UIPickerView *categoryPicker;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIView *wholeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UILabel *successLabel;

@property (strong, nonatomic) NSArray *categories;

@end

@implementation ShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSExtensionItem *extensionItem = self.extensionContext.inputItems.firstObject;
    self.descField.text = [extensionItem.attributedContentText string];
    
    NSItemProvider *itemProvider = extensionItem.attachments.firstObject;
    if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeURL]) {
        [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeURL options:nil completionHandler:^(NSURL *item, NSError * _Null_unspecified error) {
            _url = item.absoluteString;
        }];
    }
    
    // Chrome
    if (!_url && extensionItem.attachments.count > 1) {
        NSItemProvider *itemProvider = extensionItem.attachments[1];
        if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeURL]) {
            [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeURL options:nil completionHandler:^(NSURL *item, NSError * _Null_unspecified error) {
                _url = item.absoluteString;
            }];
        }
    }
    
    [self.indicator stopAnimating];
    self.wholeView.transform = CGAffineTransformMakeTranslation(0, 600);
    self.categories = @[@"瞎推荐", @"iOS", @"Android", @"App", @"前端", @"拓展资源", @"福利"];
    RAC(self.submitButton, enabled) = [[RACSignal combineLatest:@[[self validTextSignalForTextField:self.descField],
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
    [self.authorField becomeFirstResponder];
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
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
    }];
}

- (IBAction)submitButtonDidPress {
    [self.view endEditing:YES];
    self.submitButton.enabled = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.mainView.alpha = 0;
        [self.indicator startAnimating];
    }];
    [UIView animateWithDuration:0.4 animations:^{
        self.heightConstraint.constant = 80;
        [self.view layoutIfNeeded];
    }];
    if (!_url) {
        self.successLabel.text = @"URL有误";
        self.successLabel.alpha = 1;
        [self.indicator stopAnimating];
        return;
    }
    self.view.userInteractionEnabled = NO;
    [[[[GKClient client] submitURL:_url desc:self.descField.text category:self.categories[[self.categoryPicker selectedRowInComponent:0]] author:self.authorField.text] deliverOnMainThread] subscribeNext:^(id  _Nullable x) {
    } error:^(NSError * _Nullable error) {
        [self.submitButton setTitle:[error localizedDescription] forState:UIControlStateNormal];
        [self.submitButton setTitleColor:[UIColor colorWithRed:1.000 green:0.231 blue:0.188 alpha:1.000] forState:UIControlStateNormal];
        [UIView animateWithDuration:0.5 animations:^{
            self.mainView.alpha = 1;
            [self.indicator stopAnimating];
        }];
        [UIView animateWithDuration:0.3 animations:^{
            self.heightConstraint.constant = 220;
            [self.view layoutIfNeeded];
        }];
        self.view.userInteractionEnabled = YES;
        self.submitButton.enabled = YES;
    } completed:^{
        //[RKDropdownAlert title:@"提交成功" message:@"等待编辑们的审核哦~" backgroundColor:GOSSAMER textColor:[UIColor whiteColor]];
        [UIView animateWithDuration:0.5 animations:^{
            self.successLabel.alpha = 1;
            [self.indicator stopAnimating];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3 delay:0.5 options:0 animations:^{
                self.wholeView.transform = CGAffineTransformMakeTranslation(0, 600);
                self.view.alpha = 0;
            } completion:^(BOOL finished) {
                [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
            }];
        }];
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

@end
