//
//  HowtoScene.m
//  GNCatch
//
//  Created by DongGyu Park on 12/8/10.
//  Copyright 2010 IVIS Lab. All rights reserved.
//

#import "HowtoLayer.h"

@implementation HowtoLayer

- (id) init {
	if((self = [super init])) {
		CCSprite *bgSprite = [CCSprite spriteWithFile:@"bg_howto.png"];
		[bgSprite setAnchorPoint:CGPointZero];
		[bgSprite setPosition:CGPointZero];
		[self addChild:bgSprite z:0 tag:kTagHowtoBackground];

		CCMenuItem *closeMenuItem = [CCMenuItemImage itemFromNormalImage:@"btn_back.png"
														   selectedImage:@"btn_back_s.png"
																  target:self
																selector:@selector(closeMenuCallback:)];
		CCMenu *menu = [CCMenu menuWithItems:closeMenuItem, nil];
		menu.position = CGPointMake(160, 40);
		[self addChild:menu z:3 tag:kTagHowtoMenu];
        
        id action = [CCSequence actions:
                     [CCCallFuncN actionWithTarget:self 
                                          selector:@selector(menuMove1:)],
                     nil];
        [menu runAction:action];

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


- (void) closeMenuCallback: (id) sender 
{
    //  장면에서 빠져나올적에는 iAD를 removeChild 시키자    
	[SceneManager goMenu];
}

-(void)dealloc
{
	[super dealloc];
}

@end