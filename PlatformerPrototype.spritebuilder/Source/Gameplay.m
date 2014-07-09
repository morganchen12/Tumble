//
//  Gameplay.m
//  PlatformerPrototype
//
//  Created by Morgan Chen on 7/3/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Gameplay.h"
#import "Player.h"
#import "Projectile.h"
#import <stdlib.h>
//#import <math.h>
#import "CCPhysics+ObjectiveChipmunk.h"

static const float EXPLOSION_RADIUS = 100;                                  //explosion radius in points
//static const float PROJECTILE_LIFESPAN = 20;                                //projectile lifespan in frames (60 frames/sec)
static const float EXPLOSION_FORCE_MULTIPLIER = 150000;                     //for easy fine tuning
static const float MIN_DISTANCE = 18;
static const float PROJECTILE_LAUNCH_FORCE = 60;

@implementation Gameplay {
    CCPhysicsNode *_physicsNode;
    CCNode *_level;
    Player *_player;
    CCNode *_contentNode;
    CCLabelTTF *_timerLabel;
    double _timeElapsed;
}

-(void)didLoadFromCCB {
    _timeElapsed = 0;
    self.userInteractionEnabled = TRUE;
    _level = [CCBReader load:@"Levels/Level1" owner:self];           //load in level with owner:self to access player
    _physicsNode.contentSize = _level.contentSize;
    _physicsNode.collisionDelegate = self;
    [_physicsNode addChild:_level];
    CCActionFollow *follow = [CCActionFollow actionWithTarget:_player worldBoundary:_level.boundingBox];
    [_contentNode runAction:follow];
//    CCLOG(@"x, y = %f, %f", _level.position.x, _level.position.y);        //debug
}

-(void)shoot:(float)angle {
    Projectile *projectile = (Projectile *)[CCBReader load:@"Projectile"];  //create Projectile and add to physicsNode at
    projectile.position = _player.position;                                 //current player position
//    projectile.lifeSpan = PROJECTILE_LIFESPAN;
    [_physicsNode addChild:projectile];
    [projectile.physicsBody applyImpulse:ccp(PROJECTILE_LAUNCH_FORCE * cos(angle),
                                             PROJECTILE_LAUNCH_FORCE * sin(angle))];
    [projectile.physicsBody applyTorque:(arc4random() % 360)];              //apply random spin (cosmetic function only)
    //CCLOG(@"\nx, y = %f, %f", _player.position.x, _player.position.y);
}

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLocation = [touch locationInNode:_physicsNode];
    if(touchLocation.x - _player.position.x == 0){
        if(touchLocation.y > touchLocation.x){ //calculate angle to shoot while avoiding divide by 0 errors
            [self shoot:M_PI / 2];
        }
        else {
            [self shoot:M_PI / -2];
        }
        return;
    }
    float angle = atan((touchLocation.y - _player.position.y) / (touchLocation.x - _player.position.x));
    if(touchLocation.x - _player.position.x < 0) {
        angle += M_PI;
    }
//    CCLOG(@"\n%f", angle);
    [self shoot:angle];
}

-(void)detonateProjectile:(Projectile *)projectile atPosition:(CGPoint)explosionPosition inCCNode:(CCNode *)node {
    float distanceToPlayer = powf(powf(explosionPosition.x - _player.position.x, 2) +
                             powf(explosionPosition.y - _player.position.y, 2), 0.5);
    if(distanceToPlayer < EXPLOSION_RADIUS && distanceToPlayer != 0){
        if(distanceToPlayer < MIN_DISTANCE){ //avoid abnormally large forces; simulate as if explosion is at least this far
            distanceToPlayer = MIN_DISTANCE; //away from player
        }
        float explosionForceConstant = EXPLOSION_FORCE_MULTIPLIER;
        float explosionMagnitude = explosionForceConstant / powf(distanceToPlayer, 2);
        
        float angle; //the following block of code calculates angle of impulse w/conditionals to avoid divide by 0 errors
        if(_player.position.x == explosionPosition.x){
            angle = M_PI / 2 * ((_player.position.y - explosionPosition.y) /
                                         fabs(_player.position.y - explosionPosition.y));
        }
        else {
            angle = atan((_player.position.y - explosionPosition.y)/(_player.position.x - explosionPosition.x));
            if(_player.position.x - explosionPosition.x < 0){
                angle += M_PI;
            }
        }
        
        CGPoint explosionVector = ccp(explosionMagnitude * (cos(angle)),  //create vector with magnitude explosionMagnitude
                                      explosionMagnitude * (sin(angle))); //and angle angle
        [_player.physicsBody applyImpulse:explosionVector];               //push player
//        CCLOG(@"\nx, y = %f, %f", explosionVector.x, explosionVector.y);
    }
    [projectile.stickyJoint invalidate];
    projectile.stickyJoint = nil;
    [projectile removeFromParent];
    
//    for(CCNode *pushable in node.children) {                              //detonate nearby projectiles
//        float distance = powf(powf(explosionPosition.x - pushable.position.x, 2) +
//                              powf(explosionPosition.y - pushable.position.y, 2), 0.5);
//        if(distance < EXPLOSION_RADIUS && ([pushable isMemberOfClass:Projectile.class] && pushable != projectile)){
//            [self detonateProjectile:(Projectile *)pushable atPosition:pushable.position inCCNode:pushable.parent];
//            break;
//        }
//    }
}

-(void)update:(CCTime)delta {
//    for(int i = 0; i < [_physicsNode.children count]; i++){
//        if([_physicsNode.children[i] isMemberOfClass:[Projectile class]]){
//            Projectile *projectile = (Projectile *)_physicsNode.children[i];
//            if(projectile.lifeSpan <= 0){
//                [self detonateProjectile:projectile atPosition:projectile.position inCCNode:_physicsNode];
//                continue;
//            }
//            projectile.lifeSpan--;
//        }
//    }
    if(_player.position.x < 0 ||                                                    //check if player exits worldbounds
       _player.position.y < 0 ||
       _player.position.x > _level.contentSize.width){
        [self restartLevel];
    }
    _timeElapsed += delta;
    _timerLabel.string = [self convertTimeToString];
}

-(void)restartLevel {
    [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:@"Gameplay"]]; //reload level upon death
}

-(NSString *)convertTimeToString {
    int hours = (int)(_timeElapsed/360);
    int minutes = (int)((_timeElapsed - hours * 360)/60);
    int seconds = (int)(_timeElapsed - (minutes*60 + hours*360));
    int centiseconds = (int)100*(_timeElapsed - seconds);
    return [NSString stringWithFormat:@"%.2i:%.2i:%.2i.%.2i", hours, minutes, seconds, centiseconds];
}

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair projectile:(CCNode *)projectile world:(CCNode *)world {
    Projectile *myProjectile = (Projectile *)projectile;
//    [myProjectile.stickyJoint invalidate];
//    myProjectile.stickyJoint = nil;
//    myProjectile.stickyJoint = [CCPhysicsJoint connectedPivotJointWithBodyA:myProjectile.physicsBody
//                                                                       bodyB:world.physicsBody
//                                                                     anchorA:myProjectile.anchorPointInPoints];
//    [myProjectile.stickyJoint tryAddToPhysicsNode:_physicsNode];
//    return TRUE;
    [self detonateProjectile:myProjectile atPosition:myProjectile.position inCCNode:_physicsNode];
}

-(BOOL)ccPhysicsCollisionPreSolve:(CCPhysicsCollisionPair *)pair player:(CCNode *)player endTrigger:(CCNode *)endTrigger {
    CCLOG(@"\nlevel end reached!!!!!!");
    return TRUE;
}

@end
