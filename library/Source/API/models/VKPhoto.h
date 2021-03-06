//
//  VKPhoto.h
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

#import "VKApiObject.h"
#import "VKApiObjectArray.h"
#import "VKPhotoSize.h"

#import "VKLikes.h"
#import "SharableProtocol.h"

@interface VKCount : VKApiObject

    @property (nonatomic, strong) NSNumber *count;

@end

//@class VKLikes;
/**
 Photo type of VK API. See descriptions here https://vk.com/dev/photo
 */

@interface VKPhoto : VKApiObject <SharableProtocol>

    @property (nonatomic, strong)           NSNumber *      id;
    @property (nonatomic, strong)           NSNumber *      album_id;
    @property (nonatomic, strong)           NSNumber *      owner_id;
    @property (nonatomic, strong)           NSString *      photo_75;
    @property (nonatomic, strong)           NSString *      photo_130;
    @property (nonatomic, strong)           NSString *      photo_604;
    @property (nonatomic, strong)           NSString *      photo_807;
    @property (nonatomic, strong)           NSString *      photo_1280;
    @property (nonatomic, strong)           NSString *      photo_2560;
    @property (nonatomic, strong)           NSNumber *      width;
    @property (nonatomic, strong)           NSNumber *      height;
    @property (nonatomic, strong)           NSString *      text;
    @property (nonatomic, strong)           NSNumber *      date;
    @property (nonatomic, strong)           VKPhotoSizes *  sizes;
    @property (nonatomic, strong, readonly) NSString *      attachmentString;
    @property (nonatomic, strong)           VKLikes *       likes;
    @property (nonatomic, strong)           VKCount *       comments;
    @property (nonatomic, strong)           NSNumber *      can_comment;
    @property (nonatomic, strong)           NSNumber *      can_repost;

    @property (nonatomic, strong)           VKCount *       tags;

    @property (nonatomic, strong)           NSNumber *      lat;
//    @property (nonatomic, strong)           NSNumber *      longtitude;

    @property (nonatomic, strong)           NSNumber *reposts;

    @property (nonatomic, strong)           UIImage *       uploadingObject;
    @property (nonatomic, assign)           float           uploadingProgress;
    @property (nonatomic, assign)           NSString *      uploadingPhotoURL;

    @property (strong, nonatomic) NSString *access_key;

// Old keys
    @property (nonatomic, strong) NSNumber *user_id;
    @property (nonatomic, strong) NSNumber *post_id;
@end


/**
 Array of API photos objects
 */
@interface VKPhotoArray : VKApiObjectArray<VKPhoto*>
@end
