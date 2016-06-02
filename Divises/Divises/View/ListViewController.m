//
//  ListViewController.m
//  Monedes
//
//  Created by Xavier Ramos on 6/1/16.
//  Copyright © 2016 Xavier Ramos. All rights reserved.


#import "ListViewController.h"
#import "AFNetworking.h"
#import "CurrencyDataHelper.h"
#import "ConnectionManager.h"
#import "ActiveTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

@interface ListViewController ()

@property (nonatomic) int moneyNamesFontSize;
@property (nonatomic) int moneyValueMainFontSize;
@property (nonatomic) int moneyValueOthersFontSize;

@property (nonatomic, readonly) ConnectionManager *connectionManager;


@end

@implementation ListViewController{
    
    NSMutableArray *activeCurrencies;
    NSMutableArray *secondaryCurrencies;
    NSDictionary *mainCurrency;
    NSNumberFormatter *numberFormatter;
    
    double valueInput;
    NSString *valueInputString;
}
- (void)handleUpdatedData:(NSNotification*)notification{
    NSLog(@"Received notification!");
    [self.currenciesTableView reloadData];
}
- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self screenConfiguration];
    
    _connectionManager = [[ConnectionManager alloc] init];

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleUpdatedData:)
                                                 name:@"currencyUpdated"
                                               object:nil];
    // NavigationBar appearance
    //-------------------------------------------------------------
    _navigationBar.translucent = NO;
    _navigationBar.tintColor = UIColorFromRGB(0xFF4543);
    _navigationBar.backgroundColor = UIColorFromRGB(0xF5F5F5);
    [_navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor blackColor],
       NSFontAttributeName:[UIFont fontWithName:@"Avenir-Heavy" size:21]}];
    //-------------------------------------------------------------
    
    valueInputString = @"";
    
    activeCurrencies = [NSMutableArray new];
    secondaryCurrencies = [NSMutableArray new];
    
    NSArray *active = [[NSUserDefaults standardUserDefaults] objectForKey:@"activeCurrencies"];
    activeCurrencies = [NSMutableArray arrayWithArray:active];
    mainCurrency = [[NSUserDefaults standardUserDefaults] objectForKey:@"mainCurrency"];

    secondaryCurrencies = [NSMutableArray arrayWithArray:activeCurrencies];
    [secondaryCurrencies removeObject:mainCurrency];
    
    [self setMainCurrencyView];
    [_connectionManager downloadCountriesCurrency];
    
    UIToolbar *keyboardDoneButtonView = [[UIToolbar alloc] init];
    [keyboardDoneButtonView sizeToFit];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(doneClicked:)];
    
    [doneButton setTintColor:UIColorFromRGB(0xFF4543)];
    
    [doneButton setTitleTextAttributes: @{NSForegroundColorAttributeName:UIColorFromRGB(0xFF4543),
                                          NSFontAttributeName:[UIFont fontWithName:@"Avenir-Heavy" size:21]} forState:UIControlStateNormal];
    UIBarButtonItem *flexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *negativeSeparator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSeparator.width = 5;
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:flexible, doneButton,negativeSeparator, nil]];
    
    _valueTextField.inputAccessoryView = keyboardDoneButtonView;
    
    NSNumber *valorInicial = [NSNumber numberWithInt:1];
    _valueTextField.text = [NSString stringWithFormat:@"%@ %@",valorInicial, [mainCurrency objectForKey:@"money_symbol"]];
    valueInput = [valorInicial doubleValue];
    
    numberFormatter = [[NSNumberFormatter alloc]init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    numberFormatter.usesGroupingSeparator = YES;
    [numberFormatter setMaximumFractionDigits:2];
    [numberFormatter setMinimumFractionDigits:2];
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(_valueTextField.frame.size.width-5, 0, 5, 37)];
    _valueTextField.rightView = paddingView;
    _valueTextField.rightViewMode = UITextFieldViewModeAlways;
}

