//
//  GameScene.m
//  CatchBusan
//
//  Created by dongupak@gmail.com on 11. 5. 13..
//  Copyright 2011 창원대학교 모바일엑스. All rights reserved.
//

#import "GameLayer.h"
#import "GameOverLayer.h"
#import "AppDelegate.h"

#define FRONT_CLOUD_SIZE 563 
#define BACK_CLOUD_SIZE  509
#define FRONT_CLOUD_TOP  400
#define BACK_CLOUD_TOP   290

// int값 min에서 max사이의 난수를 생성하여 float로 반환하는 기능
float clampRandomNumber(int min, int max)
{
	int t = arc4random()%(max-min);
	
	return (t+min)*1.0f; // 실수로 바꾸어서 반환함
}

@implementation GameLayer

enum {
    kTagBackground = 1400,
    kTagMenu,
    kTagPlayer,
    kTagSprite,
    kTagSpriteSheet,
    kTagScoreLabel,
    kTagScoreSprite,
    kTagLifeLabel,
    kTagLifeSprite,
    kTagBombGroup,
    kTagLogoGroup,
    kTagFakeLogoGroup,
    kTagJokerGroup,
    kTagMessage,
};

enum {
    kTagBusanLogo = 3500,
    kTagBusanSubLogo,
    kTagBomb,
    kTagFakeLogo,
};

@synthesize player;
@synthesize logoGroupNode;
@synthesize scoreLabel, lifeLabel;
@synthesize message;
@synthesize  subLogoImageArray;
@synthesize  fakeLogoImageArray;

#define NUM_OF_GAMER_LIFE   (3)
#define INIT_SCORE          (0)

-(id) init
{
	if ((self = [super init]))
	{
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
		float imageHeight = 0;
        
		gameScore = INIT_SCORE;
        numOfLife   = NUM_OF_GAMER_LIFE;
        smokeAnimate = nil;
        comboCount = 0; // 콤보 계산을 위한 카운터
        logoGenInterval = 1.0f;
        
        // audio engine
		sae=[SimpleAudioEngine sharedEngine];
        [sae preloadEffect:@"background.mp3"];
		[sae preloadEffect:@"handgun_fire.wav"];
        [sae preloadEffect:@"wav16.wav"];
        [sae preloadEffect:@"bellOing.m4a"];
        //[sae playBackgroundMusic:@"background.mp3"];
		
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.gameScore = 0;
        
        [self initImageArray];
        [self setBackground];
        [self createBombSmoke];
        [self createLogoExplosion];
        [self createBombDownAnimation];
        [self createEnergyBar];
        //[self createCloud];
        [self createCloudWithSize:FRONT_CLOUD_SIZE top:FRONT_CLOUD_TOP fileName:@"cloud_front.png" interval:15 z:3];
        [self createCloudWithSize:BACK_CLOUD_SIZE  top:BACK_CLOUD_TOP  fileName:@"cloud_back.png"  interval:30 z:1];

        [self displayScoreAndLife];
        
		self.message = [MessageNode node];
		[self addChild:self.message z:1200 tag:kTagMessage];
		
		// 가속도 입력
		self.isAccelerometerEnabled = YES;
		
		// 게임 플레이어 스프라이트 추가
		player = [Player spriteWithFile:@"character0001.png"];
        [player playerAnimation];
        
        // 스프라이트 배치 플레이어 첫 시작위치
		imageHeight = player.contentSize.height;
		player.position = ccp(screenSize.width/2, imageHeight/2);
        [self addChild:player z:400 tag:kTagPlayer];
				
        logoGroupNode = [CCNode node];
        [self addChild:logoGroupNode z:90   tag:kTagLogoGroup];
        
		[self schedule:@selector(generateLogoAndFakeLogo) interval:logoGenInterval];
        [self schedule:@selector(animateLogoAndCountScore)];
        [self scheduleUpdate];
	}
	
	return self;
}

-(void) createEnergyBar
{
    CCSprite *ptEnergyEmpty = [CCSprite spriteWithFile:@"pole_em.png"];
    ptEnergyEmpty.anchorPoint = ccp(0, 0);
    ptEnergyEmpty.position = ccp(280, 85);
    [self addChild:ptEnergyEmpty z:20];
    
    ptEnergy = [CCProgressTimer progressWithFile:@"pole_en.png"];
    ptEnergy.type = kCCProgressTimerTypeVerticalBarBT;
    ptEnergy.anchorPoint = ccp(0, 0);
    ptEnergy.position = ccp(280, 85);
    ptEnergy.percentage=100;
    [self addChild:ptEnergy z:21];
}

