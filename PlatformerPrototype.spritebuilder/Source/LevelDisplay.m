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
    _numberLabel.string = [NSString stringWithFormat:@"%i", levelNumber];
    _levelNumber = levelNumber;
}

-(void)setTime:(float)time {
    _timeLabel.string = [self convertTimeToString:time];
    _time = time;
}

-(NSString *)convertTimeToString:(float)time {
    int hours = (int)(time/3600);
    int minutes = (int)((time - hours*3600)/60);
    int seconds = (int)(time - (minutes*60 + hours*3600));
    int centiseconds = (int)100*(time - (seconds + minutes*60 + hours*3600));
    return [NSString stringWithFormat:@"%.2i:%.2i:%.2i.%.2i", hours, minutes, seconds, centiseconds];
}

-(void)playLevel{
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
    Gameplay *gameplay = gameplayScene.children[0];
    gameplay.currentLevel = [NSString stringWithFormat:@"Levels/Level%i", _levelNumber];
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
}

@end
