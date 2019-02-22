//
//  FFDataStore.h
//  Objc_MVC
//
//  Created by 张宏伟 on 2019/2/20.
//  Copyright © 2019年 张宏伟. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FFToDoItem.h"
NS_ASSUME_NONNULL_BEGIN


typedef NSString * FFDataChangeKey NS_STRING_ENUM;
typedef NSString * FFDataCMDKind NS_STRING_ENUM;

extern FFDataChangeKey const FFDataChangeCMDKey;
extern FFDataChangeKey const FFDataChangeKindKey;
extern FFDataChangeKey const FFDataChangeIndexesKey;
//extern FFDataChangeKey const FFDataChangeOldKey;
//extern FFDataChangeKey const FFDataChangeNewKey;

extern FFDataCMDKind const FFDataCMDKindRefresh;
extern FFDataCMDKind const FFDataCMDKindLoadMore;

typedef NS_ENUM(NSUInteger, FFDataChange) {
    FFDataChangeSetting = 1,
    FFDataChangeInsertion = 2,
    FFDataChangeRemoval = 3,
    FFDataChangeReplacement = 4,
    FFDataChangeExchange = 5,
};

typedef NS_ENUM(NSUInteger, FFDataSource) {
    FFDataSourceLocal = 1,
    FFDataSourceNetwork = 2,
    FFDataSourceICloud = 3,
};

typedef NS_ENUM(NSUInteger, FFModalFetchStatus) {
    FFModalFetchStatusWillBeginRefresh = 1,
    FFModalFetchStatusIsLoading = 2,
    FFModalFetchStatusEndRefresh = 3,
    FFModalFetchStatusWillBeginLoadingMore = 4,
    FFModalFetchStatusEndLoadingMore = 5,
};

@class FFToDoItem, FFDataStore;

@protocol FFDataStoreDelegate <NSObject>

@optional

- (void)dataStore:(FFDataStore *)dataStore indexpathesDidChanged:(NSDictionary<FFDataChangeKey,id> *)change;

- (void)dataStore:(FFDataStore *)dataStore statusDidChanged:(FFModalFetchStatus)status;

@end

@interface FFDataStore : NSObject

@property (weak, nonatomic) id<FFDataStoreDelegate> delegate;

- (FFToDoItem *)objectAtIndexPath:(NSIndexPath *)indexPath;

@property (readonly, nonatomic) NSUInteger sectionCount;

- (NSUInteger)numberOfItemsInSection:(NSUInteger)section;

@property (readonly, nonatomic) FFModalFetchStatus networkStatus;


- (void)addItem:(FFToDoItem *)item toSection:(NSUInteger)section cmd:(NSString *)cmd;

- (void)insertItem:(FFToDoItem *)item toIndexPath:(NSIndexPath *)indexPath cmd:(NSString *)cmd;

- (void)removeObjectsAtIndexes:(NSArray <NSIndexPath *> *)indexPathes cmd:(NSString *)cmd;

@end

@interface FFDataStore (Fetch)

@property (readonly, nonatomic) BOOL canRefresh;

- (void)restoreFromLocal;

- (void)preserveToLocal;

- (void)refreshData;

- (void)loadMoreData;

@end
NS_ASSUME_NONNULL_END
