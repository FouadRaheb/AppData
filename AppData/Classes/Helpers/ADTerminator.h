//
//  ADAppTerminator.h
//  AppData
//
//  Created by udevs on 21/11/2020.
//

#ifndef ADTerminator_h
#define ADTerminator_h

typedef const struct __SBSApplicationTerminationAssertion *SBSApplicationTerminationAssertionRef;

FOUNDATION_EXTERN SBSApplicationTerminationAssertionRef SBSApplicationTerminationAssertionCreateWithError(void *unknown, NSString *bundleIdentifier, int reason, int *outError);
FOUNDATION_EXTERN void SBSApplicationTerminationAssertionInvalidate(SBSApplicationTerminationAssertionRef assertion);
FOUNDATION_EXTERN NSString *SBSApplicationTerminationAssertionErrorString(int error);

#endif /* ADAppTerminator_h */
