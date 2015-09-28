//
//  PDFChoiceTableViewController.m
//  ILPDFKitSample
//
//  Created by Aaron Hilton on 2015-09-27.
//  Copyright © 2015 Iwe Labs. All rights reserved.
//

#import "PDFChoiceTableViewController.h"
#import "PDFForm.h"

static NSString *cellIdentifier = @"PDFChoiceTableViewCell";

@interface PDFChoiceTableViewController ()
<UIPopoverPresentationControllerDelegate>
@property(nonatomic) NSInteger selectedOption;
@end

@implementation PDFChoiceTableViewController

- (instancetype) initWithForm:(PDFForm *)form {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        _form = form;
        _selectedOption = [form.options indexOfObject:form.value];
        self.modalPresentationStyle = UIModalPresentationPopover;
    }
    return self;
}


- (void) loadView {
    [super loadView];
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:cellIdentifier];
}

- (CGSize) preferredContentSize {
    CGSize size = CGSizeMake(400, 600);

    // Check if we can collapse our max height to fit the number of rows.
    CGFloat rowHeight = self.form.options.count * 44;
    if (size.height > rowHeight) {
        size.height = rowHeight;
    }

    return size;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_selectedOption >= 0 && _selectedOption < self.form.options.count) {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:_selectedOption inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.form.options.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];

    cell.textLabel.text = self.form.options[indexPath.row];
    cell.selected = (indexPath.row == _selectedOption);
    return cell;
}

#pragma mark - TableView Delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *value = self.form.options[indexPath.row];
    [self.form setValue:value];
    [_delegate pdfChoiceTable:self didSelectValue:value];
}

#pragma mark - PopoverPresentationController methods
- (UIPopoverPresentationController*) popoverPresentationController {
    UIPopoverPresentationController *pop = [super popoverPresentationController];
    pop.delegate = self;
    return pop;
}

- (void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController {
    [_delegate pdfChoiceTableCancled:self];
}

@end
