//
//  UIViewController+KeyboardAvoiding.m
//  ReadySteadyLearn
//
//  Created by HeYilei on 15/10/2015.
//  Copyright © 2015 jEyLaBs. All rights reserved.
//

#import "UIViewController+KeyboardAvoiding.h"
#import <objc/runtime.h>
#import "Aspects.h"

static char keyboardTopInViewAssociatedObjectKey;
static const double kAnimationDuration = 0.3;

@implementation UIViewController (KeyboardAvoiding)
@dynamic keyboardTopInView;
- (void)setupKeyboardAvoidingWithKeyboardTopInView:(CGFloat)top {
    self.keyboardTopInView = top;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardAvoiding_dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    [self aspect_hookSelector:@selector(viewWillAppear:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo, BOOL animated){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardAvoiding_keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardAvoiding_keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }error:NULL];
    
    [self aspect_hookSelector:@selector(viewWillDisappear:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo, BOOL animated){
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    }error:NULL];
}

- (void)setupKeyboardAvoiding {
    [self setupKeyboardAvoidingWithKeyboardTopInView:0.0];
}

#pragma mark - property

- (CGFloat)keyboardTopInView{
    return [objc_getAssociatedObject(self, &keyboardTopInViewAssociatedObjectKey) doubleValue];
}

- (void)setKeyboardTopInView:(CGFloat)keyboardTopInView{
    objc_setAssociatedObject(self, &keyboardTopInViewAssociatedObjectKey, [NSNumber numberWithDouble:keyboardTopInView], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - methods

- (void)keyboardAvoiding_dismissKeyboard{
    [self.view endEditing:YES];
}

- (void)keyboardAvoiding_keyboardWillShow:(NSNotification *)notification{
    const CGFloat kOffset = 15.0;
    CGSize keyboardSize = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    if (self.keyboardTopInView == 0) {
        [UIView animateWithDuration:kAnimationDuration animations:^{
            CGRect frame = self.view.frame;
            frame.origin.y = -(keyboardSize.height * 0.5);//move the view upwards by 1/2 of the keyboard height
            self.view.frame = frame;
        }];
    }else{
        [UIView animateWithDuration:kAnimationDuration animations:^{
            CGRect frame = self.view.frame;
            frame.origin.y = -(self.keyboardTopInView - (frame.size.height - keyboardSize.height) + kOffset);//move the view upwards to the given height
            if (frame.origin.y > 0) {
                frame.origin.y = 0;
            }
            self.view.frame = frame;
        }];
    }
    
}

- (void)keyboardAvoiding_keyboardWillHide:(NSNotification *)notification{
    [UIView animateWithDuration:kAnimationDuration animations:^{
        CGRect frame = self.view.frame;
        frame.origin.y = 0.0;//reset the frame of the view
        self.view.frame = frame;
    }];
}

@end
