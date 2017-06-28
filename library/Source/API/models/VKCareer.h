//
//  VKCareer.h
//  VK-ios-sdk
//
//  Created by Алексей Берёзка on 28/06/2017.
//  Copyright © 2017 VK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VKApiObjectArray.h"

@interface VKCareer : VKApiObject

/**
 Компания
 */
@property (nonatomic, strong)   NSString *  company;

/**
 Страна
 */
@property (nonatomic, strong)   NSNumber *  country_id;

/**
 Город
 */
@property (nonatomic, strong)   NSNumber *  city_id;

/**
 С когда
 */
@property (nonatomic, strong)   NSNumber *  from;

/**
 До когда
 */
@property (nonatomic, strong)   NSNumber *  until;

/**
 Кем
 */
@property (nonatomic, strong)   NSString *  position;

@end


@interface VKCareersArray : VKApiObjectArray

@end
