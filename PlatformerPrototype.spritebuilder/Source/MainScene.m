//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"
#import "Player.h"
#import <CoreMotion/CoreMotion.h>

@implementation MainScene {
    Player *_player;
    CCPhysicsNode *_physicsNode;
    CMMotionManager *_motionManager;
}

-(void)didLoadFromCCB {
    NSDictionary *levelProgress = [MGWU objectForKey:@"levelProgress"];
    if(levelProgress == nil){
        levelProgress = [Gameplay generateEmptyLevelProgress];
    }
    [MGWU setObject:levelProgress forKey:@"levelProgress"];
    [_motionManager startAccelerometerUpdates];
}

-(void)fixedUpdate:(CCTime)delta {
    CMAcceleration acceleration = _motionManager.accelerometerData.acceleration;    //move player on device tilt
    float accel = acceleration.y;
    if(fabs(_player.physicsBody.velocity.x) > 150){
        if(_player.physicsBody.velocity.x > 0 && accel > 0){
            accel = 0;
        }
        else if(_player.physicsBody.velocity.x < 0 && accel < 0){
            accel = 0;
        }
    }
    [_player.physicsBody applyImpulse:ccp(accel * 75, 0)];
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
