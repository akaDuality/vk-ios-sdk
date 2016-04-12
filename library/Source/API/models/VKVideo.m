//
//  VKVideo.m
//  VK
//
//  Created by Рубанов Михаил on 16/11/14.
//  Copyright (c) 2014 akaDuality. All rights reserved.
//

#import "VKVideo.h"

@implementation VKVideo

@end



@implementation VKVideoArray
-(instancetype)initWithDictionary:(NSDictionary *)dict
{
    return [super initWithDictionary:dict objectClass:[VKVideo class]];
}
@end