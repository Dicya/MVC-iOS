//
//  FFDataStore.m
//  Objc_MVC
//
//  Created by 张宏伟 on 2019/2/20.
//  Copyright © 2019年 张宏伟. All rights reserved.
//

#import "FFDataStore.h"

FFDataChangeKey const FFDataChangeCMDKey = @"cmd";
FFDataChangeKey const FFDataChangeKindKey = @"kind";
FFDataChangeKey const FFDataChangeIndexesKey = @"indexes";
FFDataChangeKey const FFDataChangeOldKey = @"old";
FFDataChangeKey const FFDataChangeNewKey = @"new";

FFDataCMDKind const FFDataCMDKindRefresh = @"refresh";
FFDataCMDKind const FFDataCMDKindLoadMore = @"loadmore";

@interface FFDataStore ()

@property (strong, nonatomic) NSMutableDictionary <NSString *, NSMutableArray <FFToDoItem *>*> *sections;

@property (copy, nonatomic) void (^loadDataFinishBlock)(void);

@property (assign, nonatomic) NSTimeInterval lastRefreshDate;

@end

@implementation FFDataStore

- (instancetype)init{
    if (self = [super init]) {
        _sections = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    return self;
}

- (NSUInteger)sectionCount{
    NSArray *keys = [self.sections allKeys];
    return keys.count;
}


- (void)addItem:(FFToDoItem *)item toSection:(NSUInteger)section cmd:(NSString *)cmd{
    if (!item) return;
    
    NSMutableDictionary *changeInfo = [NSMutableDictionary dictionaryWithCapacity:3];
    changeInfo[FFDataChangeCMDKey] = cmd;
    changeInfo[FFDataChangeKindKey] = [NSNumber numberWithInt:FFDataChangeInsertion];
    [[self dataForSection:section] addObject:item];
    NSUInteger idx = [self dataForSection:section].count -1;
    changeInfo[FFDataChangeIndexesKey] = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:idx inSection:section], nil];
    [self.delegate dataStore:self indexpathesDidChanged:changeInfo];
}

- (void)insertItem:(FFToDoItem *)item toIndexPath:(NSIndexPath *)indexPath cmd:(NSString *)cmd{
    if (!item) return;
    NSString *key = [NSString stringWithFormat:@"section_%ld", indexPath.section];
    if (!self.sections[key]) {
        [self addItem:item toSection:indexPath.section cmd:cmd];
        return;
    }
    [[self dataForSection:indexPath.section] insertObject:item atIndex:indexPath.row];
    
    NSMutableDictionary *changeInfo = [NSMutableDictionary dictionaryWithCapacity:3];
    changeInfo[FFDataChangeKindKey] = [NSNumber numberWithInt:FFDataChangeInsertion];
    changeInfo[FFDataChangeIndexesKey] = [NSArray arrayWithObjects:indexPath, nil];
    changeInfo[FFDataChangeCMDKey] = cmd;
    [self.delegate dataStore:self indexpathesDidChanged:changeInfo];
}

- (void)removeObjectsAtIndexes:(NSArray<NSIndexPath *> *)indexPathes cmd:(NSString *)cmd{
    if (!indexPathes) return;
    for (NSIndexPath *indexPath in indexPathes) {
        [[self dataForSection:indexPath.section] removeObjectAtIndex:indexPath.row];
    }
    NSMutableDictionary *changeInfo = [NSMutableDictionary dictionaryWithCapacity:3];
    changeInfo[FFDataChangeKindKey] = [NSNumber numberWithInt:FFDataChangeRemoval];
    changeInfo[FFDataChangeIndexesKey] = indexPathes;
    changeInfo[FFDataChangeCMDKey] = cmd;
    [self.delegate dataStore:self indexpathesDidChanged:changeInfo];
}


- (FFToDoItem *)objectAtIndexPath:(NSIndexPath *)indexPath{
    if (!indexPath) return nil;
    return [[self dataForSection:indexPath.section] objectAtIndex:indexPath.row];
}

- (NSUInteger)numberOfItemsInSection:(NSUInteger)section{
    return [self dataForSection:section].count;
}

- (NSMutableArray <FFToDoItem *> *)dataForSection:(NSUInteger)section{
    NSString *key = [NSString stringWithFormat:@"section_%ld", section];
    NSMutableArray *data = [self.sections objectForKey:key];
    if (!data) {
        data = [NSMutableArray array];
        self.sections[key] = data;
    }
    return data;
}

@end

@implementation FFDataStore (Fetch)

- (NSString *)getArchivedFilePath{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    return [documentPath stringByAppendingPathComponent:@"data.data"];
}

- (void)preserveToLocal{
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithCapacity:2];
    data[@"last"] = [NSDate date];
    data[@"todo"] = [self dataForSection:0];
    NSData *archived = [NSKeyedArchiver archivedDataWithRootObject:data];
    NSString *path = [self getArchivedFilePath];
    [archived writeToFile:path atomically:YES];
}

