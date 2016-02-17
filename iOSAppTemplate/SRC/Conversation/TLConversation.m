//
//  TLConversation.m
//  iOSAppTemplate
//
//  Created by 李伯坤 on 15/9/16.
//  Copyright (c) 2015年 lbk. All rights reserved.
//

#import "TLConversation.h"

@implementation TLConversation

+ (instancetype)TLConversationWithDict:(NSDictionary *)dict{
    return [[self alloc] initWithDict:dict];
}

- (instancetype)initWithDict:(NSDictionary *)dict{
    if (self = [super init]){
        [ self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

@end
