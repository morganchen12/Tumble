//
//  Player.m
//  PlatformerPrototype
//
//  Created by Morgan Chen on 7/3/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Player.h"

@implementation Player

-(void)didLoadFromCCB {
    self.physicsBody.collisionGroup = @"playerCollisionGroup";
    self.physicsBody.collisionType = @"player";
}

@end