-(void) updateEnergyBar
{
    if ( player.playerHP < 0) {
        player.playerHP = 0;
    }
    else if( player.playerHP > 100){
        player.playerHP = 99;
    }
    
    ptEnergy.percentage = player.playerHP;
}

-(void) setBackground
{
    // 배경그림 입히기 
    CCSprite *bgSprite=[CCSprite spriteWithFile:@"bg_game.png"];
//    bgSprite.opacity = 100;
    bgSprite.anchorPoint=CGPointZero;
    bgSprite.position=CGPointZero;
    [self addChild:bgSprite z:0 tag:kTagBackground];
}

-(void) displayScoreAndLife
{
    CCSprite *scoreSprite = [CCSprite spriteWithFile:@"score.png"];
    scoreSprite.anchorPoint = CGPointZero;
    scoreSprite.position = ccp(15, 450);
    [self addChild:scoreSprite z:1000 tag:kTagScoreSprite];
    
    // 점수를 표시할 레이블(CCLabel)을 만듭니다.
    // 처음에 보일 스트링으로 Score: 0000을 사용합니다.
    // 폰트는 Arial을 사용하며 폰트의 크기를 22로 정합니다.
    NSString *scoreString = [NSString stringWithFormat:@" %05d", gameScore];
    //CCLabelTTF *label=[CCLabelTTF labelWithString:scoreString fontName:@"American Typewriter" fontSize:18];
    CCLabelBMFont *label = [CCLabelBMFont labelWithString:scoreString fntFile:@"futura-48.fnt"];
    label.scale = 0.35;                        
    label.color = ccc3(10, 20, 210);
    self.scoreLabel = label;
    self.scoreLabel.anchorPoint = CGPointZero;
    self.scoreLabel.position = ccp(90, 460);
    [self addChild:self.scoreLabel z:1000 tag:kTagScoreLabel];
    [label release];
    
    CCSprite *lifeSprite = [CCSprite spriteWithFile:@"life.png"];
    lifeSprite.anchorPoint = CGPointZero;
    lifeSprite.position = ccp(240, 445);
    [self addChild:lifeSprite z:1000 tag:kTagLifeSprite];
    
    NSString *lifeString = [NSString stringWithFormat:@": %2d", numOfLife];
    label= [CCLabelBMFont labelWithString:lifeString fntFile:@"futura-48.fnt"];
    label.color = ccc3(10, 20, 210);
    label.scale = 0.35;
    self.lifeLabel = label;
    self.lifeLabel.anchorPoint = CGPointZero;
    self.lifeLabel.position = ccp(275, 460);
    [self addChild:self.lifeLabel z:1000 tag:kTagLifeLabel];
    
    [label release];
}

-(void) createBombDownAnimation
{
    [[CCSpriteFrameCache sharedSpriteFrameCache] 
     addSpriteFramesWithFile:@"Bomb.plist"];
    
    NSMutableArray *bombFrames = [NSMutableArray array];
    for(NSInteger idx = 1; idx < 8; idx++) {
        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"bomb%04d.png",idx]];
        [bombFrames addObject:frame];
    }
    
    CCAnimation *bombDownAnimation = [CCAnimation animationWithFrames:bombFrames
                                                              delay:0.07];
    bombDownAnimate = [[CCAnimate alloc] initWithAnimation:bombDownAnimation 
                                      restoreOriginalFrame:NO];
}

- (void)createCloud {
    id enterRight	= [CCMoveTo actionWithDuration:20 position:ccp(0, 310)];
    id enterRight2	= [CCMoveTo actionWithDuration:20 position:ccp(0, 310)];
    id exitLeft		= [CCMoveTo actionWithDuration:20 position:ccp(-FRONT_CLOUD_SIZE, 310)];
    id exitLeft2	= [CCMoveTo actionWithDuration:20 position:ccp(-FRONT_CLOUD_SIZE, 310)];
    id reset		= [CCMoveTo actionWithDuration:0  position:ccp( FRONT_CLOUD_SIZE, 310)];
    id reset2		= [CCMoveTo actionWithDuration:0  position:ccp( FRONT_CLOUD_SIZE, 310)];
    id seq1			= [CCSequence actions: exitLeft, reset, enterRight, nil];
    id seq2			= [CCSequence actions: enterRight2, exitLeft2, reset2, nil];
    
    CCSprite *spCloud1 = [CCSprite spriteWithFile:@"cloud_front.png"];
    [spCloud1 setAnchorPoint:ccp(0,1)];
    [spCloud1.texture setAliasTexParameters];
    [spCloud1 setPosition:ccp(0, 310)];
    [spCloud1 runAction:[CCRepeatForever actionWithAction:seq1]];
    [self addChild:spCloud1 z:1 ];
    
    CCSprite *spCloud2 = [CCSprite spriteWithFile:@"cloud_front.png"];
    [spCloud2 setAnchorPoint:ccp(0,1)];
    [spCloud2.texture setAliasTexParameters];
    [spCloud2 setPosition:ccp(FRONT_CLOUD_SIZE, 310)];
    [spCloud2 runAction:[CCRepeatForever actionWithAction:seq2]];
    [self addChild:spCloud2 z:1 ];
}

