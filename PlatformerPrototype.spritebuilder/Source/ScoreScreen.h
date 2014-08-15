//
//  ScoreScreen.h
//  PlatformerPrototype
//
//  Created by Morgan Chen on 7/14/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCNode.h"
#import "Gameplay.h"

@interface ScoreScreen : CCNode

@property (nonatomic) NSString *nextLevelName;
@property (nonatomic) CCLabelTTF *timeLabel;
@property (nonatomic) CCLabelTTF *bestLabel;

-(void)loadNextLevel;

@end
