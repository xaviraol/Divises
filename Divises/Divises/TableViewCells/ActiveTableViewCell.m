//
//  ActiveTableViewCell.m
//  Monedes
//
//  Created by Xavier Ramos on 28/1/16.
//  Copyright © 2016 Xavier Ramos. All rights reserved.
//

#import "ActiveTableViewCell.h"

@implementation ActiveTableViewCell

- (void)awakeFromNib {
    // Initialization code
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    if( screenHeight > 480 && screenHeight < 667 ){
        NSLog(@"iPhone 5/5s");
        _topCurrent.constant = -6;
        
    } else if ( screenHeight > 480 && screenHeight < 736 ){
        NSLog(@"iPhone 6");
        _topCurrent.constant = -6;

        
    } else if ( screenHeight > 480 ){
        NSLog(@"iPhone 6 Plus");
        _topCurrent.constant = -3;

    } else {
        NSLog(@"iPhone 4/4s");
        _topCurrent.constant = -6;

    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
