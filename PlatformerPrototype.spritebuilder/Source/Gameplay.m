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
#import "CCPhysics+ObjectiveChipmunk.h"
#import <CoreMotion/CoreMotion.h>
#import "Level.h"
#import "ScoreScreen.h"

static const float PLAYER_ACCEL_MULTIPLIER = 25;                            //scalar to multiply tilt force with
static const float EXPLOSION_RADIUS = 100;                                  //explosion radius in points
static const float EXPLOSION_FORCE_MULTIPLIER = 150000;                     //for easy fine tuning
static const float MIN_DISTANCE = 20;
static const float PROJECTILE_LAUNCH_FORCE = 75;
static const float PROJECTILE_COOLDOWN = 15;                                //in 60ths of a second
static const float PLAYER_XVEL_CAP = 100;                                   //cap on player xvelocity after which player
                                                                            //cannot accelerate further via tilt

@implementation Gameplay {
    BOOL _shooting;
    int _coolDown;                                                          //interval between shots
    float _angleToShootAt;
    float _timeElapsed;
    CMMotionManager *_motionManager;
    CCPhysicsNode *_physicsNode;
    CCNode *_level;
    Player *_player;
    CCNode *_contentNode;
    CCAction *_followPlayer;
//    NSString *_currentLevel;                                              //relative filepath to current level
//    CCLabelTTF *_timerLabel;                                              //broken 7/11/14
}

-(void)onEnter {
    [super onEnter];
    [_motionManager startAccelerometerUpdates];
    _level = [CCBReader load:_currentLevel owner:self];           //load in level with owner:self to access player
    _physicsNode.contentSize = _level.contentSize;
    _physicsNode.collisionDelegate = self;
    [_physicsNode addChild:_level];
    _followPlayer = [CCActionFollow actionWithTarget:_player worldBoundary:_level.boundingBox];
    [_contentNode runAction:_followPlayer];
}

-(void)onExit {
    [super onExit];
    [_motionManager stopAccelerometerUpdates];
}

-(void)didLoadFromCCB {
    [[CCDirector sharedDirector] setDisplayStats:YES];
    if(_currentLevel == nil) {
        _currentLevel = @"Levels/Level1";
    }
    _shooting = FALSE;
    _timeElapsed = 0;
    _motionManager = [[CMMotionManager alloc] init];
    self.userInteractionEnabled = TRUE;
}

-(void)shoot {
    if(_coolDown <= 0){
        Projectile *projectile = (Projectile *)[CCBReader load:@"Projectile"];  //create Projectile and add to physicsNode at
        projectile.position = _player.position;                                 //current player position
        //    projectile.lifeSpan = PROJECTILE_LIFESPAN;
        [_physicsNode addChild:projectile];
        [projectile.physicsBody applyImpulse:ccp(PROJECTILE_LAUNCH_FORCE * cos(_angleToShootAt),
                                                 PROJECTILE_LAUNCH_FORCE * sin(_angleToShootAt))];
        [projectile.physicsBody applyTorque:(arc4random() % 360)];              //apply random spin (cosmetic only)
        _coolDown = PROJECTILE_COOLDOWN;
    }
}

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    _shooting = TRUE;
    CGPoint touchLocation = [touch locationInNode:_physicsNode];
    if(touchLocation.x - _player.position.x == 0){
        if(touchLocation.y > touchLocation.x){ //calculate angle to shoot while avoiding divide by 0 errors
            _angleToShootAt = M_PI / 2;
        }
        else {
            _angleToShootAt = M_PI / -2;
        }
        return;
    }
    _angleToShootAt = atan((touchLocation.y - _player.position.y) / (touchLocation.x - _player.position.x));
    if(touchLocation.x - _player.position.x < 0) {
        _angleToShootAt += M_PI;
    }
}

