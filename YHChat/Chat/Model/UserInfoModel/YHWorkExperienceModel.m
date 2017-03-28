//
//  YHWorkExperienceModel.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by YHIOS003 on 16/5/17.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import "YHWorkExperienceModel.h"
#import <objc/runtime.h>

//#import "NSObject+YHDBRuntime.h"


@implementation YHWorkExperienceModel


//YHSERIALIZE_CODER_DECODER();
//
//YHSERIALIZE_COPY_WITH_ZONE();

//YHSERIALIZE_DESCRIPTION();

-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}

- (id)copy
{
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)mutableCopy
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return [self mutableCopy];
}

//+ (NSString *)yh_primaryKey{
//    return @"workExpId";
//}
//
//+ (NSDictionary *)yh_replacedKeyFromPropertyName{
//    return @{@"workExpId":YHDB_PrimaryKey};
//}


@end
