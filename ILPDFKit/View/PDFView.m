// PDFView.m
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
#import "PDFFormButtonField.h"
#import "PDF.h"

@interface PDFView(Delegates) <UIScrollViewDelegate,UIGestureRecognizerDelegate,UIWebViewDelegate>
@end

@interface PDFView(Private)
- (void)fadeInWidgetAnnotations;
@end

@implementation PDFView {
    BOOL _canvasLoaded;
}

#pragma mark - PDFView

- (instancetype)initWithFrame:(CGRect)frame dataOrPath:(id)dataOrPath additionViews:(NSArray*)widgetAnnotationViews {
    self = [super initWithFrame:frame];
    if (self) {
        CGRect contentFrame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        _pdfView = [[SJCSimplePDFView alloc] initWithFrame:contentFrame];
        _pdfView.viewMode = kSJCPDFViewModeContinuous;
//        _pdfView.delegate = self;
        _pdfView.bouncesZoom = NO;
        _pdfView.autoresizingMask =  UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
         self.autoresizingMask =  UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
        [self addSubview:_pdfView];
        CGFloat zoomScale = 1;
        [_pdfView setZoomScale:zoomScale];
        _pdfView.maximumZoomScale = zoomScale;
        _pdfView.minimumZoomScale = zoomScale;
        [_pdfView setContentOffset:CGPointZero];
        //This allows us to prevent the keyboard from obscuring text fields near the botton of the document.
        [_pdfView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
        _pdfWidgetAnnotationViews = [[NSMutableArray alloc] initWithArray:widgetAnnotationViews];
        for (PDFWidgetAnnotationView *element in _pdfWidgetAnnotationViews) {
            element.alpha = 0;
            element.parentView = self;
            [_pdfView addSubview:element];
            if ([element isKindOfClass:[PDFFormButtonField class]]) {
                [(PDFFormButtonField*)element setButtonSuperview];
            }
        }
        
        if ([dataOrPath isKindOfClass:[NSString class]]) {
            _pdfView.PDFFileURL = [NSURL fileURLWithPath:dataOrPath];
//            [_pdfView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:dataOrPath]]];
        } else if([dataOrPath isKindOfClass:[NSData class]]) {
            _pdfView.PDFData = dataOrPath;
//            [_pdfView loadData:dataOrPath MIMEType:@"application/pdf" textEncodingName:@"NSASCIIStringEncoding" baseURL:[NSURL new]];
        }

        [self fadeInWidgetAnnotations];

        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:nil action:NULL];
        [self addGestureRecognizer:tapGestureRecognizer];
        tapGestureRecognizer.delegate = self;

        // Register for keyboard appearance changes.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    }
    return self;
}

/**
 On keyboard appearance,
 adjust scrollView insets so we can scroll the active widget onto the screen.
 */
- (void)keyboardDidShow:(NSNotification*) notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, keyboardSize.height, 0);
    [_pdfView setContentInset:insets];
    [_pdfView setScrollIndicatorInsets:insets];
    [self scrollActiveWidgetToVisible];
}

/**
 On keyboard hiding,
 Just reset the scroll insets.
*/
- (void)keyboardDidHide:(NSNotification*) notification {
    UIEdgeInsets insets = UIEdgeInsetsZero;
    [_pdfView setContentInset:insets];
    [_pdfView setScrollIndicatorInsets:insets];
    [self scrollActiveWidgetToVisible];
}

/**
 Hook the setter for activeWidgetAnnotationView, and update widget visibility.
 */
- (void) setActiveWidgetAnnotationView:(PDFWidgetAnnotationView *)activeWidgetAnnotationView {
    _activeWidgetAnnotationView = activeWidgetAnnotationView;
    [self scrollActiveWidgetToVisible];
}

/**
 Scroll the active widget into view, if it'll be obscured by the new keyboard rect.
 */
- (void) scrollActiveWidgetToVisible {
    if( _activeWidgetAnnotationView ) {
        CGRect widgetRect = [_pdfView convertRect:_activeWidgetAnnotationView.bounds fromView:_activeWidgetAnnotationView];
        [_pdfView scrollRectToVisible:widgetRect animated:YES];
    }
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addPDFWidgetAnnotationView:(PDFWidgetAnnotationView *)viewToAdd {
    [_pdfWidgetAnnotationViews addObject:viewToAdd];
    [_pdfView addSubview:viewToAdd];
}

- (void)removePDFWidgetAnnotationView:(PDFWidgetAnnotationView *)viewToRemove {
    [viewToRemove removeFromSuperview];
    [_pdfWidgetAnnotationViews removeObject:viewToRemove];
}

- (void)setWidgetAnnotationViews:(NSArray *)additionViews {
    for (UIView *v in _pdfWidgetAnnotationViews) [v removeFromSuperview];
    _pdfWidgetAnnotationViews = nil;
    _pdfWidgetAnnotationViews = [[NSMutableArray alloc] initWithArray:additionViews];
    for (PDFWidgetAnnotationView *element in _pdfWidgetAnnotationViews) {
        element.alpha = 0;
        element.parentView = self;
        [_pdfView addSubview:element];
        if ([element isKindOfClass:[PDFFormButtonField class]]) {
            [(PDFFormButtonField*)element setButtonSuperview];
        }
    }
    if (_canvasLoaded) [self fadeInWidgetAnnotations];
}

//#pragma mark - UIWebViewDelegate
//
//- (void)webViewDidFinishLoad:(UIWebView *)webView {
//    _canvasLoaded = YES;
//    if (_pdfWidgetAnnotationViews) {
//        [self fadeInWidgetAnnotations];
//    }
//}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat scale = scrollView.zoomScale;
    if (scale < 1.0f) scale = 1.0f;
    for (PDFWidgetAnnotationView *element in _pdfWidgetAnnotationViews) {
        [element updateWithZoom:scale];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (_activeWidgetAnnotationView == nil) return NO;
    if (!CGRectContainsPoint(_activeWidgetAnnotationView.frame, [touch locationInView:_pdfView])) {
        if ([_activeWidgetAnnotationView isKindOfClass:[UITextView class]]) {
            [_activeWidgetAnnotationView resignFirstResponder];
        } else {
            [_activeWidgetAnnotationView resign];
        }
    }
    return NO;
}

#pragma mark - Private

- (void)fadeInWidgetAnnotations {
    [UIView animateWithDuration:0.5 delay:0.2 options:0 animations:^{
        for (UIView *v in _pdfWidgetAnnotationViews) v.alpha = 1;
    } completion:^(BOOL finished) {}];
}


@end




