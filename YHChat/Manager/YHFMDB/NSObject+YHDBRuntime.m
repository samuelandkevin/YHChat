//
//  NSObject+Runtime.m
//  
//
//  Created by YHIOS002 on 16/11/9.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import "NSObject+YHDBRuntime.h"
#import <objc/runtime.h>

@implementation YHDBRuntimeIvar

@end

@implementation NSObject (YHDBRuntime)

NSString *const YHDB_AppendingID = @"_id";

NSString *const YHDB_PrimaryKey = @"id";

NSString *const YHDB_AutoIncreaseID = @"AutoIncreaseID";

/**
 * 实现该方法，则必须实现：yh_replacedKeyFromPropertyName
 * 设置主键:能够唯一标示该模型的属性
 * 
 */
+ (NSString *)yh_primaryKey{
    return nil;
}

/**
 *  属性为数组
 *
 */

+ (NSDictionary *)yh_propertyIsInstanceOfArray{
    return nil;
}

/**
 *  属性为NSDATA
 *
 */
+ (NSDictionary *)yh_propertyIsInstanceOfData{
    return nil;
}

/**
 *  将属性为UIImage
 *
 */
+ (NSDictionary *)yh_propertyIsInstanceOfImage{
    return nil;
}

/**
 *  只有这个数组中的属性名才允许
 */
+ (NSArray *)yh_allowedPropertyNames{
    return nil;
}

/**
 *  这个数组中的属性名将会被忽略：不进行
 */
+ (NSArray *)yh_ignoredPropertyNames{
    return nil;
}

/**
 *  将属性名换为其他key
 *
 */
+ (NSDictionary *)yh_replacedKeyFromPropertyName{
    return nil;
}

/**
 *  将属性是一个模型对象:字典再根据属性名获取value作为字段名
    示例：@{@"tea":[NSString stringWithFormat:@"tea%@",YHDB_AppendingID]}；
 *
 */
+ (NSDictionary*)yh_replacedKeyFromDictionaryWhenPropertyIsObject{
    return nil;
}

+ (NSDictionary *)yh_getClassForKeyIsObject{
    return nil;
}

+ (void)yh_objectIvar_nameAndIvar_typeWithOption:(RuntimeObjectIvarsOption )option{
    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList(self, &count);
    for (int i =0; i < count; i++) {
        Ivar ivar = ivars[i];
        /** 成员变量名 */
        NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
        const char *type = ivar_getTypeEncoding(ivar);
        NSInteger ivar_type = (NSInteger ) type[0];
        NSString *ivar_name = [key substringFromIndex:1];
        YHDBRuntimeIvar *model = [YHDBRuntimeIvar new];
        model.name = ivar_name;
        model.type = ivar_type;
        model.typeName = [NSString stringWithCString:type encoding:NSUTF8StringEncoding];
        if (option) {
            option(model);
        }
    }
    free(ivars);
}

#pragma mark -- SQL
+ (NSString *)yh_sqlForCreatTable:(NSString *)table primaryKey:(NSString *)primaryKey{
    return [self yh_sqlForCreateTable:table primaryKey:primaryKey extraKeyValues:nil];
}

