//
//  EagleGuestureImageView.h
//  GestImageView
//
//  Created by eagle on 14-7-6.
//  Copyright (c) 2014年 eagle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EagleGuestureImageView : UIImageView<UIGestureRecognizerDelegate>
@property CGFloat lastRotation;

@property CGFloat minScale; //最大的缩放
@property CGFloat maxScale; //最小的缩放

@property CGFloat maxBounceScale; //bounce 最大缩放
@property CGFloat minBounceScale; //bounce 最小缩放

@property CGPoint prePoint; //移动的点


-(void)initSetRotation:(BOOL)rotation scale:(BOOL)scale move:(BOOL)move;
@property CGSize initSize;
@end
