//
//  SIImageSequenceView.h
//
//  Created by Kevin Cao on 12-6-25.
//  Copyright (c) 2012年 Sumi Interactive. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "EagleGuestureImageView.h"


#define MAXROAMSTEP 300
#define STARTSTEP 40

typedef NS_ENUM(NSUInteger,RoamVelocityStatus)  //漫游方式
{
    RoamVelocityStatusSpeedUp=0, //加速
    RoamVelocityStatusUniformSpeed //匀速
};


//enum RoamVelocityStatus{
//    RoamVelocityStatusSpeedUp=0, //加速
//    RoamVelocityStatusUniformSpeed //匀速
//    
//};
//typedef enum RoamVelocityStatus RoamVelocityStatus;

typedef NS_ENUM(NSUInteger, SIImageSequenceViewState) //序列状态
{
    SIImageSequenceViewStateIdling = 0,
	SIImageSequenceViewStateInteracting,
	SIImageSequenceViewStateDecelerating,
	SIImageSequenceViewStateSpinning,
	SIImageSequenceViewStateFreeSpinning
};

//enum SIImageSequenceViewState{
//    SIImageSequenceViewStateIdling = 0,
//	SIImageSequenceViewStateInteracting,
//	SIImageSequenceViewStateDecelerating,
//	SIImageSequenceViewStateSpinning,
//	SIImageSequenceViewStateFreeSpinning
//    
//};
//typedef enum SIImageSequenceViewState SIImageSequenceViewState;


typedef NS_ENUM(NSUInteger, SpinDirection) //播放次序
{
    spinDirectionPositive=1,
    spinDirectionNegative=-1
};

//enum SpinDirection{
//    spinDirectionPositive=1,
//    spinDirectionNegative=-1
//    
//};
//typedef enum SpinDirection SpinDirection;

typedef NS_ENUM(NSUInteger, CoordinateDirection)//坐标方向
{
    coordinateDirectionX=0,
    coordinateDirectionY,
};
//
//enum CoordinateDirection{
//    coordinateDirectionX=0,
//    coordinateDirectionY,
//    
//};
//typedef enum SpinDirection CoordinateDirection;

@protocol SIImageSequenceViewDelegate;

@interface SIImageSequenceView : EagleGuestureImageView


@property(nonatomic,retain)UIView *hotView; //热区

@property SpinDirection                 spinDirection; //播放次序
@property CoordinateDirection           coordinateDirection; //坐标轴
@property int                           preOffsetFrameIndex; //前一张图片 default is 0
@property BOOL                          roam;//是否漫游
@property (retain,nonatomic) NSMutableArray *Images;//使用图片数组
@property BOOL useImageArray; //是否使用图片数组
@property RoamVelocityStatus roamVelocityStatus;//漫游速度方式
//@property


@property (nonatomic, strong) NSBundle *bundle;
@property (nonatomic, copy) NSString   *pathFormat;									// required

@property (nonatomic, assign) NSUInteger               frameCount;					// default is 36
@property (nonatomic, assign) NSInteger                frameIndex;					// default is 0
@property (nonatomic, assign, getter = isLooping) BOOL looping;						// default is YES
@property (nonatomic, assign) float                    friction;				// default is 0.8

@property (nonatomic, readonly) SIImageSequenceViewState      state;				// default is SIImageSequenceViewStateIdling
@property (nonatomic, readonly, getter = isFreeSpinning) BOOL freeSpinning;

@property (nonatomic, retain) IBOutlet id <SIImageSequenceViewDelegate> delegate;

-(id)initWithFrame:(CGRect)frame
        PathFormat:(NSString *)pathFormat
        frameCount:(NSInteger)frameCount
           looping:(BOOL)looping
              roam:(BOOL)roam
        imageArray:(BOOL)useImageArray
     SpinDirection:(SpinDirection)spinDirection
CoordinateDirection:(CoordinateDirection)coordinateDirection;


-(id)initWithFrame:(CGRect)frame
        PathFormat:(NSString *)pathFormat
        frameCount:(NSInteger)frameCount
           looping:(BOOL)looping
              roam:(BOOL)roam
roamVelocityStatus:(RoamVelocityStatus)roamVelocityStatus  //漫游速度方式
        imageArray:(BOOL)useImageArray
     SpinDirection:(SpinDirection)spinDirection
CoordinateDirection:(CoordinateDirection)coordinateDirection;

- (id)initWithPathFormat:(NSString *)pathFormat bundle:(NSBundle *)bundle;

- (void)spinToFrameIndex:(NSInteger)frameIndex speed:(NSInteger)speed completion:(void (^)(BOOL finished))completion;
- (void)startUseImageArrayFreeSpinWithSpeed:(NSInteger)speed;
- (void)startFreeSpinWithSpeed:(NSInteger)speed;
- (void)stopFreeSpin;

// eagle add
-(float)changeValueInView:(CGPoint)point;//返回改变值

-(void)reset;//重置

@end

@protocol SIImageSequenceViewDelegate <NSObject>

@optional
- (void)imageSequenceView:(SIImageSequenceView *)imageSequenceView didChangeState:(SIImageSequenceViewState)state;

-(void)imageDidChange:(NSInteger)index;

@end
