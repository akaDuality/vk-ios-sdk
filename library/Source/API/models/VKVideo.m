//
//  VKVideo.m
//  VK
//
//  Created by Рубанов Михаил on 16/11/14.
//  Copyright (c) 2014 akaDuality. All rights reserved.
//

#import "VKVideo.h"

@implementation VKVideo

- (NSString *)attachmentString{
    return [NSString stringWithFormat:@"video%@_%@", _owner_id, _id];
}

@end

@implementation VKVideoArray

-(instancetype)initWithDictionary:(NSDictionary *)dict{
    return [super initWithDictionary:dict objectClass:[VKVideo class]];
}

@end