//
//  VKVideo.h
//  VK
//
//  Created by Рубанов Михаил on 16/11/14.
//  Copyright (c) 2014 akaDuality. All rights reserved.
//

#import "VKApiObjectArray.h"
#import "VKLikes.h"
#import "VKAttachableProtocol.h"

@interface VKVideo : VKApiObject <VKAttachableProtocol>

@property (nonatomic) NSNumber *id;
@property (nonatomic) NSNumber *owner_id;
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *descriptionVK;
@property (nonatomic) NSNumber *date;
@property (nonatomic) NSNumber *duration;

@property (nonatomic) NSNumber *views;
@property (nonatomic) NSNumber *comments;

@property (nonatomic) NSString  *photo_130;
@property (nonatomic) NSString  *photo_320;
@property (nonatomic) NSString  *photo_640;
@property (nonatomic) NSString  *photo_800;

@property (nonatomic) NSString *link;
@property (strong, nonatomic) NSString *access_key;



@property (nonatomic) NSString *player;


#pragma mark Extended

//privacy_view — настройки приватности в формате настроек приватности; (приходит только для текущего пользователя)
//privacy_comment — настройки приватности в формате настроек приватности; (приходит только для текущего пользователя)
/// может ли текущий пользователь оставлять комментарии к ролику (1 — может, 0 — не может);
@property (nonatomic) NSNumber *can_comment;
/// может ли текущий пользователь скопировать ролик с помощью функции «Рассказать друзьям» (1 — может, 0 — не может);
@property (nonatomic) NSNumber *can_repost;
/// число отметок «Мне нравится»;
@property (nonatomic) NSNumber *count;
/// зацикливание воспроизведения видеозаписи (1 — зацикливается, 0 — не зацикливается).
@property (nonatomic) NSNumber *repeat;

/*!
 *  Информация о лайках
 */
@property (nonatomic, strong) VKLikes * likes;

@end


@interface VKVideoArray : VKApiObjectArray

@end
