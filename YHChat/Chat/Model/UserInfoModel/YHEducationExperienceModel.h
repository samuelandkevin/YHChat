//
//  YHEducationExperienceModel.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by YHIOS003 on 16/5/17.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YHEducationExperienceModel : NSObject<NSCopying>

@property(nonatomic,copy)   NSString * eduExpId;
@property(nonatomic,strong) NSString * school;
@property(nonatomic,strong) NSString * major;
@property(nonatomic,strong) NSString * educationBackground;
@property(nonatomic,strong) NSString * beginTime;
@property(nonatomic,strong) NSString * endTime;
@property(nonatomic,strong) NSString * moreDescription;


@end
