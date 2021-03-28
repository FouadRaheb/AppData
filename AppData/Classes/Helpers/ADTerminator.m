//
//  ADAppTerminator.m
//  AppData
//
//  Created by udevs on 21/11/2020.
//

#import <Foundation/Foundation.h>
#import <dlfcn.h>
#import "ADTerminator.h"

static SBSApplicationTerminationAssertionRef (*SBSApplicationTerminationAssertionCreateWithError_Ptr)(void *unknown, NSString *bundleIdentifier, int reason, int *outError);

static void (*SBSApplicationTerminationAssertionInvalidate_Ptr)(SBSApplicationTerminationAssertionRef assertion);

SBSApplicationTerminationAssertionRef SBSApplicationTerminationAssertionCreateWithError(void *unknown, NSString *bundleIdentifier, int reason, int *outError) {
    if (SBSApplicationTerminationAssertionCreateWithError_Ptr) {
        return SBSApplicationTerminationAssertionCreateWithError_Ptr(unknown, bundleIdentifier, reason, outError);
    }
    return NULL;
}

void SBSApplicationTerminationAssertionInvalidate(SBSApplicationTerminationAssertionRef assertion) {
    if (SBSApplicationTerminationAssertionInvalidate_Ptr) {
        return SBSApplicationTerminationAssertionInvalidate_Ptr(assertion);
    }
}

__attribute__((constructor))
static void initializeFunctions() {
    void *handle = NULL;
    if (@available(iOS 13, *)) {
        handle = dlopen("/System/Library/PrivateFrameworks/SpringBoard.framework/SpringBoard", RTLD_LAZY);
    } else {
        handle = dlopen("/System/Library/PrivateFrameworks/SpringBoardServices.framework/SpringBoardServices", RTLD_LAZY);
    }
    
    if (handle) {
        SBSApplicationTerminationAssertionCreateWithError_Ptr = dlsym(handle, "SBSApplicationTerminationAssertionCreateWithError");
        SBSApplicationTerminationAssertionInvalidate_Ptr = dlsym(handle, "SBSApplicationTerminationAssertionInvalidate");
        dlclose(handle);
    }
}
