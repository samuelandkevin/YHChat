//
//  YHExpressionHelper.m
//
//
//  Created by samuelandkevin on 17/2/10.
//  Copyright (c) 2017 samuelandkevin. All rights reserved.
//

#import "YHExpressionHelper.h"

#define kWBLinkAtName @"at" //NSString
#define kWBCellTextHighlightColor UIColorHex(527ead) // Link 文本色
#define kWBCellTextHighlightBackgroundColor UIColorHex(bfdffe) // Link 点击背景色

@implementation YHExpressionHelper


+ (NSBundle *)emoticonBundle {
    static NSBundle *bundle;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"ExpressionKeyboard" ofType:@"bundle"];
        bundle = [NSBundle bundleWithPath:bundlePath];
    });
    return bundle;
}

//toolBar资源
+ (NSBundle *)toolBarBundle{
    static NSBundle *bundle;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bundle = [NSBundle bundleWithPath:[[self emoticonBundle].bundlePath stringByAppendingPathComponent:@"toolBar"]];
    });
    return bundle;
}

//"+"资源
+ (NSBundle *)extraBundle{
    static NSBundle *bundle;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bundle = [NSBundle bundleWithPath:[[self emoticonBundle].bundlePath stringByAppendingPathComponent:@"extra"]];
    });
    return bundle;
}

+ (YYMemoryCache *)imageCache {
    static YYMemoryCache *cache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [YYMemoryCache new];
        cache.shouldRemoveAllObjectsOnMemoryWarning = NO;
        cache.shouldRemoveAllObjectsWhenEnteringBackground = NO;
        cache.name = @"WeiboImageCache";
    });
    return cache;
}

+ (UIImage *)imageNamed:(NSString *)name {
    if (!name) return nil;
    UIImage *image = [[self imageCache] objectForKey:name];
    if (image) return image;
    NSString *ext = name.pathExtension;
    if (ext.length == 0) ext = @"png";
    
    NSString *path = [[self toolBarBundle] pathForScaledResource:name ofType:ext];
    if (!path){
        path = [[self extraBundle] pathForScaledResource:name ofType:ext];
    }
    if (!path) {
        return nil;
    }
    
    image = [UIImage imageWithContentsOfFile:path];
    image = [image imageByDecoded];
    if (!image) return nil;
    [[self imageCache] setObject:image forKey:name];
    return image;
}

+ (UIImage *)imageWithPath:(NSString *)path {
    if (!path) return nil;
    UIImage *image = [[self imageCache] objectForKey:path];
    if (image) return image;
    if (path.pathScale == 1) {
        // 查找 @2x @3x 的图片
        NSArray *scales = [NSBundle preferredScales];
        for (NSNumber *scale in scales) {
            image = [UIImage imageWithContentsOfFile:[path stringByAppendingPathScale:scale.floatValue]];
            if (image) break;
        }
    } else {
        image = [UIImage imageWithContentsOfFile:path];
    }
    if (image) {
        image = [image imageByDecoded];
        [[self imageCache] setObject:image forKey:path];
    }
    return image;
}


+ (NSArray <YHExtraModel*>*)extraModels{
    static NSMutableArray *extras;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSString *plistPath = [[self extraBundle].bundlePath stringByAppendingPathComponent:@"info.plist"];
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:plistPath];
        NSArray *more = dict[@"more"];
        NSArray *ret  = [NSArray modelArrayWithClass:[YHExtraModel class] json:more];
        extras = [NSMutableArray arrayWithArray:ret];
        
    });
    return extras;
}

