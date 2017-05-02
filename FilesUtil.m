//
//	FilesUtil.m
//	FilesUtil
//
//	Created by Steve Caine on 08/16/14.
//
//	This code is distributed under the terms of the MIT license.
//
//	Copyright (c) 2014-2017 Steve Caine.
//

#import "FilesUtil.h"

#import "Debug_iOS.h"

// --------------------------------------------------
static NSInteger sortFilesByThis(id lhs, id rhs, void *v);
// --------------------------------------------------

static NSString * const STR_ErrorDomain = @"FilesUtilErrorDomain";

static NSString * const type_json  = @"json";
static NSString * const type_plist = @"plist";

// --------------------------------------------------

@interface FilesUtil ()
@end

// --------------------------------------------------
#pragma mark -
// --------------------------------------------------

@implementation FilesUtil

+ (NSError *)errorWithDescription:(NSString *)description {
	return [self errorWithDescription:description domain:nil];
}

+ (NSError *)errorWithDescription:(NSString *)description domain:(NSString *)domain {
	NSError *result = nil;
	
	if (description.length) {
		if (domain.length == 0)
			domain = STR_ErrorDomain;
		result = [NSError errorWithDomain:domain
									 code:-1
								 userInfo:@{ NSLocalizedDescriptionKey : description }];
	}
	return result;
}

// --------------------------------------------------

+ (double)ageOfFile:(NSString *)filePath error:(NSError **)outError {
	double result = 0.0;
	NSError *error;
	NSDictionary *attribs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error];
	if (attribs && !error) {
		NSDate *date = [attribs objectForKey:NSFileModificationDate];
		result = -[date timeIntervalSinceNow];
	}
	if (outError) *outError = error;
	return result;
}

+ (BOOL)fileExists:(NSString *)path {
	if (path.length) {
		BOOL isDirectory;
		BOOL found = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory];
		return (found && !isDirectory);
	}
	return NO;
}

// --------------------------------------------------
// these returns PATH if dir exists, else return -nil-

+ (NSString *)documentsDirectory {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	return [paths firstObject];
}

+ (NSString *)cacheDirectory {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	return [paths firstObject];
}

+ (NSString *)cacheSubDirectory:(NSString *)name { // name of subfolder in cache dir
	NSString *result = nil;
	// TODO: check name is valid for a directory
	if ([name length]) {
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
		NSString *dir = [paths firstObject];
		if ([dir length])
			result = [dir stringByAppendingPathComponent:name];
	}
	return result;
}

// --------------------------------------------------
// DO overwrite existing files
+ (NSUInteger)copyBundleFilesOfType:(NSString *)type toDir:(NSString *)dirPath {
	return [self copyBundleFilesOfType:type toDir:dirPath overwriteExisting:YES];
}

// DON'T overwrite existing files
+ (NSUInteger)mergeBundleFilesOfType:(NSString *)type intoDir:(NSString *)dirPath {
	return [self copyBundleFilesOfType:type toDir:dirPath overwriteExisting:NO];
}

// LOCAL METHOD
+ (NSUInteger)copyBundleFilesOfType:(NSString *)type toDir:(NSString *)dirPath overwriteExisting:(BOOL)overwriteYesNo {
	NSUInteger result = 0;
	
	NSFileManager *defaultManager = [NSFileManager defaultManager];
	
	NSArray *filePaths = [self pathsForBundleFilesType:type sortedBy:0]; //bundleFiles
	for (NSString *srcPath in filePaths) {
		NSString *srcName = [srcPath lastPathComponent];
		NSString *dstPath = [dirPath stringByAppendingPathComponent:srcName];
//		MyLog(@"copy \n'%@'\n to \n'%@'", srcPath, dstPath);
		
		BOOL exists = [defaultManager fileExistsAtPath:dstPath];
		if (exists && overwriteYesNo == NO)
			continue;
		
		NSError *error = nil;
		if (exists) {
			[defaultManager removeItemAtPath:dstPath error:&error];
			if (error) {
				MyLog(@"Failed to delete existing file '%@': %@", srcName, [error localizedDescription]);
			}
		}
		if (error == nil)
			[defaultManager copyItemAtPath:srcPath toPath:dstPath error:&error];
		if (error) {
			MyLog(@"Failed to copy file '%@': %@", srcName, [error localizedDescription]);
		}
	}
	
	return result;
}

