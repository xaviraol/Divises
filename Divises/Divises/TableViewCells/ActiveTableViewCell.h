//
//  ActiveTableViewCell.h
//  Monedes
//
//  Created by Xavier Ramos on 28/1/16.
//  Copyright © 2016 Xavier Ramos. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActiveTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *valueLabel;
@property (nonatomic, weak) IBOutlet UILabel *moneyNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *currentValueLabel;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *topCurrent;

@property (nonatomic) int moneyNamesFontSize;
@property (nonatomic) int moneyValueOthersFontSize;

@end
