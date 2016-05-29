//
//  AddViewController.h
//  Monedes
//
//  Created by Xavier Ramos on 6/1/16.
//  Copyright © 2016 Xavier Ramos. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic,weak) IBOutlet UIBarButtonItem *barButton;

@property (nonatomic, weak) IBOutlet UITableView *currenciesTableView;
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;

@property (nonatomic,weak) IBOutlet UISegmentedControl *segmentedControl;

- (IBAction) segmentAction:(id)sender;
- (IBAction) backToListAction;


@end