// --------------------------------------------------

+ (NSUInteger)countForFilesOfType:(NSString *)type inDir:(NSString *)dirPath filter:(BOOL(^)(NSString *))filter {
//	MyLog(@"%s '%@'", __FUNCTION__, dirPath);
	NSUInteger result = 0;
	
	if (type.length && dirPath.length) {
		BOOL isDir = NO;
		if ([[NSFileManager defaultManager] fileExistsAtPath:dirPath isDirectory:&isDir] && isDir) {
			NSError *error = nil;
			NSArray* files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirPath error:&error];
			
			if (files.count) {
				for (NSString *file in files) {
					if ([file.pathExtension isEqualToString:type] && (filter == nil || filter(file)))
						++result;
				}
			}
			else if (error)
				MyLog(@"Error counting files in '%@': %@", dirPath, [error localizedDescription]);
		}
	}
	return result;
}

+ (NSUInteger)clearFilesOfType:(NSString *)type inDir:(NSString *)dirPath filter:(BOOL(^)(NSString *))filter {
	NSUInteger result = 0;

	if (type.length && dirPath.length) {
		BOOL isDir = NO;
		if ([[NSFileManager defaultManager] fileExistsAtPath:dirPath isDirectory:&isDir] && isDir) {
			NSError *error = nil;
			NSArray* files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirPath error:&error];
			
			if (files.count) {
				for (NSString *file in files) {
					NSString *path = [NSString pathWithComponents:@[dirPath, file]];
					if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] && !isDir) {
						if ([file.pathExtension isEqualToString:type] && (filter == nil || filter(file))) {
							if ([[NSFileManager defaultManager] removeItemAtPath:path error:&error])
								++result;
						}
					}
				}
			}
			else if (error)
				MyLog(@"Error clearing files in '%@': %@", dirPath, [error localizedDescription]);
		}
	}
	return result;
}

// --------------------------------------------------
// TODO: check 'type' is valid for a filename extension
+ (NSArray *)pathsForFilesType:(NSString *)type inDir:(NSString *)dirPath sortedBy:(FilesUtil_SortFilesBy)sortedBy {
	NSMutableArray * result = nil;
	
	if ([type length] && [dirPath length]) {
		BOOL isDir = NO;
		if ([[NSFileManager defaultManager] fileExistsAtPath:dirPath isDirectory:&isDir] && isDir) {
			NSError *error = nil;
			NSArray* files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirPath error:&error];
			if (error != nil) {
				MyLog(@"Error counting files: %@", [error localizedDescription]);
			}
			else {
//				int index = 0;
				for (NSString *file in files) {
//					MyLog(@"%2i: '%@'", index++, file);
					NSString *path = [NSString pathWithComponents:@[dirPath, file]];
					if ([[path pathExtension] isEqualToString:type]) {
						if (result == nil)
							result = [NSMutableArray arrayWithCapacity:1];
						[result addObject:path];
					}
				}
				//MyLog(@"%s result == %@", __FUNCTION__, [FilesUtil namesFromPaths:result stripExtensions:NO]);
				if ([result count] > 1) {
					NSArray *sorted = [result sortedArrayUsingFunction:sortFilesByThis context:&sortedBy];
					result = [NSMutableArray arrayWithArray:sorted];
					//MyLog(@" result => %@", [FilesUtil namesFromPaths:result stripExtensions:NO]);
				}
			}
		}
	}
	return result;
}

// --------------------------------------------------

