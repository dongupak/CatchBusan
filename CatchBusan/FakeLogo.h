//
//  FakeLogo.h
//  GNCatch
//
//  Created by DongGyu Park on 11. 9. 8..
//  Copyright 2011 DongGyu Park. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Logo.h"

// 가짜 부산지역 로고로 먹게되면 감점이 됨
@interface FakeLogo : Logo {
}

- (id)initWithName:(NSString *)nameOfFakeLogo;
- (void)logoAnimationWithName:(NSString *)nameOfFakeLogo;

@end
