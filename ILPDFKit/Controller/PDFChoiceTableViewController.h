//
//  PDFChoiceTableViewController.h
//  ILPDFKitSample
//
//  Created by Aaron Hilton on 2015-09-27.
//  Copyright © 2015 Conquer Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PDFForm;

@class PDFChoiceTableViewController;
@protocol PDFChoiceTableDelegate <NSObject>
- (void) pdfChoiceTable:(PDFChoiceTableViewController*)table didSelectValue:(NSString*)value;
- (void) pdfChoiceTableCancled:(PDFChoiceTableViewController *)table;
@end

@interface PDFChoiceTableViewController : UITableViewController
@property(nonatomic, strong) PDFForm *form;
@property(nonatomic, weak) id<PDFChoiceTableDelegate> delegate;

- (instancetype) initWithForm:(PDFForm *)form;

@end
