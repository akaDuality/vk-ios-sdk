//
//  VKUser.h
//
//  Copyright (c) 2014 VK.com
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//  the Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import <Foundation/Foundation.h>
#import "VKApiObject.h"
#import "VKApiObjectArray.h"
#import "VKAudio.h"
#import "VKCounters.h"
#import "VKPhoto.h"
#import "VKSchool.h"
#import "VKUniversity.h"
#import "VKRelative.h"
#import "VKCareer.h"

typedef NS_ENUM(NSInteger, NameCase) {
    /*!
     *  Именительный. Алексей Берёзка.
     */
    NameCaseNominative,
    
    /*!
     *  Родительный. Алексея Берёзки.
     */
    NameCaseGenetive,
    
    /*!
     *  Дательный. Алексею Берёзке.
     */
    NameCaseDative,
    
    /*!
     *  Винительный. Алексея Берёзку.
     */
    NameCaseAccusative,
    
    /*!
     *  Творительный. Алексеем Берёзкой.
     */
    NameCaseInstrumental,
    
    /*!
     *  Предложный. Алексее Берёзке.
     */
    NameCasePrepositional
};

@interface VKGeoObject : VKApiObject
@property(nonatomic, strong) NSNumber *id;
@property(nonatomic, strong) NSString *title;
@end

@interface VKCity : VKGeoObject
@end

@interface VKCountry : VKGeoObject
@end

/**
 * User personal information (field 'personal')
 */
@interface VKPersonal : VKObject
@property(nonatomic, strong) NSArray *langs;
@property(nonatomic, strong) NSNumber *political;
@property(nonatomic, strong) NSString *religion;
@property(nonatomic, strong) NSNumber *life_main;
@property(nonatomic, strong) NSNumber *people_main;
@property(nonatomic, strong) NSString *inspired_by;
@property(nonatomic, strong) NSNumber *smoking;
@property(nonatomic, strong) NSNumber *alcohol;
@end

/**
 * User last seen information (field 'last_seen')
 */
@interface VKLastSeen : VKApiObject
@property(nonatomic, strong) NSNumber *time;
@property(nonatomic, strong) NSNumber *platform;
@end

/**
 * Information about connected services by user (field 'exports')
 */
@interface VKExports : VKApiObject
@property(nonatomic, strong) NSNumber *twitter;
@property(nonatomic, strong) NSNumber *facebook;
@property(nonatomic, strong) NSNumber *livejournal;
@property(nonatomic, strong) NSNumber *instagram;
@end

/**
 User type of VK API. See descriptions here https://vk.com/dev/fields
 */
@interface VKUser : VKApiObject
@property(nonatomic, strong) NSNumber *id;

/*!
 *  Именительный. Алексей.
 */
@property(nonatomic, strong) NSString *first_name;

/*!
 *  Именительный. Берёзка.
 */
@property(nonatomic, strong) NSString *last_name;

/*!
 *  Родительный. Алексея.
 */
@property(nonatomic, strong) NSString *first_name_gen;

/*!
 *  Родительный. Берёзки.
 */
@property(nonatomic, strong) NSString *last_name_gen;

/*!
 *  Дательный. Алексею.
 */
@property(nonatomic, strong) NSString *first_name_dat;

/*!
 *  Дательный. Берёзке.
 */
@property(nonatomic, strong) NSString *last_name_dat;

/*!
 *  Винительный. Алексея.
 */
@property(nonatomic, strong) NSString *first_name_acc;

/*!
 *  Винительный. Берёзку.
 */
@property(nonatomic, strong) NSString *last_name_acc;

/*!
 *  Творительный. Алексеем.
 */
@property(nonatomic, strong) NSString *first_name_ins;

/*!
 *  Творительный. Берёзкой.
 */
@property(nonatomic, strong) NSString *last_name_ins;

/*!
 *  Предложный. Алексее.
 */
@property(nonatomic, strong) NSString *first_name_abl;

/*!
 *  Предложный. Берёзке.
 */
@property(nonatomic, strong) NSString *last_name_abl;

/*!
 *  Именительный. Алексей Берёзка.
 */
@property(nonatomic, strong) NSString *fullName;

/*!
 *  Родительный. Алексея Берёзки.
 */
@property(nonatomic, strong) NSString *fullNameGen;

/*!
 *  Дательный. Алексею Берёзке.
 */
@property(nonatomic, strong) NSString *fullNameDat;

/*!
 *  Винительный. Алексея Берёзку.
 */
@property(nonatomic, strong) NSString *fullNameAcc;

/*!
 *  Творительный. Алексеем Берёзкой.
 */
@property(nonatomic, strong) NSString *fullNameIns;

