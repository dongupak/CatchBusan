//
//  GNSubLogo.h
//  GNCatch
//
//  Created by DongGyu Park on 11. 9. 8..
//  Copyright 2011 DongGyu Park. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Logo.h"

// 경남지역 산하 지자체 로고 클래스 
@interface BusanSubLogo : Logo {

}

- (id)initWithName:(NSString *)nameOfFakeLogo;
- (void)logoAnimationWithName:(NSString *)nameOfFakeLogo;

@end
