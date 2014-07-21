//
//  ClockwiseSquare.m
//  PlatformerPrototype
//
//  Created by Morgan Chen on 7/21/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "ClockwiseSquare.h"

static const float ROTATION_ANGLE = 20; //in degrees per 1/60 second
//static const float ROTATION_SPEED_RANGE = 0.1;

@implementation ClockwiseSquare {
}

-(void)didLoadFromCCB {
    self.rotation = arc4random() % 360;
    self.physicsBody.collisionGroup = @"world";
//    self.physicsBody.type = CCPhysicsBodyTypeKinematic;
    [self runAction:[CCActionRepeatForever actionWithAction:[CCActionRotateBy actionWithDuration:1 angle:ROTATION_ANGLE]]];
//    _rotationSpeed = ROTATION_BASE_SPEED + ROTATION_SPEED_RANGE * (((arc4random()%100) - 50)/100.f);
//    CCLOG(@"%f", _rotationSpeed);
}

-(void)update:(CCTime)delta {
    
}

@end
