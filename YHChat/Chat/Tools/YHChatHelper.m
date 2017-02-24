//
//  YHChatHelper.m
//  YHChat
//
//  Created by YHIOS002 on 17/2/22.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "YHChatHelper.h"
#import "YHChatModel.h"

@implementation YHChatHelper

#pragma mark - 产生模拟数据源 (模拟服务器数据,实际开发可删除)
//随机生成totalCount数量的聊天记录
+ (NSArray <YHChatModel *>*)randomGenerateChatModel:(int)totalCount{
    
    NSMutableArray *retArr = [NSMutableArray arrayWithCapacity:totalCount];
    for (int i=0; i<totalCount; i++) {
        YHChatModel *model = [self _creatOneChatModelWithTotalCount:totalCount];
        [retArr addObject:model];
    }
    return retArr;
}

+ (YHChatModel *)_creatOneChatModelWithTotalCount:(int)totalCount{
    
    YHChatModel *model = [YHChatModel new];
    
    //用户ID
    NSArray *uidArr = @[@"1",@"2",@"3",@"4"];
    int nUidLength  = arc4random() % uidArr.count;
    model.speakerId = uidArr[nUidLength];
    if ([model.speakerId isEqualToString:MYUID]) {
        model.direction = 0;
    }else{
        model.direction = 1;
    }
    
    //发言者头像
    NSArray *avtarArray = @[
                            @"http://testapp.gtax.cn/images/2016/11/09/64a62eaaff7b466bb8fab12a89fe5f2f.png!m90x90.png",
                            @"https://testapp.gtax.cn/images/2016/09/30/ad0d18a937b248f88d29c2f259c14b5e.jpg!m90x90.jpg",
                            @"https://testapp.gtax.cn/images/2016/09/14/c6ab40b1bc0e4bf19e54107ee2299523.jpg!m90x90.jpg",
                            @"http://testapp.gtax.cn/images/2016/11/14/8d4ee23d9f5243f98c79b9ce0c699bd9.png!m90x90.png",
                            @"https://testapp.gtax.cn/images/2016/09/14/8cfa9bd12e6844eea0a2e940257e1186.jpg!m90x90.jpg"];
    int avtarIndex = arc4random() % avtarArray.count;
    if (avtarIndex < avtarArray.count) {
        
        if ([model.speakerId isEqualToString:MYUID]) {
            model.speakerAvatar = MYAVTARURL;
        }else{
            model.speakerAvatar = [NSURL URLWithString:avtarArray[avtarIndex]];
        }
        
    }
    
    //聊天记录ID
    CGFloat myIdLength = arc4random() % totalCount;
    int result = (int)myIdLength % 2;
    model.chatId = [NSString stringWithFormat:@"%d",result];;
    
    //名字
    CGFloat nLength = arc4random() % 3 + 1;
    NSMutableString *nStr = [NSMutableString new];
    for (int i = 0; i < nLength; i++) {
        [nStr appendString: @"测试名字"];
    }
    if ([model.speakerId isEqualToString:MYUID]) {
        model.speakerName = @"我";
    }else{
        model.audienceName = nStr;
    }
    
    
    //消息类型
    NSArray *msgTypeArr = @[@(0),@(1),@(2),@(3)];
    int nMsgTypeLength  = arc4random() % msgTypeArr.count;
    model.msgType = nMsgTypeLength;

    //消息内容为文本
    CGFloat qlength = arc4random() % totalCount+1;
    NSMutableString *qStr = [[NSMutableString alloc] init];
    for (NSUInteger i = 0; i < qlength; ++i) {
        [qStr appendString:@"消息内容很长，消息内容很长."];
    }
    model.msgContent = qStr;
    
    //消息内容为图片
    NSArray *imgMsgArr = @[@"img[https://testapp.gtax.cn/images/2016/08/25/2241c4b32b8445da87532d6044888f3d.jpg!t300x300.jpg]",
                           
                           @"img[https://testapp.gtax.cn/images/2016/08/25/0abd8670e96e4357961fab47ba3a1652.jpg!t300x300.jpg]",
                           
                           @"img[https://testapp.gtax.cn/images/2016/08/25/5cd8aa1f1b1f4b2db25c51410f473e60.jpg!t300x300.jpg]",
                           
                           @"img[https://testapp.gtax.cn/images/2016/08/25/5e8b978854ef4a028d284f6ddc7512e0.jpg!t300x300.jpg]",
                           
                           @"img[https://testapp.gtax.cn/images/2016/08/25/03c58da45900428796fafcb3d77b6fad.jpg!t300x300.jpg]",
                           
                           @"img[https://testapp.gtax.cn/images/2016/08/25/dbee521788da494683ef336432028d48.jpg!t300x300.jpg]",
                           
                           @"img[https://testapp.gtax.cn/images/2016/08/25/4cd95742b6744114ac8fa41a72f83257.jpg!t300x300.jpg]",
                           
                           @"img[https://testapp.gtax.cn/images/2016/08/25/4d49888355a941cab921c9f1ad118721.jpg!t300x300.jpg]",
                           
                           @"img[https://testapp.gtax.cn/images/2016/08/25/ea6a22e8b4794b9ba63fd6ee587be4d1.jpg!t300x300.jpg]"];
    int imglength = arc4random() % imgMsgArr.count;
    if (model.msgType == 1) {
        model.msgContent = imgMsgArr[imglength];
    }
    
    
    
    //发布时间
    model.createTime = @"2013-04-17";
    
    return model;
}


#pragma mark - Public
+ (YHChatModel *)creatMessage:(NSString *)msg msgType:(YHMessageType)msgType  toID:(NSString *)toID {
    YHChatModel *model  = [YHChatModel new];
    model.speakerId     = MYUID;
    model.speakerAvatar = MYAVTARURL;
    model.direction     = 0;
    model.msgType       = msgType;
    model.audienceId = toID;
    model.chatType   = msgType;
    model.msgContent = msg;
    model.timestamp  = [YHChatHelper currentMsgTime];
    return model;
}

// current message time
+ (int)currentMsgTime
{
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    int iTime     = (int)(time * 1000);
    return iTime;
}
@end
