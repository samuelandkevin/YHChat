//
//  CellDocument.h
//  YHChat
//
//  Created by samuelandkevin on 17/3/28.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YHFileModel.h"

@protocol CellDocumentDelegate <NSObject>

- (void)onCheckBoxSelected:(BOOL)selected fileModel:(YHFileModel *)fileModel;

@end

@interface CellDocument : UITableViewCell

@property (nonatomic, copy) YHFileModel *model;

@property (nonatomic,weak)id<CellDocumentDelegate>delegate;
@end
