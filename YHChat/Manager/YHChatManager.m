//
//  YHChatManager.m
//  YHChat
//
//  Created by YHIOS002 on 17/3/16.
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

//发送消息
- (void)sendData:(id)data {
    WeakSelf
    dispatch_async(self.socketQueue, ^{
        if (weakSelf.socket != nil) {
            // 只有 SR_OPEN 开启状态才能调 send 方法啊，不然要崩
            if (weakSelf.socket.readyState == SR_OPEN) {
                [weakSelf.socket send:data];    // 发送数据
                
            } else if (weakSelf.socket.readyState == SR_CONNECTING) {
                DDLog(@"正在连接中，重连后其他方法会去自动同步数据");
                // 每隔2秒检测一次 socket.readyState 状态，检测 10 次左右
                // 只要有一次状态是 SR_OPEN 的就调用 [weakSelf.socket send:data] 发送数据
                // 如果 10 次都还是没连上的，那这个发送请求就丢失了，这种情况是服务器的问题了，小概率的
                // 代码有点长，我就写个逻辑在这里好了
                
            } else if (weakSelf.socket.readyState == SR_CLOSING || weakSelf.socket.readyState == SR_CLOSED) {
                // websocket 断开了，调用 reConnect 方法重连
                
            }
        } else {
            DDLog(@"没网络，发送失败，一旦断网 socket 会被我设置 nil 的");
            DDLog(@"其实最好是发送前判断一下网络状态比较好，我写的有点晦涩，socket==nil来表示断网");
        }
    });
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