-(void)doneClicked:(id)sender{
    [_valueTextField resignFirstResponder];
    
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *elValor = [f numberFromString:valueInputString];
    valueInput = [elValor doubleValue];
    if (valueInput == 0) {
        _valueTextField.text = [NSString stringWithFormat:@"0 %@",[mainCurrency objectForKey:@"money_symbol"]];
    }
    
    [UIView transitionWithView:_currenciesTableView
                      duration:0.7f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^(void) {
                        [_currenciesTableView reloadData];
                        [self setMainCurrencyView];
                        valueInputString = @"";
                        
                    } completion:NULL];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range     replacementString:(NSString *)string{
    
    NSNumber *valueNumber;
    NSString *valueString;
    
    if ([string isEqualToString:@""]) {
        if (valueInputString.length<1) {
            _valueTextField.text = [mainCurrency objectForKey:@"money_symbol"];
            return NO;
        }else{
            valueInputString = [valueInputString substringToIndex:[valueInputString length]-1];
            if (valueInputString.length <1) {
                valueString = [numberFormatter stringFromNumber:[NSNumber numberWithDouble:0]];
            }else{
                valueNumber = [numberFormatter numberFromString:valueInputString];
                valueString = [numberFormatter stringFromNumber:valueNumber];
            }
        }
    }else{
        valueInputString = [NSString stringWithFormat:@"%@%@",valueInputString,string];
        valueNumber = [numberFormatter numberFromString:valueInputString];
        valueString = [numberFormatter stringFromNumber:valueNumber];
    }
    
    NSString *tot = [NSString stringWithFormat:@"%@ %@",valueString,[mainCurrency objectForKey:@"money_symbol"]];
    _valueTextField.text = tot;
    
    return NO;
}

-(void)setMainCurrencyView{
    
    NSString *moneyText = [NSString stringWithFormat:@"%@",[mainCurrency objectForKey:@"money_name"]];
    [_moneyLabel setText: [moneyText uppercaseString]];
    [_moneyLabel setFont:[UIFont fontWithName:@"Avenir-Heavy" size:_moneyNamesFontSize]];
    [_valueTextField setFont:[UIFont fontWithName:@"Avenir-Heavy" size:_moneyValueMainFontSize]];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return secondaryCurrencies.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"activeTableViewCell";
    ActiveTableViewCell *cell = (ActiveTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    NSDictionary *currency = [NSDictionary new];

    currency = secondaryCurrencies[indexPath.row];
    
    double exchange = [CurrencyDataHelper calculateChange:[NSNumber numberWithDouble:valueInput] fromCurrentCurrency:[mainCurrency objectForKey:@"money_code"] toMainCurrency:[currency objectForKey:@"money_code"]];
    cell.valueLabel.text = [NSString stringWithFormat:@"%@ %@",[numberFormatter stringFromNumber:[NSNumber numberWithDouble:exchange]],[currency objectForKey:@"money_symbol"]];
    
    NSString *moneyText = [NSString stringWithFormat:@"%@",[currency objectForKey:@"money_name"]];
    [cell.moneyNameLabel setText: [moneyText uppercaseString]];
    
    double currentValue = [CurrencyDataHelper calculateChange:[NSNumber numberWithInt:1] fromCurrentCurrency:[currency objectForKey:@"money_code"] toMainCurrency:[mainCurrency objectForKey:@"money_code"]];
    
    cell.currentValueLabel.text = [NSString stringWithFormat:@"1 %@ = %@ %@", [currency objectForKey:@"money_symbol"],[numberFormatter stringFromNumber:[NSNumber numberWithDouble:currentValue]], [mainCurrency objectForKey:@"money_symbol"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *tempMainCurrency = secondaryCurrencies[indexPath.row];
    [secondaryCurrencies removeObject:tempMainCurrency];
    [secondaryCurrencies addObject:mainCurrency];
    mainCurrency = tempMainCurrency;
    [[NSUserDefaults standardUserDefaults]setValue:mainCurrency forKey:@"mainCurrency"];
    [[NSUserDefaults standardUserDefaults]setValue:activeCurrencies forKey:@"activeCurrencies"];
    valueInput = 1;
    valueInputString = @"";
    _valueTextField.text = [NSString stringWithFormat:@"1 %@",[mainCurrency objectForKey:@"money_symbol"]];
    [UIView transitionWithView:_currenciesTableView
                      duration:0.7f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^(void) {
                        [_currenciesTableView reloadData];
                        [self setMainCurrencyView];
                        
                    } completion:NULL];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSDictionary *currency = secondaryCurrencies[indexPath.row];
        [secondaryCurrencies removeObject:currency];
        [activeCurrencies removeObject:currency];
        
        [[NSUserDefaults standardUserDefaults] setValue:activeCurrencies forKey:@"activeCurrencies"];
        
        [_currenciesTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        [tableView endUpdates];
    }
}

-(IBAction)addCurrencyAction{
    [self performSegueWithIdentifier:@"toAddSegue" sender:nil];
}

-(IBAction)toInfoAction:(id)sender{
    [self performSegueWithIdentifier:@"toInfoSegue" sender:nil];
}

-(void)screenConfiguration{
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    if( screenHeight > 480 && screenHeight < 667 ){
        //NSLog(@"iPhone 5/5s");
        _mainCurrencyViewHeight.constant = 150;
        _topMainValue.constant = -10;
        
        _moneyNamesFontSize = 13;
        _moneyValueMainFontSize = 70;
        _moneyValueOthersFontSize = 33;
        
    } else if ( screenHeight > 480 && screenHeight < 736 ){
        //NSLog(@"iPhone 6");
        _mainCurrencyViewHeight.constant = 160;
        _topMainValue.constant = -4;
        
        _moneyNamesFontSize = 15;
        _moneyValueMainFontSize = 83;
        _moneyValueOthersFontSize = 36;
        
    } else if ( screenHeight > 480 ){
        //NSLog(@"iPhone 6 Plus");
        _mainCurrencyViewHeight.constant = 180;
        _topMainValue.constant = 3;
        
        _moneyNamesFontSize = 16;
        _moneyValueMainFontSize = 85;
        _moneyValueOthersFontSize = 40;
        
    } else {
        //NSLog(@"iPhone 4/4s");
        _mainCurrencyViewHeight.constant = 120;
        _topMainValue.constant = -10;
        
        _moneyNamesFontSize = 13;
        _moneyValueMainFontSize = 70;
        _moneyValueOthersFontSize = 33;
    }
}

@end
