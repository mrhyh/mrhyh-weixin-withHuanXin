//
//  common.h
//  iOSAppTemplate
//
//  Created by 李伯坤 on 15/9/16.
//  Copyright (c) 2015年 lbk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface common : NSObject

void TLLogError(id className, id funcName, NSError *error);
void TLLogWarning(id className, id funcName, NSString *format,...);

@end
