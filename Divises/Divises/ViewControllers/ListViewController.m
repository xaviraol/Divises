//
//  ListViewController.m
//  Monedes
//
//  Created by Xavier Ramos on 6/1/16.
//  Copyright © 2016 Xavier Ramos. All rights reserved.


#import "ListViewController.h"
#import "AFNetworking.h"
#import "ActiveTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

@interface ListViewController ()


@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

//constraints and font-sizes for screens
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *mainCurrencyViewHeight;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *topMainValue;

@property (nonatomic) int moneyNamesFontSize;
@property (nonatomic) int moneyValueMainFontSize;
@property (nonatomic) int moneyValueOthersFontSize;

@property (nonatomic, weak) IBOutlet UITableView *currenciesTableView;
@property (nonatomic, strong) NSMutableArray *activeCurrencies;
@property (nonatomic, strong) NSMutableArray *secondaryCurrencies;
@property (nonatomic, strong) NSDictionary *mainCurrency;

//mainCurrencyView
@property (nonatomic, weak) IBOutlet UIView *mainCurrencyView;
@property (nonatomic, weak) IBOutlet UILabel *moneyLabel;
@property (nonatomic, weak) IBOutlet UITextField *valueTextField;

@property (nonatomic, strong) NSNumberFormatter *numberFormatter;

@property (nonatomic) double valorInput;
@property (nonatomic, strong) NSString *valorInputString;

-(IBAction)addCurrencyAction;
-(IBAction)toInfoAction:(id)sender;


@property (nonatomic) BOOL cellSelected;
@property (nonatomic) BOOL scrolling;
@end

@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self screenConfiguration];

    // NavigationBar appearance
    //-------------------------------------------------------------
    _navigationBar.translucent = NO;
    _navigationBar.tintColor = UIColorFromRGB(0xFF4543);
    _navigationBar.backgroundColor = UIColorFromRGB(0xF5F5F5);
    [_navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor blackColor],
       NSFontAttributeName:[UIFont fontWithName:@"Avenir-Heavy" size:21]}];
    //-------------------------------------------------------------

    _valorInputString = @"";
    
    _activeCurrencies = [NSMutableArray new];
    _secondaryCurrencies = [NSMutableArray new];
    
    NSArray *active = [[NSUserDefaults standardUserDefaults] objectForKey:@"activeCurrencies"];
    _activeCurrencies = [NSMutableArray arrayWithArray:active];
    _mainCurrency = [[NSUserDefaults standardUserDefaults] objectForKey:@"mainCurrency"];
    
//    if (_mainCurrency == nil){
//        _mainCurrency = _activeCurrencies[0];
//        [[NSUserDefaults standardUserDefaults]setValue:_mainCurrency forKey:@"mainCurrency"];
//    }else{
//        BOOL hihamain= NO;
//        for (NSDictionary *dict in _activeCurrencies) {
//            if ([dict isEqualToDictionary:_mainCurrency]) {
//                hihamain= YES;
//            }
//        }
//        if (!hihamain) {
//            _mainCurrency = _activeCurrencies[0];
//            [[NSUserDefaults standardUserDefaults]setValue:_mainCurrency forKey:@"mainCurrency"];
//        }
//    }
    _secondaryCurrencies = [NSMutableArray arrayWithArray:_activeCurrencies];
    [_secondaryCurrencies removeObject:_mainCurrency];
    
    [self setMainCurrencyView];
    [self downloadCountriesCurrency];
    
    
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
    _valueTextField.text = [NSString stringWithFormat:@"%@ %@",valorInicial, [_mainCurrency objectForKey:@"money_symbol"]];
    _valorInput = [valorInicial doubleValue];
    
    _numberFormatter = [[NSNumberFormatter alloc]init];
    [_numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    _numberFormatter.usesGroupingSeparator = YES;
    [_numberFormatter setMaximumFractionDigits:2];
    [_numberFormatter setMinimumFractionDigits:2];
    [_numberFormatter setDecimalSeparator:@","];
    [_numberFormatter setGroupingSeparator:@"."];
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(_valueTextField.frame.size.width-5, 0, 5, 37)];
    _valueTextField.rightView = paddingView;
    _valueTextField.rightViewMode = UITextFieldViewModeAlways;
}

