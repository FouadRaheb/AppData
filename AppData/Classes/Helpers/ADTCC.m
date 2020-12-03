//
//  TCC.m
//  AppData
//
//  Created by udevs on 21/11/2020.
//

#import <Foundation/Foundation.h>
#import <dlfcn.h>
#import "ADTCC.h"

NSString *const kTCCServiceAll = @"kTCCServiceAll";

static int (*TCCAccessResetForBundle_Ptr) (NSString *, CFBundleRef);

__attribute__((constructor))
static void initializeFunctions() {
    void *handler = dlopen("/System/Library/PrivateFrameworks/TCC.framework/TCC", RTLD_LAZY);
    if (handler){
        TCCAccessResetForBundle_Ptr = dlsym(handler, "TCCAccessResetForBundle");
        dlclose(handler);
    }
}

int TCCAccessResetForBundle(NSString *service, CFBundleRef bundle) {
    return TCCAccessResetForBundle_Ptr(service, bundle);
}
