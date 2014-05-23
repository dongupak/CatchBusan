//
//  LogoIntroScene.m
//  GNCatch
//
//  Created by DongGyu Park on 12/8/10.
//  Copyright 2010 IVIS Lab. All rights reserved.
//

#import "LogoIntroLayer.h"
//#import "IntroLogoScrollView.h"

@implementation LogoIntroLayer

@synthesize imageBG;

- (id) init {
	if((self = [super init])) {
		CCSprite *bgSprite = [CCSprite spriteWithFile:@"bg_ex.png"];
		[bgSprite setAnchorPoint:CGPointZero];
		[bgSprite setPosition:CGPointZero];
		[self addChild:bgSprite z:0 tag:kTagLogoIntroBackground];
        
		CCMenuItem *closeMenuItem = [CCMenuItemImage itemFromNormalImage:@"btn_back.png"
														   selectedImage:@"btn_back_s.png"
																  target:self
																selector:@selector(closeMenuCallback:)];
		CCMenu *menu = [CCMenu menuWithItems:closeMenuItem, nil];
		menu.position = CGPointMake(160, 40);
		[self addChild:menu z:30 tag:kTagLogoIntroMenu];
        id action = [CCSequence actions:
                     [CCCallFuncN actionWithTarget:self 
                                          selector:@selector(menuMove1:)],
                     nil];
        [menu runAction:action];
        
        //ScrollView
        CGRect bounds = [[UIScreen mainScreen] bounds];
        bounds.size.height -= 110;
        
        imageBG = [UIImage imageNamed:@"logo_ex.png"];
        imageView = [[UIImageView alloc] initWithImage:imageBG];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [imageView setFrame:CGRectMake(10,0,imageBG.size.width,imageBG.size.height)];
        
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 140, 320, 270)];
        [scrollView setContentSize:CGSizeMake(imageBG.size.width,imageBG.size.height)];
        [scrollView addSubview:imageView];
        [imageView release];
        
        scrollView.delegate = self;
        scrollView.maximumZoomScale = 1.0f;
        scrollView.minimumZoomScale = 1.0f;
        
        [[[CCDirector sharedDirector] openGLView] addSubview:scrollView];
        
        //ScrollView FadeIn
        scrollView.alpha = 0;
        [UIScrollView beginAnimations:@"FadeIn" context:nil];
        [UIScrollView setAnimationDelegate:self];
        [UIScrollView setAnimationDuration:2.6];
        scrollView.alpha = 1;
        [UIScrollView commitAnimations];
	}
	return self;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return imageView;
}

- (void)onExit
{
    // 장면에서 소거되면 superview로 부터 scrollView를 제거시킨다
    [scrollView removeFromSuperview];
}

// 메뉴가 최종적으로 아래위로 움직이는 애니메이션을 위한 메소드
-(void) menuMoveUpDown:(id)sender withOffset:(int)offset
{
	// CCMoveBy에 의해 상대적인 위치로 이동한다
	id moveUp = [CCMoveBy actionWithDuration:0.9 position:ccp(0, offset)];
	id moveDown = [CCMoveBy actionWithDuration:0.9 position:ccp(0, -offset)];
	// 아래위 움직임을 반복한다
	id moveUpDown = [CCSequence actions:moveUp, moveDown, nil];
	
	[sender runAction:[CCRepeatForever actionWithAction:moveUpDown]];	
}

-(void)menuMove1:(id)sender
{
	[self menuMoveUpDown:sender withOffset:5];
}

- (void) gotoMenu
{
    [UIScrollView beginAnimations:@"FadeOut" context:nil];
    [UIScrollView setAnimationDelegate:self];
    [UIScrollView setAnimationDuration:1.0]; //애니메이션 일어나는시간
    scrollView.alpha = 0;
    [UIScrollView commitAnimations];
    
    [SceneManager goMenu];
}

- (void) closeMenuCallback: (id) sender 
{
    [self performSelector:@selector(gotoMenu) withObject:nil afterDelay:0.1];
}

-(void)dealloc
{    
	[super dealloc];
}

@end