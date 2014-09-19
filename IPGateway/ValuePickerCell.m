//
//  ValuePickerCell.m
//  IPGateway
//
//  Created by Shengbin Meng on 14/9/19.
//  Copyright (c) 2014 Peking University. All rights reserved.
//

#import "ValuePickerCell.h"

@implementation ValuePickerCell
@synthesize label, valueLable;
@synthesize stepper;

- (void)dealloc {
    [self.label release];
    [self.valueLable release];
    [self.stepper release];
    [super dealloc];
}

@end
