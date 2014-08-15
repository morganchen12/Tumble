//
//  ScoreScreen.m
//  PlatformerPrototype
//
//  Created by Morgan Chen on 7/14/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "ScoreScreen.h"

@implementation ScoreScreen

-(void)loadNextLevel {
    [(Gameplay *)self.parent loadNextLevel:self.nextLevelName];
}

@end
