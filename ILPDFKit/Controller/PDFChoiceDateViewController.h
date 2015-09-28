//
//  PDFChoiceDateViewController.h
//  ILPDFKitSample
//
//  Created by Aaron Hilton on 2015-09-27.
//  Copyright © 2015 Iwe Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PDFForm;

@class PDFChoiceDateViewController;
@protocol PDFChoiceDateDelegate <NSObject>
- (void) pdfChoiceDate:(PDFChoiceDateViewController*)datevc didSelectDate:(NSString*)value;
- (void) pdfChoiceDateDismissed;
@end

@interface PDFChoiceDateViewController : UIViewController
@property(nonatomic, strong) PDFForm *form;
@property(nonatomic, weak) id<PDFChoiceDateDelegate> delegate;

- (instancetype) initWithForm:(PDFForm *)form;
@end
