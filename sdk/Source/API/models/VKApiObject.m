//
//  VKApiObject.m
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

#import <objc/runtime.h>
#import "VKApiObject.h"
#import "VKApiObjectArray.h"



#ifdef DEBUG
#define PRINT_PARSE_DEBUG_INFO YES
#else
#define PRINT_PARSE_DEBUG_INFO NO
#endif

static NSString *const INT_NAME = @"int";
static NSString *const DOUBLE_NAME = @"double";
static NSString *const ID_NAME = @"id";



static NSString *getPropertyType(objc_property_t property) {
    const char *type = property_getAttributes(property);
    NSString *typeString = [NSString stringWithUTF8String:type];
    NSArray *attributes = [typeString componentsSeparatedByString:@","];
    NSString *typeAttribute = [attributes objectAtIndex:0];
    NSString *propertyType = [typeAttribute substringFromIndex:1];
    const char *rawPropertyType = [propertyType UTF8String];
    
    if (strcmp(rawPropertyType, @encode(float)) == 0 ||
        strcmp(rawPropertyType, @encode(CGFloat)) == 0 ||
        strcmp(rawPropertyType, @encode(double)) == 0) {
        return DOUBLE_NAME;
    }
    else if (strcmp(rawPropertyType, @encode(int)) == 0 ||
             strcmp(rawPropertyType, @encode(long)) == 0 ||
             strcmp(rawPropertyType, @encode(NSInteger)) == 0 ||
             strcmp(rawPropertyType, @encode(NSUInteger)) == 0) {
        return INT_NAME;
    }
    else if (strcmp(rawPropertyType, @encode(id)) == 0) {
        return ID_NAME;
    }
    
    if ([typeAttribute hasPrefix:@"T@"] && [typeAttribute length] > 1) {
        NSString *typeClassName = [typeAttribute substringWithRange:NSMakeRange(3, [typeAttribute length] - 4)];  //turns @"NSDate" into NSDate
        if (typeClassName != nil) {
            return typeClassName;
        }
    }
    
    return nil;
}
static NSString *getPropertyName(objc_property_t prop) {
    const char *propCName = property_getName(prop);
    NSString *propertyName =  [NSString stringWithCString:propCName encoding:[NSString defaultCStringEncoding]];
    
//    NSLog(@"poperty %@", propertyName);
//    if ([propertyName isEqualToString:@"copy_history"]) {
//        
//    }
    return propertyName;
}




@interface VKPropertyHelper ()
@property (nonatomic, assign) objc_property_t property;
@property (nonatomic, readwrite, strong) NSString *propertyName;
@property (nonatomic, readwrite, strong) NSString *propertyClassName;
@property (nonatomic, readwrite, strong) Class propertyClass;

@property (nonatomic, readwrite, assign) BOOL isPrimitive;
@property (nonatomic, readwrite, assign) BOOL isModelsArray;
@property (nonatomic, readwrite, assign) BOOL isModel;

-(instancetype) initWith:(objc_property_t) prop;
@end


@implementation VKPropertyHelper

-(instancetype)initWith:(objc_property_t)prop {
    self = [super init];
    self.property = prop;
    
    NSString *propertyName = getPropertyName(prop);
    
//    if ([propertyName isEqual:@"description"]){
//        propertyName = @"descriptionVK";
//    }
//    else if ([propertyName isEqualToString:@"copy_history"]){
//        propertyName = @"history";
//    }
    self.propertyName = propertyName;
    
    _propertyClassName = getPropertyType(self.property);
    _isPrimitive = [@[DOUBLE_NAME, INT_NAME, ID_NAME] containsObject:_propertyClassName];
    //NSLog(@"VKPropertyHelper %@: %@", self.propertyName, _propertyClassName);
    if (!_isPrimitive) {
        _propertyClass = NSClassFromString(_propertyClassName);
        if(!(_isModelsArray = [_propertyClass isSubclassOfClass:[VKApiObjectArray class]])) {
            _isModel = [_propertyClass isSubclassOfClass:[VKApiObject class]];
        }
    }
    return self;
}
@end







@interface VKApiObject ()
@property NSMutableDictionary * classesProperties;// = nil;
@end

@implementation VKApiObject

//static NSMutableDictionary * classesProperties = nil;

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        id response = dict[@"response"];
        if (response){
            //NSLog(@"response: %@", response);
            [self parse:response];
        } else {
            [self parse:dict];
        }
    }
    return self;
}

