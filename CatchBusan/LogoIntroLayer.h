//
//  LogoIntroLayer.h
//  GNCatch
//
//  Created by DongGyu Park on 12/8/10.
//  Copyright 2010 IVIS Lab. All rights reserved.
//

#import "cocos2d.h"
#import "SceneManager.h"
//#import "IntroLogoScrollView.h"

enum {
	kTagLogoIntroBackground = 0,
	kTagLogoIntroMenu,
    kTagScrollView,
};

@interface LogoIntroLayer : CCLayer <UIScrollViewDelegate>{
    //IntroLogoScrollView *introLogoScrollView;
    UIScrollView *scrollView;
    UIImageView *imageView;
    UIImage *imageBG;
    
}

@property (nonatomic, retain) UIImage *imageBG;

-(void) menuMoveUpDown:(id)sender withOffset:(int)offset;
-(void) menuMove1:(id)sender;

@end