- (void)createCloudWithSize:(int)imgSize top:(int)imgTop fileName:(NSString*)fileName interval:(int)interval z:(int)z {
    id enterRight	= [CCMoveTo actionWithDuration:interval position:ccp(0, imgTop)];
    id enterRight2	= [CCMoveTo actionWithDuration:interval position:ccp(0, imgTop)];
    id exitLeft		= [CCMoveTo actionWithDuration:interval position:ccp(-imgSize, imgTop)];
    id exitLeft2	= [CCMoveTo actionWithDuration:interval position:ccp(-imgSize, imgTop)];
    id reset		= [CCMoveTo actionWithDuration:0  position:ccp( imgSize, imgTop)];
    id reset2		= [CCMoveTo actionWithDuration:0  position:ccp( imgSize, imgTop)];
    id seq1			= [CCSequence actions: exitLeft, reset, enterRight, nil];
    id seq2			= [CCSequence actions: enterRight2, exitLeft2, reset2, nil];
    
    CCSprite *spCloud1 = [CCSprite spriteWithFile:fileName];
    [spCloud1 setAnchorPoint:ccp(0,1)];
    [spCloud1.texture setAliasTexParameters];
    [spCloud1 setPosition:ccp(0, imgTop)];
    [spCloud1 runAction:[CCRepeatForever actionWithAction:seq1]];
    [self addChild:spCloud1 z:z ];
    
    CCSprite *spCloud2 = [CCSprite spriteWithFile:fileName];
    [spCloud2 setAnchorPoint:ccp(0,1)];
    [spCloud2.texture setAliasTexParameters];
    [spCloud2 setPosition:ccp(imgSize, imgTop)];
    [spCloud2 runAction:[CCRepeatForever actionWithAction:seq2]];
    [self addChild:spCloud2 z:z ];
}

-(void)createLogoExplosion
{
    [[CCSpriteFrameCache sharedSpriteFrameCache] 
        addSpriteFramesWithFile:@"EffectAndLogo.plist"];
    
    logoExplosion = [[CCSprite alloc] init];
    [self addChild:logoExplosion z:500];    
    
    NSMutableArray *frames = [NSMutableArray array];
    for(NSInteger idx = 1; idx < 8; idx++) {
        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"Effect%04d.png",idx]];
        [frames addObject:frame];
    }
    
    CCAnimation *bubbleAnimation = [CCAnimation animationWithFrames:frames
                                                              delay:0.07];
    logoExplosionAnimate = [[CCAnimate alloc] initWithAnimation:bubbleAnimation restoreOriginalFrame:NO];

    [[CCSpriteFrameCache sharedSpriteFrameCache] 
     addSpriteFramesWithFile:@"EnemySheet.plist"];
    
    fakeLogoExplosion = [[CCSprite alloc] init];
    [self addChild:fakeLogoExplosion z:500];    
    
    frames = [NSMutableArray array];
    for(NSInteger idx = 1; idx < 8; idx++) {
        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"EnemyEffect%04d.png",idx]];
        [frames addObject:frame];
    }
    
    bubbleAnimation = [CCAnimation animationWithFrames:frames
                                                 delay:0.07];
    fakeLogoExplosionAnimate = [[CCAnimate alloc] initWithAnimation:bubbleAnimation restoreOriginalFrame:NO];
}

-(void)createBombSmoke
{
    [[CCSpriteFrameCache sharedSpriteFrameCache] 
            addSpriteFramesWithFile:@"gun.plist"];
    
    bombSmoke = [[CCSprite alloc] init];
    [self addChild:bombSmoke z:500];    
    
    NSMutableArray *smokeFrames = [NSMutableArray array];
    for(NSInteger idx = 1; idx < 10; idx++) {
        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"shotgun_smoke2_%04d.png",idx]];
        [smokeFrames addObject:frame];
    }
        
    CCAnimation *smokeAnimation = [CCAnimation animationWithFrames:smokeFrames
                                                 delay:0.07];

    
    smokeAnimate = [[CCAnimate alloc] initWithAnimation:smokeAnimation restoreOriginalFrame:NO];
}

