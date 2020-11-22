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


__attribute__((constructor))
static void initializeFunctions() {
    void *handler = dlopen("/System/Library/PrivateFrameworks/SpringBoard.framework/SpringBoard", RTLD_LAZY);
    if (handler){
        SBSApplicationTerminationAssertionCreateWithError_Ptr = dlsym(handler, "SBSApplicationTerminationAssertionCreateWithError");
        SBSApplicationTerminationAssertionInvalidate_Ptr = dlsym(handler, "SBSApplicationTerminationAssertionInvalidate");
        dlclose(handler);
    }
}

SBSApplicationTerminationAssertionRef SBSApplicationTerminationAssertionCreateWithError(void *unknown, NSString *bundleIdentifier, int reason, int *outError) {
    return SBSApplicationTerminationAssertionCreateWithError_Ptr(unknown, bundleIdentifier, reason, outError);
}

void SBSApplicationTerminationAssertionInvalidate(SBSApplicationTerminationAssertionRef assertion) {
    return SBSApplicationTerminationAssertionInvalidate_Ptr(assertion);
}
