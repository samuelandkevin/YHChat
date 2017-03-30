//
//  NSObject+Runtime.h
//  
//
//  Created by YHIOS002 on 16/11/9.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface YHDBRuntimeIvar : NSObject

/** 模型属性的名称 */
@property (nonatomic, copy) NSString *name;

/** 模型属性的类型值 */
@property(nonatomic,assign) NSInteger type;

/** 模型属性类型名称 */
@property(nonatomic,copy)   NSString  *typeName;

@end


/** ivar_name:属性名，如果符合主键声明条件会自动替换成主键：YHDB_PrimaryKey */
#define YHDB_EqualsPrimaryKey(ivar_name)         if ([[[model class] yh_primaryKey] isEqualToString:ivar_name]) ivar_name = YHDB_PrimaryKey;
/** 模型属性，建表时字段所加的后缀 */
extern NSString *const YHDB_AppendingID;
/** 所有表的主键默认设置 */
extern NSString *const YHDB_PrimaryKey;

typedef enum{
    /** 字符串类型 */
    RuntimeObjectIvarTypeObject = 64,
    /** 浮点型 */
    RuntimeObjectIvarTypeDoubleAndFloat = 100,
    /** 数组 */
    RuntimeObjectIvarTypeArray = 65,
    /** 流：data */
    RuntimeObjectIvarTypeData = 66,
    /** 图片：image */
    RuntimeObjectIvarTypeImage = 67,
    /** 其他(在数据库中使用long进行取值) */
    RuntimeObjectIvarTypeOther = -1
}RuntimeObjectIvarType;

typedef void(^RuntimeObjectIvarsOption)(YHDBRuntimeIvar *ivar);

@interface NSObject (YHDBRuntime)

/**
 * 实现该方法，则必须实现：yh_replacedKeyFromPropertyName
 * 设置主键:能够唯一标示该模型的属性
 *
 */
+ (NSString *)yh_primaryKey;

/**
 *  将属性为数组
 *
 */
+ (NSDictionary *)yh_propertyIsInstanceOfArray;

/**
 *  将属性为NSDATA
 *
 */
+ (NSDictionary *)yh_propertyIsInstanceOfData;

/**
 *  将属性为UIImage
 *
 */
+ (NSDictionary *)yh_propertyIsInstanceOfImage;

/**
 *  只有这个数组中的属性名才允许
 */
+ (NSArray *)yh_allowedPropertyNames;

/**
 *  这个数组中的属性名将会被忽略：不进行
 */
+ (NSArray *)yh_ignoredPropertyNames;

/**
 *  将属性名换为其他key
 *
 */
+ (NSDictionary *)yh_replacedKeyFromPropertyName;

/**
 *  将属性是一个模型对象:字典再根据属性名获取value作为字段名
 *
 */
+ (NSDictionary*)yh_replacedKeyFromDictionaryWhenPropertyIsObject;
/**
 *  key : 模型对象的名字
 *  通过key获取类名
 */
+ (NSDictionary *)yh_getClassForKeyIsObject;


/** 获取对象的属性名和属性类型 */
+ (void)yh_objectIvar_nameAndIvar_typeWithOption:(RuntimeObjectIvarsOption )option;

+ (void)yh_replaceKeyWithIvarModel:(YHDBRuntimeIvar *)model option:(RuntimeObjectIvarsOption )option ;

/** 不保存到数据库的属性集合 */
+ (NSArray *)yh_propertyDonotSave;


/** 创表*/
//创表一:自定义表名
+ (NSString *)yh_sqlForCreatTable:(NSString *)table primaryKey:(NSString *)primaryKey;
//创表二:表名默认为类名
+ (NSString *)yh_sqlForCreateTableWithPrimaryKey:(NSString *)primaryKey ;

/**创表：除模型的属性之外， 有多余的字段 */
//创表三:
+ (NSString *)yh_sqlForCreateTable:(NSString *)table primaryKey:(NSString *)primaryKey  extraKeyValues:(NSArray <YHDBRuntimeIvar *> *)extraKeyValues;


//条件查询语句
+ (NSString *)yh_sqlForExcuteWithTable:(NSString *)table primaryKey:(NSString *)primaryKey userInfo:(NSDictionary *)userInfo fuzzyUserInfo:(NSDictionary *)fuzzyUserInfo otherSQL:(NSDictionary *)otherSQL value:(id )value;



@end
