//
//  Projectile.m
//  PlatformerPrototype
//
//  Created by Morgan Chen on 7/3/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Projectile.h"

@implementation Projectile

-(void)didLoadFromCCB {
    self.physicsBody.collisionGroup = @"playerCollisionGroup";
    self.physicsBody.collisionType = @"projectile";
}

@end
