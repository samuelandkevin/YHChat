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

@implementation YHChatHelper

#pragma mark - Public
+ (YHChatModel *)creatMessage:(NSString *)msg msgType:(YHMessageType)msgType  toID:(NSString *)toID {
    YHChatModel *model  = [YHChatModel new];
    model.speakerId     = MYUID;
    model.speakerAvatar = MYAVTARURL;
    model.direction     = 0;
    model.msgType       = msgType;
    model.audienceId = toID;
    model.chatType   = msgType;
    CGFloat addFontSize = [[[NSUserDefaults standardUserDefaults] valueForKey:kSetSystemFontSize] floatValue];
    model.msgContent = [YHExpressionHelper attributedStringWithText:msg fontSize:(addFontSize+14) textColor:RGB16(0x303030)];
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

+ (void)registerCellClassWithTableView:(__weak UITableView *)tableView{
   
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

+ (CGFloat)heightWithModel:(__weak YHChatModel *)model tableView:(__weak UITableView *)tableView{
    if(model.status == 1){
        //消息撤回
        return [CellChatTips hyb_heightForTableView:tableView config:^(UITableViewCell *sourceCell) {
            CellChatTips *cell = (CellChatTips *)sourceCell;
            cell.model = model;
        }];
    }else{
        if (model.msgType == YHMessageType_Image) {
            if (model.direction == 0) {
                
                return [CellChatImageRight hyb_heightForTableView:tableView config:^(UITableViewCell *sourceCell) {
                    CellChatImageRight *cell = (CellChatImageRight *)sourceCell;
                    [cell setupModel:model];
                }];
                
            }else{
                
                return [CellChatImageLeft hyb_heightForTableView:tableView config:^(UITableViewCell *sourceCell) {
                    CellChatImageLeft *cell = (CellChatImageLeft *)sourceCell;
                    [cell setupModel:model];
                }];
            }
            
        }else if (model.msgType == YHMessageType_Voice){
            if (model.direction == 0) {
                return [CellChatVoiceRight hyb_heightForTableView:tableView config:^(UITableViewCell *sourceCell) {
                    CellChatVoiceRight *cell = (CellChatVoiceRight *)sourceCell;
                    [cell setupModel:model];
                }];
            }else{
                return [CellChatVoiceLeft hyb_heightForTableView:tableView config:^(UITableViewCell *sourceCell) {
                    CellChatVoiceLeft *cell = (CellChatVoiceLeft *)sourceCell;
                    [cell setupModel:model];
                }];
            }
        }else{
            if (model.direction == 0) {
                return [CellChatTextRight hyb_heightForTableView:tableView config:^(UITableViewCell *sourceCell) {
                    CellChatTextRight *cell = (CellChatTextRight *)sourceCell;
                    [cell setupModel:model];
                }];
            }else{
                return [CellChatTextLeft hyb_heightForTableView:tableView config:^(UITableViewCell *sourceCell) {
                    CellChatTextLeft *cell = (CellChatTextLeft *)sourceCell;
                    [cell setupModel:model];
                }];
            }
        }
        
    }
}

- (void)dealloc{
    DDLog(@"%s is dealloc",__func__);
}
@end
