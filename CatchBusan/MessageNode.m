/*
 This work is licensed under the Creative Commons Attribution-Share Alike 3.0 United States License. 
 To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/us/ or 
 send a letter to Creative Commons, 171 Second Street, Suite 300, San Francisco, California, 94105, USA.
 
 Jed Laudenslayer
 http://kwigbo.com
 
 */

#import "MessageNode.h"

@implementation MessageNode

@synthesize lifeMinus, combo3, comboCombo;

-(id) init
{	
	CGSize windowSize = [[CCDirector sharedDirector] winSize];
	const float X_POSITION_OF_MESSAGE = windowSize.width/2.0;
	const float Y_POSITION_OF_MESSAGE = 400.0f;
	CGPoint pos = CGPointMake(X_POSITION_OF_MESSAGE, Y_POSITION_OF_MESSAGE);
	
	self = [super init];
	if (self)
	{
		// 현재 노드에 miss, perfect, correct 스프라이트 노드를 자식 노드로 추가 
		lifeMinus = [CCSprite spriteWithFile:@"msg_life_minus.png"];
		[self addChild:lifeMinus];
		
		combo3 = [CCSprite spriteWithFile:@"msg_combo3.png"];
		[self addChild:combo3];
		
		comboCombo = [CCSprite spriteWithFile:@"msg_combo_combo.png"];
		[self addChild:comboCombo];
				
		for (CCSprite *sprite in [self children]) {
			// 각각의 노드에 대한 위치는 화면의 중앙 상단으로 한다
			sprite.position = pos;
			// 스프라이트는 처음에는 숨겨둔다
			sprite.visible = NO;
		}
	}
	
	return self;
}

// showMessage 메소드는 int를 매개변수로 받아서 각 스프라이트를 지역변수 sprite에 할당함.
-(void)showMessage:(int)message
{
	CGSize windowSize = [[CCDirector sharedDirector] winSize];
	const float X_POSITION_OF_MESSAGE = windowSize.width/2.0;
	const float Y_POSITION_OF_MESSAGE = 400;
	CGPoint pos = CGPointMake(X_POSITION_OF_MESSAGE, Y_POSITION_OF_MESSAGE);
	
	[self showMessage:message atPosition:pos];
}

-(void)showMessage:(int)message atPosition:(CGPoint)pos
{
	CCSprite *sprite		= nil;
	id		action			= nil;

	// 메시지 종류에 따라 서로 다른 메시지 액션
	switch ( message ) 
    {
		case LIFE_MINUS_MESSAGE:
			sprite = lifeMinus;
			sprite.visible = YES;
			[sprite setPosition:ccp(pos.x, 180)];
			// 순차적인 액션을 보여줌, life Minus인 경우
			// 화면의 아래쪽으로 떨어진다..
			action = [CCSequence actions:
					  [CCFadeTo actionWithDuration:0.8 opacity:250],
					  [CCDelayTime actionWithDuration:1.2], 
					  [CCEaseBackIn actionWithAction:
					   [CCMoveTo actionWithDuration:0.3 position:ccp(pos.x, -50)]],
					  [CCFadeTo actionWithDuration:0.01 opacity:0],
					  nil];
			break;
		case COMBO3_MESSAGE:
			sprite = combo3;
			sprite.visible = YES;
			[sprite setPosition:pos];
			action = [CCSequence actions:
					  [CCFadeTo actionWithDuration:0.5 opacity:250],
					  [CCDelayTime actionWithDuration:0.9], 
					  [CCMoveTo actionWithDuration:0.2 position:ccp(pos.x, 550)], 
					  [CCFadeTo actionWithDuration:0.01 opacity:0],
					  nil];
			break;
		case COMBO_COMBO_MESSAGE:
			sprite = comboCombo;
			sprite.visible = YES;
			[sprite setPosition:pos];
			action = [CCSequence actions:
					  [CCFadeTo actionWithDuration:0.5 opacity:250],
					  [CCDelayTime actionWithDuration:0.9], 
					  [CCMoveTo actionWithDuration:0.2 position:ccp(pos.x, 550)], 
					  [CCFadeTo actionWithDuration:0.01 opacity:0],
					  nil];
			break;
		default:
			sprite = combo3;
			sprite.visible = YES;
			[sprite setPosition:pos];
			id scaledMove = [self scaledMoveAction:sprite];
			action = [CCSequence actions:
					  [CCScaleTo actionWithDuration:0.01 scale:1.0f],
					  [CCFadeTo actionWithDuration:0.2 opacity:250],
					  [CCDelayTime actionWithDuration:0.7], 
					  scaledMove,
					  nil];
			// 순차적인 액션을 보여줌
			break;
	}
	
	// 순차적인 액션을 보여줌
	[sprite runAction:action];
	return;
}

-(id)scaledMoveAction:(CCSprite *)sprite
{
	CGSize	windowSize			= [[CCDirector sharedDirector] winSize];
	float	halfOfWindowWidth	= windowSize.width/2.0f;
	CGPoint targetPoint			= ccp(halfOfWindowWidth,
									windowSize.height+sprite.contentSize.height+30);		
	
	// 두 가지 종류의 spawning action을 만든다
	id move = [CCSpawn actions:	
					 [CCEaseBackIn actionWithAction:
					  [CCMoveTo actionWithDuration:0.4 position:targetPoint]], 
					 [CCEaseBackIn actionWithAction:
					  [CCScaleTo actionWithDuration:0.4 scale:0.4f]],
					 nil] ;

	return move;
}

@end
