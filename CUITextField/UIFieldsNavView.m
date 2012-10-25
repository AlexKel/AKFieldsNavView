
//
//  UIFieldsNavView.m
//  CUITextField
//
//  Created by alex.kelbas on 24/10/2012.
//  Copyright (c) 2012 tecmark. All rights reserved.
//

#import "UIFieldsNavView.h"

@interface UIFieldsNavView ()
@property (nonatomic, strong) UIToolbar *navigationToolbar;
@property (nonatomic, strong) UISegmentedControl *navigationSegmentedControl;
@end

@implementation UIFieldsNavView
@synthesize textFields = _textFields;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    
    NSArray *sortedFields = [self.textFields sortedArrayUsingComparator:^(UITextField *a, UITextField *b){
        
        if (a.frame.origin.y > b.frame.origin.y)
        {
            return NSOrderedDescending;
        }
        else if (a.frame.origin.y < b.frame.origin.y)
        {
            return NSOrderedAscending;
        }
        else return NSOrderedSame;
        
    }];

    
    self.textFields = [[NSArray alloc] initWithArray:sortedFields];
    
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
    
   
    
    for (UITextField *filed in self.textFields)
    {
        [filed setInputAccessoryView:self.navigationToolbar];
    }
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(keyboardWillShow:)
     name:UIKeyboardWillShowNotification
     object:nil];
    
    
    
    
}

- (void) done:(id)sender
{
    NSArray *activeFields = [self.textFields filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.isFirstResponder == 1"]];
    if (activeFields.count)
    {
        [[activeFields objectAtIndex:0] resignFirstResponder];
    }
}

- (void) keyboardWillShow:(NSNotification*)aNotification
{
    [self resetNavigationButtons];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}




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

- (void) resetNavigationButtons
{
    NSArray *activeFields = [self.textFields filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.isFirstResponder == 1"]];
    
    NSLog(@"activeFields: %@", activeFields);
    if (activeFields.count)
    {
        int index = [self.textFields indexOfObject:[activeFields objectAtIndex:0]];
        NSLog(@"index: %d", index);
        [self.navigationSegmentedControl setEnabled:index > 0 forSegmentAtIndex:0];
        [self.navigationSegmentedControl setEnabled:index < self.textFields.count-1 forSegmentAtIndex:1];
        
    }
    
    
    
}


@end
