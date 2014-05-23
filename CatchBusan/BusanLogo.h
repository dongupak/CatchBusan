//
//  GNLogo.h
//  GNCatch
//
//  Created by DongGyu Park on 11. 9. 8..
//  Copyright 2011 DongGyu Park. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Logo.h"

// 경남 로고 
@interface BusanLogo : Logo {
    
}

- (id)initWithName:(NSString *)nameOfBusanLogo;
- (void)logoAnimationWithName:(NSString *)nameOfBusanLogo;
- (void)scaleUpDown;

@end