-(void)showBombEffect:(CGPoint) point
{
    // smokeAnimate가 nil이면 smokeAnimate를 생성한다.
    if(smokeAnimate == nil)
        [self createBombSmoke];
        
    bombSmoke.position = point;
    
    if (![smokeAnimate isDone]) 
        [bombSmoke stopAction:smokeAnimate];  
    [bombSmoke runAction:smokeAnimate];
    [sae playEffect:@"handgun_fire.wav"];
}

// 폭탄에 부딪힐때의 blink 시간과 횟수
#define LIFE_LOST_BLINK_DURATION    0.9
#define LIFE_LOST_BLINK_COUNT       3

-(void) decreaseLife
{
    [self.message showMessage:LIFE_MINUS_MESSAGE];
    
    numOfLife = numOfLife - 1;
    if ( numOfLife <= 0)
        [self gameOver];
    else {
        player.playerHP = 100;
        [self updateEnergyBar];
        
        // 폭탄에 맞으면 캐릭터는 3번 깜박인다. - blink 효과
        id blinkAction = [CCBlink actionWithDuration:LIFE_LOST_BLINK_DURATION 
                                              blinks:LIFE_LOST_BLINK_COUNT];
        [self.player runAction:blinkAction];
    }
    
    [self updateLifeLabel];
}

-(void)showBusanLogoEffect:(CGPoint) point
{
    if(logoExplosionAnimate == nil)
        [self createLogoExplosion];
    
    logoExplosion.position = point;
    
    if (![logoExplosionAnimate isDone]) 
        [logoExplosion stopAction:logoExplosionAnimate];  
    [logoExplosion runAction:logoExplosionAnimate];
}

// 가짜 로고에 부딪힐때의 blink 시간과 횟수
#define FAKE_LOGO_BLINK_DURATION    0.2
#define FAKE_LOGO_BLINK_COUNT       1

-(void)showFakeLogoEffect:(CGPoint) point
{
    if(fakeLogoExplosionAnimate == nil)
        [self createLogoExplosion];
    
    fakeLogoExplosion.position = point;
    
    // 가짜로고에 맞으면 blink 효과를 한번 준다
    id blinkAction = [CCBlink actionWithDuration:FAKE_LOGO_BLINK_DURATION 
                                          blinks:FAKE_LOGO_BLINK_COUNT];
    [self.player runAction:blinkAction];
    
    if (![fakeLogoExplosionAnimate isDone]) 
        [fakeLogoExplosion stopAction:fakeLogoExplosionAnimate];  
    [fakeLogoExplosion runAction:fakeLogoExplosionAnimate];
}

- (void) showComboMessage
{
    CGPoint randomPoint = ccp(clampRandomNumber(100,250), clampRandomNumber(200,400));
    
    if( comboCount == 3 ) {
        [message showMessage:COMBO3_MESSAGE atPosition:randomPoint];
    }
    else if ( comboCount > 3 ){
        [message showMessage:COMBO_COMBO_MESSAGE atPosition:randomPoint];
        comboCount = 0; // reset Combo Count
    }
    
}
#define BS_LOGO_HP_VALUE    (10)
#define BS_LOGO_VALUE       (100)
#define BS_SUB_LOGO_VALUE   (10)

-(void) getBSBonus
{
    [self showComboMessage];
    [sae playEffect:@"wav16.wav"];
    
    gameScore += BS_LOGO_VALUE;
    player.playerHP += BS_SUB_LOGO_VALUE * 2;
    if( player.playerHP > 100 )
        player.playerHP = 100;
    
    [self updateEnergyBar];
    [self updateScore];
}

-(void) getBSSubBonus
{
    [self showComboMessage];
    [sae playEffect:@"wav16.wav"];

    gameScore += BS_SUB_LOGO_VALUE;
    [self updateScore];
}

-(void) getFakeLogo
{
    [sae playEffect:@"bellOing.m4a"];
    
    if (gameScore <= 0) // 점수가 0점 이하이면 업데이트 안함 
        return;
    
    gameScore -= BS_SUB_LOGO_VALUE;
    player.playerHP -= BS_SUB_LOGO_VALUE;
    
    // playerHP가 -가 되면 Life가 줄어들고 Life도 1감소한다
    if (player.playerHP < 0)  {
        player.playerHP = 100;
        [self decreaseLife];
        [message showMessage:LIFE_MINUS_MESSAGE];
    }
    
    [self updateEnergyBar];
    [self updateScore];
}

