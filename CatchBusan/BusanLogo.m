//
//  GNLogo.m
//  GNCatch
//
//  Created by DongGyu Park on 11. 9. 8..
//  Copyright 2011 DongGyu Park. All rights reserved.
//

#import "BusanLogo.h"

#define EFFECT_SHEET_PLIST @"EffectAndLogo.plist"

@implementation BusanLogo

- (id)initWithName:(NSString *)nameOfBusanLogo
{
    if((self=[super init]))
    {
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:EFFECT_SHEET_PLIST];
        NSString *nameOfFile = [nameOfBusanLogo stringByAppendingFormat:@"0001.png"];
        
        CCTexture2D *texture = [[CCTexture2D alloc] initWithImage:[UIImage imageNamed:nameOfFile]];
        [self setTexture:texture];
    }
    
    return self;
}

- (void)logoAnimationWithName:(NSString *)nameOfBusanLogo
{
    // playerCharacter.plist로 부터 spriteFrame을 읽어들임
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:EFFECT_SHEET_PLIST];
    
    NSMutableArray *frames = [NSMutableArray array];
    for(NSInteger idx = 1; idx < 7; idx++) {
        NSString *nameOfFile = [nameOfBusanLogo stringByAppendingFormat:@"%04d.png",idx];
        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] 
                                spriteFrameByName:nameOfFile];
        [frames addObject:frame];
    }
    CCAnimation *playerAnimation = [[CCAnimation alloc] initWithFrames:frames
                                                                 delay:0.05];
    CCAnimate *playerAnimate = [[CCAnimate alloc] initWithAnimation:playerAnimation restoreOriginalFrame:NO];
    
    id actionRepeat  = [CCRepeatForever actionWithAction:playerAnimate];
    [self runAction:actionRepeat];
}

#define SCALE_UP_DURATION    (0.5)
#define SCALE_DOWN_DURATION   (0.5)

- (void) scaleUpDown
{
    // 로고는 LOGO_ACTION_DURATION 초 만큼 회전
	id scaleUp = [CCScaleTo actionWithDuration:SCALE_UP_DURATION scale:1.2];
    id scaldDown = [CCScaleTo actionWithDuration:SCALE_DOWN_DURATION scale:1.0];
    
    CCSequence *action = [CCSequence actions:scaleUp, 
                          scaldDown, nil];
	// 무기는 action1 또는 최대 duration 이후에 action2에서 소거된다.
	// 그렇게하지 않으면 회전하지도 않고 정지한 수리검이 남는 수가 있다
	id actionRepeat = [CCRepeatForever actionWithAction:action];	
	
	[self runAction:actionRepeat];
}

@end
