//
//  SceneManager.m
//  GNCatch
//
//  Created by MajorTom on 9/7/10.
//  Copyright iphonegametutorials.com 2010. All rights reserved.
//

#import "SceneManager.h"

// Scene간 Transtion에 경과되는 시간
#define TRANSITION_DURATION (1.2f)

@interface FadeWhiteTransition : CCTransitionFade 
+(id) transitionWithDuration:(ccTime) t scene:(CCScene*)s;
@end

@interface FadeBlackTransition : CCTransitionFade 
+(id) transitionWithDuration:(ccTime) t scene:(CCScene*)s;
@end

@interface ZoomFlipXLeftOver : CCTransitionFlipX 
+(id) transitionWithDuration:(ccTime) t scene:(CCScene*)s;
@end

@interface FlipYDownOver : CCTransitionFlipY 
+(id) transitionWithDuration:(ccTime) t scene:(CCScene*)s;
@end

@implementation FadeWhiteTransition
+(id) transitionWithDuration:(ccTime) t scene:(CCScene*)s {
	return [self transitionWithDuration:t scene:s withColor:ccWHITE];
}
@end

@implementation FadeBlackTransition
+(id) transitionWithDuration:(ccTime) t scene:(CCScene*)s {
	return [self transitionWithDuration:t scene:s withColor:ccBLACK];
}
@end

@implementation ZoomFlipXLeftOver
+(id) transitionWithDuration:(ccTime) t scene:(CCScene*)s {
	return [self transitionWithDuration:t scene:s orientation:kOrientationLeftOver];
}
@end

@implementation FlipYDownOver
+(id) transitionWithDuration:(ccTime) t scene:(CCScene*)s {
	return [self transitionWithDuration:t scene:s orientation:kOrientationDownOver];
}
@end

static int sceneIdx=0;
static NSString *transitions[] = {
	//@"FlipYDownOver",
	@"FadeWhiteTransition",
    @"FadeBlackTransition"
	//@"ZoomFlipXLeftOver",
};

Class nextTransition()
{	
	// HACK: else NSClassFromString will fail
	[CCTransitionRadialCCW node];
	
	sceneIdx++;
	sceneIdx = sceneIdx % ( sizeof(transitions) / sizeof(transitions[0]) );
	NSString *r = transitions[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}

@interface SceneManager ()
+(void) go: (CCLayer *) layer withTransition: (NSString *)transitionString;
+(void) go: (CCLayer *) layer;
+(CCScene *) wrap: (CCLayer *) layer;
@end


@implementation SceneManager

+(void) goMenu{
	CCLayer *layer = [MenuLayer node];
	[SceneManager go:layer withTransition:@"FadeWhiteTransition"];
}

+(void) goGame{
	CCLayer *layer = [GameLayer node];
	[SceneManager go:layer];
}

+(void) goGameOver{
	CCLayer *layer = [GameOverLayer node];
	[SceneManager go:layer];
}

+(void) goHowto{
	CCLayer *layer = [HowtoLayer node];
	[SceneManager go:layer];
}

+(void) goCredit{
	CCLayer *layer = [CreditLayer node];
	[SceneManager go:layer];
}

// 로고를 설명하는 introLayer
+(void) goLogoIntro{
	CCLayer *layer = [LogoIntroLayer node];
	[SceneManager go:layer withTransition:@"FadeWhiteTransition"];
}

+(void) go:(CCLayer *)layer withTransition:(NSString *)transitionString ofDelay:(float)t
{
	CCDirector *director = [CCDirector sharedDirector];
	CCScene *newScene = [SceneManager wrap:layer];
	
	Class transition = NSClassFromString(transitionString);
	
	// 이미 실행중인 Scene이 있을 경우 replaceScene을 호출
	if ([director runningScene]) {
		[director replaceScene:[transition transitionWithDuration:t 
															scene:newScene]];
	} // 최초의 Scene은 runWithScene으로 구동시킴
	else {
		[director runWithScene:newScene];		
	}
}

+(void) go:(CCLayer *)layer withTransition:(NSString *)transitionString
{
	CCDirector *director = [CCDirector sharedDirector];
	CCScene *newScene = [SceneManager wrap:layer];
	
	Class transition = NSClassFromString(transitionString);
	
	// 이미 실행중인 Scene이 있을 경우 replaceScene을 호출
	if ([director runningScene]) {
		[director replaceScene:[transition transitionWithDuration:TRANSITION_DURATION 
															scene:newScene]];
	} // 최초의 Scene은 runWithScene으로 구동시킴
	else {
		[director runWithScene:newScene];		
	}
}

+(void) go:(CCLayer *)layer
{
	CCDirector *director = [CCDirector sharedDirector];
	CCScene *newScene = [SceneManager wrap:layer];
	
	Class transition = nextTransition();
	
	if ([director runningScene]) {
		[director replaceScene:[transition transitionWithDuration:TRANSITION_DURATION 
															scene:newScene]];
	}else {
		[director runWithScene:newScene];		
	}
}

+(CCScene *) wrap:(CCLayer *)layer{
	CCScene *newScene = [CCScene node];
	[newScene addChild: layer];
	return newScene;
}

@end
