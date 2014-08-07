//
//  DynamicObstacle.m
//  Tumble
//
//  Created by Morgan Chen on 8/7/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "DynamicObstacle.h"
#import "CCPhysics+ObjectiveChipmunk.h"

static const float ROTATION_TOLERANCE = M_PI;                              //max angular velocity in rad/sec before damping
static const float DAMPING_MAGNITUDE = 0.95;

@implementation DynamicObstacle

-(void)didLoadFromCCB {
//    self.physicsBody.body.body->velocity_func = obstacleUpdateVelocity;
}

//static void obstacleUpdateVelocity(cpBody *body, cpVect gravity, cpFloat damping, cpFloat dt){
//    if(cpBodyGetType(body) == CP_BODY_TYPE_KINEMATIC) return;
//	
//	cpAssertSoft(body->m > 0.0f && body->i > 0.0f, "Body's mass and moment must be positive to simulate. (Mass: %f Moment: %f)", body->m, body->i);
//	
//	body->v = cpvadd(cpvmult(body->v, damping), cpvmult(cpvadd(gravity, cpvmult(body->f, body->m_inv)), dt));
//	body->w = body->w*damping + body->t*body->i_inv*dt;
//	
//	// Reset forces.
//	body->f = cpvzero;
//	body->t = 0.0f;
//	
//	cpAssertSaneBody(body);
//}

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
