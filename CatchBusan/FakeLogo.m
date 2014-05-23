//
//  FakeLogo.m
//  GNCatch
//
//  Created by DongGyu Park on 11. 9. 8..
//  Copyright 2011 DongGyu Park. All rights reserved.
//

#import "FakeLogo.h"

#define SPRITE_SHEET_PLIST @"EnemySheet.plist"

@implementation FakeLogo

// 스프라이트 이미지를 주어진 파일이름으로 설정한다
- (id)initWithName:(NSString *)nameOfFakeLogo
{
    if((self=[super init]))
    {
        // SPRITE_SHEET_PLIST로 부터 spriteFrame을 읽어들임
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:SPRITE_SHEET_PLIST];
        NSString *nameOfFile = [nameOfFakeLogo stringByAppendingFormat:@"0001.png"];
        CCTexture2D *texture = [[CCTexture2D alloc] initWithImage:[UIImage imageNamed:nameOfFile]];
        [self setTexture:texture];
    }
    
    return self;
}

- (void)logoAnimationWithName:(NSString *)nameOfFakeLogo
{
    // SPRITE_SHEET_PLIST로 부터 spriteFrame을 읽어들임
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:SPRITE_SHEET_PLIST];
    
    NSMutableArray *frames = [NSMutableArray array];
    for(NSInteger idx = 1; idx < 8; idx++) {
        NSString *nameOfFile = [nameOfFakeLogo stringByAppendingFormat:@"%04d.png",idx];
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

@end
