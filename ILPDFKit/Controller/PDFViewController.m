// PDFViewController.m
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

#import "PDF.h"
#import "PDFFormContainer.h"
#import "PDFChoiceTableViewController.h"
#import "PDFChoiceDateViewController.h"
#import "PDFFormChoiceField.h"

@interface PDFViewController(Private)
<PDFChoiceTableDelegate, PDFChoiceDateDelegate>

- (void)loadPDFView;
- (CGPoint)margins;
@end

@implementation PDFViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadPDFView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    _pdfView.alpha = 0;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    for (PDFForm *form in self.document.forms) {
        [form removeObservers];
    }
    [_pdfView removeFromSuperview];self.pdfView = nil;
    [self loadPDFView];
}

#pragma mark - PDFViewController

- (instancetype)initWithData:(NSData *)data {
    self = [super initWithNibName:nil bundle:nil];
    if (self != nil) {
        _document = [[ILPDFDocument alloc] initWithData:data];
    }
    return self;
}

- (instancetype)initWithResource:(NSString *)name {
    self = [super initWithNibName:nil bundle:nil];
    if (self != nil) {
        _document = [[ILPDFDocument alloc] initWithResource:name];
    }
    return self;
}

- (instancetype)initWithPath:(NSString *)path {
    self = [super initWithNibName:nil bundle:nil];
    if(self != nil) {
        _document = [[ILPDFDocument alloc] initWithPath:path];
    }
    return self;
}

- (nullable instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self != nil) {
    }
    return self;
}


- (void)reload {
    [_document refresh];
    [_pdfView removeFromSuperview];
    _pdfView = nil;
    [self loadPDFView];
}

#pragma mark - Private

- (void)loadPDFView {
    id pass = (_document.documentPath ? _document.documentPath:_document.documentData);
    CGPoint margins = [self getMargins];
    NSArray *additionViews = [_document.forms createWidgetAnnotationViewsForSuperviewWithWidth:self.view.bounds.size.width margin:margins.x hMargin:margins.y];
    _pdfView = [[ILPDFView alloc] initWithFrame:self.view.bounds dataOrPath:pass additionViews:additionViews];
    _pdfView.delegate = self;
    [self.view addSubview:_pdfView];
}

- (CGPoint)getMargins {
    // AH: Removed margines, because the new SJSimplePDFView is much more derministic with zero margines (configured to be zero)
    return CGPointMake(0, 0);

//    static const float PDFLandscapePadWMargin = 0; // 13.0f;
//    static const float PDFLandscapePadHMargin = 0; // 7.25f;
//    static const float PDFPortraitPadWMargin = 0; // 9.0f;
//    static const float PDFPortraitPadHMargin = 0;  // 6.10f;
//    static const float PDFPortraitPhoneWMargin = 0; //3.5f;
//    static const float PDFPortraitPhoneHMargin = 0; // 6.7f;
//    static const float PDFLandscapePhoneWMargin = 0; // 6.8f;
//    static const float PDFLandscapePhoneHMargin = 0; // 6.5f;

//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//        if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation))return CGPointMake(PDFPortraitPadWMargin,PDFPortraitPadHMargin);
//        else return CGPointMake(PDFLandscapePadWMargin,PDFLandscapePadHMargin);
//    } else {
//        if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation))return CGPointMake(PDFPortraitPhoneWMargin,PDFPortraitPhoneHMargin);
//        else return CGPointMake(PDFLandscapePhoneWMargin,PDFLandscapePhoneHMargin);
//    }
}

#pragma mark - PDFViewDelegate handlers

- (void) pdfView:(ILPDFView *)view withForm:(PDFForm *)form choiceFieldWasHit:(PDFFormChoiceField *)field {
    UIPopoverPresentationController *popover;
    
    if( [form.uname isEqualToString:@"date"] ) {
        PDFChoiceDateViewController *choiceDate = [[PDFChoiceDateViewController alloc] initWithForm:form];
        choiceDate.delegate = self;
        [self presentViewController:choiceDate animated:YES completion:nil];
        popover = choiceDate.popoverPresentationController;
    } else {
        // Present the choice field's list popover.
        PDFChoiceTableViewController *choiceTable = [[PDFChoiceTableViewController alloc] initWithForm:form];
        choiceTable.delegate = self;
        [self presentViewController:choiceTable animated:YES completion:nil];
        popover = choiceTable.popoverPresentationController;
    }

    // Configure the popover controller
//    popover.permittedArrowDirections = UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown;
    popover.sourceRect = field.frame;
    popover.sourceView = _pdfView.pdfView;
}


#pragma mark PDFChoiceTableVC delegate

- (void) pdfChoiceTable:(PDFChoiceTableViewController*)table didSelectValue:(NSString *)value {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) pdfChoiceTableCancled:(PDFChoiceTableViewController *)table {
}

#pragma mark PDFChoiceDateVC delegate
- (void) pdfChoiceDate:(PDFChoiceDateViewController*)datevc didSelectDate:(NSString*)value {
    
}

- (void) pdfChoiceDateDismissed {
//    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
