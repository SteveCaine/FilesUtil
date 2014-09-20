//
//	FilesUtil.m
//	FilesUtil
//
//	Created by Steve Caine on 08/16/14.
//
//	This code is distributed under the terms of the MIT license.
//
//	Copyright (c) 2014 Steve Caine.
//

#import "FilesUtil.h"

#import "AppDelegate.h"

#import "Debug_iOS.h"

@interface FilesUtil ()
@end

#pragma mark -

@implementation FilesUtil

#pragma mark - locals

#pragma mark - globals

// write contents of -str- to new file, replacing any preexisting, and return path to new file
+ (NSString *)writeString:(NSString *)str toFile:(NSString *)name inFolder:(NSString *)path {
	NSString *result = nil;
	
	NSString *dst_path = [path stringByAppendingPathComponent:name];
	BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:dst_path];
	NSError *error = nil;
	if (exists) {
		(void) [[NSFileManager defaultManager] removeItemAtPath:dst_path error:&error];
	}
	if (error)
		NSLog(@"Error clearing older file '%@': %@", name, error);
	
	else {
		NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
		BOOL wrote = [[NSFileManager defaultManager] createFileAtPath:dst_path contents:data attributes:nil];
		if (!wrote)
			NSLog(@"Failed to write file '%@'", name);
		else
			result = dst_path;
	}
	return result;
}

+ (NSString *)writeString:(NSString *)str toDocFile:(NSString *)name {
	NSString *docsDir = [AppDelegate documentsDirectory];
	return [FilesUtil writeString:str toFile:name inFolder:docsDir];
}

+ (NSString *)writeString:(NSString *)str toCacheFile:(NSString *)name {
	NSString *cacheDir = [AppDelegate cacheDirectory];
	return [FilesUtil writeString:str toFile:name inFolder:cacheDir];
}

/* TK
+ (NSString *)appendString:(NSString *)str toFile:(NSString *)name inFolder:(NSString *)path {
	return nil;
}

+ (NSString *)appendString:(NSString *)str toDocFile:(NSString *)name {
	return nil;
}

+ (NSString *)appendString:(NSString *)str toCacheFile:(NSString *)name {
	return nil;
}
*/

@end
