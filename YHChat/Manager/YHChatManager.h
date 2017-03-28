//
//  YHChatManager.h
//  YHChat
//
//  Created by samuelandkevin on 17/3/16.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YHChatManager : NSObject

+ (YHChatManager*)sharedInstance;

//连接
- (void)connectToUserID:(NSString *)toUserId isGroupChat:(BOOL)isGroupChat;
//关闭
- (void)close;
@end
