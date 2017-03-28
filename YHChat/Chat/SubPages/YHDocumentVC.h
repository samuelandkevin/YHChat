//
//  YHDocumentVC.h
//  YHChat
//
//  Created by samuelandkevin on 17/3/28.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YHDocumentVC : UIViewController

- (void)didSelectFilesComplete:(void(^)(NSArray <NSString *> *files))complete;
@end