-(void) countLifeAndScoreWith:(NSArray *)collisionArray
{
    for (Logo *aLogo in collisionArray) {
        switch (aLogo.tag) {
            case kTagBomb :
                comboCount = 0;     // reset Combo Count
                // life가 감소함
                [self decreaseLife];
                [self showBombEffect:aLogo.position];
                break;
            case kTagBusanLogo :
                comboCount++;
                [self showBusanLogoEffect:aLogo.position];
                [self getBSBonus];
                break;
            case kTagBusanSubLogo:
                comboCount++;
                [self getBSSubBonus];
                [self showBusanLogoEffect:aLogo.position];
                break;
            case kTagFakeLogo:
                comboCount = 0;     // reset Combo Count
                [self showFakeLogoEffect:aLogo.position];
                [self getFakeLogo];
                break;
            default:
                break;
        }
    }
}

#define BS_LOGO_MISS_VALUE      (10)
#define BS_SUB_LOGO_MISS_VALUE  (5)

// BusanLogo(경남 로고)를 놓지면 감점..
-(void) missBusanLogo
{
    // 경남 로고를 놓쳤으므로 combo Count가 reset됨
    comboCount = 0; // reset Combo Count
    
    if ( gameScore <= 0)
        return;
    
    gameScore -= BS_LOGO_MISS_VALUE;
    [self updateScore];
}

// BusanSub(부산시 산하지자체 로고)를 놓지면 감점
-(void) missBusanSubLogo
{
    comboCount = 0; // reset Combo Count
    player.playerHP -= BS_SUB_LOGO_MISS_VALUE;
    if ( player.playerHP <= 0) {
        player.playerHP = 100;
        [self decreaseLife];
    }
    
    [self updateEnergyBar];
    if ( gameScore <= 0)
        return;
    
    gameScore -= BS_SUB_LOGO_MISS_VALUE;
    [self updateScore];
}

-(void)animateLogoAndCountScore
{
    CGSize winsize = [[CCDirector sharedDirector] winSize];
    const int toBeDeletedArraySize = [[logoGroupNode children] count]+1;
    
    // 로고들 중에서 화면을 벗어난 것들이 있는지 있으면 그룹 노드에서 삭제함
    NSMutableArray *toBeDeletedLogos = [[NSMutableArray alloc] 
                                        initWithCapacity:toBeDeletedArraySize];
    
    for (Logo *aLogo in [logoGroupNode children]) {
        // 로고가 화면 아래로 떨어지고 나면
        if ([aLogo isOutsideWindow:winsize] == YES) {
            switch ( aLogo.tag ) {
                // 부산로고가 떨어지면 penalty
                case kTagBusanLogo:
                    [self missBusanLogo];
                    break;
                // 부산시 산하지자체 로고가 떨어지면 penalty+에너지 바 감소
                case kTagBusanSubLogo:
                    [self missBusanSubLogo];
                    break;
                // 폭탄, 가짜로고의 경우 아무 penalty나 incentive가 없다
                case kTagBomb :
                case kTagFakeLogo:
                default:
                    break;
            }
            // 화면 밖으로 로고가 나가면 toBeDeletedLogos 배열에 넣어서 나중에 삭제 
            [toBeDeletedLogos addObject:aLogo];
        }
    }
    
    if( [player hasCollionWith:logoGroupNode] )
    {
        [self countLifeAndScoreWith:player.collisonLogoArray];
        // 플레이어와 충돌한 로고들은 toBeDeletedLogos에 넣어둔다..
        // 나중에 한꺼번에 제거시키도록 한다.
        [toBeDeletedLogos addObjectsFromArray:player.collisonLogoArray];
    }

    for(Logo *aLogo in toBeDeletedLogos) {
		[logoGroupNode removeChild:aLogo cleanup:NO];
	}
    [toBeDeletedLogos release];
}

-(void)updateScore
{
    // 점수가 - 가 되면 안되요..
    if( gameScore < 0 )  gameScore = 0;
    
    // 점수가 높아질수록 로고 생성 속도는 빨라짐
    if ( gameScore > 3000)
        logoGenInterval = 0.8f;
    else if( gameScore > 6000 )
        logoGenInterval = 0.6f;
    else if( gameScore > 10000 )
        logoGenInterval = 0.4f;
    
    NSString *str = [NSString stringWithFormat:@" %05d", gameScore];
    [self.scoreLabel setString:str];
    
    // 점수를 확대하는 효과
    id scaleAction = [CCSequence actions:
                      [CCScaleTo actionWithDuration:0.1 scale:0.40],
                      [CCScaleTo actionWithDuration:0.1 scale:0.35], nil];
    [self.scoreLabel runAction:scaleAction];
}

