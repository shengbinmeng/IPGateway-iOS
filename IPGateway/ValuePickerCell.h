//
//  ValuePickerCell.h
//  IPGateway
//
//  Created by Shengbin Meng on 14/9/19.
//  Copyright (c) 2014 Peking University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ValuePickerCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *label;
@property (nonatomic, retain) IBOutlet UILabel *valueLable;
@property (nonatomic, retain) IBOutlet UIStepper *stepper;

@end
