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
#import "VKUtil.h"



#ifdef DEBUG
#define PRINT_PARSE_DEBUG_INFO YES
#else
#define PRINT_PARSE_DEBUG_INFO NO
#endif

static NSString *const INT_NAME = @"int";
static NSString *const DOUBLE_NAME = @"double";
static NSString *const BOOL_NAME = @"bool";
static NSString *const ID_NAME = @"id";



static NSString *getPropertyType(objc_property_t property) {
    const char *type = property_getAttributes(property);
    NSString *typeString = [NSString stringWithUTF8String:type];
    NSArray *attributes = [typeString componentsSeparatedByString:@","];
    NSString *typeAttribute = [attributes objectAtIndex:0];
    NSString *propertyType = [typeAttribute substringFromIndex:1];
    const char *rawPropertyType = [propertyType UTF8String];
    
#warning missing CGFloat check?
    if (strcmp(rawPropertyType, @encode(float)) == 0
        || strcmp(rawPropertyType, @encode(double)) == 0) {
        return DOUBLE_NAME;
    }
    
    else if (strcmp(rawPropertyType, @encode(char)) == 0
             || strcmp(rawPropertyType, @encode(short)) == 0
             || strcmp(rawPropertyType, @encode(int)) == 0
             || strcmp(rawPropertyType, @encode(long)) == 0
             || strcmp(rawPropertyType, @encode(long long)) == 0
             || strcmp(rawPropertyType, @encode(unsigned char)) == 0
             || strcmp(rawPropertyType, @encode(unsigned short)) == 0
             || strcmp(rawPropertyType, @encode(unsigned int)) == 0
             || strcmp(rawPropertyType, @encode(unsigned long)) == 0
             || strcmp(rawPropertyType, @encode(unsigned long long)) == 0) {
        return INT_NAME;
    }
    else if (strcmp(rawPropertyType, @encode(BOOL)) == 0) {
        return BOOL_NAME;
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

- (instancetype)initWith:(objc_property_t)prop {
    if (self = [super init]) {
        _property = prop;
        _propertyName = getPropertyName(prop);
        _propertyClassName = getPropertyType(self.property);
        _isPrimitive = [@[DOUBLE_NAME, INT_NAME, BOOL_NAME] containsObject:_propertyClassName];
        
        if (!_isPrimitive) {
            _propertyClass = NSClassFromString(_propertyClassName);
            
            BOOL isModelsArray = [_propertyClass isSubclassOfClass:[VKApiObjectArray class]];// || [_propertyClass isSubclassOfClass:[NSMutableArray class]];
            if (isModelsArray) {
                _isModelsArray = isModelsArray;
            } else {
                _isModel = [_propertyClass isSubclassOfClass:[VKApiObject class]];
            }
        }
    }
    return self;
}
@end







@interface VKApiObject ()
@property NSMutableDictionary * classesProperties;
@end

@implementation VKApiObject

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    dict = VK_ENSURE_DICT(dict);
    if (!dict) {
        return nil;
    }
    if ((self = [super init])) {
        id response = dict[@"response"];
        if (response)
            [self parse:response];
        else
            [self parse:dict];
    }
    return self;
}

- (void)parse:(NSDictionary *)dict {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _classesProperties = [NSMutableDictionary dictionary];
    });
    NSString *className = NSStringFromClass(self.class);
    __block NSMutableDictionary *propDict = nil;
    @synchronized (_classesProperties) {
        propDict = [_classesProperties objectForKey:className];
    }
    if (!propDict) {
        [self enumPropertiesWithBlock:^(VKPropertyHelper * helper, int totalProps) {
            if (!propDict){
                propDict = [NSMutableDictionary dictionaryWithCapacity:totalProps];
            }
            propDict[helper.propertyName] = helper;
        }];
        if (!propDict) {
            propDict = [NSMutableDictionary new];
        }
        @synchronized (_classesProperties) {
            _classesProperties[className] = propDict;
        }
    }
    NSMutableArray *warnings = PRINT_PARSE_DEBUG_INFO ? [NSMutableArray new] : nil;
    for (__strong NSString *key in dict) {
        id resultObject = nil;
        id parseObject = dict[key];
        
        // Key exchange
        if ([key isEqualToString:@"copy_history"]) {
            key = @"history";
        } else if ([key isEqualToString:@"description"]){
            key = @"descriptionVK";
        } else if ([key isEqualToString:@"new_pts"]){
            key = @"pts";
        }
        
        VKPropertyHelper *propHelper = propDict[key];
        if (!propHelper) {
            // Если свойство не найдено
            // Проверим среди сменившихся имён
            // Если не нашли — сообщаем
            if (!propHelper) {
                NSLog(@"😡 Missed key %@ in class %@", key, className);
                continue;
            }
        };
        
//        if ([key isEqualToString:@"description"]) {
//            NSLog(@"%@", parseObject);
//        }
        
        NSString *propertyName = propHelper.propertyName;
        Class propertyClass = propHelper.propertyClass;
        
        if (propHelper.isPrimitive) {
            //NSLog(@"isPrimitive");
            [self setValue:parseObject forKey:propertyName];
            continue;
        } else if (propHelper.isModelsArray) {
            if ([parseObject isKindOfClass:[NSDictionary class]]) {
                //NSLog(@"%@ isModelsArray-[NSDictionary class]", NSStringFromClass(propHelper.propertyClass));
                resultObject = [[propertyClass alloc] initWithDictionary:parseObject];
            }
            else if ([parseObject isKindOfClass:[NSArray class]]) {
                //NSLog(@"%@ isModelsArray-[NSArray class]", NSStringFromClass(propHelper.propertyClass));
                resultObject = [[propertyClass alloc] initWithArray:parseObject objectClass:[self itemClassForArrayClass:propHelper.propertyClass]];
            }
            else {
                if (PRINT_PARSE_DEBUG_INFO) {
                    [warnings addObject:[NSString stringWithFormat:@"property %@ is parcelable, but data is not", propertyName]];
                }
            }
        }
        else if (propHelper.isModel) {
            if ([parseObject isKindOfClass:[NSDictionary class]]) {
                //NSLog(@"isModel-[NSDictionary class]");
                //                resultObject = [propertyClass createWithDictionary:parseObject];
                resultObject = [[propertyClass alloc] initWithDictionary:parseObject];
                
            } else if ([parseObject isKindOfClass:[NSArray class]]) {
                //NSLog(@"isModel-[NSArray class]");
                //                resultObject = [propertyClass createWithArray:parseObject];
                resultObject = [[propertyClass alloc] initWithArray:parseObject objectClass:[self itemClassForArrayClass:propHelper.propertyClass]];
            }
            else {
                //NSLog(@"isModel-else");
                if (PRINT_PARSE_DEBUG_INFO) {
                    [warnings addObject:[NSString stringWithFormat:@"property %@ is parcelable, but data is not", propertyName]];
                }
            }
        }
        else {
            //NSLog(@"else");
            resultObject = parseObject;
            if (propertyClass && ![resultObject isKindOfClass:propertyClass]) {
                if ([(Class) propertyClass isSubclassOfClass:[NSString class]]) {
                    resultObject = [resultObject respondsToSelector:@selector(stringValue)] ? [resultObject stringValue] : nil;
                } else {
//                    resultObject = nil;
//                    if (PRINT_PARSE_DEBUG_INFO) {
//                        [warnings addObject:[NSString stringWithFormat:@"property with name '%@' expected class '%@', result class '%@'", propertyName, propertyClass, [resultObject class]]];
//                    }
                }
                
            } else if (propHelper.isPrimitive) {
                if ([resultObject isKindOfClass:[NSNumber class]]) {
                    resultObject = resultObject;
                } else {
//                    resultObject = nil;
                }
            }
        }
        
        if (!resultObject &&  PRINT_PARSE_DEBUG_INFO) {
            [warnings addObject:[NSString stringWithFormat:@"Unknown property with name '%@' expected class '%@', result class '%@'", propertyName, propertyClass, [resultObject class]]];
        }
        [self setValue:resultObject forKey:propertyName];
    }
    
    if (PRINT_PARSE_DEBUG_INFO && warnings.count) {
        NSLog(@"Parsing '%@' complete. Warnings: %@", self, warnings);
    }
}

