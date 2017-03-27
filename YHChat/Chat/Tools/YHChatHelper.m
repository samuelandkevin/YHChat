//
//  YHChatHelper.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 17/2/22.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "YHChatHelper.h"
#import "YHChatModel.h"
#import "YHChatHeader.h"
#import "UITableViewCell+HYBMasonryAutoCellHeight.h"
#import "YHExpressionHelper.h"
#import "NSDate+Extension.h"
#import "YHChatTextLayout.h"

@interface YHChatHelper()

@property (nonatomic,strong) NSMutableDictionary *heightDict;

@end

@implementation YHChatHelper

- (instancetype)init{
    if (self = [super init]) {
        self.heightDict = [NSMutableDictionary new];
    }
    return  self;
}

#pragma mark - Public
+ (YHChatModel *)creatMessage:(NSString *)msg msgType:(YHMessageType)msgType  toID:(NSString *)toID {
    YHChatModel *model  = [YHChatModel new];
    model.speakerId     = MYUID;
    model.speakerAvatar = MYAVTARURL;
    model.speakerName   = @"samuelandkevin";
    model.direction     = 0;
    model.msgType       = msgType;
    model.audienceId = toID;
    model.chatType   = msgType;
    model.chatId        = [NSString stringWithFormat:@"%ld",1000 + random()%1000];//本地消息记录ID是手动设置，等消息发送成功后将此替换。
    CGFloat addFontSize = [[[NSUserDefaults standardUserDefaults] valueForKey:kSetSystemFontSize] floatValue];
    
    UIColor *textColor = [UIColor blackColor];
    UIColor *matchTextColor = UIColorHex(527ead);
    UIColor *matchTextHighlightBGColor = UIColorHex(bfdffe);
    if (model.direction == 0) {
        textColor = [UIColor whiteColor];
        matchTextColor = [UIColor greenColor];
        matchTextHighlightBGColor = [UIColor grayColor];
    }
    model.msgContent = msg;
    YHChatTextLayout *layout = [[YHChatTextLayout alloc] init];
    [layout layoutWithText:msg fontSize:addFontSize+14 textColor:textColor matchTextColor:matchTextColor matchTextHighlightBGColor:matchTextHighlightBGColor];
    model.layout = layout;
    NSDate *date = [[NSDate alloc] init ];
    model.createTime  = [date getNowDate];
    return model;
}

// current message time
+ (int)currentMsgTime
{
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    int iTime     = (int)(time * 1000);
    return iTime;
}

- (void)registerCellClassWithTableView:(__weak UITableView *)tableView{
   
    [tableView registerClass:[CellChatTextLeft class] forCellReuseIdentifier:NSStringFromClass([CellChatTextLeft class])];
    [tableView registerClass:[CellChatTextRight class] forCellReuseIdentifier:NSStringFromClass([CellChatTextRight class])];
    [tableView registerClass:[CellChatImageLeft class] forCellReuseIdentifier:NSStringFromClass([CellChatImageLeft class])];
    [tableView registerClass:[CellChatImageRight class] forCellReuseIdentifier:NSStringFromClass([CellChatImageRight class])];
    [tableView registerClass:[CellChatVoiceLeft class] forCellReuseIdentifier:NSStringFromClass([CellChatVoiceLeft class])];
    [tableView registerClass:[CellChatVoiceRight class] forCellReuseIdentifier:NSStringFromClass([CellChatVoiceRight class])];
    [tableView registerClass:[CellChatTips class] forCellReuseIdentifier:NSStringFromClass([CellChatTips class])];

}