+ (NSArray<YHEmoticonGroup *> *)emoticonGroups {
    static NSMutableArray *groups;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *emoticonBundlePath = [[NSBundle mainBundle] pathForResource:@"ExpressionKeyboard" ofType:@"bundle"];
        NSString *emoticonPlistPath = [emoticonBundlePath stringByAppendingPathComponent:@"emoticons.plist"];
        NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:emoticonPlistPath];
        NSArray *packages = plist[@"packages"];
        groups = (NSMutableArray *)[NSArray modelArrayWithClass:[YHEmoticonGroup class] json:packages];
        
        NSMutableDictionary *groupDic = [NSMutableDictionary new];
        for (int i = 0, max = (int)groups.count; i < max; i++) {
            YHEmoticonGroup *group = groups[i];
            if (group.groupID.length == 0) {
                [groups removeObjectAtIndex:i];
                i--;
                max--;
                continue;
            }
            NSString *path = [emoticonBundlePath stringByAppendingPathComponent:group.groupID];
            NSString *infoPlistPath = [path stringByAppendingPathComponent:@"info.plist"];
            NSDictionary *info = [NSDictionary dictionaryWithContentsOfFile:infoPlistPath];
            [group modelSetWithDictionary:info];
            if (group.emoticons.count == 0) {
                i--;
                max--;
                continue;
            }
            groupDic[group.groupID] = group;
        }
        
        NSArray<NSString *> *additionals = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[emoticonBundlePath stringByAppendingPathComponent:@"additional"] error:nil];
        for (NSString *path in additionals) {
            YHEmoticonGroup *group = groupDic[path];
            if (!group) continue;
            NSString *infoJSONPath = [[[emoticonBundlePath stringByAppendingPathComponent:@"additional"] stringByAppendingPathComponent:path] stringByAppendingPathComponent:@"info.json"];
            NSData *infoJSON = [NSData dataWithContentsOfFile:infoJSONPath];
            YHEmoticonGroup *addGroup = [YHEmoticonGroup modelWithJSON:infoJSON];
            if (addGroup.emoticons.count) {
                for (YHEmoticon *emoticon in addGroup.emoticons) {
                    emoticon.group = group;
                }
                [((NSMutableArray *)group.emoticons) insertObjects:addGroup.emoticons atIndex:0];
            }
        }
    });
    return groups;
}


+ (NSRegularExpression *)regexAt {
    static NSRegularExpression *regex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 微博的 At 只允许 英文数字下划线连字符，和 unicode 4E00~9FA5 范围内的中文字符，这里保持和微博一致。。
        // 目前中文字符范围比这个大
        regex = [NSRegularExpression regularExpressionWithPattern:@"@[-_a-zA-Z0-9\u4E00-\u9FA5]+" options:kNilOptions error:NULL];
    });
    return regex;
}

+ (NSRegularExpression *)regexEmoticon {
    static NSRegularExpression *regex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regex = [NSRegularExpression regularExpressionWithPattern:@"\\[[^ \\[\\]]+?\\]" options:kNilOptions error:NULL];
    });
    return regex;
}

+ (NSRegularExpression *)regexURL{
    static NSRegularExpression *regex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regex = [NSRegularExpression regularExpressionWithPattern:@"\\bhttps?://[a-zA-Z0-9\\-.]+(?::(\\d+))?(?:(?:/[a-zA-Z0-9\\-._?,'+\\&%$=~*!():@\\\\]*)+)?" options:kNilOptions error:NULL];
    });
    return regex;
}

+ (NSDictionary *)emoticonDic {
    static NSMutableDictionary *dic;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *emoticonBundlePath = [self emoticonBundle].bundlePath;
        dic = [self _emoticonDicFromPath:emoticonBundlePath];
    });
    return dic;
}

+ (NSMutableDictionary *)_emoticonDicFromPath:(NSString *)path {
    NSMutableDictionary *dic = [NSMutableDictionary new];
    YHEmoticonGroup *group = nil;
    NSString *jsonPath = [path stringByAppendingPathComponent:@"info.json"];
    NSData *json = [NSData dataWithContentsOfFile:jsonPath];
    if (json.length) {
        group = [YHEmoticonGroup modelWithJSON:json];
    }
    if (!group) {
        NSString *plistPath = [path stringByAppendingPathComponent:@"info.plist"];
        NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:plistPath];
        if (plist.count) {
            group = [YHEmoticonGroup modelWithJSON:plist];
        }
    }
    for (YHEmoticon *emoticon in group.emoticons) {
        if (emoticon.png.length == 0) continue;
        NSString *pngPath = [path stringByAppendingPathComponent:emoticon.png];
        if (emoticon.chs) dic[emoticon.chs] = pngPath;
        if (emoticon.cht) dic[emoticon.cht] = pngPath;
    }
    
    NSArray *folders = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    for (NSString *folder in folders) {
        if (folder.length == 0) continue;
        NSDictionary *subDic = [self _emoticonDicFromPath:[path stringByAppendingPathComponent:folder]];
        if (subDic) {
            [dic addEntriesFromDictionary:subDic];
        }
    }
    return dic;
}

