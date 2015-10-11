//
//  VKObject.m
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

#import "VKObject.h"
#import <objc/message.h>



@implementation VKObject


#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder
{
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

- (void)encodeWithCoder:(NSCoder *)aCoder
{
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

- (BOOL)saveToDiskWithKey:(NSString *)key
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:key];
    return [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (id)loadFromDiskWithKey:(NSString *)key
{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    id result = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return result;
}
@end
