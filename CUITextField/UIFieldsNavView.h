//
//  UIFieldsNavView.h
//  CUITextField
//
//  Created by alex.kelbas on 24/10/2012.
//  Copyright (c) 2012 tecmark. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFieldsNavView : UIView
@property (nonatomic, strong) IBOutletCollection(UITextField) NSArray *textFields;
@end
