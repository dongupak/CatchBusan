//
//  RootViewController.h
//  CatchBusan
//
//  Created by IVIS Lab , Changwon National Univ. on 11. 10. 31..
//  Copyright DongGyu Park 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import "AppDelegate.h"

@interface RootViewController : UIViewController {
	int64_t  currentScore;
}

@property (nonatomic, assign) int64_t currentScore;

@end
