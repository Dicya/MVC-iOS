//
//  FFEditTableViewController.h
//  Objc_MVC
//
//  Created by 张宏伟 on 2019/2/21.
//  Copyright © 2019年 张宏伟. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FFToDoItem.h"
NS_ASSUME_NONNULL_BEGIN

@interface FFEditTableViewController : UITableViewController

@property (nonatomic, copy) void (^editBlock)(FFToDoItem *item);
@end

NS_ASSUME_NONNULL_END
