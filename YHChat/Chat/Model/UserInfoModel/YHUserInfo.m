//
//  YHUserInfo.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/4/25.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import "YHUserInfo.h"
//#import "JPUSHService.h"
#import <objc/runtime.h>

//#import "NSObject+YHDBRuntime.h"

@implementation YHUserInfo
@synthesize mobilephone = _mobilephone;
@synthesize uid = _uid;
@synthesize accessToken = _accessToken;
@synthesize taxAccount = _taxAccount;
@synthesize avatarImage = _avatarImage;


//YHSERIALIZE_CODER_DECODER();
//
//YHSERIALIZE_COPY_WITH_ZONE();

//YHSERIALIZE_DESCRIPTION();

- (id)init
{
	self = [super init];

	if (!self)
	{
		return nil;
	}
	_isRegister = NO;
	_jobTags = [NSMutableArray array];
	_workExperiences = [NSMutableArray array];
	_eductaionExperiences = [NSMutableArray array];

	//    self.userConfig     = [HHUserConfig new];
	return self;
}

#pragma mark - Getter

//- (NSString *)uid
//{
//	if (!_uid && _isSelfModel)
//	{
//		NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:kUserUid];
//
//		if (userId)
//		{
//			_uid = userId;
//		}
//	}
//	return _uid;
//}

//- (NSString *)accessToken
//{
//	if (!_accessToken && _isSelfModel)
//	{
//		NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:kAccessToken];
//
//		if (accessToken)
//		{
//			_accessToken = accessToken;
//		}
//	}
//	return _accessToken;
//}
//
//- (NSString *)mobilephone
//{
//	if (!_mobilephone && _isSelfModel)
//	{
//		NSString *mobilePhone = [[NSUserDefaults standardUserDefaults] objectForKey:kMobilePhone];
//
//		if (mobilePhone)
//		{
//			_mobilephone = mobilePhone;
//		}
//	}
//	return _mobilephone;
//}
//
//- (NSString *)taxAccount
//{
//	if (!_taxAccount && _isSelfModel)
//	{
//		NSString *taxAccount = [[NSUserDefaults standardUserDefaults] objectForKey:kTaxAccount];
//
//		if (taxAccount)
//		{
//			_taxAccount = taxAccount;
//		}
//	}
//	return _taxAccount;
//}

#pragma mark - Setter
//- (void)setAccessToken:(NSString *)accessToken
//{
//	if (accessToken)
//	{
//		_accessToken = accessToken;
//
//		if (_isSelfModel)
//		{
//			[[NSUserDefaults standardUserDefaults] setObject:_accessToken forKey:kAccessToken];
//			[[NSUserDefaults standardUserDefaults] synchronize];
//		}
//	}
//}
//
//- (void)setMobilephone:(NSString *)mobilephone
//{
//	if (mobilephone)
//	{
//		_mobilephone = mobilephone;
//
//		if (_isSelfModel)
//		{
//			[[NSUserDefaults standardUserDefaults] setObject:_mobilephone forKey:kMobilePhone];
//			[[NSUserDefaults standardUserDefaults] synchronize];
//		}
//	}
//}
//
//- (void)setUid:(NSString *)uid
//{
//	if (uid)
//	{
//		_uid = uid;
//
//		if (_isSelfModel)
//		{
//			[[NSUserDefaults standardUserDefaults] setObject:_uid forKey:kUserUid];
//			[[NSUserDefaults standardUserDefaults] synchronize];
//		}
//	}
//}
//
//- (void)setTaxAccount:(NSString *)taxAccount
//{
//	if (taxAccount && taxAccount.length)
//	{
//		_taxAccount = taxAccount;
//
//		if (_isSelfModel)
//		{
//			[[NSUserDefaults standardUserDefaults] setObject:_taxAccount forKey:kTaxAccount];
//			[[NSUserDefaults standardUserDefaults] synchronize];
//		}
//	}
//}
//
//- (void)setUpdateStatus:(UpdateStatus)updateStatus
//{
//	_updateStatus = updateStatus;
//
//	if (_updateStatus == updateFinish)
//	{
//		[[NSNotificationCenter defaultCenter] postNotificationName:Event_UserInfo_UpdateFinish object:nil];
//	}
//}

- (void)setAvatarImage:(UIImage *)avatarImage
{
	_avatarImage = avatarImage;

	if (!_avatarImage)
	{
		_avatarImage = [UIImage imageNamed:@"common_avatar_120px"];
	}
}

- (UIImage *)avatarImage
{
	if (!_avatarImage)
	{
		_avatarImage = [UIImage imageNamed:@"common_avatar_120px"];
	}
	return _avatarImage;
}



//#pragma mark - YHFMDB
//+ (NSString *)yh_primaryKey{
//    return @"uid";
//}
//
//+ (NSDictionary *)yh_replacedKeyFromPropertyName{
//    return @{@"uid":YHDB_PrimaryKey};
//}
//
//+ (NSDictionary *)yh_propertyIsInstanceOfArray{
//    return @{
//             @"jobTags":[NSString class],
//             @"workExperiences":[YHWorkExperienceModel class],
//             @"eductaionExperiences":[YHEducationExperienceModel class]
//            };
//}
//
//+ (NSDictionary *)yh_replacedKeyFromDictionaryWhenPropertyIsObject{
//    return @{@"userSetting":[NSString stringWithFormat:@"userSetting%@",YHDB_AppendingID],
//
//             };
//}

#pragma mark - Life

- (void)dealloc {
    
}

@end
