//
//  FFEditTableViewController.m
//  Objc_MVC
//
//  Created by 张宏伟 on 2019/2/21.
//  Copyright © 2019年 张宏伟. All rights reserved.
//

#import "FFEditTableViewController.h"
#import "FFToDoItem.h"

@interface FFEditTableViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *timeTextField;
@property (weak, nonatomic) IBOutlet UITextField *detailTextField;

@end

@implementation FFEditTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [UIView new];
    
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneBtnDidClicked:)];
    self.navigationItem.rightBarButtonItem = doneBtn;
    doneBtn.enabled = NO;
    
}

- (void)doneBtnDidClicked:(id)sender{
    NSString *name = [self.nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    FFToDoItem *item = [[FFToDoItem alloc] initWithTitle:name];
    [self.navigationController popViewControllerAnimated:YES];
    if (self.editBlock) {
        self.editBlock(item);
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField == self.nameTextField) {
        NSString *name = [self.nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        self.navigationItem.rightBarButtonItem.enabled = name.length > 0;
    }
    return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == self.nameTextField) {
        [self.timeTextField becomeFirstResponder];
    }else if (textField == self.timeTextField){
        [self.detailTextField becomeFirstResponder];
    }else if (textField == self.detailTextField){
        NSString *name = [self.nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (name.length > 0) {
            [self doneBtnDidClicked:self];
        }
    }
    return YES;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}


@end
