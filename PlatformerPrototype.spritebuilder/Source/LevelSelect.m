//
//  LevelSelect.m
//  PlatformerPrototype
//
//  Created by Morgan Chen on 7/23/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "LevelSelect.h"
#import "LevelDisplay.h"

@implementation LevelSelect {
    CCNode *_layoutNode;
    NSUserDefaults *_userDefaults;
    NSDictionary *_levelProgress;
    int _levelsUnlocked;
}

-(void)didLoadFromCCB{
    _userDefaults = [NSUserDefaults standardUserDefaults];
    _levelProgress = [_userDefaults objectForKey:@"levelProgress"];
    self.userInteractionEnabled = YES;
    _levelsUnlocked = 1; //loop sets _levelsUnlocked to number of levels beaten + 1
    for(id key in _levelProgress){
        if([(NSNumber *)[_levelProgress objectForKey:key] floatValue] > 0.f){
            _levelsUnlocked++;
        }
    }
    if(_levelsUnlocked > [_levelProgress count] && [_levelProgress count] > 0){
        _levelsUnlocked = (int)[_levelProgress count];
    }
    [self populateScreen];
}

-(void)populateScreen {
    for(int i = 0; i < _levelsUnlocked; i++){
        int row = (int)(i/5);
        int col = i%5;
        LevelDisplay *levelDisplay = (LevelDisplay *)[CCBReader load:@"LevelDisplay"];
        levelDisplay.position = ccp(85*col, 55 * (4-row));
        NSString *key = [NSString stringWithFormat:@"Levels/Level%i", i+1];
        float levelTime = [(NSNumber *)[_levelProgress objectForKey:key] floatValue];
        levelDisplay.levelNumber = i+1;
        levelDisplay.time = levelTime;
        [_layoutNode addChild:levelDisplay];
    }
}

@end
