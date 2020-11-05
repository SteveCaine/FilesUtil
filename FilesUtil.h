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
	SortFiles_NO,
	SortFiles_alphabeticalAscending,
	SortFiles_alphabeticalDescending,
	SortFiles_newestFirst,
	SortFiles_oldestFirst,
	SortFiles_largestFirst,
	SortFiles_smallestFirst
} FilesUtil_SortFilesBy;

// --------------------------------------------------

@interface FilesUtil : NSObject

+ (NSError *)errorWithDescription:(NSString *)description;
+ (NSError *)errorWithDescription:(NSString *)description domain:(NSString *)domain;

+ (NSDate *)		  dateOfFile:(NSString *)path error:(NSError **)error;
+ (NSTimeInterval)	   ageOfFile:(NSString *)path error:(NSError **)error;
+ (unsigned long long)sizeOfFile:(NSString *)path error:(NSError **)outError;

+ (BOOL)fileExists:(NSString *)path;
+ (BOOL) clearFile:(NSString *)path error:(NSError **)outError;

+ (BOOL)directoryExists:(NSString *)path;

// --------------------------------------------------
// returns PATH if exists, else returns -nil-
+ (NSString *)documentsDirectory;
+ (NSString *)cacheDirectory;
+ (NSString *)cacheSubDirectory:(NSString *)name; // name of subfolder in cache dir
+ (NSString *)tempDirectory;

// --------------------------------------------------
#pragma mark -
// --------------------------------------------------

+ (NSUInteger) copyBundleFilesOfType:(NSString *)type   toDir:(NSString *)path; // overwrites existing files
+ (NSUInteger)mergeBundleFilesOfType:(NSString *)type intoDir:(NSString *)path; // leaves existing files unchanged

// --------------------------------------------------

+ (NSUInteger)countForFilesOfType:(NSString *)type inDir:(NSString *)dirPath filter:(BOOL(^)(NSString *))filter;
+ (NSUInteger)   clearFilesOfType:(NSString *)type inDir:(NSString *)dirPath filter:(BOOL(^)(NSString *))filter;

// --------------------------------------------------

+ (NSArray *)pathsForFilesType:(NSString *)type inDir:(NSString *)dirPath sortedBy:(FilesUtil_SortFilesBy)sortedBy;

+ (NSArray *)pathsForBundleFilesType:(NSString *)type sortedBy:(FilesUtil_SortFilesBy)sortedBy;

+ (NSArray *)namesFromPaths:(NSArray *)paths stripExtensions:(BOOL)stripYesNo;

+ (NSArray *)pathsForNames:(NSArray *)names inDir:(NSString *)path;

// --------------------------------------------------
#pragma mark -
// --------------------------------------------------
// include filename extension

- (NSData *)dataFromBundleFile:(NSString *)fileName;

// --------------------------------------------------
#pragma mark -
// --------------------------------------------------
// read .plist and .json files as arrays and dictionaries
// returns nil if file is not array/dictionary as requested
// --------------------------------------------------
// NOTE: bundle file names EXCLUDE ".plist"/".json" extension

+ (NSArray *)          arrayFromBundle_plist:(NSString *)name error:(NSError **)outError;
+ (NSDictionary *)dictionaryFromBundle_plist:(NSString *)name error:(NSError **)outError;
// --------------------------------------------------
+ (NSArray *)          arrayFromBundle_json:(NSString *)name error:(NSError **)outError;
+ (NSDictionary *)dictionaryFromBundle_json:(NSString *)name error:(NSError **)outError;

// --------------------------------------------------
// NOTE: file paths INCLUDE ".plist"/".json" extension

+ (NSArray *)          arrayFromFilePath_json:(NSString *)path error:(NSError **)outError;
+ (NSDictionary *)dictionaryFromFilePath_json:(NSString *)path error:(NSError **)outError;

+ (NSArray *)          arrayFromFileURL_json:(NSURL *)url error:(NSError **)outError;
+ (NSDictionary *)dictionaryFromFileURL_json:(NSURL *)url error:(NSError **)outError;

// --------------------------------------------------

+ (BOOL)writeJson:(id)obj toFile:(NSString *)name inDir:(NSString *)path error:(NSError **)outError;
+ (BOOL)writeJson:(id)obj toDocFile:(NSString *)name error:(NSError **)outError;

// --------------------------------------------------
// do same to .plist files using built-in NSArray/NSDictionary methods

// TODO:? add an NSPropertyListSerialization implementation w/ more control over process?

+ (BOOL)writePlist:(id)obj toFile:(NSString *)name inDir:(NSString *)path error:(NSError **)outError;
+ (BOOL)writePlist:(id)obj toDocFile:(NSString *)name error:(NSError **)outError;

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

// adds date as prefix to file
+ (NSString *)writeString:(NSString *)str toDocFile:(NSString *)name withDate:(NSDate *)date;

/* TK
+ (NSString *)appendString:(NSString *)str toFile:(NSString *)name inFolder:(NSString *)path;

+ (NSString *)appendString:(NSString *)str toDocFile:(NSString *)name;
*/

@end

// --------------------------------------------------
