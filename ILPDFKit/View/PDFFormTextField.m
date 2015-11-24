// PDFFormTextField.m
//
// Copyright (c) 2015 Iwe Labs
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


#import <QuartzCore/QuartzCore.h>
#import "PDF.h"
#import "PDFFormTextField.h"

@interface PDFFormTextField(Delegates) <UITextViewDelegate,UITextFieldDelegate>
@end

@implementation PDFFormTextField {
    BOOL _multiline;
    UIView *_textFieldOrTextView;
    CGFloat _baseFontSize;
    CGFloat _currentFontSize;
}

@synthesize textFieldOrTextView = _textFieldOrTextView;

#pragma mark - NSObject

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - PDFFormTextField

- (instancetype)initWithForm:(PDFForm*)form frame:(CGRect)frame multiline:(BOOL)multiline alignment:(NSTextAlignment)alignment secureEntry:(BOOL)secureEntry readOnly:(BOOL)ro {
    self = [super initWithFrame:frame];
    if (self != nil) {
        self.opaque = NO;
        self.backgroundColor = ro ? [UIColor clearColor]:PDFWidgetColor;
//        if (!multiline) {
//            self.layer.cornerRadius = self.frame.size.height/6;
//        }
        _multiline = multiline;
        CGRect textFrame = CGRectMake(0, 0, frame.size.width, frame.size.height);

        UIFont *font;
        if(form.defaultAppearance) {
            font = form.daFont;
        } else {
            font = [UIFont systemFontOfSize:_baseFontSize];
        }
        
        if( multiline ) {
            UITextView *tv = [[UITextView alloc] initWithFrame:textFrame];
            tv.font = font;
            tv.textColor = form.daColor;
            tv.textAlignment = (NSTextAlignment)alignment;
            tv.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
            tv.delegate = self;
            tv.scrollEnabled = YES;
            [tv setTextContainerInset:UIEdgeInsetsMake(4, 10, 4, 4)];
            _textFieldOrTextView = tv;
        } else {
            UITextField *tf = [[UITextField alloc] initWithFrame:textFrame];
            if (secureEntry) {
                tf.secureTextEntry = YES;
            }

            tf.font = font;
            tf.textColor = form.daColor;
            tf.textAlignment = (NSTextAlignment)alignment;
            tf.delegate = self;
            tf.adjustsFontSizeToFitWidth = YES;
            tf.minimumFontSize = PDFFormMinFontSize;
            tf.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
            tf.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, frame.size.height)];
            tf.leftViewMode = UITextFieldViewModeAlways;
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextFieldTextDidChangeNotification object:tf];
            _textFieldOrTextView = tf;
        }

        if (ro) {
            _textFieldOrTextView.userInteractionEnabled = NO;
        }
        
        _textFieldOrTextView.opaque = NO;
        _textFieldOrTextView.backgroundColor = [UIColor clearColor];
        _baseFontSize = [PDFWidgetAnnotationView fontSizeForRect:frame value:nil multiline:multiline choice:NO];
        _currentFontSize = _baseFontSize;
        
        [self addSubview:_textFieldOrTextView];
    }
    return self;
}

#pragma mark - PDFWidgetAnnotationView

- (void)setValue:(NSString *)value {
    if ([value isKindOfClass:[NSNull class]]) {
        [self setValue:nil];
        return;
    }
    [_textFieldOrTextView performSelector:@selector(setText:) withObject:value];
    [self refresh];
}

- (NSString *)value {
    NSString *ret = [_textFieldOrTextView performSelector:@selector(text)];
    return [ret length] ? ret:nil;
}

- (void)updateWithZoom:(CGFloat)zoom {
    [super updateWithZoom:zoom];
    [_textFieldOrTextView performSelector:@selector(setFont:) withObject:[UIFont systemFontOfSize:_currentFontSize = _baseFontSize*zoom]];
    [_textFieldOrTextView setNeedsDisplay];
    [self setNeedsDisplay];
}

- (void)refresh {
    [self setNeedsDisplay];
    [_textFieldOrTextView setNeedsDisplay];
}

#pragma mark - Notification Responders

- (void)textChanged:(id)sender {
    [self.delegate widgetAnnotationValueChanged:self];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self.delegate widgetAnnotationEntered:self];
    self.parentView.activeWidgetAnnotationView = self;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    self.parentView.activeWidgetAnnotationView = nil;
}

- (void)textViewDidChange:(UITextView *)textView {
    [self.delegate widgetAnnotationValueChanged:self];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    CGSize contentSize = CGSizeMake(textView.bounds.size.width-PDFFormMinFontSize, CGFLOAT_MAX);
    float numLines = ceilf((textView.bounds.size.height / textView.font.lineHeight));
    NSString *newString = [textView.text stringByReplacingCharactersInRange:range withString:text];

    // Early exit if we're deleting characters.
    if ([newString length] < [textView.text length])
        return YES;
    
    // Otherwise calculate if we can fit any new characters.
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    CGRect textRect = [newString boundingRectWithSize:contentSize
                                        options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                      attributes:@{NSFontAttributeName:textView.font,NSParagraphStyleAttributeName:paragraphStyle}
                                        context:nil];

    float usedLines = ceilf(textRect.size.height/textView.font.lineHeight);
    if (usedLines >= numLines && usedLines > 1)
        return NO;

    return YES;
}

#pragma mark - UITextFieldDelegate


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([newString length] <= [textField.text length]) return YES;
    if ([newString sizeWithAttributes:@{NSFontAttributeName:textField.font}].width > (textField.bounds.size.width + PDFFormMinFontSize)) {
       return NO;
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self.delegate widgetAnnotationEntered:self];
     self.parentView.activeWidgetAnnotationView = self;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.parentView.activeWidgetAnnotationView = nil;
}

- (void)resign {
    [_textFieldOrTextView resignFirstResponder];
}

@end
