//
//  SIImageSequenceView.m
//
//  Created by Kevin Cao on 12-6-25.
//  Copyright (c) 2012年 Sumi Interactive. All rights reserved.
//

#import "SIImageSequenceView.h"
#import <QuartzCore/QuartzCore.h>

static float map(float value, float fromMin, float fromMax, float toMin, float toMax)
{
	return toMin + (value - fromMin) / (fromMax - fromMin) * (toMax - toMin);
}

@interface SIImageSequenceView ()
{
	NSInteger _originFrameIndex;
	NSInteger _targetFrameIndex;
	NSInteger _freeSpinSpeed;
	float _speed;
	CADisplayLink *_displayLink;
	BOOL _isDirty;
	BOOL _isRendering;
	void (^_completion)(BOOL finished);
}

@end

@implementation SIImageSequenceView

//- (void)dealloc
//{
////    [_hotView release];
//    _hotView=nil;
//    
////    [_Images release];
//    _Images=nil;
//    
//    self.delegate=nil;
//    
////    [_bundle release];
//    _bundle=nil;
//    
////    [_pathFormat release];
//    _pathFormat=nil;
//
//    [super dealloc];
//
//}

#pragma mark
#pragma mark eagle init method
-(id)initWithFrame:(CGRect)frame
        PathFormat:(NSString *)pathFormat
        frameCount:(NSInteger)frameCount
           looping:(BOOL)looping
              roam:(BOOL)roam
        imageArray:(BOOL)useImageArray
     SpinDirection:(SpinDirection)spinDirection
CoordinateDirection:(CoordinateDirection)coordinateDirection;
{
    self=[super initWithFrame:frame];
    if (self) {
        self.pathFormat=pathFormat;
        self.frameCount=frameCount;
        if (useImageArray) {
            [self performSelectorInBackground:@selector(initImagesArray) withObject:nil];
        }
        self.useImageArray=useImageArray;
        self.looping=looping;
        self.roam=roam;
        self.spinDirection=spinDirection;
        self.coordinateDirection=coordinateDirection;
        [self commonInitEagle];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame
        PathFormat:(NSString *)pathFormat
        frameCount:(NSInteger)frameCount
           looping:(BOOL)looping
              roam:(BOOL)roam
roamVelocityStatus:(RoamVelocityStatus)roamVelocityStatus  //漫游速度方式
        imageArray:(BOOL)useImageArray
     SpinDirection:(SpinDirection)spinDirection
CoordinateDirection:(CoordinateDirection)coordinateDirection;
{
    self=[super initWithFrame:frame];
    if (self) {
        self.pathFormat=pathFormat;
        self.frameCount=frameCount;
        if (useImageArray) {
            [self performSelectorInBackground:@selector(initImagesArray) withObject:nil];
        }
        self.useImageArray=useImageArray;
        self.looping=looping;
        self.roam=roam;
        self.spinDirection=spinDirection;
        self.coordinateDirection=coordinateDirection;
        self.roamVelocityStatus=roamVelocityStatus;
        [self commonInitEagle];
    }
    return self;

}

#pragma mark
#pragma mark init path format
- (id)initWithPathFormat:(NSString *)pathFormat bundle:(NSBundle *)bundle
{
    self = [super initWithImage:nil];
    if (self) {
        self.bundle = bundle;
        self.pathFormat = pathFormat;
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self commonInit];
	}
	return self;
}

-(void)initImagesArray;
{
    NSBundle *bundle = _bundle;
	if (!bundle) {
		bundle = [NSBundle mainBundle];
	}
    _Images=[[NSMutableArray alloc] initWithCapacity:10];
    for (int i=0; i<self.frameCount; i++) {
        NSString *path=[bundle pathForResource:[NSString stringWithFormat:_pathFormat, i] ofType:nil];
//        UIImage *image = [[UIImage alloc] initWithContentsOfFile:path];
//        [_Images addObject:image];
//        [image release];
        [_Images addObject:[UIImage imageWithContentsOfFile:path]];
//        NSLog(@" %d image %@",i,image);
    }
}


- (void)commonInit
{
    self.userInteractionEnabled = YES;
	UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHandler:)];
    [self addGestureRecognizer:recognizer];
