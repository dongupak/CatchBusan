//
//  Player.m
//  GNCatch
//
//  Created by DongGyu Park on 11. 9. 8..
//  Copyright 2011 DongGyu Park. All rights reserved.
//

#import "Player.h"

#define CHARACTER_SHEET_PLIST   @"character.plist"
#define NUM_OF_CHARACTER_FRAME  13

@implementation Player

@synthesize playerVelocity, playerHP, isAlive;
@synthesize collisonLogoArray;

-(id)init
{
	if((self = [super init]))
	{
		self.isAlive = YES;
        self.playerHP = 100;
        self.collisonLogoArray = [[NSMutableArray alloc] init];
    }
	return self;
}

- (void)playerAnimation
{
    // playerCharacter.plist로 부터 spriteFrame을 읽어들임
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:CHARACTER_SHEET_PLIST];
    
    NSMutableArray *frames = [NSMutableArray array];
    for(NSInteger idx = 1; idx <= NUM_OF_CHARACTER_FRAME; idx++) {
        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"character%04d.png",idx]];
        [frames addObject:frame];
    }
    CCAnimation *playerAnimation = [[CCAnimation alloc] initWithFrames:frames
                                                                 delay:0.05];
    CCAnimate *playerAnimate = [[CCAnimate alloc] initWithAnimation:playerAnimation restoreOriginalFrame:NO];

    id actionRepeat  = [CCRepeatForever actionWithAction:playerAnimate];
    [self runAction:actionRepeat];
}

- (CGRect) scaledRect:(float) theScaleOffset ofSprite:(CCSprite *)sprite
{
    // 스케일 오프셋 만큼 줄어든 사각형을 만들어 반환한다
    CGFloat startX = sprite.position.x-sprite.contentSize.width/2+theScaleOffset;
    CGFloat startY = sprite.position.y-sprite.contentSize.height/2+theScaleOffset;
    
	CGRect rect = CGRectMake(startX, startY,
                             sprite.contentSize.width-theScaleOffset, 
                             sprite.contentSize.height-theScaleOffset);
	return rect;
}

- (CGRect) scaledRect:(float) theScaleOffset
{
    // 스케일 오프셋 만큼 줄어든 사각형을 만들어 반환한다
    CGFloat startX = self.position.x-self.contentSize.width/2 + theScaleOffset;
    CGFloat startY = self.position.y-self.contentSize.height/2 + theScaleOffset;
    
	CGRect rect = CGRectMake(startX, startY,
                             self.contentSize.width, 
                             self.contentSize.height-theScaleOffset);
	return rect;
}

#define     SCALE_FACTOR            (0.4)
#define     COLLISION_TEST_OFFSET   (20)
#define     SCALE_OFFSET            (35.0)
#define     SMALL_SCALE_OFFSET      (15.0)

#define     THRESHOLD_DISTANCE      60.0f

- (float) distanceTo:(Logo *)aLogo
{
    float distX = aLogo.position.x-self.position.x;
    float distY = aLogo.position.y-self.position.y;
    
    //NSLog(@"distanceTo = %7.2f", (float)sqrt((double)(distX*distX + distY*distY)));
    return (float)sqrt((double)(distX*distX + distY*distY));
}

- (BOOL) collideWith: (Logo *)aLogo 
{	
    if( [self distanceTo:aLogo] < THRESHOLD_DISTANCE )
        return YES;
    
    return NO;
}

#define LOGO_COLLISION_CHECK_THRESHOLD   (5)

- (BOOL) hasCollionWith:(CCNode *)logoGroup
{
    [collisonLogoArray removeAllObjects];
    
    for (Logo *aLogo in [logoGroup children]) {
        // 로고가 LOGO_COLLISION_CHECK_THRESHOLD 아래로
        // 화면의 외부에 있으면 충돌검사가 의미가 없음
        // 또한 로고가 이미 죽음 상태이면 검사가 필요없음
        if ((aLogo.position.y < LOGO_COLLISION_CHECK_THRESHOLD) ||
            (aLogo.isAlive == NO ))
            continue;
        else if ([self collideWith:aLogo] == YES) {
            aLogo.isAlive = NO;
            [collisonLogoArray addObject:aLogo];
        }
	}
    
    if( [collisonLogoArray count] == 0 )
        return NO;  //  no collision
    
    return YES;  // collision occurred
}

- (void) dealloc
{
    [self removeAllChildrenWithCleanup:YES];
    [collisonLogoArray release];
	[super dealloc];
}


@end