+ (NSArray *)pathsForBundleFilesType:(NSString *)type sortedBy:(FilesUtil_SortFilesBy)sortedBy {
	NSArray *result = nil;
	
	if ([type length]) {
		result = [[NSBundle mainBundle] pathsForResourcesOfType:type inDirectory:nil];
		//MyLog(@"%s result == %@", __FUNCTION__, [FilesUtil namesFromPaths:result stripExtensions:NO]);
		if ([result count] > 1) {
			result = [result sortedArrayUsingFunction:sortFilesByThis context:&sortedBy];
			//MyLog(@" result => %@", [FilesUtil namesFromPaths:result stripExtensions:NO]);
		}
	}
	return result;
}

// --------------------------------------------------

+ (NSArray *)namesFromPaths:(NSArray *)paths stripExtensions:(BOOL)stripYesNo {
	NSMutableArray * result = nil;
	if ([paths count]) {
		// TODO: check that each is a valid file path?
		for (NSString *path in paths) {
			NSString *name = [path lastPathComponent];
			if (stripYesNo)
				name = [name stringByDeletingPathExtension];
			if (result == nil)
				result = [NSMutableArray arrayWithCapacity:1];
			[result addObject:name];
		}
	}
	return result;
}

// --------------------------------------------------
#pragma mark -
// --------------------------------------------------

+ (NSArray *)arrayFromBundle_json:(NSString *)fileName error:(NSError **)outError {
	id obj = [self.class objFromBundle_json:fileName error:outError];
	if ([obj isKindOfClass:NSArray.class])
		return obj;
	return nil;
}

+ (NSDictionary *)dictionaryFromBundle_json:(NSString *)fileName error:(NSError **)outError {
	id obj = [self.class objFromBundle_json:fileName error:outError];
	if ([obj isKindOfClass:NSDictionary.class])
		return obj;
	return nil;
}

// --------------------------------------------------

+ (NSArray *)arrayFromBundle_plist:(NSString *)fileName {
	NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:type_plist];
	NSArray *result = [NSArray arrayWithContentsOfFile:path];
	return result;
}

+ (NSDictionary *)dictionaryFromBundle_plist:(NSString *)fileName {
	NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:type_plist];
	NSDictionary *result = [NSDictionary dictionaryWithContentsOfFile:path];
	return result;
}

// --------------------------------------------------
#pragma mark -
// --------------------------------------------------

+ (id)objFromBundle_json:(NSString *)fileName error:(NSError **)outError {
	id obj = nil;
	
	NSError *error = nil;
	if (fileName.length) {
		NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:type_json];
		NSData *data = [NSData dataWithContentsOfFile:path];
		if (data && data.length) {
			obj = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
		}
		else error = [self errorWithDescription:@"Failed to read file in objFromBundle_json."];
	}
	else error = [self errorWithDescription:@"Empty fileName in objFromBundle_json."];
	if (outError) *outError = error;
	return obj;
}

// --------------------------------------------------
#pragma mark -
// --------------------------------------------------

+ (BOOL)writeJson:(id)obj toFile:(NSString *)fileName inDir:(NSString *)dirPath error:(NSError **)outError {
	BOOL result = NO;
	
	NSError *error = nil;
	if (fileName.length && dirPath.length && obj != nil) {
		if ([obj isKindOfClass:NSDictionary.class] || [obj isKindOfClass:NSArray.class]) {
			NSData *json = [NSJSONSerialization dataWithJSONObject:obj options:0 error:&error];
			if (json.length) {
				NSString *path = [dirPath stringByAppendingPathComponent:fileName];
				path = [path stringByAppendingPathExtension:type_json];
				result = [json writeToFile:path options:0 error:&error];
				NSLog(@"wrote JSON = %s", result ? "YES" : "NO");
			}
		}
		else error = [self errorWithDescription:@"FilesUtil:writeJson can only handle dictionaries and arrays."];
	}
	else error = [self errorWithDescription:@"Nil file/dir/object in writeJson:"];
	if (outError) *outError = error;
	
	return result;
}
+ (BOOL)writeJson:(id)obj toDocFile:(NSString *)fileName error:(NSError **)outError {
	BOOL result = NO;
	result = [self writeJson:obj toFile:fileName inDir:self.documentsDirectory error:outError];
	return result;
}

