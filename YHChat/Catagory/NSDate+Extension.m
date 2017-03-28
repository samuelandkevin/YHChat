//
//  NSDate+Extension.m
//  YHChat
//
//  Created by samuelandkevin on 17/3/22.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "NSDate+Extension.h"

@interface NSDate()
@property (nonatomic,strong) NSDateFormatter *sharedDateFormatter;
@end

@implementation NSDate (Extension)

static NSDateFormatter * sharedDateFormatterInstance;

#pragma mark - Lazy Load
- (NSDateFormatter *)sharedDateFormatter {
    if(sharedDateFormatterInstance == nil)
        sharedDateFormatterInstance = [[NSDateFormatter alloc] init];
    return sharedDateFormatterInstance;
}


+ (NSString *)showDateString:(NSString *)dateString{
    if (!dateString) {
        return @"";
    }
    NSDate *date = [self dateByStringFormat:@"yyyy-MM-dd HH:mm:ss" dateString:dateString];
    return [self getNormalShowDateString:date];
}


+ (NSString *)getNormalShowDateString:(NSDate *)date{
    
    NSDate *nowDate      =  [NSDate date];
    NSString *dateStr    =  [date toStringByformat:@"yyyy-MM-dd"];
    NSString *curDateStr =  [nowDate toStringByformat:@"yyyy-MM-dd"];
    
    if ([dateStr isEqualToString:curDateStr])
    {
        //当天信息
        
        NSInteger hour =  [[date toStringByformat:@"HH"] integerValue];
        NSString *strMonment = @"";
        if(hour < 6){
            strMonment = @"凌晨";
        }
        else if (hour < 12){
            strMonment = @"上午";
        }
        else if (hour < 18){
            strMonment = @"下午";
        }
        else{
            strMonment = @"晚上";
        }
        
        return [date toStringByformat:[NSString stringWithFormat:@"%@ HH:mm",strMonment]];
    }
    else
    {
        NSDate *yesterday = [NSDate dateWithTimeIntervalSince1970:[nowDate timeIntervalSince1970]-(24*60*60)];
        NSDate *dayBeforeYesterday = [NSDate dateWithTimeIntervalSince1970:[nowDate timeIntervalSince1970] - 48*60*60];
        
        NSString *yesterdatStr =  [yesterday toStringByformat:@"yyyy-MM-dd"];
        NSString *dayBeYesdatStr  =  [dayBeforeYesterday toStringByformat:@"yyyy-MM-dd"];
        if ([dateStr isEqualToString:yesterdatStr])//昨天
        {
            return [date toStringByformat:@"昨天 HH:mm" ];
        }
        else if ([dateStr isEqualToString:dayBeYesdatStr])
        {
            return [date toStringByformat:@"前天 HH:mm"];
        }
        else
        {
            NSString *dateStr = [date toStringByformat:@"yyyy" ];
            NSString *curDateStr = [nowDate toStringByformat:@"yyyy"];
            if ([dateStr isEqualToString:curDateStr])//当年
            {
                NSString *toString = [date toStringByformat:@"M月d日"];
                return toString;
                
            }
            else//超过一年
            {
                return [date toStringByformat:@"yyyy年MM月dd日"];
            }
        }
    }
}

+ (BOOL)compareWithBeginDateString:(NSString *)beginDateString andEndDateString:(NSString *)endDateString
{
    NSDate *beginDate = [NSDate new];
    NSDate *endDate =  [NSDate new];
    
    [beginDate.sharedDateFormatter setDateFormat:@"yyyy-MM"];
    [endDate.sharedDateFormatter setDateFormat:@"yyyy-MM"];
    
    beginDate = [beginDate.sharedDateFormatter dateFromString:beginDateString];
    endDate   = [endDate.sharedDateFormatter dateFromString:endDateString];
    NSComparisonResult result = [beginDate compare:endDate];
    
    if (result == NSOrderedAscending)
    {
        return YES;
    }
    return NO;
}

/**
 *  格式化日期
 *
 *  @param dateFormat 日期格式，etg：@"yyyy-MM-dd HH:mm:ss"
 *
 *  @return 字符串
 */
