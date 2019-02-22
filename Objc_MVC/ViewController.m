//
//  ViewController.m
//  Objc_MVC
//
//  Created by 张宏伟 on 2019/2/20.
//  Copyright © 2019年 张宏伟. All rights reserved.
//

#import "ViewController.h"
#import "FFDataStore.h"
#import "FFEditTableViewController.h"
@interface ViewController ()<UITableViewDataSource, UITableViewDelegate, FFDataStoreDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *addBtn;

@property (strong, nonatomic) FFDataStore *data;

@end

static FFDataCMDKind kCMDInsert = @"insert";
static FFDataCMDKind kCMDDelete = @"delete";

@implementation ViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        
        _data = [[FFDataStore alloc] init];
        _data.delegate = self;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.addBtn.enabled = NO;
    self.tableView.tableFooterView = [UIView new];
    
//    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] initWithFrame:CGRectZero];
//    self.tableView.refreshControl = refreshControl;
//    [refreshControl addTarget:self.data action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    
    [self.data restoreFromLocal];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preserveToLocal) name:UIApplicationWillTerminateNotification object:nil];
    
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Handler: Action
- (IBAction)addBtnDidClicked:(id)sender {
    FFEditTableViewController *editVc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass(FFEditTableViewController.class)];
    editVc.editBlock = ^(FFToDoItem * _Nonnull item) {
        [self.data insertItem:item toIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] cmd:kCMDInsert];
    };
    [self.navigationController pushViewController:editVc animated:YES];
}

#pragma mark - Handler: Notify

- (void)preserveData{
    [self.data preserveToLocal];
}

#pragma mark - Protocol: UITableViewDataSource & UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.data.sectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.data numberOfItemsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseId" forIndexPath:indexPath];
    cell.textLabel.text = [self.data objectAtIndexPath:indexPath].title;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    // notify update data
    [self.data removeObjectsAtIndexes:@[indexPath] cmd:kCMDDelete];
}

#pragma mark - Protocol: FFDataStoreDelegate

- (void)dataStore:(FFDataStore *)dataStore indexpathesDidChanged:(NSDictionary<FFDataChangeKey,id> *)change{
    
    FFDataChange kind = [change[FFDataChangeKindKey] intValue];
    NSArray <NSIndexPath *> *indexes = change[FFDataChangeIndexesKey];
    
    switch (kind) {
        case FFDataChangeSetting:{
            // notify update UI: tableview
            [self.tableView reloadData];
            
            // notify update UI: add btn
            [self updateAddBtnStatus];
            break;
        }
            
        case FFDataChangeInsertion:{
            // notify update UI: tableview
            [self.tableView insertRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationRight];

            // notify update UI: add btn
            [self updateAddBtnStatus];
            break;
        }
        case FFDataChangeRemoval:{
            // notify update UI: tableview
            [self.tableView deleteRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationLeft];
            
            // notify update UI: add btn
            [self updateAddBtnStatus];
            break;
        }
        default:
            break;
    }
}

- (void)dataStore:(FFDataStore *)dataStore statusDidChanged:(FFModalFetchStatus)status{
    if (status == FFModalFetchStatusWillBeginRefresh) {
        self.addBtn.enabled = NO;
    }else if (status == FFModalFetchStatusEndRefresh){
        [self.tableView.refreshControl endRefreshing];
    }
}

#pragma mark - private: update ui

- (void)updateAddBtnStatus{
    BOOL canAdd = [self.data numberOfItemsInSection:0] < 10;
    self.addBtn.enabled = canAdd;
}

@end
