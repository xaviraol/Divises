//
//  BottomToTopSegue.m
//  Monedes
//
//  Created by Xavier Ramos on 1/2/16.
//  Copyright © 2016 Xavier Ramos. All rights reserved.
//

#import "BottomToTopSegue.h"

@implementation BottomToTopSegue

-(void)perform{
    
    UIView *preV = ((UIViewController *)self.sourceViewController).view;
    UIView *newV = ((UIViewController *)self.destinationViewController).view;
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    [window insertSubview:newV aboveSubview:preV];
    [newV setFrame:preV.window.frame];
    [newV setTransform:CGAffineTransformMakeTranslation(0, -preV.frame.size.height)];
    [newV setAlpha:1.0];
    
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationOptionTransitionFlipFromTop
                     animations:^{
                         [newV setTransform:CGAffineTransformMakeTranslation(0,0)];
                         [newV setAlpha:1.0];
                     }
                     completion:^(BOOL finished){
                         [preV removeFromSuperview];
                         window.rootViewController = self.destinationViewController;
                     }];
}

@end
