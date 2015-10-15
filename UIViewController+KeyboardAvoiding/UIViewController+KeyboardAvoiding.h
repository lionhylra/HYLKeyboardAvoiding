//
//  UIViewController+KeyboardAvoiding.h
//  ReadySteadyLearn
//
//  Created by HeYilei on 15/10/2015.
//  Copyright © 2015 jEyLaBs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (KeyboardAvoiding)
@property (nonatomic, assign) CGFloat keyboardTopInView;

/**
 *  Call this method in viewDidLoad.
 *
 *  @param top The top of the keyboard in the view's coordination system
 *
 */
- (void) setupKeyboardAvoidingWithKeyboardTopInView:(CGFloat)top;

/**
 *  Call this method in viewDidLoad. By default, the view will move upwords by half of the keyboard's height.
 *
 */
- (void) setupKeyboardAvoiding;
@end