//    [recognizer release];
//	_looping = NO;
	_friction = 0.8;
//cos(<#double#>)
//	_frameCount = 60;
	_state = SIImageSequenceViewStateIdling;
}

- (void)commonInitEagle;
{
//    NSLog(@"commonInitEagle self.useImageArray %d",self.useImageArray);
    self.userInteractionEnabled = YES;
    _hotView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 800, 600)];
    _hotView.center=CGPointMake(512, 384);
//    _hotView.backgroundColor=[UIColor redColor];
    
    UIPanGestureRecognizer *recognizer;
    if (self.roam) //漫游方式
    {
        recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panRoam:)];
    }
    else //非漫游方式
    {
        if (self.useImageArray)
        {
            recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panUseImageArray:)];
        }
        else
        {
        recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHandler:)];
        }
        
    }
    
    [_hotView addGestureRecognizer:recognizer];
    
//    [recognizer release];
    [self addSubview:_hotView];
    //	_looping = NO;
	_friction = 0.8;
    //	_frameCount = 60;
	_state = SIImageSequenceViewStateIdling;
}

#pragma mark - Override

- (void)willMoveToSuperview:(UIView *)newSuperview
{
	if (nil == newSuperview) {
		if (_completion) {
			_completion(NO);
			_completion = nil;
		}
		[self setState:SIImageSequenceViewStateIdling];
		[self stopRendering];
	}
}

#pragma mark - Setters

- (void)setBundle:(NSBundle *)bundle
{
	_bundle = bundle;
	[self invalidate];
}

- (void)setPathFormat:(NSString *)pathFormat
{
	_pathFormat = pathFormat;
	[self invalidate];
}

- (void)setFrameIndex:(NSInteger)frameIndex
{
	[self setFrameIndex:frameIndex immediately:NO];
}

#pragma mark - Public

- (void)spinToFrameIndex:(NSInteger)frameIndex speed:(NSInteger)speed completion:(void (^)(BOOL))completion
{
	_targetFrameIndex = [self mappedFrameIndex:frameIndex];
	if (_targetFrameIndex == _frameIndex) {
		if (completion) {
			completion(YES);
		}
		return;
	}
	_speed = speed;
	_completion = [completion copy];
	[self setState:SIImageSequenceViewStateSpinning];
	[self startRendering];
}

- (void)startFreeSpinWithSpeed:(NSInteger)speed
{
	_freeSpinning = YES;
	_freeSpinSpeed = _speed = speed;
	[self setState:SIImageSequenceViewStateFreeSpinning];
	[self startRendering];
}

- (void)startUseImageArrayFreeSpinWithSpeed:(NSInteger)speed
{
//    NSLog(@"startUseImageArrayFreeSpinWithSpeed");
	_freeSpinning = YES;
	_freeSpinSpeed = _speed = speed;
	[self setState:SIImageSequenceViewStateFreeSpinning];
	[self startRenderingUseImageArray];
}

- (void)stopFreeSpin
{
	if (_state != SIImageSequenceViewStateFreeSpinning) {
		return;
	}
	_freeSpinning = NO;
	[self pauseRendering];
	[self setState:SIImageSequenceViewStateIdling];
}

#pragma mark - Private

