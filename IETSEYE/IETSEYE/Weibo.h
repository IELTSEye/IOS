//
//  Weibo.h
//  IETSEYE
//
//  Created by WillLee on 13-12-19.
//  Copyright (c) 2013年 WillLee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Weibo : NSObject

@property (nonatomic, retain) NSString *uid;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *content;
@property (nonatomic, retain) NSString *created_at;

@end

