//
//  dyldBypass.m
//
//  Created by Kyle Nicol on 9/20/19.
//  Copyright © 2019 Hydra. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "dyldBypass.h"
#import "fishhook.h"

@implementation dyldBypass

#pragma mark Shared Variable Declarations
    int swapLC = 0;
    int swapCS = 0;
    
    // UPDATE THIS 
    //uint8_t lcData[0x4000] = {0xcf,0xfa, etc etc Your first 4 memory pages here as a byte array like this..., 0x4D};
    // AND THIS
    //uint8_t csData[0x1000] = {0x6D,0x6B, ETC ETC Your Code Signature 1 memory page byte array here...,0x30};

#pragma mark Bypass Functions
    // Store orig imp to pointer
    static ssize_t (*orig_read)(int, void *, ssize_t);
    // Custom Replacement Function
    ssize_t hacked_read(int fildes, void *buf, ssize_t nbytes){
        if (nbytes == 0x4000 && swapLC == 0){
            ssize_t ret = 0x4000;
            void *origLC = &lcData;
            memcpy(buf, origLC, ret);
            swapLC += 1;
            return ret;
        } else if (nbytes == 0x1000 && swapCS == 0) {
            ssize_t ret = 0x1000;
            void *origCS = &csData;
            memcpy(buf, origCS, ret);
            swapCS += 1;
            return ret;
        } else {
            return orig_read(fildes, buf, nbytes);
        }
    }
    
+(void)init{
    NSLog(@"[dyldBypass] - Init dyldBypass");
    
    rebind_symbols((struct rebinding[1]) {
        { "read", (void *)hacked_read, (void **)&orig_read }
    }, 1);
}

@end