-(void)updateLifeLabel
{
    // life가 -가 되면 안되요
    if ( numOfLife < 0)     numOfLife = 0;

    NSString *str = [NSString stringWithFormat:@": %2d", numOfLife];
    [self.lifeLabel setString:str];
    
    id scaleAction = [CCSequence actions:
                      [CCScaleTo actionWithDuration:0.2 scale:0.40],
                      [CCScaleTo actionWithDuration:0.1 scale:0.35], nil];
    
    [self.lifeLabel runAction:scaleAction];
}

-(void) initImageArray
{
    // 임시로 지자체 이미지 대신 휠 배열을 사용하자.
	NSString *busanSubLogoPath = [[NSBundle mainBundle] pathForResource:@"BusanSubLogo"
                                                           ofType:@"plist"];
	NSMutableArray *BusanSubLogoArray = [[NSMutableArray alloc] initWithContentsOfFile:busanSubLogoPath];
	self.subLogoImageArray = BusanSubLogoArray;
    [BusanSubLogoArray release];
    
    // 가짜 지자체 이미지도 여기서 읽도록 한다.
	NSString *fakeLogoPath = [[NSBundle mainBundle] pathForResource:@"FakeLogo"
                                                           ofType:@"plist"];
    NSMutableArray *fakeLogoArray = [[NSMutableArray alloc] initWithContentsOfFile:fakeLogoPath];
    self.fakeLogoImageArray = fakeLogoArray;
    [fakeLogoArray release];
}

-(LOGOTYPE) chooseRandomLogoType
{
    LOGOTYPE aLogoType;
    int randomRange = 20;
    int chooseObj = arc4random() % randomRange;
    
    switch (chooseObj) {
        case 0 :     
        case 1 :        // 10% 확률로 부산 로고
            aLogoType = BusanLogoType;
            break;
        case 2 :
        case 3 :
        case 4 :
        case 5 :        // 20% 확률로 폭탄이 떨어짐
            aLogoType = BombType;
            break;
        case 6 :
        case 7 :
        case 8 :
        case 9 :
        case 10 :
        case 11 :
        case 12 :       // 35% 확률로 가짜 로고
            aLogoType = FakeLogoType;
            break;
        default:        // 35% 확률로 부산시 산하 로고
            aLogoType = BusanSubLogoType;
            break;
    }
        
    return aLogoType;
}

#define CONTENT_OFFSET          (60)
#define NAME_OF_BUSAN_LOGO      (@"Busan")
#define DEFAULT_LOGO_WIDTH      (50)
#define DEFAULT_LOGO_HEIGHT     (50)

-(BusanLogo *)generateBusanLogo
{
    int halfOfLogoWidth = DEFAULT_LOGO_WIDTH, pointX = 100 ;    // default value
	float timeDuration = 0.0f ; // default time duration
    CGSize winsize = [[CCDirector sharedDirector] winSize];

    BusanLogo *aBusanLogo = [[BusanLogo alloc] initWithName:NAME_OF_BUSAN_LOGO];
    [aBusanLogo logoAnimationWithName:NAME_OF_BUSAN_LOGO];
    // 부산시 로고는 크기가 변하면서, 좌우로 움직이며 떨어진
    [aBusanLogo scaleUpDown];
    [aBusanLogo leftRightMoveAction];
    
    halfOfLogoWidth = aBusanLogo.contentSize.width/2.0;
    // 화면내에 랜덤하게 경남로고가 나타나도록 함 
    pointX = clampRandomNumber(halfOfLogoWidth, winsize.width - halfOfLogoWidth);
	aBusanLogo.position = ccp(pointX, winsize.height + DEFAULT_LOGO_HEIGHT);
    
    // aBusanLogo의 목적지 Y값은 content크기보다 더 아래쪽으로 두어
    // 사라졌는지 검사가 쉽도록 한다
    float targetPointY = -aBusanLogo.contentSize.height-CONTENT_OFFSET;
    // 로고가 생성되어 떨어지는 시간..
	timeDuration = clampRandomNumber(100, 400)/50.0f;
	id actionMove=[CCMoveTo actionWithDuration:timeDuration
                                      position:ccp(aBusanLogo.position.x,targetPointY)];
	[aBusanLogo runAction:[CCSequence actions:actionMove, nil]];
    // logoGroupNode에 FakeLogo를 추가하고 애니메이션 시킨다.
    [logoGroupNode addChild:aBusanLogo z:300 tag:kTagBusanLogo];

    return aBusanLogo;
}

