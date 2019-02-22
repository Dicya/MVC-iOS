//
//  FFToDoItem.h
//  Objc_MVC
//
//  Created by 张宏伟 on 2019/2/21.
//  Copyright © 2019年 张宏伟. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FFToDoItem : NSObject <NSCoding>

@property (copy, nonatomic) NSString *uuid;

@property (copy, nonatomic) NSString *title;

- (instancetype)initWithTitle:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
