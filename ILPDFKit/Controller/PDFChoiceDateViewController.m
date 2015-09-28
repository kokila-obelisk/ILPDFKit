//
//  PDFChoiceDateViewController.m
//  ILPDFKitSample
//
//  Created by Aaron Hilton on 2015-09-27.
//  Copyright © 2015 Iwe Labs. All rights reserved.
//

#import "PDFChoiceDateViewController.h"
#import "PDFForm.h"

@interface PDFChoiceDateViewController ()
<UIPopoverPresentationControllerDelegate>
@property(nonatomic, strong) UIDatePicker *datePicker;
@property(nonatomic, strong) NSDateFormatter *dateFormatter;
@end

@implementation PDFChoiceDateViewController

- (instancetype) initWithForm:(PDFForm*)form {
    self = [super init];
    if (self) {
        _form = form;
        
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.timeStyle = NSDateFormatterNoStyle;
        _dateFormatter.dateStyle = NSDateFormatterLongStyle;
        _dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        NSDate *date = [_dateFormatter dateFromString:form.value];
        if( date == nil ) {
            date = [NSDate date];
        }
        
        self.datePicker = [[UIDatePicker alloc] init];
        _datePicker.datePickerMode = UIDatePickerModeDate;
        _datePicker.date = date;
        [_datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
        
        self.modalPresentationStyle = UIModalPresentationPopover;
    }
    return self;
}


- (void)loadView {
    self.view = _datePicker;
}

- (CGSize) preferredContentSize {
    CGSize size = _datePicker.bounds.size;
    return size;
}


#pragma mark - Date Picker handler

- (void) dateChanged:(id)sender {
    NSString *dateValue = [_dateFormatter stringFromDate:_datePicker.date];
    _form.value = dateValue;
    [_delegate pdfChoiceDate:self didSelectDate:dateValue];
}

#pragma mark - PopoverPresentationController methods
- (UIPopoverPresentationController*) popoverPresentationController {
    UIPopoverPresentationController *pop = [super popoverPresentationController];
    pop.delegate = self;
    return pop;
}

- (void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController {
    [_delegate pdfChoiceDateDismissed];
}

@end