- (void)parse:(NSDictionary *)jasonDict {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
        _classesProperties = [NSMutableDictionary dictionaryWithCapacity:100];
//    });
    
    NSString * className = NSStringFromClass(self.class);
    __block NSMutableDictionary * propDict = [_classesProperties objectForKey:className];
    
    if (!propDict) {
        [self enumPropertiesWithBlock:^(VKPropertyHelper * helper, int totalProps) {
            if (!propDict){
                propDict = [NSMutableDictionary dictionaryWithCapacity:totalProps];
            }
            propDict[helper.propertyName] = helper;
        }];
        
#warning somtimes crashed here when load dialogs. Возможно, это проблема выполнения в неправильном потоке
        _classesProperties[className] = propDict;
    }
    NSMutableArray * warnings = PRINT_PARSE_DEBUG_INFO ? [NSMutableArray new] : nil;
//        NSLog(@"DICT: %@", dict);
    //    NSLog(@"Properties count %d", [dict count]);
    for (__strong NSString * key in jasonDict)
    {
        id          resultObject    = nil;
        id          parseObject     = [jasonDict objectForKey:key];
        
        
        VKPropertyHelper * propHelper = [propDict objectForKey:key];
        if (!propHelper) {
            // Если свойство не найдено
            // Проверим среди сменившихся имён
            if ([key isEqualToString:@"copy_history"]) {
                key = @"history";
            } else if ([key isEqualToString:@"description"]){
                key = @"descriptionVK";
            } else if ([key isEqualToString:@"new_pts"]){
                key = @"pts";
            }
            propHelper = [propDict objectForKey:key];
            
            // Если не нашли — сообщаем
            if (!propHelper) {
#warning uncomment if needed
//                NSLog(@"CONTINUE on key %@", key);
                continue;
            }
        }
        

        if ([key isEqualToString:@"description"]) {
            NSLog(@"%@", parseObject);
        }
        NSString*   propertyName    = propHelper.propertyName;
        Class       propertyClass   = propHelper.propertyClass;
        
        //        NSLog(@"self.className: %@", NSStringFromClass(self.class));
        //        NSLog(@"propertyClassName: %@", propHelper.propertyClassName);
        //        NSLog(@"key: %@", key);
        
        if (propHelper.isPrimitive) {
            //NSLog(@"isPrimitive");
            [self setValue:parseObject forKey:propertyName];
            continue;
        }
        if (propHelper.isModelsArray) {
            if ([parseObject isKindOfClass:[NSDictionary class]]) {
                //NSLog(@"%@ isModelsArray-[NSDictionary class]", NSStringFromClass(propHelper.propertyClass));
                resultObject = [[propertyClass alloc] initWithDictionary:parseObject];
            }
            else if ([parseObject isKindOfClass:[NSArray class]]) {
                //NSLog(@"%@ isModelsArray-[NSArray class]", NSStringFromClass(propHelper.propertyClass));
                resultObject = [[propertyClass alloc] initWithArray:parseObject objectClass:[self properClassForClass:propHelper.propertyClass]];
            }
            else {
                //NSLog(@"isModelsArray-else");
                if (PRINT_PARSE_DEBUG_INFO)
                    [warnings addObject:[NSString stringWithFormat:@"property %@ is parcelable, but data is not", propertyName]];
            }
        }
        else if (propHelper.isModel) {
            if ([parseObject isKindOfClass:[NSDictionary class]]) {
                //NSLog(@"isModel-[NSDictionary class]");
                resultObject = [[propertyClass alloc] initWithDictionary:parseObject];
            }
            else {
                //NSLog(@"isModel-else");
                if (PRINT_PARSE_DEBUG_INFO)
                    [warnings addObject:[NSString stringWithFormat:@"property %@ is parcelable, but data is not", propertyName]];
            }
        }
        else {
            //NSLog(@"else");
            resultObject = parseObject;
            if (![resultObject isKindOfClass:propertyClass]) {
                //§NSLog(@"else-!propertyClass");
                if (PRINT_PARSE_DEBUG_INFO)
                    [warnings addObject:[NSString stringWithFormat:@"property with name %@ expected class %@, result class %@", propertyName, propertyClass, [resultObject class]]];
            }
        }
        [self setValue:resultObject forKey:propertyName];
    }
    
    if (PRINT_PARSE_DEBUG_INFO && warnings.count){
        NSLog(@"Parsing %@ complete. Warnings: %@", self, warnings);
    }
}

