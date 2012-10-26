/*
 Copyright (c) 2012 Aleksandr Kelbas
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */


#import "AKFieldsNavView.h"

@interface AKFieldsNavView ()
@property (nonatomic, strong) UIToolbar *navigationToolbar;
@property (nonatomic, strong) UISegmentedControl *navigationSegmentedControl;
@end

@implementation AKFieldsNavView
@synthesize textFields = _textFields;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark - Setup

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    // If already set, return
    if (self.navigationToolbar && self.navigationSegmentedControl && self.textFields)
        return;
    
    
    // Sort fields by y offset
    NSArray *sortedFields = [self.textFields sortedArrayUsingComparator:^(UITextField *a, UITextField *b){
        CGRect aRect = [self convertRect:a.frame fromView:a.superview];
        CGRect bRect = [self convertRect:b.frame fromView:b.superview];
        
        if (aRect.origin.y > bRect.origin.y)
        {
            return NSOrderedDescending;
        }
        else if (aRect.origin.y < bRect.origin.y)
        {
            return NSOrderedAscending;
        }
        else return NSOrderedSame;
        
    }];
    
    // Make sure all objects in array are of UITextField or UITextView class
    Class textFieldClass = NSClassFromString(@"UITextField");
    Class textViewClass = NSClassFromString(@"UITextView");
    NSArray *filteredFields = [sortedFields filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.class == %@ || self.class == %@", textFieldClass, textViewClass]];

    
    // Initialise array, toolbar and segmented control
    self.textFields = [[NSArray alloc] initWithArray:filteredFields];
    self.navigationToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    self.navigationSegmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Previous", @"Next", nil]];
    [self.navigationSegmentedControl addTarget:self action:@selector(nextPrevious:) forControlEvents:UIControlEventValueChanged];
    [self.navigationSegmentedControl setMomentary:YES];
    [self.navigationSegmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];
    
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *control = [[UIBarButtonItem alloc] initWithCustomView:self.navigationSegmentedControl];
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    
    [self.navigationToolbar setItems:[NSArray arrayWithObjects:control, flex, done, nil]];
    [self.navigationToolbar setBarStyle:UIBarStyleBlackTranslucent];
    
   
    // add input accessory toolbar to each view
    for (id field in self.textFields)
    {
        if ([field respondsToSelector:@selector(setInputAccessoryView:)])
            [field setInputAccessoryView:self.navigationToolbar];
    }
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(keyboardWillShow:)
     name:UIKeyboardWillShowNotification
     object:nil];

    
}

#pragma mark - Notification centre

- (void) keyboardWillShow:(NSNotification*)aNotification
{
    [self resetNavigationButtons];
}

- (void) dealloc
{
    // Remove observer when view gets deallocated
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Navigation

/* Resign first responder */
- (void) done:(id)sender
{
    NSArray *activeFields = [self.textFields filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.isFirstResponder == 1"]];
    if (activeFields.count)
    {
        [[activeFields objectAtIndex:0] resignFirstResponder];
    }
}

/* Navigate to next or previous view according to segment pressed */
- (void) nextPrevious:(UISegmentedControl*)sender
{
    NSArray *activeFields = [self.textFields filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.isFirstResponder == 1"]];
    if (activeFields.count)
    {
        int index = [self.textFields indexOfObject:[activeFields objectAtIndex:0]];
        switch (sender.selectedSegmentIndex) {
            case 0:
            {
                // previous
                index--;
            }
                break;
            case 1:
                index++;
                break;
                
            default:
                break;
        }
        
        [[self.textFields objectAtIndex:index] becomeFirstResponder];
        
    }
    
    [self resetNavigationButtons];
}


/* Enable or disable navigation buttons if needed */
- (void) resetNavigationButtons
{
    NSArray *activeFields = [self.textFields filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.isFirstResponder == 1"]];
    
    if (activeFields.count)
    {
        int index = [self.textFields indexOfObject:[activeFields objectAtIndex:0]];
        [self.navigationSegmentedControl setEnabled:index > 0 forSegmentAtIndex:0];
        [self.navigationSegmentedControl setEnabled:index < self.textFields.count-1 forSegmentAtIndex:1];
        
    }
    
    
    
}


@end