#pragma mark
#pragma mark handle pan recognizer
- (void)panHandler:(UIPanGestureRecognizer *)recognizer
{
//	CGPoint translation = [recognizer translationInView:self];
    CGPoint translation = [recognizer translationInView:_hotView];
//    NSLog(@"translation point %@",NSStringFromCGPoint(translation));
//	NSLog(@"translationpoint %@",NSStringFromCGPoint(translation));
	switch (recognizer.state) {
		case UIGestureRecognizerStateBegan:
		{
			_originFrameIndex = _frameIndex;
			_speed = 0;
            _preOffsetFrameIndex=0;
			if (_completion) {
				_completion(NO);
				_completion = nil;
			}
			[self pauseRendering];
			[self setState:SIImageSequenceViewStateInteracting];
			break;
		}
		case UIGestureRecognizerStateChanged:
		{
            [self stopFreeSpin];
            float changeValue=[self changeValueInView:translation];
//			NSInteger offsetFrameIndex = roundf(map(fabsf(translation.x), 0, self.bounds.size.width, 0, self.frameCount)) * (translation.x > 0 ? 1 : -1);
//            NSLog(@"changeValue %lf",changeValue);
//            NSLog(@"changeValue%f alldistance%d",[self changeValueInView:translation],[self allDistance]);
            NSInteger offsetFrameIndex = roundf(map(fabsf(changeValue), 0, [self allDistance], 0, self.frameCount)) * (changeValue > 0 ? 1 : -1);

            if (_preOffsetFrameIndex!=offsetFrameIndex) {
//                NSLog(@"panHandler offsetFrameIndex %d _preOffsetFrameIndex%d",offsetFrameIndex,_preOffsetFrameIndex);
               [self setFrameIndex:_originFrameIndex + offsetFrameIndex immediately:YES];
                _preOffsetFrameIndex=offsetFrameIndex;
            }

//            NSLog(@"originFrameIndex %d",_originFrameIndex);
			break;
		}
		case UIGestureRecognizerStateEnded:
		case UIGestureRecognizerStateCancelled:
		{
            [self stopFreeSpin];
//			_speed = [recognizer velocityInView:self].x * .001;
            _speed=[self speedVelocityInView:recognizer];
//            NSLog(@"end speed %f",_speed);
			[self setState:SIImageSequenceViewStateDecelerating];
			[self startRendering];
			break;
		}
		default:
			break;
	}
}

- (void)panUseImageArray:(UIPanGestureRecognizer *)recognizer
{
  
    CGPoint translation = [recognizer translationInView:_hotView];
//    NSLog(@"xxxxxxxxxxxxxxxxxxxxxxxxpanUseImageArray point %@",NSStringFromCGPoint(translation));
	switch (recognizer.state) {
		case UIGestureRecognizerStateBegan:
		{
			_originFrameIndex = _frameIndex;
			_speed = 0;
            _preOffsetFrameIndex=0;
			if (_completion) {
				_completion(NO);
				_completion = nil;
			}
			[self pauseRendering];
			[self setState:SIImageSequenceViewStateInteracting];
			break;
		}
		case UIGestureRecognizerStateChanged:
		{
//             NSLog(@"xxxxxxxxxxxxxxxxxxxxxxxxpanUseImageArray point %@",NSStringFromCGPoint(translation));
//            [self stopFreeSpin];
            float changeValue=[self changeValueInView:translation];
            NSInteger offsetFrameIndex = roundf(map(fabsf(changeValue), 0, [self allDistance], 0, self.frameCount)) * (changeValue > 0 ? 1 : -1);
            
            if (_preOffsetFrameIndex!=offsetFrameIndex) {
                [self setUseImageArrayFrameIndex:_originFrameIndex + offsetFrameIndex immediately:YES];
                _preOffsetFrameIndex=offsetFrameIndex;
            }
			break;
		}
		case UIGestureRecognizerStateEnded:
		case UIGestureRecognizerStateCancelled:
		{
//            [self stopFreeSpin];
            //			_speed = [recognizer velocityInView:self].x * .001;
            _speed=[self speedVelocityInView:recognizer];
//            NSLog(@"end speed %f",_speed);
			[self setState:SIImageSequenceViewStateDecelerating];
			[self startRendering];
			break;
		}
		default:
			break;
	}
}

