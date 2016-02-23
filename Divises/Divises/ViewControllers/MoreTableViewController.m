//
//  MoreTableViewController.m
//  Monedes
//
//  Created by Xavier Ramos on 4/2/16.
//  Copyright © 2016 Xavier Ramos. All rights reserved.
//

#import "MoreTableViewController.h"

@interface MoreTableViewController ()

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

@implementation MoreTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // UINavigationBar Appearance
    //--------------------------------------------------------------
    _navigationBar.translucent = NO;
    _navigationBar.tintColor = UIColorFromRGB(0xFF4543);
    _navigationBar.backgroundColor = UIColorFromRGB(0xF5F5F5);
    [_navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor blackColor],
       NSFontAttributeName:[UIFont fontWithName:@"Avenir-Heavy" size:21]}];
    //--------------------------------------------------------------
    
    //BarButton Appearance
    //--------------------------------------------------------------
    [_barButton setTitleTextAttributes:@{NSForegroundColorAttributeName:UIColorFromRGB(0xFF4543),
                                         NSFontAttributeName:[UIFont fontWithName:@"Avenir-Heavy" size:17]} forState:UIControlStateNormal];
    //--------------------------------------------------------------
    
    //Label sizes:
    //--------------------------------------------------------------
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    int fontSize;
    if( screenHeight > 480 && screenHeight < 667 ){
        //NSLog(@"iPhone 5/5s");
        fontSize = 13;
        _heightLabelHow.constant = 120;
        
        _topHowTitle.constant = 10;
        _topHow.constant = -4;
        _topCurrency.constant = -7;
        _topInfoCurrency.constant = -7;
        
        _topXavi.constant = 25;
        
    } else if ( screenHeight > 480 && screenHeight < 736 ){
        //NSLog(@"iPhone 6");
        fontSize = 15;
        _heightLabelHow.constant = 140;
        _topHowTitle.constant = 20;

        _topHow.constant = 0;
        _topCurrency.constant = -3;
        _topInfoCurrency.constant = 0;

        _topXavi.constant = 25;

    } else if ( screenHeight > 480 ){
        //NSLog(@"iPhone 6 Plus");
        fontSize = 15;
        _heightLabelHow.constant = 140;
        _topHowTitle.constant = 20;

        _topHow.constant = -8;
        _topCurrency.constant = -1;
        _topInfoCurrency.constant = 0;

        _topXavi.constant = 25;
    } else {
        //NSLog(@"iPhone 4/4s");
        fontSize = 13;
        _heightLabelHow.constant = 120;
        
        _topHowTitle.constant = 10;
        _topHow.constant = -4;
        _topCurrency.constant = -7;
        _topInfoCurrency.constant = -7;
        
        _topXavi.constant = 25;

    }
    [_howTitleLabel setFont:[UIFont fontWithName:@"Avenir-Heavy" size:fontSize]];
    [_howTextLabel setFont:[UIFont fontWithName:@"Avenir-Medium" size:fontSize+1]];
    
    [_currencyTitleLabel setFont:[UIFont fontWithName:@"Avenir-Heavy" size:fontSize]];
    [_currencyTextLabel setFont:[UIFont fontWithName:@"Avenir-Medium" size:fontSize+1]];
    [_currencyInfoLabel setFont:[UIFont fontWithName:@"Avenir-Medium" size:fontSize+1]];

    
    [_xaviTitleLabel setFont:[UIFont fontWithName:@"Avenir-Heavy" size:fontSize]];
    [_xaviTextLabel setFont:[UIFont fontWithName:@"Avenir-Medium" size:fontSize+1]];
    
    //--------------------------------------------------------------

}

-(IBAction)backToList:(id)sender{
    [self performSegueWithIdentifier:@"backToListSegue" sender:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

@end
