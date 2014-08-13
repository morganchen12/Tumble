//
//  PlayerClip.m
//  Tumble
//
//  Created by Morgan Chen on 8/13/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "PlayerClip.h"

@implementation PlayerClip

-(void)didLoadFromCCB {
    self.physicsBody.density = 10.f;
    self.physicsBody.friction = 0.3f;
    self.physicsBody.elasticity = 0.f;
    self.physicsBody.collisionType = @"playerClip";
    self.physicsBody.type = CCPhysicsBodyTypeStatic;
}

@end