-(void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLocation = [touch locationInNode:_physicsNode];
    if(touchLocation.x - _player.position.x == 0){
        if(touchLocation.y > touchLocation.x){ //calculate angle to shoot while avoiding divide by 0 errors
            _angleToShootAt = M_PI / 2;
        }
        else {
            _angleToShootAt = M_PI / -2;
        }
        return;
    }
    _angleToShootAt = atan((touchLocation.y - _player.position.y) / (touchLocation.x - _player.position.x));
    if(touchLocation.x - _player.position.x < 0) {
        _angleToShootAt += M_PI;
    }
}

-(void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    _shooting = FALSE;
}

-(void)touchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
    _shooting = FALSE;
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
    }
//    CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"Explosion"];
//    explosion.autoRemoveOnFinish = NO;
//    explosion.autoRemoveOnFinish = YES;
//    explosion.position = projectile.position;
//    [projectile.parent addChild:explosion];
    [projectile removeFromParent];
}

-(void)update:(CCTime)delta {
    CMAcceleration acceleration = _motionManager.accelerometerData.acceleration;    //move player on device tilt
    float accel = acceleration.y;
    if(fabs(_player.physicsBody.velocity.x) > PLAYER_XVEL_CAP){
        if(_player.physicsBody.velocity.x > 0 && accel > 0){
            accel = 0;
        }
        else if(_player.physicsBody.velocity.x < 0 && accel < 0){
            accel = 0;
        }
    }
    [_player.physicsBody applyImpulse:ccp(accel * PLAYER_ACCEL_MULTIPLIER, 0)];
    
    _timeElapsed += delta;
//    _timerLabel.string = [self convertTimeToString];
    
    if(_coolDown > 0) {
        _coolDown--;
    }
    else if(_shooting){
        [self shoot];
    }
    
    if(_player.position.x < 0 ||                                                    //check if player exits worldbounds
       _player.position.y < 0 ||
       _player.position.x > _level.contentSize.width){
        [self restartLevel];
    }
}

-(void)restartLevel {
    [_contentNode stopAction:_followPlayer];
    CCScene *levelScene = [CCBReader loadAsScene:@"Gameplay"];
    Gameplay *gameplay = levelScene.children[0];
    gameplay.currentLevel = self.currentLevel;
    [[CCDirector sharedDirector] replaceScene:levelScene]; //reload level upon death, keep timer time
}

-(NSString *)convertTimeToString {
    int hours = (int)(_timeElapsed/3600);
    int minutes = (int)((_timeElapsed - hours*3600)/60);
    int seconds = (int)(_timeElapsed - (minutes*60 + hours*3600));
    int centiseconds = (int)100*(_timeElapsed - (seconds + minutes*60 + hours*3600));
    return [NSString stringWithFormat:@"%.2i:%.2i:%.2i.%.2i", hours, minutes, seconds, centiseconds];
}

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair projectile:(CCNode *)projectile world:(CCNode *)world {
    Projectile *myProjectile = (Projectile *)projectile;
    [self detonateProjectile:myProjectile atPosition:myProjectile.position inCCNode:_physicsNode];
}

-(void)loadNextLevel:(NSString *)levelName {
    [_contentNode stopAction:_followPlayer];
    _currentLevel = levelName;
    CCScene *nextLevelScene = [CCBReader loadAsScene:@"Gameplay"];
    Gameplay *nextGameplay = nextLevelScene.children[0];
    nextGameplay.currentLevel = levelName;
    [[CCDirector sharedDirector] replaceScene:nextLevelScene];
}

-(BOOL)ccPhysicsCollisionPreSolve:(CCPhysicsCollisionPair *)pair player:(CCNode *)player endTrigger:(CCNode *)endTrigger {
    self.paused = YES;
    Level *currentLevel = (Level *)_level;
    NSString *nextLevel = currentLevel.nextLevel;
    ScoreScreen *scoreScreen = (ScoreScreen *)[CCBReader load:@"ScoreScreen"];
    scoreScreen.nextLevelName = nextLevel;
    scoreScreen.timeLabel.string = [self convertTimeToString];
    scoreScreen.positionType = CCPositionTypeNormalized;
    scoreScreen.position = ccp(0.5, 0.5);
    scoreScreen.ownerNode = self;
    [self addChild:scoreScreen];
    return TRUE;
}

@end
