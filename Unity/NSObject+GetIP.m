//
//  NSObject+GetIP.m
//  HYSEM
//
//  Created by 王一成 on 2017/7/28.
//  Copyright © 2017年 WGM. All rights reserved.
//

#import "NSObject+GetIP.h"

#import <arpa/inet.h>

#import <ifaddrs.h>

@implementation NSObject (GetIP)

+ (NSString *)deviceIPAdress {
    NSString *address = @"an error occurred when obtaining ip address";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    success = getifaddrs(&interfaces);
    
    if (success == 0) { // 0 表示获取成功
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in  *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    freeifaddrs(interfaces);
    
    DLog(@"%@", address);
    
    return address;
}

@end
