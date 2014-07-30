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
    NSDictionary *levelProgress = [MGWU objectForKey:@"levelProgress"];
    if(levelProgress == nil){
        levelProgress = [Gameplay generateEmptyLevelProgress];
    }
    [MGWU setObject:levelProgress forKey:@"levelProgress"];
}

-(void)play {
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
//    CCColor *white = [CCColor colorWithWhite:1 alpha:1];
//    CCTransition *transition = [CCTransition transitionFadeWithColor:white duration:0.5f];
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
}

-(void)levelSelect {
    CCScene *levelSelectScene = [CCBReader loadAsScene:@"LevelSelect"];
    [[CCDirector sharedDirector] replaceScene:levelSelectScene];
}

-(void)crossPromo {
    [MGWU displayCrossPromo];
}

@end
