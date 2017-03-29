//
//  YHChatModel.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/12/29.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import "YHChatModel.h"
//#import "NSObject+YHDBRuntime.h"


@implementation YHChatModel

//#pragma mark - 数据库操作
//+ (NSString *)yh_primaryKey{
//    return @"chatId";
//}
//
//+ (NSDictionary *)yh_replacedKeyFromPropertyName{
//    return @{@"chatId":YHDB_PrimaryKey};
//}
//
//-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
//    
//}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _cellHeight = 0;
    }
    return self;
}


@end


@implementation YHAudioModel


@end

