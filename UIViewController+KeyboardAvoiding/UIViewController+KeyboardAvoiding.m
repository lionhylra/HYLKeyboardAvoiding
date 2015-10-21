//
//UIViewController+KeyboardAvoiding.h
//The MIT License (MIT)
//
//Copyright (c) 2015 Yilei He
//https://github.com/lionhylra/HYLKeyboardAvoiding
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//SOFTWARE.

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
        [[NSNotificationCenter defaultCenter] addObserver:aspectInfo.instance selector:@selector(keyboardAvoiding_keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:aspectInfo.instance selector:@selector(keyboardAvoiding_keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }error:NULL];
    
    [self aspect_hookSelector:@selector(viewWillDisappear:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo, BOOL animated){
        [[NSNotificationCenter defaultCenter] removeObserver:aspectInfo.instance name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:aspectInfo.instance name:UIKeyboardWillHideNotification object:nil];
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
            frame.origin.y = -(self.keyboardTopInView - (frame.size.height - keyboardSize.height));//move the view upwards to the given height
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
