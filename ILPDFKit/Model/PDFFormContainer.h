// PDFFormContainer.h
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

#import <Foundation/Foundation.h>
#import "PDFForm.h"


@class ILPDFDocument;
@class PDFFormContainer;

@protocol PDFFormContainerDelegate <NSObject>

@optional
-(void)pdfFormContainer:(PDFFormContainer*)container didUpdateForm:(PDFForm*)form withValue:(NSString*)value;

@end


/** The PDFFormContainer class represents a container class for all the PDFForm objects attached to a ILPDFDocument.
 */
@interface PDFFormContainer : NSObject <NSFastEnumeration>

/** The parent ILPDFDocument.
 */
@property (nonatomic, weak) ILPDFDocument *document;

/** Delegate for form updates
 */
@property (nonatomic, weak) id<PDFFormContainerDelegate> delegate;

/**---------------------------------------------------------------------------------------
 * @name Creating a PDFFormContainer
 *  ---------------------------------------------------------------------------------------
 */
/** Creates a new instance of PDFFormContainer
 @param parent The ILPDFDocument that owns the PDFFormContainer.
 @return A new PDFFormContainer object.
 */
- (instancetype)initWithParentDocument:(ILPDFDocument *)parent NS_DESIGNATED_INITIALIZER;

/**
 * Make super designated initializer unavailable.
 */
- (instancetype) __unavailable init;

/**---------------------------------------------------------------------------------------
 * @name Retrieving Forms
 *  ---------------------------------------------------------------------------------------
 */


/** Returns all forms with called by name
 
 @param name The name to filter by.
 @return An array of the filtered forms.
 @discussion Generally this will return an array with a single
 object. When multiple forms have the same name, their values are kept
 the same because they are treated as logically the same entity with respect 
 to a name-value pair. For example, a choice form called
 'City' may be set as 'Lusaka' by the user on page 1, and another choice form
 also called 'City' on a summary page at the end will also be synced to have the
 value of 'Lusaka'. This is in conformity with the PDF standard. Another common relevent scenario
 involves mutually exclusive radio button/check box groups. Such groups are composed of multiple forms
 with the same name. Their common value is the exportValue of the selected button. If the value is equal 
 to the exportValue for such a form, it is checked. In this way, it is easy to see as well why such
 groups are mutually exclusive. Buttons with distinct names are not mutually exclusive, 
 that is they don't form a radio button group.
 */
- (NSArray *)formsWithName:(NSString *)name;


/** Returns all forms with called by type
 
 @param type The type to filter by.
 @return An array of the filtered forms.
 @discussion Here are the possible types:
 
 PDFFormTypeNone: An unknown form type.
 PDFFormTypeText: A text field, either multiline or singleline.
 PDFFormTypeButton: A radio button, combo box buttton, or push button.
 PDFFormTypeChoice: A combo box.
 PDFFormTypeSignature: A signature form.
 */
- (NSArray *)formsWithType:(PDFFormType)type;



/**---------------------------------------------------------------------------------------
 * @name Getting Visual Representations
 *  ---------------------------------------------------------------------------------------
 */

/** Returns an array of UIView based objects representing the forms.
 
 @param width The width of the superview to add the resulting views as subviews.
 @param margin The left and right margin of the superview with respect to the PDF canvas portion of the UIWebView.
 @param hmargin The top margin of the superview with respect to the PDF canvas portion of the UIWebView.
 @return An NSArray containing the resulting views. You are responsible for releasing the array.
 */
- (NSArray *)createWidgetAnnotationViewsForSuperviewWithWidth:(CGFloat)width margin:(CGFloat)margin hMargin:(CGFloat)hmargin;


/**---------------------------------------------------------------------------------------
 * @name Setting Values
 *  ---------------------------------------------------------------------------------------
 */

/** Sets a form value.
 @param val The value to set.
 @param name The name of the form(s) to set the value for. 
 */
- (void)setValue:(NSString *)val forFormWithName:(NSString *)name;

/**---------------------------------------------------------------------------------------
 * @name XML 
 *  ---------------------------------------------------------------------------------------
 */

/** Returns an XML representation of the form values in the document.
 @return The xml string defining the value and hierarchical structure of all forms in the document.
 */
- (NSString *)formXML;

/**---------------------------------------------------------------------------------------
 * @name Dictionary
 *  ---------------------------------------------------------------------------------------
 */

/**
 Returns a copy of all key value pairs of the pdf form fields
 @return NSDictionary defining the key and array of values of all the pdf forms in the document.
 */
- (NSDictionary *) copyNameTree;


@end
