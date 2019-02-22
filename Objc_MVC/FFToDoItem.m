//
//  FFToDoItem.m
//  Objc_MVC
//
//  Created by 张宏伟 on 2019/2/21.
//  Copyright © 2019年 张宏伟. All rights reserved.
//

#import "FFToDoItem.h"

@implementation FFToDoItem

- (instancetype)initWithTitle:(NSString *)title{
    if (self = [super init]) {
        _title = title;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.uuid forKey:@"uuid"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        _uuid = [aDecoder decodeObjectForKey:@"uuid"];
        _title = [aDecoder decodeObjectForKey:@"title"];
    }
    return self;
}

@end
