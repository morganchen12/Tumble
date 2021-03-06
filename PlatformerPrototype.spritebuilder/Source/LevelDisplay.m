//
//  LevelDisplay.m
//  PlatformerPrototype
//
//  Created by Morgan Chen on 7/23/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "LevelDisplay.h"
#import "Gameplay.h"

@implementation LevelDisplay {
    CCLabelTTF *_numberLabel;
    CCLabelTTF *_timeLabel;
}

-(void)didLoadFromCCB {
    self.userInteractionEnabled = TRUE;
}

-(void)setLevelNumber:(int)levelNumber {
    _numberLabel.string = [NSString stringWithFormat:@"Level %i", levelNumber];
    _levelNumber = levelNumber;
}

-(void)setTime:(float)time {
    _timeLabel.string = [Gameplay convertTimeToString:time];
    _time = time;
}

-(NSString *)convertLevelNumberToString {
    return [NSString stringWithFormat:@"Levels/Level%i", _levelNumber];
}

-(void)recordAnalytics {
    NSDictionary *params = @{@"levelName": [self convertLevelNumberToString]};
    [MGWU logEvent:@"levelSelected" withParams:params];
}

-(void)playLevel{
    [self recordAnalytics];
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
    Gameplay *gameplay = gameplayScene.children[0];
    gameplay.currentLevel = [self convertLevelNumberToString];
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
}

@end
