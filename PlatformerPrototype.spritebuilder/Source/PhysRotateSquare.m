//
//  PhysRotateSquare.m
//  PlatformerPrototype
//
//  Created by Morgan Chen on 7/23/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "PhysRotateSquare.h"

static const float ROTATION_TOLERANCE = M_PI*2;                              //max angular velocity in rad/sec before damping
static const float DAMPING_MAGNITUDE = 0.95;

@implementation PhysRotateSquare {
    CCNode *_square;
    CCNode *_pivotNode;
}

-(void)didLoadFromCCB {
    _square.physicsBody.collisionGroup = @"worldBrushes";
    _square.physicsBody.collisionType = @"world";
    _pivotNode.physicsBody.collisionMask = @[];
}

-(void)fixedUpdate:(CCTime)delta {
    if(fabs(self.physicsBody.angularVelocity) > ROTATION_TOLERANCE){
        if(self.physicsBody.angularVelocity >= 0){
            self.physicsBody.angularVelocity = (self.physicsBody.angularVelocity - ROTATION_TOLERANCE)*DAMPING_MAGNITUDE + ROTATION_TOLERANCE;
        }
        else {
            self.physicsBody.angularVelocity = (self.physicsBody.angularVelocity + ROTATION_TOLERANCE)*DAMPING_MAGNITUDE - ROTATION_TOLERANCE;
        }
    }
}

@end
