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
    self.physicsBody.collisionType = @"playerClip";
}

@end