-(void)generateBusanSubLogo
{
    int randLogoIndex = arc4random() % [self.subLogoImageArray count];
    int halfOfLogoWidth = DEFAULT_LOGO_WIDTH, pointX = 100 ;    // default value
	float timeDuration = 0.0f ;
    CGSize winsize = [[CCDirector sharedDirector] winSize];
    
    // plist로 부터 지자체의 로고를 읽어서 랜덤하게 그려주도록 하지...
    NSString *nameOfSubLogo = [self.subLogoImageArray objectAtIndex:randLogoIndex];
    
    BusanSubLogo *aSubLogo = [[BusanSubLogo alloc] initWithName:nameOfSubLogo];
    [aSubLogo logoAnimationWithName:nameOfSubLogo];
    // 좌우로 왔다갔다 하면서 떨어짐
    [aSubLogo leftRightMoveAction];
    
    halfOfLogoWidth = aSubLogo.contentSize.width/2.0;
    pointX = clampRandomNumber(halfOfLogoWidth, winsize.width - halfOfLogoWidth);
	aSubLogo.position = ccp(pointX, winsize.height + DEFAULT_LOGO_HEIGHT);
    
	// logo의 목적지 Y값은 content크기보다 더 아래쪽으로 두어
    // 사라졌는지 검사가 쉽도록 한다
    float targetPointY = -aSubLogo.contentSize.height-CONTENT_OFFSET;
    // 로고가 생성되어 떨어지는 시간..
	timeDuration = clampRandomNumber(100, 400)/50.0f;
	id actionMove = [CCMoveTo actionWithDuration:timeDuration 
                                        position:ccp(aSubLogo.position.x,targetPointY)];
	[aSubLogo runAction:[CCSequence actions:actionMove, nil]];
    [logoGroupNode addChild:aSubLogo z:300 tag:kTagBusanSubLogo];
}

-(Bomb *)generateBomb
{
    int halfOfLogoWidth = DEFAULT_LOGO_WIDTH, pointX = 100 ;    // default value
	float timeDuration = 0.0f ;
    CGSize winsize = [[CCDirector sharedDirector] winSize];
    
    Bomb *aBomb = [Bomb spriteWithFile:@"bomb0001.png"];
    // 떨어지면서 회전하는 액션
    
    [aBomb logoAction];
    if ( bombDownAnimate != nil) {
        CCRepeatForever *repeatAction = [CCRepeatForever actionWithAction:bombDownAnimate];
        [aBomb runAction:repeatAction];
    }
    halfOfLogoWidth = aBomb.contentSize.width/2.0;
    pointX = clampRandomNumber(halfOfLogoWidth, winsize.width - halfOfLogoWidth);
	aBomb.position = ccp(pointX, winsize.height + DEFAULT_LOGO_HEIGHT);
    
    // aBomb의 목적지 Y값은 content크기보다 더 아래쪽으로 두어
    // 사라졌는지 검사가 쉽도록 한다
    float targetPointY = -aBomb.contentSize.height-CONTENT_OFFSET;
    // 로고가 생성되어 떨어지는 시간..
	timeDuration = clampRandomNumber(100, 400)/50.0f;
	id actionMove=[CCMoveTo actionWithDuration:timeDuration
                                      position:ccp(aBomb.position.x,targetPointY)];
	[aBomb runAction:[CCSequence actions:actionMove, nil]];
    // logoGroupNode에 FakeLogo를 추가하고 애니메이션 시킨다.
    [logoGroupNode addChild:aBomb z:300 tag:kTagBomb];
    
    return aBomb;
}

-(void)generateFakeLogo
{
    int randLogoIndex = arc4random() % [self.fakeLogoImageArray count];
    int halfOfLogoWidth = DEFAULT_LOGO_WIDTH, pointX = 100 ;    // default value
	float timeDuration = 0.0f ;
    CGSize winsize = [[CCDirector sharedDirector] winSize];
    
    NSString *nameOfFakeLogo = [self.fakeLogoImageArray objectAtIndex:randLogoIndex];
    FakeLogo *aFakeLogo = [[FakeLogo alloc] initWithName:nameOfFakeLogo];
    [aFakeLogo logoAnimationWithName:nameOfFakeLogo];
    
    // 떨어지면서 회전하는 액션
    [aFakeLogo leftRightMoveAction];
    halfOfLogoWidth = aFakeLogo.contentSize.width/2.0;
    pointX = clampRandomNumber(halfOfLogoWidth, winsize.width - halfOfLogoWidth);
	aFakeLogo.position = ccp(pointX, winsize.height + DEFAULT_LOGO_HEIGHT);
    
    // fakeLogo의 목적지 Y값은 content크기보다 더 아래쪽으로 두어
    // 사라졌는지 검사가 쉽도록 한다
    float targetPointY = -aFakeLogo.contentSize.height-CONTENT_OFFSET;
    // 로고가 생성되어 떨어지는 시간..
	timeDuration = clampRandomNumber(100, 400)/50.0f;
	id actionMove=[CCMoveTo actionWithDuration:timeDuration
                                      position:ccp(aFakeLogo.position.x,targetPointY)];
	[aFakeLogo runAction:[CCSequence actions:actionMove, nil]];
    // logoGroupNode에 FakeLogo를 추가하고 애니메이션 시킨다.
    [logoGroupNode addChild:aFakeLogo z:300 tag:kTagFakeLogo];
    
    //NSLog(@"logoGroupNode count = %d", [[logoGroupNode children] count]);
    [aFakeLogo release];
}

