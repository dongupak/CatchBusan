//
//  HowtoScene.h
//  GNCatch
//
//  Created by DongGyu Park on 12/8/10.
//  Copyright 2010 IVIS Lab. All rights reserved.
//

#import "cocos2d.h"
#import "SceneManager.h"

enum {
	kTagHowtoBackground = 0,
	kTagHowtoMenu,
};

@interface HowtoLayer : CCLayer {
}

-(void) menuMoveUpDown:(id)sender withOffset:(int)offset;
-(void) menuMove1:(id)sender;
@end
