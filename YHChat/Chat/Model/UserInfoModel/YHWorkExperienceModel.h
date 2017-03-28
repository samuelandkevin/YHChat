//
//  YHWorkExperienceModel.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by YHIOS003 on 16/5/17.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YHWorkExperienceModel : NSObject<NSCopying>

@property(nonatomic,copy)   NSString * workExpId;
@property(nonatomic,strong) NSString * company;
@property(nonatomic,strong) NSString * position;
@property(nonatomic,strong) NSString * beginTime;
@property(nonatomic,strong) NSString * endTime;
@property(nonatomic,strong) NSString * moreDescription;
@end
