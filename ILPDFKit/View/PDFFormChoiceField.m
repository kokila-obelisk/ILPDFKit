// PDFFormChoiceField.m
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
#import "PDFFormChoiceField.h"

#define PDFChoiceFieldRowHeightDivisor MIN(5,[self.options count])

@interface PDFFormChoiceFieldDropIndicator : UIView
@end

@implementation PDFFormChoiceFieldDropIndicator

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGFloat margin = rect.size.width/3;
    CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
    CGContextMoveToPoint(ctx, margin, margin);
    CGContextAddLineToPoint(ctx, rect.size.width-margin, rect.size.height/2);
    CGContextAddLineToPoint(ctx, margin, rect.size.height-margin);
    CGContextAddLineToPoint(ctx,margin,margin);
    CGContextFillPath(ctx);
}

@end

@implementation PDFFormChoiceField {
    NSArray *_options;
    NSUInteger _selectedIndex;
    UILabel *_selection;
    UIButton *_middleButton;
    BOOL _dropped;
    CGFloat _baseFontHeight;
    __weak PDFForm *_form;
}

#pragma mark - PDFFormChoiceField

- (instancetype)initWithForm:(PDFForm*)form frame:(CGRect)frame options:(NSArray *)opt {
    self = [super initWithFrame:frame];
    if (self != nil) {
        self.opaque = NO;
        self.backgroundColor = PDFWidgetColor; // FIXME:  Need image support [PDFWidgetColor colorWithAlphaComponent:1];
        self.layer.cornerRadius = self.frame.size.height/6;
        _options = opt;
        _form = form;
        self.clipsToBounds = YES;

        CGRect selectionFrame = CGRectMake(10, 0, frame.size.width-10, frame.size.height);
        _baseFontHeight = [PDFWidgetAnnotationView fontSizeForRect:selectionFrame value:nil multiline:NO choice:YES];
        _selection = [[UILabel alloc] initWithFrame:selectionFrame];
        _selection.opaque = NO;
        _selection.adjustsFontSizeToFitWidth = YES;
        [_selection setBackgroundColor:[UIColor clearColor]];
        [self updateSelectionUI];
        [self addSubview:_selection];

        _middleButton = [[UIButton alloc] initWithFrame:self.bounds];
        _middleButton.opaque = NO;
        _middleButton.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        _middleButton.backgroundColor = [UIColor clearColor];
        [_middleButton addTarget:self action:@selector(dropButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_middleButton];
    }
    return self;
}

#pragma mark - PDFWidgetAnnotationView

- (NSString *)value {
    return [_selection.text length] ? _selection.text:nil;
}

- (void)setValue:(NSString *)value {
    if ([value isKindOfClass:[NSNull class]]) {
        self.value = nil;
        return;
    }
    if (value != nil) {
        NSUInteger nind = [_options indexOfObject:value];
        _selectedIndex = nind;
    } else {
        _selectedIndex = NSNotFound;
    }
    [_selection setText:value];
    [self refresh];
}

- (void)setOptions:(NSArray *)opt {
    if ([opt isKindOfClass:[NSNull class]]) {
        self.options = nil;
        return;
    }
    if (_options != opt) {
        _options = opt;
    }
}

- (NSArray *)options {
    return _options;
}

- (void)refresh {
    [super refresh];
}

- (void)resign {
//    if (_dropped) [self dropButtonPressed:_dropIndicator];
}

- (void)updateSelectionUI {
    CGRect selectionFrame = CGRectMake(10, 0, self.frame.size.width-10, self.frame.size.height);
    _selection.frame  = selectionFrame;
    if(_form.defaultAppearance) {
        [_selection setTextColor:_form.daColor];
        [_selection setFont:_form.daFont];
        //            NSLog(@"Form (%@) [%@]: defaultAppearance: %f size, %@ font", form.name, form.uname, form.daSize, form.daFont.fontName );
    } else {
        [_selection setTextColor:[UIColor blackColor]];
        [_selection setFont:[UIFont systemFontOfSize:_baseFontHeight]];
        //            NSLog(@"Form (%@) [%@]: defaultAppearance: %f size, %@ font", form.name, form.uname, _baseFontHeight, @"System" );
    }
}

- (void)updateWithZoom:(CGFloat)zoom {
    [super updateWithZoom:zoom];
    [self updateSelectionUI];
    [self setNeedsDisplay];
}

#pragma mark - Responder

- (void)dropButtonPressed:(id)sender {
    [self.parentView.delegate pdfView:self.parentView withForm:(PDFForm*)self.delegate choiceFieldWasHit:self];
}


@end
