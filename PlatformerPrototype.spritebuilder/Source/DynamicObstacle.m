//
//  DynamicObstacle.m
//  Tumble
//
//  Created by Morgan Chen on 8/7/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "DynamicObstacle.h"
#import "CCPhysics+ObjectiveChipmunk.h"

static const float ROTATION_TOLERANCE = M_PI*2;                              //max angular velocity in rad/sec before damping
static const float DAMPING_MAGNITUDE = 0.95;

@implementation DynamicObstacle

-(void)didLoadFromCCB {

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
