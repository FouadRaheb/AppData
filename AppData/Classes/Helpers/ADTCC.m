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
static CFArrayRef (*TCCAccessCopyInformationForBundle_Ptr)(CFBundleRef);


int TCCAccessResetForBundle(NSString *service, CFBundleRef bundle) {
    return TCCAccessResetForBundle_Ptr(service, bundle);
}

NSArray<NSDictionary *> *TCCAccessCopyInformationForBundle(CFBundleRef bundle) {
    CFArrayRef array = TCCAccessCopyInformationForBundle_Ptr(bundle);
    NSArray *objcArray = (__bridge_transfer NSArray *)array;
    return [objcArray copy];
}


__attribute__((constructor))
static void initializeFunctions() {
    void *handler = dlopen("/System/Library/PrivateFrameworks/TCC.framework/TCC", RTLD_LAZY);
    if (handler) {
        TCCAccessResetForBundle_Ptr = dlsym(handler, "TCCAccessResetForBundle");
        TCCAccessCopyInformationForBundle_Ptr = dlsym(handler, "TCCAccessCopyInformationForBundle");
        dlclose(handler);
    }
}
