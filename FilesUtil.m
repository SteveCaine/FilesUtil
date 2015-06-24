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

// --------------------------------------------------

NSInteger sortFilesByThis(id lhs, id rhs, void *v) {
	
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
#pragma mark -
// --------------------------------------------------

@interface FilesUtil ()
@end

// --------------------------------------------------
#pragma mark -
// --------------------------------------------------

@implementation FilesUtil

+ (double)ageOfFile:(NSString *)filePath error:(NSError **)error {
	double result = 0.0;
	NSDictionary *attribs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:error];
	if (attribs && !*error) {
		NSDate *date = [attribs objectForKey:NSFileModificationDate];
		result = -[date timeIntervalSinceNow];
	}
	return result;
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
// TODO: check 'type' is valid for a filename extension
+ (NSArray *)pathsForFilesType:(NSString *)type inDir:(NSString *)dirPath sortedBy:(FilesUtil_SortFilesBy)sortedBy {
	NSMutableArray * result = nil;
	
	if ([type length] && [dirPath length]) {
		if ([[NSFileManager defaultManager] fileExistsAtPath:dirPath]) {
			NSError *error = nil;
			// "Performs a shallow search of the specified directory ..."
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

// --------------------------------------------------
#pragma mark -
// --------------------------------------------------

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
