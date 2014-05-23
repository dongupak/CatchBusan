//
//  Logo.m
//  GNCatch
//
//  Created by DongGyu Park on 11. 9. 9..
//  Copyright 2011 DongGyu Park. All rights reserved.
//

#import "Logo.h"

@implementation Logo

@synthesize isAlive;

// weapon 초기화 
// [super init]을 통하여 CCSprite 초기화 결과를 self가 받아온다 
-(id)init
{
	if((self = [super init]))
	{
		self.isAlive = YES;
    }
    
	return self;
}

// 위에서 떨어지는 로고가 윈도우의 외부로 나가는지 검사
-(BOOL)isOutsideWindow:(CGSize) windowSize
{
	CGFloat leftMost = self.position.x - self.contentSize.width/2;
	CGFloat rightMost =  self.position.x + self.contentSize.width/2;
	//CGFloat bottomMost = self.position.y - self.contentSize.height/2;
	CGFloat topMost = self.position.y + self.contentSize.height/2;
	
    // rightMost가 0보다 작아질 경우 화면의 외부 
    // topMost가 0보다 작아질 경우 화면의 외부로 나가는 것임
	if ( rightMost < 0 || topMost < 0 || leftMost > windowSize.width )
		return YES;
    
    return NO;
}

#define ROTATION_DURATION    (30)
#define ROTATION_ANGLE     (9000)

- (void) logoAction
{
    // 로고는 LOGO_ACTION_DURATION 초 만큼 회전
	id rotationAction = [CCRotateBy actionWithDuration:ROTATION_DURATION
                                                 angle:ROTATION_ANGLE];
    
	// 무기는 action1 또는 최대 duration 이후에 action2에서 소거된다.
	// 그렇게하지 않으면 회전하지도 않고 정지한 수리검이 남는 수가 있다
	id actionRepeat = [CCRepeatForever actionWithAction:rotationAction];	
	
	[self runAction:actionRepeat];
}

- (void) rotateAction
{
    // 로고는 LOGO_ACTION_DURATION 초 만큼 회전
	id rotationAction = [CCRotateBy actionWithDuration:ROTATION_DURATION
                                                 angle:ROTATION_ANGLE];
    
	// 무기는 action1 또는 최대 duration 이후에 action2에서 소거된다.
	// 그렇게하지 않으면 회전하지도 않고 정지한 수리검이 남는 수가 있다
	id actionRepeat = [CCRepeatForever actionWithAction:rotationAction];	
	
	[self runAction:actionRepeat];
}

#define LEFT_RIGHT_MOVE_DURATION    (0.5)
#define LEFT_RIGHT_MOVE_ANGLE       (30)

- (void) leftRightMoveAction
{
    // 로고는 LOGO_ACTION_DURATION 초 만큼 회전
	id leftRotationAction = [CCRotateTo actionWithDuration:LEFT_RIGHT_MOVE_DURATION
                                                     angle:LEFT_RIGHT_MOVE_ANGLE];
    id rightRotateAction = [CCRotateTo actionWithDuration:LEFT_RIGHT_MOVE_DURATION
                                                    angle:-LEFT_RIGHT_MOVE_ANGLE];
    
    CCSequence *action = [CCSequence actions:leftRotationAction, 
                          rightRotateAction, nil];
	// 무기는 action1 또는 최대 duration 이후에 action2에서 소거된다.
	// 그렇게하지 않으면 회전하지도 않고 정지한 수리검이 남는 수가 있다
	id actionRepeat = [CCRepeatForever actionWithAction:action];	
	
	[self runAction:actionRepeat];
}


// 화면에서 터지는 장면이 pop될때 하는 일
// ScaleTo 객체를 이용한 순차적 애니메이션인 Sequence를 생성함
- (void) pop
{
    NSLog(@"pop");
    
	// actionWithDuration에서 0.1초간 scale을 .5로 하여 축소시킨 후 0.1초간 2배 확대
	// 여기서도 전체 애니메이션 시퀀스가 실행되는 시간은 0.2 (0.1+0.1)초에 불과
	id popSequence = [CCSequence actions:
                      [CCScaleTo actionWithDuration:.1 scale:.5],
                      [CCScaleTo actionWithDuration:1.5 scale:2], 
                      [CCCallFunc actionWithTarget:self selector:@selector(finishedPopSequence)], 
                      nil];
	[self runAction:popSequence];
}

// 종료된 pop Sequence
- (void) finishedPopSequence
{
	self.scale = 1;
    self.visible = NO;
    isAlive = NO;
}

@end