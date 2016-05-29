//
//  MoreTableViewController.h
//  Monedes
//
//  Created by Xavier Ramos on 4/2/16.
//  Copyright © 2016 Xavier Ramos. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoreTableViewController : UITableViewController

-(IBAction)backToList:(id)sender;

@property (nonatomic, weak) IBOutlet UIBarButtonItem *barButton;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

@property (nonatomic, weak) IBOutlet UILabel *howTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *howTextLabel;

@property (nonatomic, weak) IBOutlet UILabel *currencyTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *currencyTextLabel;
@property (nonatomic, weak) IBOutlet UILabel *currencyInfoLabel;

@property (nonatomic, weak) IBOutlet UILabel *xaviTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *xaviTextLabel;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *heightLabelHow;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *topHowTitle;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *topHow;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *topCurrency;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *topInfoCurrency;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *topXavi;

@end