- (Class)itemClassForArrayClass:(Class)arrayClass{
    Class result = arrayClass;
    NSString *className = NSStringFromClass(arrayClass);
    NSString *resultClassName = className;
    
    if ([arrayClass isSubclassOfClass:[VKApiObjectArray class]]){
        resultClassName = NSStringFromClass([(VKApiObjectArray *)arrayClass objectClass]);
    } else {
        NSLog(@"❌ Don't know how to parse array '%@'", className);
    }
    
    result = NSClassFromString(resultClassName);
    
    return result;
}

- (void)enumPropertiesWithBlock:(void (^)(VKPropertyHelper * helper, int totalProps))processBlock {
    unsigned int propertiesCount;
    //Get all properties of current class
    Class searchClass = [self class];
    Class lastViewedClass = Nil;
    NSArray *ignoredProperties = [self ignoredProperties];
    while (lastViewedClass != [VKApiObject class]) {
        objc_property_t *properties = class_copyPropertyList(searchClass, &propertiesCount);
        
        for (int i = 0; i < propertiesCount; i++) {
            objc_property_t property = properties[i];
            
            //NSLog(@"enumPropertiesWithBlock %@: %s", NSStringFromClass(searchClass), property_getName(property));
            
            
            VKPropertyHelper *helper = [[VKPropertyHelper alloc] initWith:property];
            if ([ignoredProperties containsObject:helper.propertyName])
                continue;
            if (processBlock)
                processBlock(helper, propertiesCount);
        }
        free(properties);
        lastViewedClass = searchClass;
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

+ (instancetype)createWithDictionary:(NSDictionary *)dict {
    return [[self alloc] initWithDictionary:dict];
}

+ (instancetype)createWithArray:(NSArray *)array {
    return nil;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if (   [key isEqualToString:@"hash"]
        || [key isEqualToString:@"superclass"]
        || [key isEqualToString:@"description"]
        || [key isEqualToString:@"debugDescription"]
        || [key isEqualToString:@"attachmentString"]){
        return;
    }
        
    if (PRINT_PARSE_DEBUG_INFO) {
        NSLog(@"Parser tried to set value '%@' for undefined key '%@' in class '%@'", value, key, NSStringFromClass(self.class));
    }
}


- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        
        unsigned int pCounter = 0;
        objc_property_t *properties = class_copyPropertyList([self class], &pCounter);
        
        for (unsigned int i = 0; i < pCounter; i++)
        {
            objc_property_t prop = properties[i];
            const char *propName = property_getName(prop);
            NSString *pUTF8 = [NSString stringWithUTF8String:propName];
            
            [self setValue:[aDecoder decodeObjectForKey:pUTF8] forKey:pUTF8];
        }
        
        free(properties);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    unsigned int pCounter = 0;
    objc_property_t *properties = class_copyPropertyList([self class], &pCounter);
    
    for (unsigned int i = 0; i < pCounter; i++)
    {
        objc_property_t prop = properties[i];
        const char *propName = property_getName(prop);
        NSString *pUTF8 = [NSString stringWithUTF8String:propName];
        
        [aCoder encodeObject:[self valueForKey:pUTF8] forKey:pUTF8];
    }
    
    free(properties);
}
@end
