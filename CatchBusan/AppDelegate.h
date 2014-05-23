//
//  AppDelegate.h
//  CatchBusan
//
//  Created by IVIS Lab , Changwon National Univ. on 11. 10. 31..
//  Copyright DongGyu Park 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SimpleAudioEngine.h"

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
    NSInteger   gameScore;  
    SimpleAudioEngine *sae;
}

@property (nonatomic, retain) UIWindow *window;
@property (readwrite) NSInteger gameScore;

@end
