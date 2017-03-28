//
//  YHChatManager.m
//  YHChat
//
//  Created by samuelandkevin on 17/3/16.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "YHChatManager.h"
#import <SocketRocket/SocketRocket.h>

@interface YHChatManager()<SRWebSocketDelegate>
@property (nonatomic,strong) SRWebSocket *socket;
@property (nonatomic,strong) dispatch_queue_t socketQueue;
@end

@implementation YHChatManager

+ (YHChatManager*)sharedInstance{
    static YHChatManager  *g_sharedInstance = nil;
    static dispatch_once_t pre = 0;
    dispatch_once(&pre, ^{
        g_sharedInstance = [[YHChatManager alloc] init];
    });
    return g_sharedInstance;
}

#pragma mark - Public
//连接
- (void)connectToUserID:(NSString *)toUserId isGroupChat:(BOOL)isGroupChat{
    //wss://apps.gtax.cn/taxtao/web_im.ws?access_token=&is_group=&to_user_id=&type=0
    //is_group 是否群聊0否 1是
    NSString *token   = @"E0BF81BFCC0349ECAF6E2F85D0704FDB";
    NSString *isGroup = isGroupChat?@"1":@"0";
    NSString *urlStr  = [NSString stringWithFormat:@"wss://apps.gtax.cn/taxtao/web_im.ws?access_token=%@&is_group=%@&to_user_id=%@&type=0" ,token,isGroup,toUserId];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    _socket = [[SRWebSocket alloc] initWithURLRequest:
                           [NSURLRequest requestWithURL:url]];
    _socketQueue = dispatch_queue_create("com.yhsoft.sockeQueue", DISPATCH_QUEUE_SERIAL);
    _socket.delegate = self;
    [_socket open];
}

//关闭连接
- (void)close{
    [_socket close];
    _socket = nil;
    _socketQueue = nil;
}


#pragma mark - @protocol SRWebSocketDelegate
- (void)webSocketDidOpen:(SRWebSocket *)webSocket{
     DDLog(@"连接成功，可以立刻登录你公司后台的服务器了，还有开启心跳");
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message{
    DDLog(@"收到数据了:%@",message);
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error{
    DDLog(@"连接失败,%@",error);
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(nullable NSString *)reason wasClean:(BOOL)wasClean{
     DDLog(@"连接断开，清空socket对象，清空该清空的东西，还有关闭心跳！");
}


@end
