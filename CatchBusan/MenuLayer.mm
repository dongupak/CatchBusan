//
//  MenuScene.m
//  GNCatch
//
//  Created by dongupak@gmail.com on 11. 5. 14..
//  Copyright 2011 창원대학교 모바일엑스. All rights reserved.
//

#import "MenuLayer.h"
#import "GameLayer.h"
#import "HowtoLayer.h"

#define CREDIT_MENU_TRANSITION_SOUND (@"hihat.wav")
#define START_MENU_TRANSITION_SOUND (@"bonus.wav")
#define HOWTO_MENU_TRANSITION_SOUND (@"hihat.wav")

@implementation MenuLayer

enum {
    kTagBackground = 0,
    kTagGameCharacter,
    kTagGameTitle,
    kTagMenu
};

@synthesize startMenuItem, howtoMenuItem, logoIntroMenuItem;
@synthesize creditMenuItem, gameCenterMenuItem;

- (void) setBackgroundAndTitles
{
    // 배경 이미지를 표시하기 위해 Sprite를 이용합니다.
    CCSprite *bgSprite = [CCSprite spriteWithFile:@"bg_menu.png"];
    bgSprite.anchorPoint = CGPointZero;
    [bgSprite setPosition: ccp(0, 0)];
    [self addChild:bgSprite z:0 tag:kTagBackground];
    
}

- (id) init {
	if( (self=[super init]) ) {
        [self setBackgroundAndTitles];
		
        // 메뉴 버튼을 만듭니다.
        // itemFromNormalImage는 버튼이 눌려지기 전에 보여지는 이미지이고, 
        // selectedImage는 버튼이 눌려졌을 때 보여지는 이미지입니다.
        // target을 self로 한 것은 버튼이 눌려졌을 때 발생하는 터치 이벤트를 MeneScene에서 
        // 처리를 하겠다는 것입니다.
        // @selector를 이용하여 버튼이 눌려졌을 때 어떤 메소드에서 처리를 할 것인지 결정합니다.
        self.startMenuItem     = [CCMenuItemImage itemFromNormalImage:@"btn_start.png" 
                                                          selectedImage:@"btn_start_s.png" 
                                                                 target:self 
                                                               selector:@selector(newGameMenuCallback:)];
        
        
        self.howtoMenuItem       = [CCMenuItemImage itemFromNormalImage:@"btn_howto.png" 
                                                          selectedImage:@"btn_howto_s.png" 
                                                                 target:self 
                                                               selector:@selector(howtoMenuCallback:)];
        
        self.logoIntroMenuItem = [CCMenuItemImage itemFromNormalImage:@"btn_logoex.png" 
                                                          selectedImage:@"btn_logoex_s.png" 
                                                                 target:self 
                                                               selector:@selector(logoIntroCallback:)];
        self.startMenuItem.position = ccp(-160, 230);
        self.howtoMenuItem.position = ccp(780, 170);
        self.logoIntroMenuItem.position = ccp(-400, 110);
        
		id menuAction1 = [CCSequence actions:	// 화면안으로 나타나는 애니메이션 
						  [CCEaseBackOut actionWithAction:
						   [CCMoveTo actionWithDuration:1.2
                                               position:ccp(160, 230)]],
						  [CCCallFuncN actionWithTarget:self 
											   selector:@selector(menuMove1:)],
						  nil];
		[self.startMenuItem runAction:menuAction1];
        
		id menuAction2 = [CCSequence actions:	// 화면안으로 나타나는 애니메이션 
						  [CCEaseBackOut actionWithAction:
						   [CCMoveTo actionWithDuration:1.3
                                               position:ccp(160, 170)]],
						  [CCCallFuncN actionWithTarget:self 
											   selector:@selector(menuMove2:)],
						  nil];
		[self.howtoMenuItem runAction:menuAction2];
        
		id menuAction3 = [CCSequence actions:	// 화면안으로 나타나는 애니메이션 
						  [CCEaseBackOut actionWithAction:
						   [CCMoveTo actionWithDuration:1.4
                                               position:ccp(160, 110)]],
						  [CCCallFuncN actionWithTarget:self 
											   selector:@selector(menuMove2:)],
						  nil];
		[self.logoIntroMenuItem runAction:menuAction3];

        self.creditMenuItem = [CCMenuItemImage itemFromNormalImage:@"btn_i.png" 
                                                 selectedImage:@"btn_i_s.png" 
                                                        target:self 
                                                      selector:@selector(goCreditScene:)];
        self.creditMenuItem.position = ccp(290, 435);
    
        // 각종 메뉴 추가 부분
        self.gameCenterMenuItem = [CCMenuItemImage itemFromNormalImage:@"btn_game_center.png" 
                                                    selectedImage:@"btn_game_center_s.png" 
                                                           target:self 
                                                         selector:@selector(goRanking:)];
        self.gameCenterMenuItem.position = ccp(280, 610);
    
        id menuAction4 = [CCSequence actions:	// 화면안으로 나타나는 애니메이션 
                          [CCDelayTime actionWithDuration:0.9],
						  [CCEaseBackOut actionWithAction:
						   [CCMoveTo actionWithDuration:1.4
                                               position:ccp(280, 110) ]],
						  [CCCallFuncN actionWithTarget:self 
											   selector:@selector(menuMove2:)],
						  nil];
        [self.gameCenterMenuItem runAction:menuAction4];
        
        // 위에서 만들어지 각각의 메뉴 아이템들을 CCMenu에 넣습니다.  
        // CCMenu는 각각의 메뉴 버튼이 눌려졌을 때 발생하는 터치 이벤트를 핸들링하고,
        // 메뉴 버튼들이 어떻게 표시될 것인 지 레이아웃 처리를 담당합니다.
        CCMenu *menu = [CCMenu menuWithItems: self.startMenuItem,
						self.howtoMenuItem, 
                        self.logoIntroMenuItem,
                        self.gameCenterMenuItem,
                        self.creditMenuItem,
						nil];
		menu.position = CGPointZero;
		
        [self addChild:menu z:2100 tag:kTagMenu];
    }	
    
	return self;
}

