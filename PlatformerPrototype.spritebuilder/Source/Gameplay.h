//
//  Gameplay.h
//  PlatformerPrototype
//
//  Created by Morgan Chen on 7/3/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCNode.h"

@interface Gameplay : CCNode <CCPhysicsCollisionDelegate>

@property(nonatomic, strong) NSString *currentLevel;

-(void)loadNextLevel:levelName;
+(NSMutableDictionary *)generateEmptyLevelProgress;
+(CGPoint)vectorNormalize:(CGPoint)vect;
+(NSString *)convertTimeToString:(float)time;

@end
