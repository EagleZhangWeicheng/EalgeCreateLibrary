//
//  EagleGuestureImageView.m
//  GestImageView
//
//  Created by eagle on 14-7-6.
//  Copyright (c) 2014年 eagle. All rights reserved.
//

#import "EagleGuestureImageView.h"

@implementation EagleGuestureImageView



-(void)initSetRotation:(BOOL)rotation scale:(BOOL)scale move:(BOOL)move;
{
    self.userInteractionEnabled=YES;
    
    
    
    //旋转
    if (rotation) {
        UIRotationGestureRecognizer *rotationGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotationImage:)];
        rotationGestureRecognizer.delegate = self;
        [self addGestureRecognizer:rotationGestureRecognizer];
//        [rotationGestureRecognizer release];
    }
    
    
    //缩放
    if (scale) {
        self.initSize=self.bounds.size;
        if (self.minScale==0) {
            self.minScale=0.8;
        }
        if (self.maxScale==0) {
            self.maxScale=2;
        }
        
        if (self.minBounceScale==0) {
            self.minBounceScale=0.2;
        }
        
        if (self.maxBounceScale==0) {
            self.maxBounceScale=0.2;
        }
        
        UIPinchGestureRecognizer *pinchGestureRecongnizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scaleImage:)];
        pinchGestureRecongnizer.delegate = self;
        [self addGestureRecognizer:pinchGestureRecongnizer];
//        [pinchGestureRecongnizer release];
    }
    
    
    //移动
    if (move) {
        UIPanGestureRecognizer *panGestureRecognizer=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(moveImage:)];
        [self addGestureRecognizer:panGestureRecognizer];
//        [panGestureRecognizer release];
    }
    
    //双击恢复
    UITapGestureRecognizer *doubleClick=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reset)];
    doubleClick.numberOfTapsRequired=2;
    doubleClick.numberOfTouchesRequired=1;
    [self addGestureRecognizer:doubleClick];
//    [doubleClick release];
}


//旋转
- (void)rotationImage:(UIRotationGestureRecognizer*)gesture {
    CGPoint location = [gesture locationInView:self.superview];
    gesture.view.center = CGPointMake(location.x, location.y);
    
    if ([gesture state] == UIGestureRecognizerStateEnded) {
        self.lastRotation = 0;
        return;
    }
    CGAffineTransform currentTransform = self.transform;
    CGFloat rotation = 0.0 - (self.lastRotation - gesture.rotation);
    CGAffineTransform newTransform = CGAffineTransformRotate(currentTransform, rotation);
    self.transform = newTransform;
    self.lastRotation = gesture.rotation;
}


//缩放
- (void)scaleImage:(UIPinchGestureRecognizer*)pinchGestureRecognizer {
    switch (pinchGestureRecognizer.state) {
            //        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged:
        {
            //            NSLog(@"scale %f",self.transform.tx);
            //            NSLog(@"imageViewFrame %@",NSStringFromCGRect(self.frame));
            
            if (self.frame.size.width/self.initSize.width>self.maxScale+self.maxBounceScale&&pinchGestureRecognizer.scale>1.0) {
                return;
            }
            
            else if (self.frame.size.width/self.initSize.width<self.minScale-self.minBounceScale&&pinchGestureRecognizer.scale<1.0) {
                return;
            }
            
            
            //            CGPoint location = [pinchGestureRecognizer locationInView:self.superview];
            //            pinchGestureRecognizer.view.center = CGPointMake(location.x, location.y);
            pinchGestureRecognizer.view.transform = CGAffineTransformScale(pinchGestureRecognizer.view.transform, pinchGestureRecognizer.scale, pinchGestureRecognizer.scale);
            pinchGestureRecognizer.scale = 1;
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStatePossible:
        {
            if (self.frame.size.width/self.initSize.width>self.maxScale)
            {
                NSLog(@"self.bounds %@",NSStringFromCGRect(self.bounds));
                
                //                [UIView animateKeyframesWithDuration:0.2 delay:0 options:0 animations:^{
                //                    // End
                //                    self.transform = CGAffineTransformMakeScale(self.maxScale,self.maxScale);
                //                } completion:^(BOOL finished) {
                //
                //                }];
                [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                                     self.transform=CGAffineTransformIdentity;
                                 } completion:^(BOOL finished) {
                                     
                                 }];
                
                
            }
            
            else if (self.frame.size.width/self.initSize.width<self.minScale)
            {
                
                //                [UIView animateKeyframesWithDuration:0.2 delay:0 options:0 animations:^{
                //                    // End
                //                    self.transform = CGAffineTransformMakeScale(self.minScale,self.minScale);
                //                } completion:^(BOOL finished) {
                //
                //                }];
                
                [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                                     self.transform=CGAffineTransformIdentity;
                                 } completion:^(BOOL finished) {
                                     
                                 }];
                
            }
            //            NSLog(@"gesture end");
        }
            break;
            
        default:
            break;
    }
}


//移动
- (void)moveImage:(UIPanGestureRecognizer *)sender {
    //    CGPoint location = [sender locationInView:self.superview];
    //    sender.view.center = CGPointMake(location.x,  location.y);
    
    
    //    NSLog(@"拖移，慢速移动");
    CGPoint translation = [sender translationInView:self.superview];
    sender.view.center = CGPointMake(sender.view.center.x + translation.x, sender.view.center.y + translation.y);
    [sender setTranslation:CGPointZero inView:self.superview];
}

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    return  YES;
//}

//恢复
-(void)reset;
{
    [UIView animateKeyframesWithDuration:0.01 delay:0 options:0 animations:^{
        // End
        self.transform = CGAffineTransformMakeScale(1,1);
    } completion:^(BOOL finished) {
        
    }];
    NSLog(@"reste");
}





@end