-(void)doneClicked:(id)sender{
    [_valueTextField resignFirstResponder];

    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *elValor = [f numberFromString:_valorInputString];
    _valorInput = [elValor doubleValue];
    if (_valorInput == 0) {
        _valueTextField.text = [NSString stringWithFormat:@"0 %@",[_mainCurrency objectForKey:@"money_symbol"]];
    }

    [UIView transitionWithView:_currenciesTableView
                      duration:0.7f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^(void) {
                        [_currenciesTableView reloadData];
                        [self setMainCurrencyView];
                        _valorInputString = @"";

                    } completion:NULL];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range     replacementString:(NSString *)string{
    
    //NSLog(@"el Text: %@",string);
    if ([string isEqualToString:@""]) {
        if (_valorInputString.length<1) {
            _valueTextField.text = [_mainCurrency objectForKey:@"money_symbol"];
            return NO;
        }else{
        NSString *newString = [_valorInputString substringToIndex:[_valorInputString length]-1];
        _valorInputString = newString;
        }
    }else{
    NSString *temp = [NSString stringWithFormat:@"%@%@",_valorInputString,string];
    _valorInputString = temp;
    }
    
    _valueTextField.text = [NSString stringWithFormat:@"%@ %@",_valorInputString,[_mainCurrency objectForKey:@"money_symbol"]];
    return NO;
}

-(void)setMainCurrencyView{

    NSString *moneyText = [NSString stringWithFormat:@"%@",[_mainCurrency objectForKey:@"money_name"]];
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
    
    return _secondaryCurrencies.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *currency = [NSDictionary new];

        static NSString *CellIdentifier = @"activeTableViewCell";
        ActiveTableViewCell *cell = [_currenciesTableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
        currency = _secondaryCurrencies[indexPath.row];
    
        double exchange = [self calculateChange:[NSNumber numberWithDouble:_valorInput] fromCurrentCurrency:[_mainCurrency objectForKey:@"money_code"] toMainCurrency:[currency objectForKey:@"money_code"]];
        cell.valueLabel.text = [NSString stringWithFormat:@"%@ %@",[_numberFormatter stringFromNumber:[NSNumber numberWithDouble:exchange]],[currency objectForKey:@"money_symbol"]];
    
        [cell.valueLabel setFont:[UIFont fontWithName:@"Avenir-Black" size:_moneyValueOthersFontSize]];

        NSString *moneyText = [NSString stringWithFormat:@"%@",[currency objectForKey:@"money_name"]];
        [cell.moneyNameLabel setText: [moneyText uppercaseString]];
        [cell.moneyNameLabel setFont:[UIFont fontWithName:@"Avenir-Heavy" size:_moneyNamesFontSize]];


        double currentValue = [self calculateChange:[NSNumber numberWithInt:1] fromCurrentCurrency:[currency objectForKey:@"money_code"] toMainCurrency:[_mainCurrency objectForKey:@"money_code"]];
    
    cell.currentValueLabel.text = [NSString stringWithFormat:@"1 %@ = %@ %@", [currency objectForKey:@"money_symbol"],[_numberFormatter stringFromNumber:[NSNumber numberWithDouble:currentValue]], [_mainCurrency objectForKey:@"money_symbol"]];
    
    [cell.currentValueLabel setFont:[UIFont fontWithName:@"Avenir-Medium" size:_moneyNamesFontSize]];
    
        return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
        NSDictionary *tempMainCurrency = _secondaryCurrencies[indexPath.row];
        [_secondaryCurrencies removeObject:tempMainCurrency];
        [_secondaryCurrencies addObject:_mainCurrency];
        _mainCurrency = tempMainCurrency;
        [[NSUserDefaults standardUserDefaults]setValue:_mainCurrency forKey:@"mainCurrency"];
        [[NSUserDefaults standardUserDefaults]setValue:_activeCurrencies forKey:@"activeCurrencies"];
    _valorInput = 1;
    _valorInputString = @"";
    _valueTextField.text = [NSString stringWithFormat:@"1 %@",[_mainCurrency objectForKey:@"money_symbol"]];
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
        NSDictionary *currency = _secondaryCurrencies[indexPath.row];
        [_secondaryCurrencies removeObject:currency];
        [_activeCurrencies removeObject:currency];
        
        [[NSUserDefaults standardUserDefaults] setValue:_activeCurrencies forKey:@"activeCurrencies"];
        
        [_currenciesTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];

        [tableView endUpdates];
    }
}

-(double) calculateChange:(NSNumber *)value fromCurrentCurrency:(NSString *)currentCurrency toMainCurrency:(NSString *)mainCurrency{
    
    NSDictionary *currencyUpdated = [[NSUserDefaults standardUserDefaults] objectForKey:@"currencyUpdated"];
    NSNumber *valor1 = [currencyUpdated objectForKey:currentCurrency];
    double resultat = [valor1 doubleValue] / [value doubleValue];
    
    NSNumber *valor2 = [currencyUpdated objectForKey:mainCurrency];
    double resultat2 = [valor2 doubleValue] / resultat;
    
    return resultat2;
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

-(void) downloadCountriesCurrency{
    
    static NSString * const BaseURLString = @"http://www.apilayer.net/api/live?access_key=9cd66e5ae1e9b2d10f0380df9ee190fb&format=1";
    
    NSURL *url = [NSURL URLWithString:BaseURLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary  *currencies = responseObject;
        NSDictionary *quotes = [currencies objectForKey:@"quotes"];
        
        NSMutableDictionary *currencyUpdated = [NSMutableDictionary new];
        
        for (NSString *key in [quotes allKeys]) {
            NSRange range = NSMakeRange(3,3);
            NSString *newKey = [key substringWithRange:range];
            
            NSNumber *value = [quotes objectForKey:key];
            [currencyUpdated setValue:value forKey:newKey];
        }
        //NSLog(@"CurrencyUpdated: %@",currencyUpdated);
        [[NSUserDefaults standardUserDefaults] setValue:currencyUpdated forKey:@"currencyUpdated"];
        [UIView transitionWithView:_currenciesTableView
                          duration:0.7f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^(void) {
                            [_currenciesTableView reloadData];
                        } completion:NULL];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error downloading data");        
    }];
    [operation start];
}

- (NSDictionary *)parseDataFromJsonsToDictionariesfromFilePath:(NSString*)filepath andFormat:(NSString *)formatType{
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:filepath ofType:formatType];
    
    NSData* data = [NSData dataWithContentsOfFile:filePath];
    __autoreleasing NSError* error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSDictionary *output = result;
    //NSLog(@"Countries: %lu",(unsigned long)output.count);
    
    return  output;
}


@end
