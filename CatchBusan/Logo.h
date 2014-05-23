//
//  Logo.h
//  GNCatch
//
//  Created by DongGyu Park on 11. 9. 9..
//  Copyright 2011 DongGyu Park. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

// 게임에서 사용할 로고 스프라이트 
@interface Logo : CCSprite {
    BOOL isAlive;
}

@property BOOL isAlive;

- (void) logoAction;
- (BOOL) isOutsideWindow:(CGSize) windowSize;
- (void) pop;
- (void) finishedPopSequence;
- (void) rotateAction;
- (void) leftRightMoveAction;
@end
