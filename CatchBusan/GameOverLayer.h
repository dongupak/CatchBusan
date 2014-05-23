//
//  GameOverScene.h
//  GNCatch
//
//  Created by GHISANG YEON on 11. 5. 14..
//  Copyright 2011 창원대학교 모바일엑스. All rights reserved.
//

#import "cocos2d.h"
#import "SimpleAudioEngine.h"
#import "SceneManager.h"
#import <GameKit/GameKit.h>

@interface GameOverLayer : CCLayer <GKLeaderboardViewControllerDelegate> {
	SimpleAudioEngine *music;
    UIViewController *backView;
}

- (void) closeMenuCallback: (id) sender;
- (void)goRanking: (id) sender;

- (void) authenticateLocalPlayer;
- (void) submitScore;
@end
