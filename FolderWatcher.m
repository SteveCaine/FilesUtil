//
//	FolderWatcher.m
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

#import <fcntl.h>
#import <sys/event.h>

#import "FolderWatcher.h"

// --------------------------------------------------

@interface FolderWatcher () {
	CFFileDescriptorRef kqref;
	CFRunLoopSourceRef	rls;
}
- (void)kqueueFired;
@end

// --------------------------------------------------
#pragma mark -
// --------------------------------------------------

static void KQCallback(CFFileDescriptorRef kqRef, CFOptionFlags callBackTypes, void *info) {
	FolderWatcher *helper = (FolderWatcher *)(__bridge id)(CFTypeRef) info;
	[helper kqueueFired];
}

// --------------------------------------------------
#pragma mark -
// --------------------------------------------------

@implementation FolderWatcher

#pragma mark - locals 

- (void)kqueueFired {
	int				kq;
	struct kevent	event;
	struct timespec timeout = { 0, 0 };
	int				eventCount;
	
	kq = CFFileDescriptorGetNativeDescriptor(self->kqref);
	assert(kq >= 0);
	
	eventCount = kevent(kq, NULL, 0, &event, 1, &timeout);
	assert( (eventCount >= 0) && (eventCount < 2) );
	
	if (eventCount == 1)
		[[NSNotificationCenter defaultCenter] postNotificationName:kDocumentChanged object:self];
	
	CFFileDescriptorEnableCallBacks(self->kqref, kCFFileDescriptorReadCallBack);
}

- (void)beginGeneratingDocumentNotificationsInPath:(NSString *)folderPath {
	int						dirFD;
	int						kq;
	int						retVal;
	struct kevent			eventToAdd;
	CFFileDescriptorContext context = {  0, (void *)(__bridge CFTypeRef) self, NULL, NULL, NULL };
	
	dirFD = open([folderPath fileSystemRepresentation], O_EVTONLY);
	assert(dirFD >= 0);
	
	kq = kqueue();
	assert(kq >= 0);
	
	eventToAdd.ident  = dirFD;
	eventToAdd.filter = EVFILT_VNODE;
	eventToAdd.flags  = EV_ADD | EV_CLEAR;
	eventToAdd.fflags = NOTE_WRITE;
	eventToAdd.data	  = 0;
	eventToAdd.udata  = NULL;
	
	retVal = kevent(kq, &eventToAdd, 1, NULL, 0, NULL);
	assert(retVal == 0);
	
	self->kqref = CFFileDescriptorCreate(NULL, kq, true, KQCallback, &context);
	rls = CFFileDescriptorCreateRunLoopSource(NULL, self->kqref, 0);
	assert(rls != NULL);
	
	CFRunLoopAddSource(CFRunLoopGetCurrent(), rls, kCFRunLoopDefaultMode);
	CFRelease(rls);
	
	CFFileDescriptorEnableCallBacks(self->kqref, kCFFileDescriptorReadCallBack);
}

#pragma mark - globals

+ (id)watcherForPath:(NSString *)watchedFolderPath {
	FolderWatcher *watcher = [[self alloc] init];
	watcher.path = watchedFolderPath;
	[watcher beginGeneratingDocumentNotificationsInPath:watchedFolderPath];
	return watcher;
}

#pragma mark - overrides

- (void)dealloc {
//	self.path = nil;
	CFRunLoopRemoveSource(CFRunLoopGetCurrent(), rls, kCFRunLoopDefaultMode);
	CFFileDescriptorDisableCallBacks(self->kqref, kCFFileDescriptorReadCallBack);
}

@end
