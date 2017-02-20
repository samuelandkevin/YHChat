//
//  YHExpressionHelper.h
//
//
//  Created by samuelandkevin on 17/2/10.
//  Copyright (c) 2017 samuelandkevin. All rights reserved.
//

#import "YYKit.h"
#import "YHModel.h"

@interface YHExpressionHelper : NSObject


/// 表情资源 bundle
+ (NSBundle *)emoticonBundle;

/// 表情 Array<YHEmoticonGroup> (实际应该做成动态更新的)
+ (NSArray<YHEmoticonGroup *> *)emoticonGroups;

/// 图片 cache
+ (YYMemoryCache *)imageCache;

/// 从 toolBarBundle / extraBundle 里获取图片 (有缓存)
+ (UIImage *)imageNamed:(NSString *)name;

/// 从path创建图片 (有缓存)
+ (UIImage *)imageWithPath:(NSString *)path;

/// 获取“+” models
+ (NSArray <YHExtraModel*>*)extraModels;

+ (NSRegularExpression *)regexEmoticon;

+ (NSDictionary *)emoticonDic;
@end
