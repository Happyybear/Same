//
//  Node.m
//  SEM
//
//  Created by xlc on 16/7/27.
//  Copyright © 2016年 王广明. All rights reserved.
//

#import "Node.h"

@implementation Node

- (instancetype)initWithParentId : (long long)parentId nodeId : (long long)nodeId name : (NSString *)name depth : (int)depth expand : (BOOL)expand mpID:(NSString *)mpID Fee:(NSString*)fee{
    self = [self init];
    if (self) {
        self.parentId = parentId;
        self.nodeId = nodeId;
        self.name = name;
        self.depth = depth;
        self.expand = expand;
        self.MpID = mpID;
        self.ramain_Fee = fee;
    }
    return self;
}

- (float)stringToFloat:(NSString *)string
{
    float a = 0;
    a = [string floatValue];
    return a;
}


@end
