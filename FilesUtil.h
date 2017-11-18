//
//	FilesUtil.h
//	FilesUtil
//
//	Created by Steve Caine on 08/16/14.
//
//	This code is distributed under the terms of the MIT license.
//
//	Copyright (c) 2014-2017 Steve Caine.
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

+ (NSError *)errorWithDescription:(NSString *)description;
+ (NSError *)errorWithDescription:(NSString *)description domain:(NSString *)domain;

+ (double)ageOfFile:(NSString *)path error:(NSError **)error;

+ (BOOL)fileExists:(NSString *)path;
+ (BOOL)clearFile:(NSString *)path error:(NSError **)outError;

+ (BOOL)directoryExists:(NSString *)path;

// --------------------------------------------------
// returns PATH if exists, else returns -nil-
+ (NSString *)documentsDirectory;
+ (NSString *)cacheDirectory;
+ (NSString *)cacheSubDirectory:(NSString *)name; // name of subfolder in cache dir

// --------------------------------------------------
#pragma mark -
// --------------------------------------------------

+ (NSUInteger) copyBundleFilesOfType:(NSString *)type   toDir:(NSString *)dirPath;
+ (NSUInteger)mergeBundleFilesOfType:(NSString *)type intoDir:(NSString *)dirPath;

// --------------------------------------------------

+ (NSUInteger)countForFilesOfType:(NSString *)type inDir:(NSString *)dirPath filter:(BOOL(^)(NSString *))filter;
+ (NSUInteger)   clearFilesOfType:(NSString *)type inDir:(NSString *)dirPath filter:(BOOL(^)(NSString *))filter;

// --------------------------------------------------

+ (NSArray *)pathsForFilesType:(NSString *)type inDir:(NSString *)dirPath sortedBy:(FilesUtil_SortFilesBy)sortedBy;

+ (NSArray *)pathsForBundleFilesType:(NSString *)type sortedBy:(FilesUtil_SortFilesBy)sortedBy;

+ (NSArray *)namesFromPaths:(NSArray *)paths stripExtensions:(BOOL)stripYesNo;

// --------------------------------------------------
#pragma mark -
// --------------------------------------------------
// read .plist and .json files as arrays and dictionaries
// returns nil if file is not array/dictionary as requested

+ (NSArray *)          arrayFromBundle_json:(NSString *)fileName error:(NSError **)outError;
+ (NSDictionary *)dictionaryFromBundle_json:(NSString *)fileName error:(NSError **)outError;

+ (NSArray *)          arrayFromBundle_plist:(NSString *)fileName;
+ (NSDictionary *)dictionaryFromBundle_plist:(NSString *)fileName;

+ (BOOL)writeJson:(id)obj toFile:(NSString *)fileName inDir:(NSString *)dirPath error:(NSError **)outError;
+ (BOOL)writeJson:(id)obj toDocFile:(NSString *)fileName error:(NSError **)outError;

// --------------------------------------------------
// do same to .plist files using built-in NSArray/NSDictionary methods

// TODO:? add an NSPropertyListSerialization implementation w/ more control over process?

+ (BOOL)writePlist:(id)obj toFile:(NSString *)fileName inDir:(NSString *)dirPath error:(NSError **)outError;
+ (BOOL)writePlist:(id)obj toDocFile:(NSString *)fileName error:(NSError **)outError;

// --------------------------------------------------
#pragma mark -
// --------------------------------------------------
// all return path to new file

+ (NSString *)writeData:(NSData *)data toFile:(NSString *)name inFolder:(NSString *)path;

+ (NSString *)writeData:(NSData *)data toDocFile:(NSString *)name;

// --------------------------------------------------
#pragma mark -
// --------------------------------------------------
// all return path to new file

+ (NSString *)writeString:(NSString *)str toFile:(NSString *)name inFolder:(NSString *)path;

+ (NSString *)writeString:(NSString *)str toDocFile:(NSString *)name;

/* TK
+ (NSString *)appendString:(NSString *)str toFile:(NSString *)name inFolder:(NSString *)path;

+ (NSString *)appendString:(NSString *)str toDocFile:(NSString *)name;
*/

@end

// --------------------------------------------------
