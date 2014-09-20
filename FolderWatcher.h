//
//	FolderWatcher.h
//	FilesUtil
//
//	Created by Steve Caine on 08/18/14.
//
//	Adapted from book "The iOS 5 Developer's Cookbook" by Erica Sadun
//	"Recipe 16-3. Using a kqueue File Monitor"
//	as described here: http://www.informit.com/articles/article.aspx?p=1846575&seqNum=5
//	and make open-source under the BSD License here: https://github.com/erica/iOS-5-Cookbook
//  Copyright (c) 2012 Erica Sadun. All rights reserved.
//

#define kDocumentChanged @"DocumentsFolderContentsDidChangeNotification"

//#import <Foundation/Foundation.h>

@interface FolderWatcher : NSObject

@property (copy, nonatomic) NSString *path;

+ (id)watcherForPath:(NSString *)watchedFolderPath;

@end
