//
//  NRFileManager.h
//  NRFoundation
//
//  Created by Nikolai Ruhe on 2015-02-22.
//  Copyright (c) 2015 Nikolai Ruhe. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSFileManager (NRFileManager)

- (BOOL)nr_getAllocatedSize:(unsigned long long *)size ofDirectoryAtURL:(NSURL *)url error:(NSError * __autoreleasing *)error;

@end
