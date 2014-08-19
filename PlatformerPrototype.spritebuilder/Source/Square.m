//
//  Square.m
//  PlatformerPrototype
//
//  Created by Morgan Chen on 7/8/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Square.h"

static const float ROTATION_TOLERANCE = M_PI/16;                              //max angular velocity in rad/sec before damping
static const float DAMPING_MAGNITUDE = 0.99;

@implementation Square

-(void)didLoadFromCCB {
    self.physicsBody.collisionGroup = @"worldBrushes";
    self.physicsBody.collisionType = @"world";
//    CCNodeColor *color = (CCNodeColor *)self.children[0];
//    color.opacity = 1.f - (arc4random() % 100)/1000.f;
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