- (void)panRoam:(UIPanGestureRecognizer *)recognizer
{
//	CGPoint translation = [recognizer translationInView:self];
    CGPoint translation = [recognizer translationInView:_hotView];
    //	NSLog(@"translationpoint %@",NSStringFromCGPoint(translation));
	switch (recognizer.state) {
		case UIGestureRecognizerStateBegan:
		{
			_originFrameIndex = _frameIndex;
			_speed = 0;
            _preOffsetFrameIndex=0;
			if (_completion) {
				_completion(NO);
				_completion = nil;
			}
			[self pauseRendering];
			[self setState:SIImageSequenceViewStateInteracting];
			break;
		}
		case UIGestureRecognizerStateChanged:
		{
//            NSLog(@"vvvvvv %@",NSStringFromCGPoint([recognizer velocityInView:_hotView]));
            
            switch (self.roamVelocityStatus) {
                case RoamVelocityStatusUniformSpeed:
                    [self stopFreeSpin];
                    float changeValue1=[self changeValueInView:translation];
                    if (changeValue1>STARTSTEP) {
                        [self startFreeSpinWithSpeed:1];
                    }
                    else if(changeValue1<-STARTSTEP)
                    {
                        [self startFreeSpinWithSpeed:-1];
                    }
                    
                    break;
                case RoamVelocityStatusSpeedUp:
                default:
                    [self stopFreeSpin];
                    //            [self startFreeSpinWithSpeed:1];
                    
                    NSLog(@"abs [self changeValueInView:translation] %d [self changeValueInView:translation] %f",abs([self changeValueInView:translation]),[self changeValueInView:translation]);
                    
                    float changeValue=[self changeValueInView:translation];
                    if (abs(changeValue)>STARTSTEP) {
                        NSInteger speed=roundf([self changeValueInView:translation]/MAXROAMSTEP);
                        NSLog(@"changevalue %f speed=%d",changeValue,speed);
                        if (changeValue>0) {
                            speed+=1;
                            NSLog(@"add 1");
                        }
                        
                        if (changeValue<0)
                        {
                            speed=speed-1;
                            NSLog(@"sub 1");
                        }
                        [self startFreeSpinWithSpeed:speed];
                        NSLog(@"speed %d",speed);
                    }
                    break;
            }
            

			break;
		}
		case UIGestureRecognizerStateEnded:
		case UIGestureRecognizerStateCancelled:
		{
            [self stopFreeSpin];
			[self setState:SIImageSequenceViewStateDecelerating];
			[self startRendering];
			break;
		}
		default:
			break;
	}
}

#pragma mark
#pragma mark pan velocity
-(float)speedVelocityInView:(UIPanGestureRecognizer*)recognizer;
{
    switch (_spinDirection) {
        case spinDirectionPositive:
//            return [recognizer velocityInView:self].x * .001;
            return [recognizer velocityInView:_hotView].x * .001;
        case spinDirectionNegative:
//            return -[recognizer velocityInView:self].x * .001;
            return -[recognizer velocityInView:_hotView].x * .001;
    }
}

#pragma mark
#pragma mark max slider distance
-(NSInteger)allDistance
{
    switch (_coordinateDirection) {
        case coordinateDirectionX:
//            return self.bounds.size.width;
            return self.hotView.frame.size.width;
        case coordinateDirectionY:
//            return self.bounds.size.height;
            return self.hotView.frame.size.height;
    }
}

#pragma mark
#pragma mark change value
-(float)changeValueInView:(CGPoint)point;
{
    switch (_coordinateDirection) {
        case coordinateDirectionX:
//            NSLog(@"xxxxxxxxxxxxx point.x%f _spinDirection%d  ji%f",point.x,_spinDirection,point.x*_spinDirection);
            return  point.x*[self valueSpinDirection];
//            return  point.x*_spinDirection;
        case coordinateDirectionY:
            return  point.y*[self valueSpinDirection];
//            return  point.y*_spinDirection;
    }
}

-(int)valueSpinDirection
{
    switch (_spinDirection) {
        case spinDirectionNegative:
            return -1;
        case spinDirectionPositive:
            return 1;
    }
}