+ (NSString *)yh_sqlForCreateTable:(NSString *)table primaryKey:(NSString *)primaryKey  extraKeyValues:(NSArray <YHDBRuntimeIvar *> *)extraKeyValues{
   
    __block NSString *initSql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (",table];
    initSql = [initSql stringByAppendingString:[NSString stringWithFormat:@"%@ INTEGER PRIMARY KEY AUTOINCREMENT,",YHDB_AutoIncreaseID]];
    NSArray *arrProDonotSave = [[self class] yh_propertyDonotSave];
    
    [self yh_objectIvar_nameAndIvar_typeWithOption:^(YHDBRuntimeIvar *ivar) {
        [self yh_replaceKeyWithIvarModel:ivar option:^(YHDBRuntimeIvar *ivar) {
            
            for (NSString *proNameDonotSave in arrProDonotSave) {
                if([proNameDonotSave isEqualToString:ivar.name]){
                    
                    return;
                }
            }
            
            initSql = [initSql stringByAppendingString:[self yh_sqlWithExtraKeyValue:@[ivar] primaryKey:primaryKey]];
        }];
        
    }];
    if (extraKeyValues) {
        initSql = [initSql stringByAppendingString:[self yh_sqlWithExtraKeyValue:extraKeyValues primaryKey:primaryKey]];
    }
    initSql = [initSql substringToIndex:initSql.length-1];
    initSql = [initSql stringByAppendingString:@");"];
    return initSql;
    
}


+ (NSString *)yh_sqlForCreateTableWithPrimaryKey:(NSString *)primaryKey {
    return [self yh_sqlForCreateTableWithPrimaryKey:primaryKey extraKeyValues:nil];
}

+ (NSString *)yh_sqlForCreateTableWithPrimaryKey:(NSString *)primaryKey  extraKeyValues:(NSArray <YHDBRuntimeIvar *> *)extraKeyValues{
    
    __block NSString *initSql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (",NSStringFromClass([self class])];
    
    [self yh_objectIvar_nameAndIvar_typeWithOption:^(YHDBRuntimeIvar *ivar) {
        [self yh_replaceKeyWithIvarModel:ivar option:^(YHDBRuntimeIvar *ivar) {
            
            initSql = [initSql stringByAppendingString:[self yh_sqlWithExtraKeyValue:@[ivar] primaryKey:primaryKey]];
        }];
        
    }];
    if (extraKeyValues) {
        initSql = [initSql stringByAppendingString:[self yh_sqlWithExtraKeyValue:extraKeyValues primaryKey:primaryKey]];
    }
    initSql = [initSql substringToIndex:initSql.length-1];
    initSql = [initSql stringByAppendingString:@");"];
    return initSql;

}

+ (NSString *)yh_sqlWithExtraKeyValue:(NSArray *)extraKeyValues primaryKey:(NSString *)primaryKey{
    NSString *initSql = @"";
    for (YHDBRuntimeIvar *model in extraKeyValues) {
        NSString *ivar_name = model.name;
        NSInteger ivar_type = model.type;
        if (ivar_type == RuntimeObjectIvarTypeDoubleAndFloat) {
            initSql = [initSql stringByAppendingString:[NSString stringWithFormat:@"%@ double DEFAULT NULL,",ivar_name]];
        }else if(ivar_type == RuntimeObjectIvarTypeObject){
            initSql = [initSql stringByAppendingString:[NSString stringWithFormat:@"%@ text DEFAULT NULL,",ivar_name]];
        }else if (ivar_type == RuntimeObjectIvarTypeArray){
            initSql = [initSql stringByAppendingString:[NSString stringWithFormat:@"%@ text DEFAULT NULL,",ivar_name]];
        }else if (ivar_type == RuntimeObjectIvarTypeData){
            initSql = [initSql stringByAppendingString:[NSString stringWithFormat:@"%@ text DEFAULT NULL,",ivar_name]];
        }else if (ivar_type == RuntimeObjectIvarTypeImage){
            initSql = [initSql stringByAppendingString:[NSString stringWithFormat:@"%@ text DEFAULT NULL,",ivar_name]];
        }else{
            /** id */
            if ([ivar_name isEqualToString:primaryKey] ) {
                initSql = [initSql stringByAppendingString:[NSString stringWithFormat:@"%@ integer(11) PRIMARY KEY ,",ivar_name]];
            }else
                initSql = [initSql stringByAppendingString:[NSString stringWithFormat:@"%@ long DEFAULT NULL,",ivar_name]];
        }
    }
    return initSql;
}

//查询语句
+ (NSString *)yh_sqlForExcuteWithTable:(NSString *)table primaryKey:(NSString *)primaryKey userInfo:(NSDictionary *)userInfo fuzzyUserInfo:(NSDictionary *)fuzzyUserInfo otherSQL:(NSDictionary *)otherSQL value:(id )value{
    
    NSString *tableName = nil;
    if (!table) {
        tableName = NSStringFromClass(self);
    }else{
        tableName = table;
    }
    
    NSString *sql  = @"";
    id priKeyValue = value;
    if (priKeyValue) {
      sql = [NSString stringWithFormat:@"select * from '%@' where %@ = '%@'",tableName,primaryKey,priKeyValue];
    }else{
        sql = [NSString stringWithFormat:@"select * from '%@' where",NSStringFromClass(self)];
    }
    
    //拼接条件查询参数
    for (int i =0 ; i< userInfo.allKeys.count; i++) {
         NSString *key = userInfo.allKeys[i];
         id value =  [userInfo valueForKey:key];
        NSString *sql2 = nil;
        if([value isKindOfClass:[NSString class]]){
            sql2 = [NSString stringWithFormat:@"%@ = '%@'",key,value];
        }else{
            sql2 = [NSString stringWithFormat:@"%@ = %@",key,value];
        }
      
        if (userInfo.allKeys.count == 1) {
            //只有一个key
            if (priKeyValue) {
                 sql = [sql stringByAppendingString:[NSString stringWithFormat:@" and %@ ",sql2]];
            }else{
                 sql = [sql stringByAppendingString:[NSString stringWithFormat:@" %@ ",sql2]];
            }
            
        }else{
            if (i == userInfo.allKeys.count-1) {
                sql = [sql stringByAppendingString:sql2];
            }else{
                if(priKeyValue){
                    sql = [sql stringByAppendingString:[NSString stringWithFormat:@" and %@ and ",sql2]];
                }else{
                    sql = [sql stringByAppendingString:[NSString stringWithFormat:@"  %@ and ",sql2]];
                }
            }
        }
       
    }
    
    
    //拼接模糊查询参数
    for (int i =0 ; i< fuzzyUserInfo.allKeys.count; i++) {
        NSString *key = fuzzyUserInfo.allKeys[i];
        id value =  [fuzzyUserInfo valueForKey:key];
        NSString *sql3 = nil;
        if([value isKindOfClass:[NSString class]]){
            sql3 = [NSString stringWithFormat:@"%@ like '%%%@%%'",key,value];
        }else{
            sql3 = [NSString stringWithFormat:@"%@ like %%%@%%",key,value];
        }
        
        if (fuzzyUserInfo.allKeys.count == 1) {
            //只有一个key
            if (priKeyValue || userInfo.allKeys.count) {
                sql = [sql stringByAppendingString:[NSString stringWithFormat:@" and %@ ",sql3]];
            }else{
                sql = [sql stringByAppendingString:[NSString stringWithFormat:@" %@ ",sql3]];
            }
            
        }else{
            if (i == fuzzyUserInfo.allKeys.count-1) {
                sql = [sql stringByAppendingString:sql3];
            }else{
                if(priKeyValue || userInfo.allKeys.count){
                    sql = [sql stringByAppendingString:[NSString stringWithFormat:@" and %@ and ",sql3]];
                }else{
                    sql = [sql stringByAppendingString:[NSString stringWithFormat:@"  %@ and ",sql3]];
                }
            }
        }
        
    }
    
    
    return sql ;
}



#pragma mark -- replaceKeyValue
/** 通过属性名获取正确的字段名 */
+ (void)yh_replaceKeyWithIvarModel:(YHDBRuntimeIvar *)model option:(RuntimeObjectIvarsOption )option {
    
    NSInteger ivar_type = model.type;
    NSString *ivar_name = model.name;
    NSString *typeName  = model.typeName;
    NSString *newIvarName = [[self yh_replacedKeyFromPropertyName] objectForKey:ivar_name];
    ivar_name = (newIvarName ) ? newIvarName : ivar_name;
    
    /** 如果属性名是对象模型名字，取值替换 */
    if ([self yh_replacedKeyFromDictionaryWhenPropertyIsObject] && [[self yh_replacedKeyFromDictionaryWhenPropertyIsObject] objectForKey:ivar_name]) {
        ivar_name =  [[self yh_replacedKeyFromDictionaryWhenPropertyIsObject] objectForKey:ivar_name];
        // 将类型重置为 非对象类型
        ivar_type = RuntimeObjectIvarTypeOther;
    }
    
    if ([self yh_propertyIsInstanceOfArray]) {
        if ([[self yh_propertyIsInstanceOfArray] objectForKey:ivar_name]) {
            ivar_type = RuntimeObjectIvarTypeArray;
        }
    }else if ([self yh_propertyIsInstanceOfImage]) {
        if ([[self yh_propertyIsInstanceOfImage] objectForKey:ivar_name]) {
            ivar_type = RuntimeObjectIvarTypeImage;
        }
    }else if ([self yh_propertyIsInstanceOfData] && [[self yh_propertyIsInstanceOfData] objectForKey:ivar_name]) {
        ivar_type = RuntimeObjectIvarTypeData;
    }
    
    YHDBRuntimeIvar *ivar = [YHDBRuntimeIvar new];
    ivar.name     = ivar_name;
    ivar.type     = ivar_type;
    ivar.typeName = typeName;
    if (option) {
        option(ivar);
    }
}

+ (NSArray *)yh_propertyDonotSave{
    return nil;
}

@end
