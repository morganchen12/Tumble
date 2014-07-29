//
//  Square.m
//  PlatformerPrototype
//
//  Created by Morgan Chen on 7/8/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Square.h"

@implementation Square

-(void)didLoadFromCCB {
    self.physicsBody.collisionGroup = @"worldBrushes";
    self.physicsBody.collisionType = @"world";
}

@end
