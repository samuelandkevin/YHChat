//
//  YHGIFModel.h
//  YHChat
//
//  Created by YHIOS002 on 17/4/12.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "YHChatServiceDefs.h"

@interface YHGIFModel : NSObject

@property (nonatomic,copy) NSString *fileName;    //文件名
@property (nonatomic,copy) NSString *filePathInServer; //服务器的文件路径
@property (nonatomic,copy) NSString *filePathInLocal;  //本地文件路径
@property (nonatomic,assign) CGFloat width;
@property (nonatomic,assign) CGFloat height;
@property (nonatomic,assign) FileStatus status;
@property (nonatomic,strong) NSData *animatedImageData;
@end
