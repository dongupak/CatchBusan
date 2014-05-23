//
//  MenuScene.h
//  GNCatch
//
//  Created by dongupak@gmail.com on 11. 5. 14..
//  Copyright 2011 창원대학교 모바일엑스. All rights reserved.
//

#import "cocos2d.h"
#import "SimpleAudioEngine.h"
#import "SceneManager.h"
#import <GameKit/GameKit.h>

@interface MenuLayer : CCLayer <GKLeaderboardViewControllerDelegate> {
    SimpleAudioEngine *sae;

    CCMenuItem *startMenuItem;
    CCMenuItem *howtoMenuItem;
    CCMenuItem *logoIntroMenuItem;
    
    CCMenuItem *gameCenterMenuItem;
	CCMenuItem *creditMenuItem;
    UIViewController *backView;
}

@property (nonatomic, retain) CCMenuItem *startMenuItem;
@property (nonatomic, retain) CCMenuItem *howtoMenuItem;
@property (nonatomic, retain) CCMenuItem *logoIntroMenuItem;

@property (nonatomic, retain) CCMenuItem *gameCenterMenuItem;
@property (nonatomic, retain) CCMenuItem *creditMenuItem;

- (void) setBackgroundAndTitles;
- (void) goCreditScene: (id) sender;
- (void) howtoMenuCallback: (id) sender;
- (void) logoIntroCallback: (id) sender ;
- (void) newGameMenuCallback: (id) sender;
- (void) goRanking: (id) sender;

- (void) menuMoveUpDown:(id)sender withOffset:(int)offset;
- (void) menuMove1:(id)sender;
- (void) menuMove2:(id)sender;
@end
