//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"
#import "Gameplay.h"

@implementation MainScene

-(void)didLoadFromCCB {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *levelProgress = [userDefaults objectForKey:@"levelProgress"];
    if(levelProgress == nil){
        levelProgress = [Gameplay generateEmptyLevelProgress];
    }
    [userDefaults setObject:levelProgress forKey:@"levelProgress"];
    [userDefaults synchronize];
}

-(void)play {
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
//    CCColor *white = [CCColor colorWithWhite:1 alpha:1];
//    CCTransition *transition = [CCTransition transitionFadeWithColor:white duration:0.5f];
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
}

@end
