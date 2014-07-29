//
//  PhysRotateSquare.m
//  PlatformerPrototype
//
//  Created by Morgan Chen on 7/23/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "PhysRotateSquare.h"

@implementation PhysRotateSquare {
    CCNode *_square;
    CCNode *_pivotNode;
}

-(void)didLoadFromCCB {
    _square.physicsBody.collisionGroup = @"worldBrushes";
    _square.physicsBody.collisionType = @"world";
    _pivotNode.physicsBody.collisionMask = @[];
}

@end