#pragma mark 
#pragma mark trik
- (void)tick:(CADisplayLink *)displayLink
{
//    NSLog(@"tick");
//	[self setFrameIndex:self.frameIndex + roundf(_speed) immediately:YES];
    [self setRoamFrameIndex:self.frameIndex + roundf(_speed) immediately:YES];
    //    NSLog(@"speed speed %f",_speed);
	switch (_state) {
		case SIImageSequenceViewStateDecelerating:
			_speed *= _friction;
            //            NSLog(@"Decelerating speed %f",_speed);
			if (fabsf(_speed) < 1.0) {
				_speed = 0;
				[self pauseRendering];
				[self didEndDecelerating];
                //                 NSLog(@"fabsf(_speed) < 1.0 speed %f",_speed);
			}
			break;
		case SIImageSequenceViewStateSpinning:
			if (fabsf(_targetFrameIndex - _frameIndex) < fabsf(_speed)) {
				_speed = 0;
				[self setFrameIndex:_targetFrameIndex immediately:YES];
				[self pauseRendering];
				[self didEndSpinning];
			}
			break;
		default:
			break;
	}
    


}

- (void)tickRoam:(CADisplayLink *)displayLink
{
	[self setFrameIndex:self.frameIndex + roundf(_speed) immediately:YES];
//    NSLog(@"speed speed %f",_speed);
	switch (_state) {
		case SIImageSequenceViewStateDecelerating:
			_speed *= _friction;
//            NSLog(@"Decelerating speed %f",_speed);
			if (fabsf(_speed) < 1.0) {
				_speed = 0;
				[self pauseRendering];
				[self didEndDecelerating];
//                 NSLog(@"fabsf(_speed) < 1.0 speed %f",_speed);
			}
			break;
		case SIImageSequenceViewStateSpinning:
			if (fabsf(_targetFrameIndex - _frameIndex) < fabsf(_speed)) {
				_speed = 0;
				[self setFrameIndex:_targetFrameIndex immediately:YES];
				[self pauseRendering];
				[self didEndSpinning];
			}
			break;
		default:
			break;
	}
}

- (void)tickUseImageArray:(CADisplayLink *)displayLink
{
    [self setUseImageArrayFrameIndex:self.frameIndex + roundf(_speed) immediately:YES];
	switch (_state) {
		case SIImageSequenceViewStateDecelerating:
			_speed *= _friction;
            //            NSLog(@"Decelerating speed %f",_speed);
			if (fabsf(_speed) < 1.0) {
				_speed = 0;
				[self pauseRendering];
				[self didEndDecelerating];
                //                 NSLog(@"fabsf(_speed) < 1.0 speed %f",_speed);
			}
			break;
		case SIImageSequenceViewStateSpinning:
			if (fabsf(_targetFrameIndex - _frameIndex) < fabsf(_speed)) {
				_speed = 0;
				[self setFrameIndex:_targetFrameIndex immediately:YES];
				[self pauseRendering];
				[self didEndSpinning];
			}
			break;
		default:
			break;
	}
}

#pragma mark
#pragma mark validate and invalidate
- (void)invalidate
{
	if (!_isDirty) {
		_isDirty = YES;
		// schedule render in next runloop
		[self performSelector:@selector(validate) withObject:nil afterDelay:0];
	}
}

- (void)validate
{
	if (_isDirty) {
		[self render];
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(validate) object:nil]; 
		_isDirty = NO;
	}
}

#pragma mark
#pragma mark change Frameindex
- (void)setFrameIndex:(NSInteger)frameIndex immediately:(BOOL)immediately
{
//    NSLog(@"now speed %f",_speed);
	_frameIndex = [self mappedFrameIndex:frameIndex];
	if (immediately) {
		[self render];
        if ([_delegate respondsToSelector:@selector(imageDidChange:)]) {
            [_delegate imageDidChange:_frameIndex];
        };
	} else {
		[self invalidate];
	}
}
- (void)setRoamFrameIndex:(NSInteger)frameIndex immediately:(BOOL)immediately
{
    //    NSLog(@"now speed %f",_speed);
	_frameIndex = [self mappedFrameIndex:frameIndex];
	if (immediately) {
		[self renderRoam];
        [_delegate imageDidChange:_frameIndex];
	} else {
		[self invalidate];
	}
}