/*!
 *  Предложный. Алексее Берёзке.
 *  Почему VK его обозвали Ablative — не знаю. Ablative — совершенно другая штука. Но я сохранил abl для единообразия с first_name_abl и last_name_abl.
 */
@property(nonatomic, strong) NSString *fullNameAbl;


@property(nonatomic, strong) NSString *domain;
@property(nonatomic, strong) VKPersonal *personal;
@property(nonatomic, strong) NSNumber *sex;
@property(nonatomic, strong) NSNumber *invited_by;


/// Is online
@property(nonatomic, strong) NSNumber *online;
/// Online from phone
@property(nonatomic, strong) NSNumber *online_mobile;
/// Online from app id
@property(nonatomic, strong) NSNumber *online_app;

@property(nonatomic, strong) NSString *bdate;
@property(nonatomic, strong) VKCity *city;
@property(nonatomic, strong) VKCountry *country;
@property(nonatomic, strong) NSMutableArray *lists;
@property(nonatomic, strong) NSString *screen_name;
@property(nonatomic, strong) NSNumber *has_mobile;
@property(nonatomic, strong) NSNumber *rate;
@property(nonatomic, strong) NSString *mobile_phone;
@property(nonatomic, strong) NSString *home_phone;
@property(nonatomic, assign) BOOL can_post;
@property(nonatomic, assign) BOOL can_see_all_posts;
@property(nonatomic, strong) NSString *status;
@property(nonatomic, strong) VKAudio *status_audio;
@property(nonatomic, assign) bool status_loaded;
@property(nonatomic, strong) VKLastSeen *last_seen;
@property(nonatomic, strong) NSNumber *relation;
@property(nonatomic, strong) VKUser *relation_partner;
@property(nonatomic, strong) VKCounters *counters;
@property(nonatomic, strong) NSString *nickname;
@property(nonatomic, strong) VKExports *exports;
@property(nonatomic, strong) NSNumber *wall_comments;
@property(nonatomic, assign) BOOL can_write_private_message;
@property(nonatomic, assign) BOOL can_see_audio;
@property(nonatomic, strong) NSString *phone;
@property(nonatomic, strong) NSNumber *faculty;
@property(nonatomic, strong) NSNumber *university;
@property(nonatomic, strong) VKUniversities *universities;
@property(nonatomic, strong) VKSchools *schools;
@property(nonatomic, strong) NSNumber *graduation;
@property(nonatomic, strong) NSNumber *friend_status;
@property(nonatomic, strong) NSNumber *is_favorite;
@property(nonatomic, strong) NSNumber *common_count;
@property(nonatomic, strong) NSString *faculty_name;
@property(nonatomic, strong) NSString *university_name;
@property(nonatomic, strong) NSString *books;
@property(nonatomic, strong) NSString *games;
@property(nonatomic, strong) NSString *interests;
@property(nonatomic, strong) NSString *movies;
@property(nonatomic, strong) NSString *tv;
@property(nonatomic, strong) NSString *about;
@property(nonatomic, strong) NSString *music;
@property(nonatomic, strong) NSString *quoutes;
@property(nonatomic, strong) NSString *activities;

@property(nonatomic, strong) NSString *photo_max;
@property(nonatomic, strong) NSString *photo_50;
@property(nonatomic, strong) NSString *photo_100;
@property(nonatomic, strong) NSString *photo_200;
@property(nonatomic, strong) NSString *photo_200_orig;
@property(nonatomic, strong) NSString *photo_400_orig;
@property(nonatomic, strong) NSString *photo_max_orig;

@property(nonatomic, strong) VKPhotoArray *photos;
@property(nonatomic, strong) NSNumber *photos_count;
@property(nonatomic, strong) VKRelativities *relatives;
@property(nonatomic, assign) NSTimeInterval bdateIntervalSort;
@property(nonatomic, strong) NSNumber *verified;
@property(nonatomic, strong) NSString *deactivated;
@property(nonatomic, strong) NSString *site;
@property(nonatomic, strong) NSString *home_town;
@property(nonatomic, strong) NSNumber *blacklisted;
@property(nonatomic, strong) NSNumber *blacklisted_by_me;
@property(nonatomic, strong) NSString *twitter;
@property(nonatomic, strong) NSString *skype;
@property(nonatomic, strong) NSString *facebook;
@property(nonatomic, strong) NSString *instagram;
@property(nonatomic, strong) NSString *livejournal;
@property(nonatomic, strong) NSString *wall_default;

@property(nonatomic, strong) NSNumber *followers_count;
@property(nonatomic, strong) NSNumber *is_hidden_from_feed;

@property (nonatomic, strong)   VKCareersArray *  career;

@end

/**
 Array of API users
 */
@interface VKUsersArray : VKApiObjectArray<VKUser*>
@end