- (void)restoreFromLocal{
    NSString *path = [self getArchivedFilePath];
    NSData *archived = [NSData dataWithContentsOfFile:path];
    NSMutableDictionary *data = [NSKeyedUnarchiver unarchiveObjectWithData:archived];
    
    NSArray <FFToDoItem *> *items = data[@"todo"];
    [[self dataForSection:0] removeAllObjects];
    if (items) {
        [[self dataForSection:0] addObjectsFromArray:items];
    }
    if ([self.delegate respondsToSelector:@selector(dataStore:indexpathesDidChanged:)]) {
        NSMutableDictionary *changeInfo = [NSMutableDictionary dictionaryWithCapacity:1];
        changeInfo[FFDataChangeKindKey] = [NSNumber numberWithInt:FFDataChangeSetting];
        [self.delegate dataStore:self indexpathesDidChanged:changeInfo];
    }
}

- (void)refreshData{
    _networkStatus = FFModalFetchStatusWillBeginRefresh;
    if ([self.delegate respondsToSelector:@selector(dataStore:statusDidChanged:)]) {
        [self.delegate dataStore:self statusDidChanged:FFModalFetchStatusWillBeginRefresh];
    }
    
    _networkStatus = FFModalFetchStatusIsLoading;
    if ([self.delegate respondsToSelector:@selector(dataStore:statusDidChanged:)]) {
        [self.delegate dataStore:self statusDidChanged:FFModalFetchStatusIsLoading];
    }
    
    NSArray <FFToDoItem *> * (^handleProgressBlock)(void) = ^(void){
        FFToDoItem *item = [[FFToDoItem alloc] initWithTitle:@"This is todo item title."];
        FFToDoItem *item1 = [[FFToDoItem alloc] initWithTitle:@"This is todo item title."];
        FFToDoItem *item2 = [[FFToDoItem alloc] initWithTitle:@"This is todo item title."];
        sleep(2.5);
        return @[item, item1, item2];
    };
    
    void (^handleNoticeBlock)(NSArray <FFToDoItem *> *) = ^(NSArray <FFToDoItem *> *items){
        [[self dataForSection:0] removeAllObjects];
        [[self dataForSection:0] addObjectsFromArray:items];
        if ([self.delegate respondsToSelector:@selector(dataStore:indexpathesDidChanged:)]) {
            NSMutableDictionary *changeInfo = [NSMutableDictionary dictionaryWithCapacity:1];
            changeInfo[FFDataChangeKindKey] = [NSNumber numberWithInt:FFDataChangeSetting];
            [self.delegate dataStore:self indexpathesDidChanged:changeInfo];
        }
        
        self -> _networkStatus = FFModalFetchStatusEndRefresh;
        if ([self.delegate respondsToSelector:@selector(dataStore:statusDidChanged:)]) {
            [self.delegate dataStore:self statusDidChanged:FFModalFetchStatusEndRefresh];
        }
    };
    
    dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT), ^{
        NSArray <FFToDoItem *> *items;
        if (handleProgressBlock) {
            items = handleProgressBlock();
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.lastRefreshDate = [NSDate timeIntervalSinceReferenceDate];
            
            if (handleNoticeBlock && items) {
                handleNoticeBlock(items);
            }
        });
    });
}

- (void)loadMoreData{
    _networkStatus = FFModalFetchStatusWillBeginLoadingMore;
    if ([self.delegate respondsToSelector:@selector(dataStore:statusDidChanged:)]) {
        [self.delegate dataStore:self statusDidChanged:FFModalFetchStatusWillBeginLoadingMore];
    }
    
    _networkStatus = FFModalFetchStatusIsLoading;
    if ([self.delegate respondsToSelector:@selector(dataStore:statusDidChanged:)]) {
        [self.delegate dataStore:self statusDidChanged:FFModalFetchStatusIsLoading];
    }
    
    FFToDoItem * (^handleProgressBlock)(void) = ^(void){
        FFToDoItem *item = [[FFToDoItem alloc] initWithTitle:@"This is todo item title."];
        sleep(2.5);
        return item;
    };
    
    void (^handleNoticeBlock)(FFToDoItem *) = ^(FFToDoItem * item){
        [self addItem:item toSection:0 cmd:FFDataCMDKindLoadMore];
        self -> _networkStatus = FFModalFetchStatusEndLoadingMore;
        if ([self.delegate respondsToSelector:@selector(dataStore:statusDidChanged:)]) {
            [self.delegate dataStore:self statusDidChanged:FFModalFetchStatusEndLoadingMore];
        }
    };
    
    dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT), ^{
        FFToDoItem *item;
        if (handleProgressBlock) {
            item = handleProgressBlock();
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (handleNoticeBlock && item) {
                handleNoticeBlock(item);
            }
        });
    });
}

- (BOOL)canRefresh{
    NSTimeInterval interval = [NSDate timeIntervalSinceReferenceDate] - self.lastRefreshDate;
    return interval >= 15000000;
}
@end
