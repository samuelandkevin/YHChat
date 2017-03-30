//
//  FMDatabase+YHDatabase.h
//  
//
//  Created by YHIOS002 on 16/11/8.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import "FMDB.h"

//补充其他SQL语句
#define YHOrderKey @"order"             //排序key
#define YHLengthLimitKey @"lengthLimit" //长度限制Key
#define YHGreaterKey @"greater"         //大于Key
#define YHLesserKey  @"lesser"          //小于Key
#define YHUpdateItemKey @"updateItem"   //指定更新字段

typedef void(^YHExistExcuteOption)(BOOL exist);
typedef void(^YHInsertOption)(BOOL insert);
typedef void(^YHUpdateOption)(BOOL update);
typedef void(^YHDeleteOption)(BOOL del);
typedef void(^YHSaveOption)(BOOL save);
typedef void(^YHExcuteOption)(id output_model);
typedef void(^YHAllModelsOption)(NSMutableArray *models);
@interface FMDatabase (YHDatabase)

/** 保存一个模型 */
- (void )yh_saveDataWithTable:(NSString *)table model:(id )model userInfo:(NSDictionary *)userInfo otherSQL:(NSDictionary *)otherSQL option:(YHSaveOption )option;
/** 删除一个模型 */
- (void)yh_deleteDataWithTable:(NSString *)table model:(id )model userInfo:(NSDictionary *)userInfo otherSQL:(NSDictionary *)otherSQL option:(YHDeleteOption )option;
/** 查询某个模型数据 */
- (id )yh_excuteDataWithTable:(NSString *)table model:(id )model  userInfo:(NSDictionary *)userInfo fuzzyUserInfo:(NSDictionary *)fuzzyUserInfo otherSQL:(NSDictionary *)otherSQL option:(YHExcuteOption )option;
/** 查询某种所有的模型数据 */
- (void)yh_excuteDatasWithTable:(NSString *)table model:(id )model userInfo:(NSDictionary *)userInfo fuzzyUserInfo:(NSDictionary *)fuzzyUserInfo otherSQL:(NSDictionary *)otherSQL option:(YHAllModelsOption )option;


#pragma mark -- PrimaryKey
/** 保存一个模型 */
- (void )yh_saveDataWithTable:(NSString *)table model:(id )model  primaryKey:(NSString *)primaryKey userInfo:(NSDictionary *)userInfo otherSQL:(NSDictionary *)otherSQL option:(YHSaveOption )option;
/** 删除一个模型 */
- (void)yh_deleteDataWithTable:(NSString *)table model:(id )model  primaryKey:(NSString *)primaryKey userInfo:(NSDictionary *)userInfo otherSQL:(NSDictionary *)otherSQL option:(YHDeleteOption )option;
/** 查询某个模型数据 */
- (id )yh_excuteDataWithTable:(NSString *)table model:(id )model  primaryKey:(NSString *)primaryKey userInfo:(NSDictionary *)userInfo fuzzyUserInfo:(NSDictionary *)fuzzyUserInfo otherSQL:(NSDictionary *)otherSQL option:(YHExcuteOption )option;
/** 查询某种所有的模型数据 */
- (void)yh_excuteDatasWithTable:(NSString *)table model:(id )model  primaryKey:(NSString *)primaryKey userInfo:(NSDictionary *)userInfo fuzzyUserInfo:(NSDictionary *)fuzzyUserInfo otherSQL:(NSDictionary *)otherSQL option:(YHAllModelsOption )option;

/** 查询表数据条数 */
- (void)numberOfDatasWithTable:(NSString *)table complete:(void(^)(NSInteger count))complete;
#pragma mark -- Method
/** 根据文件名获取文件全路径 */
- (NSString *)fullPathWithFileName:(NSString *)fileName;

@end
