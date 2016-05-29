//
//  AddCurrencyCell.m
//  Monedes
//
//  Created by Xavier Ramos on 27/1/16.
//  Copyright © 2016 Xavier Ramos. All rights reserved.
//

#import "AddCurrencyCell.h"

@implementation AddCurrencyCell

- (void)awakeFromNib {
    // Initialization code
    _imageSelected.layer.cornerRadius = _imageSelected.bounds.size.height/2;
    _imageSelected.backgroundColor = UIColorFromRGB(0xFF4543);

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
