//
//  GameScene.h
//  CatchBusan
//
//  Created by dongupak@gmail.com on 11. 5. 13..
//  Copyright 2011 창원대학교 모바일엑스. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h> 

#import "SimpleAudioEngine.h"
#import "cocos2d.h"
#import "MessageNode.h"
#import "SceneManager.h"

#import "Player.h"      // 플레이어 

#import "Logo.h"
#import "BusanLogo.h"      // 조커 역할을 하는 경남로고, 에너지와 점수 증가
#import "BusanSubLogo.h"   // 점수를 얻을 수 있는 경남지역내 지자체 로고
#import "Bomb.h"        // life를 잃는 폭탄
#import "FakeLogo.h"    // 가짜 경남지자체 로고(먹으면 감점)

typedef enum {
    BusanLogoType = 2900,
    BusanSubLogoType,
    FakeLogoType,
    BombType,
} LOGOTYPE;

@interface GameLayer : CCLayer 
{
	Player  *player;   
	CGPoint playerVelocity;
    NSInteger   comboCount;
    
    CCLabelBMFont *scoreLabel;
    CCLabelBMFont *lifeLabel;
    
    CCNode  *logoGroupNode;     // 게임속 지자체 로고
    
    CCAnimate *smokeAnimate;
    CCAnimate *bombDownAnimate;
    CCAnimate *logoExplosionAnimate;
    CCAnimate *fakeLogoExplosionAnimate;
    
    CCSprite *bombSmoke;
    CCSprite *bombSprite;
    CCSprite *logoExplosion;
    CCSprite *fakeLogoExplosion;
    
    CCProgressTimer *ptEnergy;
    
    NSMutableArray *subLogoImageArray;
    NSMutableArray *fakeLogoImageArray;
		
	NSInteger gameScore, numOfLife;     // 게임 점수와 life 개수 
	MessageNode *message;
	
	SimpleAudioEngine *sae;
    
    // game control properties
	float logoGenInterval;      // 로고 생성 시간간격
}

@property (nonatomic, retain) Player *player;

@property (nonatomic, retain) CCNode *logoGroupNode;

@property (nonatomic, retain) CCLabelBMFont *scoreLabel;
@property (nonatomic, retain) CCLabelBMFont *lifeLabel;

@property (nonatomic, retain) MessageNode *message;

// plist로부터 로고를 읽어들임
@property (nonatomic, retain) NSMutableArray *subLogoImageArray;  
// plist로부터 가짜로고를 읽어들임
@property (nonatomic, retain) NSMutableArray *fakeLogoImageArray;  

- (void) initImageArray;
- (void) displayScoreAndLife;

- (LOGOTYPE) chooseRandomLogoType;
- (void) animateLogoAndCountScore;

- (void) updateScore;
- (void) updateLifeLabel;

- (void) setBackground;
- (void) decreaseLife;
- (void) createBombSmoke;
- (void) createBombDownAnimation;
- (void) createLogoExplosion;
- (void) createEnergyBar;
- (void) gameOver;
- (void) createCloud;
- (void)createCloudWithSize:(int)imgSize top:(int)imgTop fileName:(NSString*)fileName interval:(int)interval z:(int)z;
@end
