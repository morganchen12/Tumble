//
//  EndTrigger.m
//  PlatformerPrototype
//
//  Created by Morgan Chen on 7/9/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "EndTrigger.h"

@implementation EndTrigger

-(void)didLoadFromCCB {
    self.physicsBody.collisionGroup = @"world";
    self.physicsBody.collisionType = @"endTrigger";
    self.physicsBody.sensor = YES;
}

@end
