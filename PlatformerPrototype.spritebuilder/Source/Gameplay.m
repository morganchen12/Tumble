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

//static const float PLAYER_COLLISION_TOLERANCE = 5000;
static const int NUMBER_OF_LEVELS = 25;
static const float PLAYER_ACCEL_MULTIPLIER = 75;                            //scalar to multiply tilt force with
static const float EXPLOSION_RADIUS = 100;                                  //explosion radius in points
static const float EXPLOSION_FORCE_MULTIPLIER = 150000;                     //for easy fine tuning
static const float EXPLOSION_FORCE_PHYSBOX_MULTIPLIER = 2000;
static const float MIN_DISTANCE = 20;
static const float PROJECTILE_LAUNCH_FORCE = .075;
static const int PROJECTILE_COOLDOWN = 15;                                  //in 60ths of a second
static const float PLAYER_XVEL_CAP = 150;                                   //cap on player xvelocity after which player
                                                                            //cannot accelerate further via tilt

@implementation Gameplay {
    BOOL _shooting;
    int _coolDown;                                                          //interval between shots
    float _angleToShootAt;
    float _timeElapsed;
    NSMutableDictionary *_levelProgress;
    CMMotionManager *_motionManager;
    CCPhysicsNode *_physicsNode;
    CCNode *_level;
    Player *_player;
    CCNode *_contentNode;
    CCAction *_followPlayer;
    CCNode *_pauseScreen;
    CGPoint _pushDirection;
//    NSString *_currentLevel;                                              //relative filepath to current level
}

-(void)onEnter {
    [super onEnter];
    _level = [CCBReader load:_currentLevel owner:self];           //load in level with owner:self to access player
    _followPlayer = [CCActionFollow actionWithTarget:_player worldBoundary:_level.boundingBox];
    [_contentNode runAction:_followPlayer];
    _physicsNode.contentSize = _level.contentSize;
    _physicsNode.collisionDelegate = self;
    [_physicsNode addChild:_level];
    [_motionManager startAccelerometerUpdates];
    self.multipleTouchEnabled = TRUE;
    self.userInteractionEnabled = TRUE;
}

-(void)pause {
    if(self.paused == FALSE){
        self.paused = TRUE;
        _pauseScreen = [CCBReader load:@"PauseScreen" owner:self];
        _pauseScreen.positionType = CCPositionTypeNormalized;
        _pauseScreen.position = ccp(0.5, 0.5);
        [self addChild:_pauseScreen];
    }
}

-(void)levelSelect {
    CCScene *levelSelectScene = [CCBReader loadAsScene:@"LevelSelect"];
    [[CCDirector sharedDirector] replaceScene:levelSelectScene];
}

-(void)unpause {
    [self removeChild:_pauseScreen];
    _pauseScreen = nil;
    self.paused = FALSE;
}

-(void)onExit {
    [super onExit];
    [_motionManager stopAccelerometerUpdates];
}

-(void)findCurrentLevel {
#ifdef DEBUG
    _currentLevel = @"Levels/Level1";
//    _currentLevel = @"Levels/Credits";
    return;
#endif
    int levelNumber = 1;
    for(id key in _levelProgress){
        if([(NSNumber *)[_levelProgress objectForKey:key] floatValue] > 0.f){
            levelNumber++;
        }
    }
    if(levelNumber > NUMBER_OF_LEVELS){
        levelNumber = NUMBER_OF_LEVELS;
    }
    _currentLevel = [NSString stringWithFormat:@"Levels/Level%i", levelNumber];
}

-(void)didLoadFromCCB {
    NSDictionary *levelProgressUnmutable = (NSDictionary *)[MGWU objectForKey:@"levelProgress"];
    _levelProgress = [levelProgressUnmutable mutableCopy];
    if(_levelProgress == nil){
        _levelProgress = [Gameplay generateEmptyLevelProgress];
    }
#ifdef DEBUG
    [[CCDirector sharedDirector] setDisplayStats:YES];  //debug fps counter
#endif
    [self findCurrentLevel];
    _shooting = FALSE;
    _timeElapsed = 0;
    _motionManager = [[CMMotionManager alloc] init];
}

+(NSMutableDictionary *)generateEmptyLevelProgress {
    float empty = 0.f;
#ifdef DEBUG
    empty = 3600.f;
#endif
    NSMutableDictionary *temp = [@{} mutableCopy];
    for(int i = 0; i < NUMBER_OF_LEVELS; i++){
        NSString *keyName = [NSString stringWithFormat:@"Levels/Level%i", i+1];
        [temp setObject:@(empty) forKey:keyName];
    }
    return temp;
}

