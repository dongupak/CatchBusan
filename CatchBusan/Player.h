//
//  Player.h
//  GNCatch
//
//  Created by DongGyu Park on 11. 9. 8..
//  Copyright 2011 DongGyu Park. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Logo.h"

@interface Player : CCSprite {
    NSInteger   playerHP;         // 게임 플레이어의 HP
    CGPoint     playerVelocity;     // 게임 플레이어의 속도
    BOOL        isAlive;
    
    // 플레이어와 로고가 충돌했을때 로고를 저장
    NSMutableArray *collisonLogoArray;  
}

@property (readwrite) CGPoint   playerVelocity;
@property (readwrite) NSInteger playerHP;
@property (readwrite) BOOL      isAlive;
@property (nonatomic, retain) NSMutableArray *collisonLogoArray;

- (BOOL) collideWith: (Logo *)sprite ;
- (BOOL) hasCollionWith: (CCNode *)logoGroup;
- (void) playerAnimation;
@end