// 메뉴가 최종적으로 아래위로 움직이는 애니메이션을 위한 메소드
-(void) menuMoveUpDown:(id)sender withOffset:(int)offset
{
	// CCMoveBy에 의해 상대적인 위치로 이동한다
	id moveUp = [CCMoveBy actionWithDuration:0.9 position:ccp(0, offset)];
	id moveDown = [CCMoveBy actionWithDuration:0.9 position:ccp(0, -offset)];
	// 아래위 움직임을 반복한다
	id moveUpDown = [CCSequence actions:moveUp, moveDown, nil];
	
	[sender runAction:[CCRepeatForever actionWithAction:moveUpDown]];	
}

-(void)menuMove1:(id)sender
{
	[self menuMoveUpDown:sender withOffset:5];
}

-(void)menuMove2:(id)sender
{
	[self menuMoveUpDown:sender withOffset:7];
}

// Credit Scene으로 이동
- (void) goCreditScene: (id) sender 
{
	[sae playEffect:CREDIT_MENU_TRANSITION_SOUND];	
	
	[SceneManager goCredit];
}

- (void) howtoMenuCallback: (id) sender 
{
	[sae playEffect:HOWTO_MENU_TRANSITION_SOUND];
	
	[SceneManager goHowto];
}

- (void) logoIntroCallback: (id) sender 
{
	[sae playEffect:HOWTO_MENU_TRANSITION_SOUND];
	
	[SceneManager goLogoIntro];
}

// 메뉴 아이템(버튼)을 만들 때 이벤트 핸들러로 등록된 메소드를 만듭니다.
- (void) newGameMenuCallback: (id) sender 
{
	[sae playEffect:START_MENU_TRANSITION_SOUND];

    [SceneManager goGame];
}

-(void)goRanking:(id)sender
{
    [sae playEffect:START_MENU_TRANSITION_SOUND];
    
    backView = [[UIViewController alloc] init];
    
    GKLeaderboardViewController *leaderboardController =
    [[GKLeaderboardViewController alloc] init];
    if ( leaderboardController != nil) {
        leaderboardController.leaderboardDelegate = self;
        [[[CCDirector sharedDirector] openGLView] addSubview:backView.view];
        [backView presentModalViewController:leaderboardController animated:YES];
    }
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
    [backView dismissModalViewControllerAnimated:YES];
    [backView.view removeFromSuperview];
}

@end