// --------------------------------------------------
#pragma mark -
// --------------------------------------------------
// write -data- to (overwriting) new file and return its path

+ (NSString *)writeData:(NSData *)data toFile:(NSString *)name inFolder:(NSString *)path {
	NSString *result = nil;
	
	if (data.length && name.length && path.length) {
	NSString *dst_path = [path stringByAppendingPathComponent:name];
	BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:dst_path];
	NSError *error = nil;
	if (exists) {
		(void) [[NSFileManager defaultManager] removeItemAtPath:dst_path error:&error];
	}
	if (error)
		NSLog(@"Error clearing older file '%@': %@", name, error);
	
	else {
		BOOL wrote = [[NSFileManager defaultManager] createFileAtPath:dst_path contents:data attributes:nil];
		if (!wrote)
			NSLog(@"Failed to write file '%@'", name);
		else
			result = dst_path;
	}
	}
	return result;
}

+ (NSString *)writeData:(NSData *)data toDocFile:(NSString *)name {
	NSString *docsDir = [self documentsDirectory];
	return [FilesUtil writeData:data toFile:name inFolder:docsDir];
}

+ (NSString *)writeData:(NSData *)data toCacheFile:(NSString *)name {
	NSString *cacheDir = [self cacheDirectory];
	return [FilesUtil writeData:data toFile:name inFolder:cacheDir];
}

// --------------------------------------------------
#pragma mark -
// --------------------------------------------------
// write -str- to (overwriting) new file and return its path
+ (NSString *)writeString:(NSString *)str toFile:(NSString *)name inFolder:(NSString *)path {
	NSString *result = nil;
	if (str.length && name.length && path.length) {
		NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
		[self writeData:data toFile:name inFolder:path];
	}
	return result;
}

+ (NSString *)writeString:(NSString *)str toDocFile:(NSString *)name {
	NSString *docsDir = [self documentsDirectory];
	return [FilesUtil writeString:str toFile:name inFolder:docsDir];
}

+ (NSString *)writeString:(NSString *)str toCacheFile:(NSString *)name {
	NSString *cacheDir = [self cacheDirectory];
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

// --------------------------------------------------
#pragma mark -
// --------------------------------------------------

static NSInteger sortFilesByThis(id lhs, id rhs, void *v) {
	
	FilesUtil_SortFilesBy sortFilesBy = SortFiles_alphabeticalAscending; // default
	if (v)
		sortFilesBy = *(FilesUtil_SortFilesBy *)v;
	
	NSString *lhsPath = (NSString *)lhs;
	NSString *rhsPath = (NSString *)rhs;
	
	NSError *lhsError = nil;
	NSError *rhsError = nil;
	
	if (sortFilesBy == SortFiles_alphabeticalAscending ||
		sortFilesBy == SortFiles_alphabeticalDescending) {
		
		NSString *lhsName = [lhsPath lastPathComponent];
		NSString *rhsName = [rhsPath lastPathComponent];
		NSInteger result = [lhsName caseInsensitiveCompare:rhsName];
		
		if (sortFilesBy == SortFiles_alphabeticalAscending)
			return result;
		else if (sortFilesBy == SortFiles_alphabeticalDescending)
			return -result;
	}
	else if (sortFilesBy == SortFiles_newestFirst ||
			 sortFilesBy == SortFiles_oldestFirst) {
		// TODO: handle errors
		double lhsAge = [FilesUtil ageOfFile:lhsPath error:&lhsError];
		double rhsAge = [FilesUtil ageOfFile:rhsPath error:&rhsError];
		
		if (lhsAge < rhsAge)
			return (sortFilesBy == SortFiles_newestFirst) ? -1 : +1;
		else
			if (rhsAge < lhsAge)
				return (sortFilesBy == SortFiles_newestFirst) ? +1 : -1;
	}
	
	return 0;
}

// --------------------------------------------------
