//
//  VKUser.m
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

#import "VKUser.h"

@implementation VKLastSeen
@end

@interface VKUser ()

@end

@implementation VKUser

static NSPersonNameComponentsFormatter * formatter;

- (NSString *)fullName{
    if(!_fullName)
        _fullName = [self fullName:NameCaseNominative];
    
    return _fullName;
}

- (NSString *)fullNameGen{
    if(!_fullNameGen)
        _fullNameGen = [self fullName:NameCaseGenetive];
    
    return _fullNameGen;
}

- (NSString *)fullNameDat{
    if(!_fullNameDat)
        _fullNameDat = [self fullName:NameCaseDative];
    
    return _fullNameDat;
}

- (NSString *)fullNameAcc{
    if(!_fullNameAcc)
        _fullNameAcc = [self fullName:NameCaseAccusative];
    
    return _fullNameAcc;
}

- (NSString *)fullNameIns{
    if(!_fullNameIns)
        _fullNameIns = [self fullName:NameCaseInstrumental];
    
    return _fullNameIns;
}

- (NSString *)fullNameAbl{
    if(!_fullNameAbl)
        _fullNameAbl = [self fullName:NameCasePrepositional];
    
    return _fullNameAbl;
}

- (NSString *)fullName:(NameCase)nameCase{
    NSString * fullName;
    
    NSString * firstName;
    NSString * lastName;
    
    switch (nameCase) {
        case NameCaseNominative:
            firstName = _first_name;
            lastName = _last_name;
            break;
        case NameCaseGenetive:
            firstName = _first_name_gen;
            lastName = _last_name_gen;
            break;
        case NameCaseDative:
            firstName = _first_name_dat;
            lastName = _last_name_dat;
            break;
        case NameCaseAccusative:
            firstName = _first_name_acc;
            lastName = _last_name_acc;
            break;
        case NameCaseInstrumental:
            firstName = _first_name_ins;
            lastName = _last_name_ins;
            break;
        case NameCasePrepositional:
            firstName = _first_name_abl;
            lastName = _last_name_abl;
            break;
        default:
            NSLog(@"Unknown NameCase %ld", (long)nameCase);
            firstName = _first_name;
            lastName = _last_name;
            break;
    }
    
    if(!firstName)
        firstName = _first_name;
    
    if(!lastName)
        lastName = _last_name;
    
    if([NSPersonNameComponents class]){ // checking availability. otherwise, pre-iOS 9 will crash
        NSPersonNameComponents * components = [NSPersonNameComponents new];
        
        components.givenName = firstName;
        components.familyName = lastName;
        
        if(!formatter){
            NSPersonNameComponentsFormatter * formatter = [NSPersonNameComponentsFormatter new];
            formatter.style = NSPersonNameComponentsFormatterStyleMedium;
        }
        
        fullName = [formatter stringFromPersonNameComponents:components];
    } else
        fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    
    
    return fullName;
}

@end

@implementation VKGeoObject
@end

@implementation VKCity
@end

@implementation VKCountry
@end

@implementation VKExports
@end

@implementation VKUsersArray

+ (Class)objectClass{
    return [VKUser class];
}

@end
