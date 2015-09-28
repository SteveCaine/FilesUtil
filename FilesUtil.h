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

// --------------------------------------------------

typedef enum FilesUtil_SortFilesBys {
	SortFiles_alphabeticalAscending,
	SortFiles_alphabeticalDescending,
	SortFiles_newestFirst,
	SortFiles_oldestFirst
} FilesUtil_SortFilesBy;

// --------------------------------------------------

@interface FilesUtil : NSObject

+ (double)ageOfFile:(NSString *)path error:(NSError **)error;

// returns PATH if exists, else returns -nil-
+ (NSString *)documentsDirectory;
+ (NSString *)cacheDirectory;
+ (NSString *)cacheSubDirectory:(NSString *)name; // name of subfolder in cache dir

+ (NSUInteger) copyBundleFilesOfType:(NSString *)type   toDir:(NSString *)dirPath;
+ (NSUInteger)mergeBundleFilesOfType:(NSString *)type intoDir:(NSString *)dirPath;

+ (NSUInteger)countForFilesOfType:(NSString *)type inDir:(NSString *)dirPath filter:(BOOL(^)(NSString *))filter;
+ (NSUInteger)   clearFilesOfType:(NSString *)type inDir:(NSString *)dirPath filter:(BOOL(^)(NSString *))filter;

+ (NSArray *)pathsForFilesType:(NSString *)type inDir:(NSString *)dirPath sortedBy:(FilesUtil_SortFilesBy)sortedBy;

+ (NSArray *)pathsForBundleFilesType:(NSString *)type sortedBy:(FilesUtil_SortFilesBy)sortedBy;

+ (NSArray *)namesFromPaths:(NSArray *)paths stripExtensions:(BOOL)stripYesNo;

// --------------------------------------------------
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

// --------------------------------------------------
