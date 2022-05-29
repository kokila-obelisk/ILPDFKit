// ILPDFView.h
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

#import <UIKit/UIKit.h>
#import "SJCSimplePDFView.h"

@class PDFWidgetAnnotationView;
@class PDFFormChoiceField;
@class ILPDFView, PDFForm;

@protocol PDFViewDelegate <NSObject>

- (void) pdfView:(ILPDFView*)view withForm:(PDFForm*)form choiceFieldWasHit:(PDFFormChoiceField*)field;

@end

/** The ILPDFView class allows for viewing a PDF file. The controller PDFViewController uses ILPDFView as its view and ILPDFDocument as its model.
 ILPDFView is typically not directly instantiated, but instead is used as the instance that comes with PDFViewController.
 */
@interface ILPDFView : UIView 

/** The array contains the PDFWidgetAnnotationView instances that are subviews of the pdfView's scrollView.
 */
@property (nonatomic, readonly) NSMutableArray *pdfWidgetAnnotationViews;

/** The view in pdfWidgetAnnotationViews has holds the input focus.
 */
@property (nonatomic, weak) PDFWidgetAnnotationView *activeWidgetAnnotationView;

/** The simple viewer used to render the PDF.
 */
@property (nonatomic, readonly) SJCSimplePDFView *pdfView;

/** Delegate handler for form interactions at the PDFViewController level (an iOS 8/9 thing)
 */
@property (nonatomic, weak) id<PDFViewDelegate> delegate;

/**---------------------------------------------------------------------------------------
 * @name Creating a ILPDFView
 *  ---------------------------------------------------------------------------------------
 */
/** Creates a new instance of ILPDFView.
 
 @param frame Frame of the view.
 @param dataOrPath Either NSData for PDF data or NSString for a PDF file path.
 @param widgetAnnotationViews NSArray of instances of PDFWidgetAnnotationalElementView to be added to the pdfView scrollView.
 @return A new instance of ILPDFView.
 */

- (instancetype)initWithFrame:(CGRect)frame dataOrPath:(id)dataOrPath additionViews:(NSArray *)widgetAnnotationViews NS_DESIGNATED_INITIALIZER;

/**
 * Make super designated initializer unavailable.
 */
- (instancetype) __unavailable initWithFrame:(CGRect)frame;
- (instancetype) __unavailable initWithCoder:(NSCoder *)aDecoder;

/**---------------------------------------------------------------------------------------
 * @name Adding and Removing Additions
 *  ---------------------------------------------------------------------------------------
 */

/** Adds an addition view.
 @param viewToAdd PDFWidgetAnnotationalElementView to be added to the pdfView scrollView.
 */
- (void)addPDFWidgetAnnotationView:(PDFWidgetAnnotationView *)viewToAdd;

/** Removes an addition view.
 @param viewToRemove PDFWidgetAnnotationalElementView to be removed from the pdfView scrollView.
 */
- (void)removePDFWidgetAnnotationView:(PDFWidgetAnnotationView *)viewToRemove;

/** Sets the UI addition views
 @param additionViews The views to add.
 */
- (void)setWidgetAnnotationViews:(NSArray *)additionViews;

@end