- (Class)properClassForClass:(Class)class{
    Class result = class;
    NSString *className = NSStringFromClass(class);
    NSString *resultClassName = className;
    
    if([className isEqualToString:@"ADVKNewsItemArray"]){
        resultClassName = @"ADVKNewsItem";
    }
    else if([className isEqualToString:@"VKGroups"]){
        resultClassName = @"VKGroup";
    }
    else if([className isEqualToString:@"VKUsersArray"]){
        resultClassName = @"VKUser";
    }
    else if([className isEqualToString:@"ADVKAttachmentArray"]){
        resultClassName = @"ADVKAttachment";
    }
    else if([className isEqualToString:@"VKMessageRespondArray"]){
        resultClassName = @"VKMessageRespond";
    }
    else if([className isEqualToString:@"VKMessageArray"]){
        resultClassName = @"VKMessage";
    }
    else if([className isEqualToString:@"VKPostArray"]){
        resultClassName = @"VKPost";
    }
    else if([className isEqualToString:@"VKPollAnswersArray"]){
        resultClassName = @"VKPollAnswer";
    }
    else if([className isEqualToString:@"VKUserCommentArray"]){
        resultClassName = @"VKUserComment";
    }
    else if([className isEqualToString:@"VKAudios"]){
        resultClassName = @"VKAudio";
    }
    else if([className isEqualToString:@"VKPhotoSizes"]){
        resultClassName = @"VKPhotoSize";
    }
    else{
        NSLog(@"Don't know how to parse array %@", className);
    }
    
    result = NSClassFromString(resultClassName);
    
    return result;
}

- (void)enumPropertiesWithBlock:(void (^)(VKPropertyHelper * helper, int totalProps))processBlock {
    unsigned int propertiesCount;
    //Get all properties of current class
    Class   searchClass = [self class];
    NSArray *ignoredProperties = [self ignoredProperties];
    
    while (searchClass != [VKApiObject class]) {
        objc_property_t *properties = class_copyPropertyList(searchClass, &propertiesCount);
        
        for (int i = 0; i < propertiesCount; i++) {
            objc_property_t property = properties[i];
            
            //NSLog(@"enumPropertiesWithBlock %@: %s", NSStringFromClass(searchClass), property_getName(property));
            
            VKPropertyHelper *helper = [[VKPropertyHelper alloc] initWith:property];
            if ([ignoredProperties containsObject:helper.propertyName])
                return;
            if (processBlock)
                processBlock(helper, propertiesCount);
        }
        free(properties);
        searchClass = [searchClass superclass];
    }
}

- (NSArray *)ignoredProperties {
    return @[@"objectClass", @"fields"];
}

- (NSMutableDictionary *)serialize {
    NSMutableDictionary *result = [NSMutableDictionary new];
    
    [self enumPropertiesWithBlock: ^(VKPropertyHelper * helper, int total) {
        if (![self valueForKey:helper.propertyName])
            return;
        Class propertyClass = NSClassFromString(helper.propertyClassName);
        if ([propertyClass isSubclassOfClass:[VKApiObjectArray class]]) {
            [[self valueForKey:helper.propertyName] serializeTo:result withName:helper.propertyName];
        }
        else if ([propertyClass isSubclassOfClass:[VKApiObject class]]) {
            [result setObject:[[self valueForKey:helper.propertyName] serialize] forKey:helper.propertyName];
        }
        else {
            [result setObject:[self valueForKey:helper.propertyName] forKey:helper.propertyName];
        }
    }];
    return result;
}

//- (NSString *)description{
//    NSString *className = NSStringFromClass([self class]);
//    NSString *description = [[@"<" stringByAppendingString:className] stringByAppendingString:@": "];
//
//    unsigned int numberOfProperties = 0;
//    objc_property_t *propertyArray = class_copyPropertyList([self class], &numberOfProperties);
//    for (NSUInteger i = 0; i < numberOfProperties; i++) {
//        objc_property_t property = propertyArray[i];
//        NSString *name = [[NSString alloc] initWithUTF8String:property_getName(property)];
//        description = [description stringByAppendingString:[NSString stringWithFormat:@"%@: %@", name, [self valueForKey:name]]];//NSLog(@"Property %@ Value: %@", name, [self valueForKey:name]);
//        if(i + 1 < numberOfProperties){
//            description = [description stringByAppendingString:@", "];
//        }
//        else{
//            description = [description stringByAppendingString:@">"];
//        }
//    }
//    free(propertyArray);
//    return description;
//}
@end
