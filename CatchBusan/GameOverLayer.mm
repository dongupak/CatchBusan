//
//  GameOverScene.m
//  GNCatch
//
//  Created by GHISANG YEON on 11. 5. 14..
//  Copyright 2011 창원대학교 모바일엑스. All rights reserved.
//

#import "GameOverLayer.h"
#import "GameLayer.h"
#import "AppDelegate.h"
#import <GameKit/GameKit.h>

@implementation GameOverLayer

enum {
    kTagBackground = 0,
    kTagScoreLabel,
    kTagMenu,
};

- (id) init {
	if( (self=[super init]) ) {
        // 배경 이미지를 표시하기 위해 Sprite를 이용합니다.
        CCSprite *bgSprite = [CCSprite spriteWithFile:@"bg_gameover.png"];
        bgSprite.anchorPoint = CGPointZero;
        [bgSprite setPosition: ccp(0, 0)];
        [self addChild:bgSprite z:kTagBackground tag:kTagBackground];
		
        CCSprite *titleSprite = [CCSprite spriteWithFile:@"title_gameover.png"];
		[titleSprite setAnchorPoint:ccp(0.5f, 0.5f)];
		[titleSprite setPosition:ccp(160, 330)];
		[self addChild:titleSprite z:10 tag:kTagBackground];

        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSString *scoreString = [NSString stringWithFormat:@" %5d", appDelegate.gameScore];
        
        [self authenticateLocalPlayer];
        [self submitScore];
        
        CCLabelBMFont *label = [CCLabelBMFont labelWithString:scoreString fntFile:@"futura-48.fnt"];                    
        label.position = ccp(110, 128);
        label.anchorPoint = ccp(0.5, 0);
        label.scale = 0.7;
        [self addChild:label z:1000 tag:kTagScoreLabel];

		// 음악설정
		music=[SimpleAudioEngine sharedEngine];
        
        // 메뉴 버튼을 만듭니다.
        // itemFromNormalImage는 버튼이 눌려지기 전에 보여지는 이미지이고, 
        // selectedImage는 버튼이 눌려졌을 때 보여지는 이미지입니다.
        // target을 self로 한 것은 버튼이 눌려졌을 때 발생하는 터치 이벤트를 GameScene에서 
        // 처리를 하겠다는 것입니다.
        // @selector를 이용하여 버튼이 눌려졌을 때 어떤 메소드에서 처리를 할 것인지 결정합니다.
        CCMenuItem *closeMenuItem = [CCMenuItemImage itemFromNormalImage:@"btn_menu.png" 
                                                        selectedImage:@"btn_menu_s.png" 
                                                                  target:self 
                                                                selector:@selector(closeMenuCallback:)];
		
		CCMenuItem *ScoreMenuItem = [CCMenuItemImage itemFromNormalImage:@"btn_ranking.png" 
                                                    selectedImage:@"btn_ranking_s.png" 
                                                                  target:self 
                                                                selector:@selector(goRanking:)];
        
        // 위에서 만들어 메뉴 아이템들을 CCMenu에 넣습니다.  
        // CCMenu는 각각의 메뉴 버튼이 눌려졌을 때 발생하는 터치 이벤트를 핸들링하고,
        // 메뉴 버튼들이 어떻게 표시될 것인지 레이아웃 처리를 담당합니다.
        CCMenu *menu1 = [CCMenu menuWithItems: closeMenuItem, nil];
        
        id action = [CCSequence actions:
                     [CCCallFuncN actionWithTarget:self 
                                          selector:@selector(menuMove1:)],
                     nil];
        [menu1 runAction:action];
        
		CCMenu *menu2 = [CCMenu menuWithItems: ScoreMenuItem, nil];
        [menu2 runAction:action];
        
        // 메뉴의 위치를 화면 가운데 아래
        menu1.position = CGPointMake(80, 40);
		menu2.position = CGPointMake(240, 40);
        
        // 만들어진 메뉴를 배경 sprite 위에 표시합니다.
        [self addChild:menu1 z:kTagMenu tag:kTagMenu];
		[self addChild:menu2 z:kTagMenu tag:kTagMenu];
    }	
    
	return self;
}

- (void) closeMenuCallback: (id) sender {
    // 더 이상 사용되지않는 그래픽 캐시를 지웁니다.
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
	
	[music playEffect:@"bonus.wav"];
	[SceneManager goMenu];
}

- (void) authenticateLocalPlayer
{
    [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError *error)
    {
        if (error == nil) {
            NSLog(@"Game Center: Player Authenticated!");
        }
        else{
            NSLog(@"Game Center: Authentication Failed!");
        }
    }];
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

-(void) submitScore
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] 
                                               delegate];
    GKScore *scoreReporter = [[[GKScore alloc] initWithCategory:@"CatchBusan_Ranking"] 
                              autorelease];
    scoreReporter.value = appDelegate.gameScore;
    
    [scoreReporter reportScoreWithCompletionHandler:^(NSError *error){
        if(error == nil)
        {
            NSLog(@"Game Center - High score successfully sent");
        }
        else 
        {
            NSLog(@"Error reporting Score : Reason: %@", [error localizedDescription]);
        }  
    }];
}

-(void)goRanking:(id)sender
{
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