- (void) generateLogoAndFakeLogo
{
    switch ([self chooseRandomLogoType]) {
        case BusanLogoType :
            [self generateBusanLogo];
            break;
        case BusanSubLogoType :
            [self generateBusanSubLogo];
            break;
        case BombType:
            [self generateBomb];
            break;
        case FakeLogoType :
            [self generateFakeLogo];
            break;
        default:
            break;
    }
}	

#pragma mark Accelerometer Input

#define DEFAULT_DECELERATION    (0.4f)
#define DEFAULT_SENSITIVITY     (6.0F)
#define MAX_VELOCITY            (200)

-(void) accelerometer:(UIAccelerometer *)accelerometer 
        didAccelerate:(UIAcceleration *)acceleration
{	
	// 현재 가속도계의 가속에 따라 속도 조절
	playerVelocity.x = playerVelocity.x * DEFAULT_DECELERATION + acceleration.x * DEFAULT_SENSITIVITY;
	
	// 플레이어 스프라이트 최대 속도 제한
	if (playerVelocity.x > MAX_VELOCITY)
		playerVelocity.x = MAX_VELOCITY;
	else if (playerVelocity.x < -MAX_VELOCITY)
		playerVelocity.x = -MAX_VELOCITY;
}

#pragma mark update

-(void) update:(ccTime)delta
{
	// player.position.x를 임시 변수로 설정
	CGPoint pos = player.position;
    pos.x += playerVelocity.x;
    
	// 플레이어 화면밖으로 이동하면 안됨
	// 플레이어 스프라이트의 위치는 이미지의 중심에 있음
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	float leftBorderLimit = 20;
	float rightBorderLimit = screenSize.width+20;
	
	// 이미지 크기와 기준에 따라 화면밖으로 이동 못하게 설정
	if (pos.x < leftBorderLimit)
	{
		pos.x = leftBorderLimit;
		// 가속도가 제로이나 속도가 남아있을때 가장자리를 향해 가속함으로 제어 
		playerVelocity = CGPointZero;
	}
	else if (pos.x > rightBorderLimit)
	{
		pos.x = rightBorderLimit;
		// 가속도가 제로이나 속도가 남아있을때 가장자리를 향해 가속함으로 제어
		playerVelocity = CGPointZero;
	}
	
	player.position = pos;
}

// The game is played only using the accelerometer. The screen may go dark while playing because the player
// won't touch the screen. This method allows the screensaver to be disabled during gameplay.
-(void) setScreenSaverEnabled:(bool)enabled
{
	UIApplication *thisApp = [UIApplication sharedApplication];
	thisApp.idleTimerDisabled = !enabled;
}

-(void)gotoGameCloseLayer
{	
    [SceneManager goGameOver];
}

#pragma mark gameOver

-(void) gameOver
{
    //[player setVisible:NO]; // 게임이 끝나서 플레이어는 보이지 않음
    id fadeAction = [CCFadeOut actionWithDuration:0.2];
    [self.player runAction:fadeAction];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.gameScore = gameScore;
    
    // 모든 로고에 대하여 액션 중지
    for (Logo *aLogo in [logoGroupNode children])
        [aLogo stopAllActions];
    
	// 사용 중인 schdule을 모두 끕니다.
	[self unschedule:@selector(generateLogoAndFakeLogo)];
    [self unschedule:@selector(animateLogoAndCountScore)];
    [self unscheduleUpdate];    // 플레이어의 동작 중지
	
	// 배경음악 종료
	[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
	
    // 더 이상 사용되지않는 그래픽 캐시를 지웁니다.
	[[CCTextureCache sharedTextureCache] removeUnusedTextures];
	
    [self performSelector:@selector(gotoGameCloseLayer) 
			   withObject:nil 
               afterDelay:4.1];
}

@end