-(void)shoot {
    if(_coolDown <= 0){
        Projectile *projectile = (Projectile *)[CCBReader load:@"Projectile"];  //create Projectile and add to physicsNode at
        projectile.position = _player.position;                                 //current player position
        projectile.zOrder = 2;
        [_physicsNode addChild:projectile];
        [projectile.physicsBody applyImpulse:ccp(PROJECTILE_LAUNCH_FORCE * cos(_angleToShootAt),
                                                 PROJECTILE_LAUNCH_FORCE * sin(_angleToShootAt))];
        [projectile.physicsBody applyAngularImpulse:((arc4random() % 360) - 180)]; //apply random spin (cosmetic only)
        _coolDown = PROJECTILE_COOLDOWN;
    }
}

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    _shooting = TRUE;
    CGPoint touchLocation = [touch locationInNode:_physicsNode];
    if(touchLocation.x - _player.position.x == 0){
        if(touchLocation.y > _player.position.y){ //calculate angle to shoot while avoiding divide by 0 errors
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
        if(touchLocation.y > _player.position.y){ //calculate angle to shoot while avoiding divide by 0 errors
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
    CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"Explosion"];
    explosion.autoRemoveOnFinish = YES;
    explosion.position = projectile.position;
    [_contentNode addChild:explosion];
    [projectile removeFromParent];
}

-(void)playerDeath {
    CCParticleSystem *playerDeath = (CCParticleSystem *)[CCBReader load:@"PlayerDeath"];
    playerDeath.autoRemoveOnFinish = TRUE;
    playerDeath.position = _player.position;
    [_player.parent addChild:playerDeath];
    self.userInteractionEnabled = FALSE;
    [_player removeFromParent];
    [self restartLevel];
}

-(void)update:(CCTime)delta {
    _timeElapsed += delta;                                                          //increment timer
}

-(void)fixedUpdate:(CCTime)delta {
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
    
    if(_player.position.x < 0 ||                                                    //check if player exits worldbounds
       _player.position.y < 0 ||
       _player.position.x > _level.contentSize.width){
        [self recordDeath];
        [self restartLevel];
    }
    
    if(_coolDown > 0) {
        _coolDown--;
    }
    else if(_shooting){
        [self shoot];
    }
}

-(void)restartLevel {
    [_contentNode stopAction:_followPlayer];
    CCScene *levelScene = [CCBReader loadAsScene:@"Gameplay"];
    Gameplay *gameplay = levelScene.children[0];
    gameplay.currentLevel = self.currentLevel;
    [[CCDirector sharedDirector] replaceScene:levelScene];
}

-(NSString *)convertTimeToString:(float)time {
    int hours = (int)(time/3600);
    int minutes = (int)((time - hours*3600)/60);
    int seconds = (int)(time - (minutes*60 + hours*3600));
    int centiseconds = (int)100*(time - (seconds + minutes*60 + hours*3600));
    NSString *output = [NSString stringWithFormat:@"%.2i:%.2i:%.2i.%.2i", hours, minutes, seconds, centiseconds];
    if(hours == 0){
        if(minutes == 0){
            return [output substringFromIndex:6];
        }
        return [output substringFromIndex:3];
    }
    return output;
}

+(CGPoint)vectorNormalize:(CGPoint)vect {
    float vectMagnitude = powf(powf(vect.x, 2) + powf(vect.y, 2), 0.5);
    return ccp(vect.x / vectMagnitude, vect.y / vectMagnitude);
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair projectile:(CCNode *)projectile world:(CCNode *)world {
    _pushDirection = [Gameplay vectorNormalize:projectile.physicsBody.velocity];
    return TRUE;
}

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair projectile:(CCNode *)projectile world:(CCNode *)world {
    Projectile *myProjectile = (Projectile *)projectile;
    if(projectile == nil){
        return;
    }
    [self detonateProjectile:myProjectile atPosition:myProjectile.position inCCNode:_physicsNode];
    
    if(world.physicsBody.type == CCPhysicsBodyTypeDynamic){
        CGPoint physBoxLaunchVect = ccp(EXPLOSION_FORCE_PHYSBOX_MULTIPLIER*_pushDirection.x,
                                        EXPLOSION_FORCE_PHYSBOX_MULTIPLIER*_pushDirection.y);
        [world.physicsBody applyImpulse:physBoxLaunchVect atLocalPoint:projectile.position];
    }
}

-(void)loadNextLevel:(NSString *)levelName {
    [_contentNode stopAction:_followPlayer];
    _currentLevel = levelName;
    CCScene *nextLevelScene = [CCBReader loadAsScene:@"Gameplay"];
    Gameplay *nextGameplay = nextLevelScene.children[0];
    nextGameplay.currentLevel = levelName;
    [[CCDirector sharedDirector] replaceScene:nextLevelScene];
}

-(void)saveProgress {
    if([_currentLevel isEqualToString:@"Levels/Credits"]){
        return;
    }
    float record = [(NSNumber *)[_levelProgress objectForKey:_currentLevel] floatValue];
    if(record == 0 || record > _timeElapsed){
        [_levelProgress setObject:@(_timeElapsed) forKey:_currentLevel];
        [MGWU setObject:_levelProgress forKey:@"levelProgress"];
    }
}

-(void)recordAnalytics {
    NSDictionary *params = @{@"levelName": _currentLevel,
                             @"timeElapsed": @(_timeElapsed)
                             };
    [MGWU logEvent:@"levelComplete" withParams:params];
}

-(void)recordDeath {
    NSDictionary *params = @{@"levelName": _currentLevel,
                             @"timeElapsed": @(_timeElapsed),
                             @"positionX": @(_player.position.x),
                             @"positionY": @(_player.position.y)
                             };
    [MGWU logEvent:@"playerDied" withParams:params];
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair player:(CCNode *)player endTrigger:(CCNode *)endTrigger {
    self.paused = YES;
    float best = [(NSNumber *)[_levelProgress objectForKey:_currentLevel] floatValue];
    if(best > _timeElapsed || best == 0){
        best = _timeElapsed;
    }
    Level *currentLevel = (Level *)_level;
    NSString *nextLevel = currentLevel.nextLevel;
    ScoreScreen *scoreScreen = (ScoreScreen *)[CCBReader load:@"ScoreScreen" owner:self];
    scoreScreen.nextLevelName = nextLevel;
    scoreScreen.timeLabel.string = [self convertTimeToString:_timeElapsed];
    scoreScreen.bestLabel.string = [self convertTimeToString:best];
    scoreScreen.positionType = CCPositionTypeNormalized;
    scoreScreen.position = ccp(0.5, 0.5);
    scoreScreen.ownerNode = self;
    [self addChild:scoreScreen];
    [self saveProgress];
    [self recordAnalytics];
    
    return TRUE;
}

@end
