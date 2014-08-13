//
//  Level.m
//  PlatformerPrototype
//
//  Created by Morgan Chen on 7/14/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Level.h"

@implementation Level {
    BOOL _isShowingContributors;
    CCSprite *_benji;
    NSArray *_contributors;
}

-(void)didLoadFromCCB {
    if([self.nextLevel isEqualToString:@"Levels/Level1"]){
        _contributors = @[_benji];
    }
}

-(void)showContributors {
    if(_isShowingContributors){
        return;
    }
    for(CCSprite *contributor in _contributors){
        contributor.position = ccp(contributor.position.x, contributor.position.y - 150);
    }
    _isShowingContributors = TRUE;
}

@end