- (UITableViewCell *)test:(__weak YHChatModel *)model tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath{
    
    if(model.status == 1){
        //消息撤回
        CellChatTips *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatTips class])];
        cell.model = model;
        return cell;
    }else{
        if (model.msgType == YHMessageType_Image){
            if (model.direction == 0) {
                
                CellChatImageRight *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatImageRight class])];
                [cell setupModel:model];
                return cell;
                
            }else{
                
                CellChatImageLeft *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatImageLeft class])];
                [cell setupModel:model];
                return cell;
            }
            
        }else if (model.msgType == YHMessageType_Voice){
            
            if (model.direction == 0) {
                CellChatVoiceRight *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatVoiceRight class])];
                cell.delegate = self;
                [cell setupModel:model];
                return cell;
            }else{
                CellChatVoiceLeft *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatVoiceLeft class])];
                cell.delegate = self;
                [cell setupModel:model];
                return cell;
            }
            
        }else{
            if (model.direction == 0) {
                CellChatTextRight *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatTextRight class])];
                cell.delegate = self;
                cell.indexPath = indexPath;
                [cell setupModel:model];
                return cell;
            }else{
                CellChatTextLeft *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatTextLeft class])];
                cell.delegate = self;
                cell.indexPath = indexPath;
                [cell setupModel:model];
                return cell;
            }
        }
        
    }
    
    return [[UITableViewCell alloc] init];
}

- (CGFloat)heightWithModel:(__weak YHChatModel *)model tableView:(__weak UITableView *)tableView{
    
    CGFloat height;
    if (model.chatId) {
        height = [_heightDict[model.chatId] floatValue];
        if (height) {
            return height;
        }
    }
    
    if(model.status == 1){
        //消息撤回
        height = [CellChatTips hyb_heightForTableView:tableView config:^(UITableViewCell *sourceCell) {
            CellChatTips *cell = (CellChatTips *)sourceCell;
            cell.model = model;
        } cache:^NSDictionary *{
            return @{
                     kHYBCacheUniqueKey: model.chatId,
                     kHYBCacheStateKey : @(model.showCheckBox),
                     kHYBRecalculateForStateKey:@(YES)
                     };// 标识不用重新更新
        }];
    }else{
        if (model.msgType == YHMessageType_Image) {
            if (model.direction == 0) {
                
                height = [CellChatImageRight hyb_heightForTableView:tableView config:^(UITableViewCell *sourceCell) {
                    CellChatImageRight *cell = (CellChatImageRight *)sourceCell;
                    [cell setupModel:model];
                }];
            }else{
                
                height = [CellChatImageLeft hyb_heightForTableView:tableView config:^(UITableViewCell *sourceCell) {
                    CellChatImageLeft *cell = (CellChatImageLeft *)sourceCell;
                    [cell setupModel:model];
                } cache:^NSDictionary *{
                    return @{
                             kHYBCacheUniqueKey: model.chatId,
                             kHYBCacheStateKey : @(model.showCheckBox),
                             kHYBRecalculateForStateKey:@(YES)
                             };// 标识不用重新更新
                }];
            }
            
        }else if (model.msgType == YHMessageType_Voice){
            if (model.direction == 0) {
                height = [CellChatVoiceRight hyb_heightForTableView:tableView config:^(UITableViewCell *sourceCell) {
                    CellChatVoiceRight *cell = (CellChatVoiceRight *)sourceCell;
                    [cell setupModel:model];
                } ];
            }else{
                height = [CellChatVoiceLeft hyb_heightForTableView:tableView config:^(UITableViewCell *sourceCell) {
                    CellChatVoiceLeft *cell = (CellChatVoiceLeft *)sourceCell;
                    [cell setupModel:model];
                } ];
            }
        }else{
            if (model.direction == 0) {
                height = [CellChatTextRight hyb_heightForTableView:tableView config:^(UITableViewCell *sourceCell) {
                    CellChatTextRight *cell = (CellChatTextRight *)sourceCell;
                    [cell setupModel:model];
                }];

            }else{
                height = [CellChatTextLeft hyb_heightForTableView:tableView config:^(UITableViewCell *sourceCell) {
                    CellChatTextLeft *cell = (CellChatTextLeft *)sourceCell;
                    [cell setupModel:model];
                }];
                
            }
        }
        
    }
    
    if (model.chatId) {
        [_heightDict setObject:@(height) forKey:model.chatId];
    }
   
    return height;
}

- (void)dealloc{
    DDLog(@"%s is dealloc",__func__);
}
@end
