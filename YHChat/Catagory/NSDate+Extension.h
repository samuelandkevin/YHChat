//
//  NSDate+Extension.h
//  YHChat
//
//  Created by samuelandkevin on 17/3/22.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Extension)

+ (NSString *)showDateString:(NSString *)dateString;

+ (BOOL)compareWithBeginDateString:(NSString *)beginDateString andEndDateString:(NSString *)endDateString;
/**
 *  格式化日期
 *
 *  @param dateFormat 日期格式，etg：@"yyyy-MM-dd HH:mm:ss"
 *
 *  @return 字符串
 */
- (NSString *)toStringByformat:(NSString *)dateFormat;

//获取固定的时间格式的当前时间 @"yyyy-MM-dd'T'HH:mm:ss"
- (NSString *)getNowDate;

//根据字符串格式转换字符串为日期
+(NSDate *)dateByStringFormat:(NSString *)format dateString:(NSString *)dateString;

//根据年月日返回日期
+(NSDate *)dateByYear:(NSInteger)year month:(NSInteger)month date:(NSInteger)date hour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second;

//返回指定时间和当前时间相比后的时间描述
+(NSString *) compareCurrentTime:(NSDate*) compareDate;

//获取NSDate的年份部分
+(NSInteger)getFullYear:(NSDate *)date;
//获取NSDate的月份部分
+(NSInteger)getMonth:(NSDate *)date;
//获取NSDate的日期部分
+(NSInteger)getDate:(NSDate *)date;
//获取NSDate的小时部分
+(NSInteger)getHour:(NSDate *)date;
//获取NSDate的分钟部分
+(NSInteger)getMinute:(NSDate *)date;
//获取NSDate的秒部分
+(NSInteger)getSecond:(NSDate *)date;

@end