//匹配@,表情后得到的属性字符串
+ (NSMutableAttributedString *)attributedStringWithText:(NSString *)text fontSize:(CGFloat)fontSize textColor:(UIColor *)textColor matchTextColor:(UIColor *)matchTextColor matchTextHighlightBGColor:(UIColor *)matchTextHighlightBGColor{
    
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    NSMutableAttributedString *aStr = [[NSMutableAttributedString alloc] initWithString:text];
    aStr.font = font;
    aStr.color = textColor;
    
    
    // 高亮状态的背景
    YYTextBorder *highlightBorder = [YYTextBorder new];
    highlightBorder.insets = UIEdgeInsetsMake(-2, 0, -2, 0);
    highlightBorder.cornerRadius = 3;
    highlightBorder.fillColor = matchTextHighlightBGColor;
    
    // 匹配 url
    NSArray *ulResults = [[YHExpressionHelper regexURL] matchesInString:aStr.string options:kNilOptions range:text.rangeOfAll];
    for (NSTextCheckingResult *at in ulResults) {
        if (at.range.location == NSNotFound && at.range.length <= 1) continue;
        if ([aStr attribute:YYTextHighlightAttributeName atIndex:at.range.location] == nil) {
            [aStr setColor:matchTextColor range:at.range];
            
            // 高亮状态
            YYTextHighlight *highlight = [YYTextHighlight new];
            [highlight setBackgroundBorder:highlightBorder];
            // 数据信息，用于稍后用户点击
            highlight.userInfo = @{kWBLinkAtName : [aStr.string substringWithRange:NSMakeRange(at.range.location + 1, at.range.length - 1)]};
            [aStr setTextHighlight:highlight range:at.range];
        }
    }
    
    
    
    
    // 匹配 @用户名
    NSArray *atResults = [[YHExpressionHelper regexAt] matchesInString:aStr.string options:kNilOptions range:text.rangeOfAll];
    for (NSTextCheckingResult *at in atResults) {
        if (at.range.location == NSNotFound && at.range.length <= 1) continue;
        if ([aStr attribute:YYTextHighlightAttributeName atIndex:at.range.location] == nil) {
            [aStr setColor:matchTextColor range:at.range];
            
            // 高亮状态
            YYTextHighlight *highlight = [YYTextHighlight new];
            [highlight setBackgroundBorder:highlightBorder];
            // 数据信息，用于稍后用户点击
            highlight.userInfo = @{kWBLinkAtName : [aStr.string substringWithRange:NSMakeRange(at.range.location + 1, at.range.length - 1)]};
            [aStr setTextHighlight:highlight range:at.range];
        }
    }
    
    
    // 匹配 [表情]
    NSArray<NSTextCheckingResult *> *emoticonResults = [[YHExpressionHelper regexEmoticon] matchesInString:aStr.string options:kNilOptions range:text.rangeOfAll];
    NSUInteger emoClipLength = 0;
    for (NSTextCheckingResult *emo in emoticonResults) {
        if (emo.range.location == NSNotFound && emo.range.length <= 1) continue;
        NSRange range = emo.range;
        range.location -= emoClipLength;
        if ([aStr attribute:YYTextHighlightAttributeName atIndex:range.location]) continue;
        if ([aStr attribute:YYTextAttachmentAttributeName atIndex:range.location]) continue;
        NSString *emoString = [aStr.string substringWithRange:range];
        NSString *imagePath = [YHExpressionHelper emoticonDic][emoString];
        UIImage *image = [YHExpressionHelper imageWithPath:imagePath];
        if (!image) continue;
        
        NSAttributedString *emoText = [NSAttributedString attachmentStringWithEmojiImage:image fontSize:fontSize];
        [aStr replaceCharactersInRange:range withAttributedString:emoText];
        emoClipLength += range.length - 1;
    }
    
    return aStr;
    
}

//从缓存中获取属性文本
+ (NSMutableAttributedString *)attributedStringWithCacheAttributeString:(NSMutableAttributedString *)attStr fontSize:(CGFloat)fontSize textColor:(UIColor *)textColor matchTextColor:(UIColor *)matchTextColor matchTextHighlightBGColor:(UIColor *)matchTextHighlightBGColor{
    
    NSMutableAttributedString * retStr = nil;
    NSString *wholeStr = attStr.string;
    NSString *content  = @"";
    NSUInteger location = [wholeStr rangeOfString:@"{\n    CTForegroundColor"].location;
    if (location != NSNotFound) {
        content = [wholeStr substringToIndex:location];
    }
    retStr = [YHExpressionHelper attributedStringWithText:content fontSize:fontSize textColor:textColor matchTextColor:matchTextColor matchTextHighlightBGColor:matchTextHighlightBGColor];
    return retStr;
}


@end