- (void)setUseImageArrayFrameIndex:(NSInteger)frameIndex immediately:(BOOL)immediately
{
    //    NSLog(@"now speed %f",_speed);
	_frameIndex = [self mappedFrameIndex:frameIndex];
	if (immediately) {
		[self renderUseImageArray];
        [_delegate imageDidChange:_frameIndex];
	} else {
		[self invalidate];
	}
}

- (NSInteger)mappedFrameIndex:(NSInteger)frameIndex
{
	NSInteger resultFrameIndex = frameIndex;
	if (frameIndex < 0) {
		if (_looping) {
			resultFrameIndex = frameIndex % (NSInteger)(_frameCount) + _frameCount;
		} else {
			resultFrameIndex = 0;
		}
	}
    else if (frameIndex >= _frameCount) {
		if (_looping) {
			resultFrameIndex = frameIndex % _frameCount;
		} else {
			resultFrameIndex = _frameCount - 1;
		}
	}
	return resultFrameIndex;
}

#pragma mark
#pragma mark render
- (void)startRendering
{
	if (_isRendering) {
		return;
	}
	if (!_displayLink) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick:)];
        _displayLink.frameInterval = 2; // 30fps
		[_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	}
	_displayLink.paused = NO;
	_isRendering = YES;
}

- (void)startRenderingUseImageArray
{
	if (_isRendering) {
		return;
	}
	if (!_displayLink) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(tickUseImageArray:)];
        _displayLink.frameInterval = 2; // 30fps
		[_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	}
	_displayLink.paused = NO;
	_isRendering = YES;
}


- (void)pauseRendering
{
	_displayLink.paused = YES;
	_isRendering = NO;
}

- (void)stopRendering
{
	[_displayLink invalidate];
	_displayLink = nil;
	_isRendering = NO;
}


- (void)render
{
	if (!_pathFormat) {
		return;
	}
	NSBundle *bundle = _bundle;
	if (!bundle) {
		bundle = [NSBundle mainBundle];
	}
    
	UIImage *image = [UIImage imageWithContentsOfFile:[bundle pathForResource:[NSString stringWithFormat:_pathFormat, _frameIndex] ofType:nil]];
//    NSLog(@"image name %@ image %@",[NSString stringWithFormat:_pathFormat, _frameIndex],image);
//    UIImage *image=[_Images objectAtIndex:_frameIndex];
    
	if (image) {
        self.image = image;
	}
}

- (void)renderRoam
{
	if (!_pathFormat) {
		return;
	}
	NSBundle *bundle = _bundle;
	if (!bundle) {
		bundle = [NSBundle mainBundle];
	}
	UIImage *image = [UIImage imageWithContentsOfFile:[bundle pathForResource:[NSString stringWithFormat:_pathFormat, _frameIndex] ofType:nil]];
    //    NSLog(@"image name %@ image %@",[NSString stringWithFormat:_pathFormat, _frameIndex],image);
	if (image) {
        self.image = image;
	}
}

- (void)renderUseImageArray
{
//    NSLog(@"renderUseImageArray image name");
    UIImage *image=[_Images objectAtIndex:_frameIndex];
	if (image) {
        self.image = image;
	}
}

#pragma mark 
#pragma mark change spin state
- (void)didEndDecelerating
{
	[self restoreState];
}

- (void)didEndSpinning
{
	if (_completion) {
		_completion(YES);
		_completion = nil;
	}
	[self restoreState];
}

- (void)restoreState
{
	if (_freeSpinning) {
		[self startFreeSpinWithSpeed:_freeSpinSpeed];
        NSLog(@"_freeSpinning");
	}
    else
    {
        NSLog(@"not _freeSpinning");
		[self setState:SIImageSequenceViewStateIdling];
	}
}

- (void)setState:(SIImageSequenceViewState)state
{
	if (_state == state) {
		return;
	}
	_state = state;
	if ([_delegate respondsToSelector:@selector(imageSequenceView:didChangeState:)]) {
		[_delegate imageSequenceView:self didChangeState:_state];
	}
}

#pragma mark
#pragma mark reset
-(void)reset;//重置
{
    self.frameIndex=self.preOffsetFrameIndex=0;
    [self render];
}

@end