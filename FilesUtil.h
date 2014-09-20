//
//	FilesUtil.h
//	FilesUtil
//
//	Created by Steve Caine on 08/16/14.
//
//	This code is distributed under the terms of the MIT license.
//
//	Copyright (c) 2014 Steve Caine.
//

#import <Foundation/Foundation.h>

@interface FilesUtil : NSObject

// all return path to new file

+ (NSString *)writeString:(NSString *)str toFile:(NSString *)name inFolder:(NSString *)path;

+ (NSString *)writeString:(NSString *)str toDocFile:(NSString *)name;

+ (NSString *)writeString:(NSString *)str toCacheFile:(NSString *)name;

/* TK
+ (NSString *)appendString:(NSString *)str toFile:(NSString *)name inFolder:(NSString *)path;

+ (NSString *)appendString:(NSString *)str toDocFile:(NSString *)name;

+ (NSString *)appendString:(NSString *)str toCacheFile:(NSString *)name;
*/

@end
