//
//  VKAttachableProtocol.h
//  VK
//
//  Created by Рубанов Михаил on 02.05.16.
//  Copyright © 2016 akaDuality. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SharableProtocol <NSObject>

- (NSString *)attachmentString;
- (NSString *)fullId;

@optional
/**
 For albums in InlineActionsView
 */
- (BOOL)isSharingDeprecatedForSpecialCases;

@end