- (NSString *)toStringByformat:(NSString *)dateFormat
{
    
    [self.sharedDateFormatter setDateFormat:dateFormat];
    NSString *returnString = [self.sharedDateFormatter stringFromDate:self];
    return returnString;
}

//获取固定的时间格式的当前时间 @"yyyy-MM-dd HH:mm:ss"
- (NSString *)getNowDate{
    NSString *dateFormat = @"yyyy-MM-dd HH:mm:ss";
    [self.sharedDateFormatter setDateFormat:dateFormat];
    NSString *returnString = [self.sharedDateFormatter stringFromDate:self];
    
    return returnString;
}

//根据字符串格式转换字符串为日期
+(NSDate *)dateByStringFormat:(NSString *)format dateString:(NSString *)dateString{
    NSDate * date = [[NSDate alloc] init];
    [date.sharedDateFormatter setDateFormat:format];
    date = [date.sharedDateFormatter dateFromString:dateString];
    return date;
}

+(NSDate *)dateByYear:(NSInteger)year month:(NSInteger)month date:(NSInteger)date hour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second{
    
    NSDate *dateObj = [[NSDate alloc] init];
    
    [dateObj.sharedDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateObj.sharedDateFormatter dateFromString:[NSString stringWithFormat:@"%4ld-%2ld-%2ld %2ld:%2ld:%2ld",(long)year,(long)month,(long)date,(long)hour,(long)minute,(long)second]];
    return dateObj;
}

+(NSString *) compareCurrentTime:(NSDate*) compareDate
{
    NSTimeInterval  timeInterval = [compareDate timeIntervalSinceNow];
    timeInterval = -timeInterval;
    long temp = 0;
    NSString *result;
    if (timeInterval < 60) {
        result = [NSString stringWithFormat:@"刚刚"];
    }
    else if((temp = timeInterval/60) <60){
        result = [NSString stringWithFormat:@"%ld分前",temp];
    }
    
    else if((temp = temp/60) <24){
        result = [NSString stringWithFormat:@"%ld小前",temp];
    }
    
    else if((temp = temp/24) <=3){
        result = [NSString stringWithFormat:@"%ld天前",temp];
    }
    else if((temp = temp/30) <12){
        result = [NSString stringWithFormat:@"%ld月前",temp];
    }
    else{
        result = [compareDate toStringByformat:@"yyyy-MM-dd"];
    }
    
    return  result;
}

//获取NSDate的年份部分
+ (NSInteger)getFullYear:(NSDate *)date{
    
    [date.sharedDateFormatter setDateFormat:@"yyyy"];
    NSString *yearStr = [date.sharedDateFormatter stringFromDate:date];
    return atoi([yearStr UTF8String]);
}

//获取NSDate的月份部分
+(NSInteger)getMonth:(NSDate *)date{
    
    [date.sharedDateFormatter setDateFormat:@"MM"];
    NSString *monthStr = [date.sharedDateFormatter stringFromDate:date];
    return atoi([monthStr UTF8String]);
    
}
//获取NSDate的日期部分
+(NSInteger)getDate:(NSDate *)date{
    
    [date.sharedDateFormatter setDateFormat:@"dd"];
    NSString *dateStr = [date.sharedDateFormatter stringFromDate:date];
    return atoi([dateStr UTF8String]);
}
//获取NSDate的小时部分
+(NSInteger)getHour:(NSDate *)date{
    
    [date.sharedDateFormatter setDateFormat:@"HH"];
    NSString *hourStr=[date.sharedDateFormatter stringFromDate:date];
    return atoi([hourStr UTF8String]);
}
//获取NSDate的分钟部分
+(NSInteger)getMinute:(NSDate *)date{
    
    date = [date.sharedDateFormatter dateFromString:@"mm"];
    NSString *minuteStr=[date.sharedDateFormatter stringFromDate:date];
    return atoi([minuteStr UTF8String]);
}
//获取NSDate的秒部分
+(NSInteger)getSecond:(NSDate *)date{
    
    date = [date.sharedDateFormatter dateFromString:@"ss"];
    NSString *secondStr=[date.sharedDateFormatter stringFromDate:date];
    return atoi([secondStr UTF8String]);
}


@end
