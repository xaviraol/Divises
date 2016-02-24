//
//  AddViewController.m
//  Monedes
//
//  Created by Xavier Ramos on 6/1/16.
//  Copyright © 2016 Xavier Ramos. All rights reserved.
//

#import "AddViewController.h"
#import "AddCurrencyCell.h"

@interface AddViewController ()

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic,weak) IBOutlet UIBarButtonItem *barButton;

//constraints i font sizes:
@property (nonatomic) int searchBarFontSize;
@property (nonatomic) int textCellsFontSize;

@property (nonatomic, weak) IBOutlet UITableView *currenciesTableView;

@property (nonatomic, strong) NSMutableArray *allCurrencies;

@property (nonatomic, strong) NSArray *alreadyActiveCurrencies;
@property (nonatomic, strong) NSMutableArray *activeCurrencies;

@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic) BOOL searchBarActive;

@property (nonatomic,weak) IBOutlet UISegmentedControl *segmentedControl;
- (IBAction)segmentAction:(id)sender;

@property (nonatomic,strong) NSArray *popularitySortedCurrencies;
@property (nonatomic,strong) NSArray *filteredPopularitySortedCurrencies;


@property (nonatomic,strong) NSDictionary *lettersSections;
@property (nonatomic,strong) NSArray *sortedLetters;
@property (nonatomic,strong) NSDictionary *lettersFilteredSections;
@property (nonatomic,strong) NSArray *sortedFilteredLetters;

@property (nonatomic, strong) NSArray *allCountries;
@property (nonatomic, strong) NSDictionary *countriesSections;
@property (nonatomic, strong) NSArray *sortedCountries;
@property (nonatomic, strong) NSDictionary *countriesFilteredSections;
@property (nonatomic, strong) NSArray *sortedFilteredCountries;

@property (nonatomic, strong) NSArray *filteredCountries;

@property (nonatomic) int sorting;


-(IBAction)backToListAction;

@end

@implementation AddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self screenConfiguration];
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
    
    // UISearchBar Appearance
    // -------------------------------------------------------------
    _searchBar.layer.borderWidth = 1;
    _searchBar.layer.borderColor = UIColorFromRGB(0xF5F5F5).CGColor;
    _searchBar.barTintColor = UIColorFromRGB(0xF5F5F5);
    _searchBar.backgroundColor = UIColorFromRGB(0xF5F5F5);
    UITextField *searchField = [_searchBar valueForKey:@"searchField"];
    searchField.backgroundColor = [UIColor whiteColor];
    searchField.textColor = [UIColor grayColor];
    [searchField setFont:[UIFont fontWithName:@"Avenir" size:_searchBarFontSize]];
    searchField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Search Currencies"];



    // -------------------------------------------------------------
    
    // UISegmentedControl Appearance
    //--------------------------------------------------------------
    _segmentedControl.tintColor = UIColorFromRGB(0xF5F5F5);
    _segmentedControl.backgroundColor = UIColorFromRGB(0xF5F5F5);
    [_segmentedControl setTitleTextAttributes: @{NSForegroundColorAttributeName:[UIColor blackColor],
                                                 NSFontAttributeName:[UIFont fontWithName:@"Avenir" size:_textCellsFontSize]} forState:UIControlStateNormal];
    [_segmentedControl setTitleTextAttributes: @{NSForegroundColorAttributeName:UIColorFromRGB(0xFF4543),
                                                 NSFontAttributeName:[UIFont fontWithName:@"Avenir" size:_textCellsFontSize]} forState:UIControlStateSelected];

    //--------------------------------------------------------------
    
    _searchBarActive = NO;

    // agafem les currencies:
    NSDictionary *currenciesDictionary = [self parseDataFromJsonsToDictionariesfromFilePath:@"RegionCountriesCurrency" andFormat:@".json"];
    _allCurrencies = [NSMutableArray new];
    
    for (NSString *key in [currenciesDictionary allKeys]) {
        NSDictionary *currency = [currenciesDictionary objectForKey:key];
        [_allCurrencies addObject:currency];
    }
    
    // agafem tots els paisos:
    NSDictionary *countriesDictionary = [self parseDataFromJsonsToDictionariesfromFilePath:@"Countries" andFormat:@".json"];
    NSMutableArray *unsortedCountries = [NSMutableArray new];
    _allCountries = [NSArray new];
    
    for (NSString *key in [countriesDictionary allKeys]) {
        NSDictionary *currency = [countriesDictionary objectForKey:key];
        [unsortedCountries addObject:currency];
    }
    _allCountries = unsortedCountries;
    
    _activeCurrencies = [NSMutableArray new];
    _alreadyActiveCurrencies = [[NSUserDefaults standardUserDefaults] objectForKey:@"activeCurrencies"];
    _activeCurrencies = [NSMutableArray arrayWithArray:_alreadyActiveCurrencies];
    
    _sorting = 0;
    //popularity
    _popularitySortedCurrencies = [self sortingByPopularity:_allCurrencies];
    
    //letters
    _lettersSections = [self sortingByLetters:_allCurrencies];
    NSArray *unsortedLetters = [_lettersSections allKeys];
    _sortedLetters = [unsortedLetters sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

    //countries
    _countriesSections = [self sortingByCountry:_allCountries];
    NSArray *unCountries = [_countriesSections allKeys];
    _sortedCountries = [unCountries sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)segmentAction:(id)sender{
    _sorting = (int)_segmentedControl.selectedSegmentIndex;
    if (_searchBarActive) {
        _searchBarActive = NO;
        _searchBar.text = @"";
    }
    [_currenciesTableView reloadData];
}

#pragma mark - Table View Delegate Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_searchBarActive){
        if (_sorting == 1) {
            return _lettersFilteredSections.count;
        }else if (_sorting ==2 ){
            return _countriesFilteredSections.count;
        }else{
            return 1;
        }
    }else{
        if (_sorting == 1) {
            return _lettersSections.count;
        }else if (_sorting == 2){
            return _countriesSections.count;
        }else{
            return 1;
        }
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_searchBarActive) {
        switch (_sorting) {
            case 0:
                return _filteredPopularitySortedCurrencies.count;
                break;
            case 1:{
                NSString *initialChar = [_sortedFilteredLetters objectAtIndex:section];
                NSArray *currenciesWithThisChar = [_lettersFilteredSections objectForKey:initialChar];
                return [currenciesWithThisChar count];
                break;
            }case 2:{
                NSString *initialChar = [_sortedFilteredCountries objectAtIndex:section];
                NSArray *currenciesWithThisChar = [_countriesFilteredSections objectForKey:initialChar];
                return [currenciesWithThisChar count];
                break;
            }default:
                return _filteredCountries.count;
                break;
        }
    }else{
        if(_sorting == 1 ){
            
            NSString *initialChar = [_sortedLetters objectAtIndex:section];
            NSArray *currenciesWithThisChar = [_lettersSections objectForKey:initialChar];
            return [currenciesWithThisChar count];
            
        }else if (_sorting==2) {
            
            NSString *initialChar = [_sortedCountries objectAtIndex:section];
            NSArray *currenciesWithThisChar = [_countriesSections objectForKey:initialChar];
            return [currenciesWithThisChar count];
            
        }else{
            return _allCurrencies.count;
        }
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (_sorting==1) {
        return 40;
    }else if (_sorting==2){
        return 40;
    }else{
        return 0;
    }
}
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UITableViewHeaderFooterView *av=[[UITableViewHeaderFooterView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    av.backgroundColor = UIColorFromRGB(0xF5F5F5);
    if (_sorting == 1) {
        NSString *initialChar;
        if (_searchBarActive){
            initialChar = [_sortedFilteredLetters objectAtIndex:section];
        }else{
            initialChar = [_sortedLetters objectAtIndex:section];
        }
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 7, 200, 30)];
        [titleLabel setText:initialChar];
        [av addSubview:titleLabel];
        
        return av;
    }else if (_sorting == 2){
        
        NSString *initialChar;
        if (_searchBarActive){
            initialChar = [_sortedFilteredCountries objectAtIndex:section];
        }else{
            initialChar = [_sortedCountries objectAtIndex:section];
        }
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 7, 200, 30)];
        [titleLabel setText:initialChar];
        [av addSubview:titleLabel];
        
        return av;
    }else{
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"addCurrencyCell";
    AddCurrencyCell *cell = [_currenciesTableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSDictionary *currency = [NSDictionary new];
    if (cell == nil){
    cell = [[AddCurrencyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    [cell.labelName setFont:[UIFont fontWithName:@"Avenir-Heavy" size:_textCellsFontSize]];
    if (_searchBarActive) {
        switch (_sorting) {
            case 0:{
                currency = _filteredPopularitySortedCurrencies[indexPath.row];
                cell.labelName.text = [NSString stringWithFormat:@"%@ - %@", [currency objectForKey:@"money_symbol"],[currency objectForKey:@"money_name"]];
                break;
            }case 1:{
                
                NSString *initialChar = [_sortedFilteredLetters objectAtIndex:indexPath.section];
                NSArray *currenciesWithThisChar = [_lettersFilteredSections objectForKey:initialChar];
                currency = [currenciesWithThisChar objectAtIndex:indexPath.row];
                cell.labelName.text = [NSString stringWithFormat:@"%@ - %@", [currency objectForKey:@"money_symbol"],[currency objectForKey:@"money_name"]];
                break;
            }case 2:{
                NSString *initialChar = [_sortedFilteredCountries objectAtIndex:indexPath.section];
                NSArray *currenciesWithThisChar = [_countriesFilteredSections objectForKey:initialChar];
                currency = [currenciesWithThisChar objectAtIndex:indexPath.row];
                cell.labelName.text = [NSString stringWithFormat:@"%@ - %@",[currency objectForKey:@"country_name"],[currency objectForKey:@"money_symbol"]];
                break;
            }default:
                break;
        }
    }else{
        switch (_sorting) {
            case 0:{
                currency = _popularitySortedCurrencies[indexPath.row];
                cell.labelName.text = [NSString stringWithFormat:@"%@ - %@", [currency objectForKey:@"money_symbol"],[currency objectForKey:@"money_name"]];
                break;
            }case 1:{
                NSString *initialChar = [_sortedLetters objectAtIndex:indexPath.section];
                NSArray *currenciesWithThisChar = [_lettersSections objectForKey:initialChar];
                currency = [currenciesWithThisChar objectAtIndex:indexPath.row];
                cell.labelName.text = [NSString stringWithFormat:@"%@ - %@", [currency objectForKey:@"money_symbol"],[currency objectForKey:@"money_name"]];
                break;
            }case 2:{
                NSString *initialChar = [_sortedCountries objectAtIndex:indexPath.section];
                NSArray *currenciesWithThisChar = [_countriesSections objectForKey:initialChar];
                currency = [currenciesWithThisChar objectAtIndex:indexPath.row];
                cell.labelName.text = [NSString stringWithFormat:@"%@ - %@",[currency objectForKey:@"country_name"],[currency objectForKey:@"money_symbol"]];
                break;
                
            }default:
                break;
        }
    }
    NSString *currentCode = [currency objectForKey:@"money_code"];
    cell.imageSelected.hidden = YES;
    for (NSDictionary *dict in _activeCurrencies) {
        NSString *activeCode = [dict objectForKey:@"money_code"];
        if([currentCode isEqualToString:activeCode]){
            //cell.accessoryType = UITableViewCellAccessoryCheckmark;
            cell.imageSelected.hidden = NO;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //[_searchBar resignFirstResponder];

    NSDictionary *currency = [NSDictionary new];
    AddCurrencyCell *cell = (AddCurrencyCell*)[_currenciesTableView cellForRowAtIndexPath:indexPath];
    
    if (_searchBarActive) {
        switch (_sorting) {
            case 0:
                currency = _filteredPopularitySortedCurrencies[indexPath.row];
                break;
            case 1:{
                NSString *initialChar = [_sortedFilteredLetters objectAtIndex:indexPath.section];
                NSArray *currenciesWithThisChar = [_lettersFilteredSections objectForKey:initialChar];
                currency = [currenciesWithThisChar objectAtIndex:indexPath.row];
                break;
            }case 2:{
                NSString *initialChar = [_sortedFilteredCountries objectAtIndex:indexPath.section];
                NSArray *currenciesWithThisChar = [_countriesFilteredSections objectForKey:initialChar];
                currency = [currenciesWithThisChar objectAtIndex:indexPath.row];
                break;
            }default:
                break;
        }
    }else{
        switch (_sorting) {
            case 0:
                currency = _popularitySortedCurrencies[indexPath.row];
                break;
            case 1:{
                NSString *initialChar = [_sortedLetters objectAtIndex:indexPath.section];
                NSArray *currenciesWithThisChar = [_lettersSections objectForKey:initialChar];
                currency = [currenciesWithThisChar objectAtIndex:indexPath.row];
                break;
            }case 2:{
                NSString *initialChar = [_sortedCountries objectAtIndex:indexPath.section];
                NSArray *currenciesWithThisChar = [_countriesSections objectForKey:initialChar];
                currency = [currenciesWithThisChar objectAtIndex:indexPath.row];
                break;
            }default:
                break;
        }
    }
    
    BOOL jahies = NO;
    NSString *currentCode = [currency objectForKey:@"money_code"];
    NSString *activeCode;
    NSDictionary *currencyTemp;
    
    for (int i=0; i<_activeCurrencies.count; i++) {
        currencyTemp = _activeCurrencies[i];
        activeCode = [currencyTemp objectForKey:@"money_code"];
        if ([currentCode isEqualToString:activeCode]) {
            jahies = YES;
            break;
        }
    }
    if (jahies) {
        //cell.accessoryType = UITableViewCellAccessoryNone;
        cell.imageSelected.hidden = YES;
        [_activeCurrencies removeObject:currencyTemp];
    }else{
        //cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.imageSelected.hidden = NO;
        for (NSDictionary *dict in _allCurrencies) {
            NSString *moneyCode = [dict objectForKey:@"money_code"];
            if ([moneyCode isEqualToString:currentCode]) {
                [_activeCurrencies addObject:dict];
                break;
            }
        }
    }
    [[NSUserDefaults standardUserDefaults] setValue:_activeCurrencies forKey:@"activeCurrencies"];
    //NSLog(@"\n\nActive Currencies: %lu",(unsigned long)_activeCurrencies.count);
    [_searchBar resignFirstResponder];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    //[_searchBar resignFirstResponder];

    NSDictionary *currency = [NSDictionary new];

    AddCurrencyCell *cell = (AddCurrencyCell*)[_currenciesTableView cellForRowAtIndexPath:indexPath];
    
    if (_searchBarActive) {
        switch (_sorting) {
            case 0:
                currency = _filteredPopularitySortedCurrencies[indexPath.row];
                break;
            case 1:{
                NSString *initialChar = [_sortedFilteredLetters objectAtIndex:indexPath.section];
                NSArray *currenciesWithThisChar = [_lettersFilteredSections objectForKey:initialChar];
                currency = [currenciesWithThisChar objectAtIndex:indexPath.row];
                break;
            }case 2:{
                NSString *initialChar = [_sortedFilteredCountries objectAtIndex:indexPath.section];
                NSArray *currenciesWithThisChar = [_countriesFilteredSections objectForKey:initialChar];
                currency = [currenciesWithThisChar objectAtIndex:indexPath.row];
                break;
                
            }default:
                break;
        }
    }else{
        switch (_sorting) {
            case 0:
                currency = _popularitySortedCurrencies[indexPath.row];
                break;
            case 1:{
                NSString *initialChar = [_sortedLetters objectAtIndex:indexPath.section];
                NSArray *currenciesWithThisChar = [_lettersSections objectForKey:initialChar];
                currency = [currenciesWithThisChar objectAtIndex:indexPath.row];
                break;
            }case 2:{
                NSString *initialChar = [_sortedCountries objectAtIndex:indexPath.section];
                NSArray *currenciesWithThisChar = [_countriesSections objectForKey:initialChar];
                currency = [currenciesWithThisChar objectAtIndex:indexPath.row];
                break;
            }default:
                break;
        }
    }
    BOOL jahies = NO;
    NSString *currentCode = [currency objectForKey:@"money_code"];
    NSString *activeCode;
    NSDictionary *currencyTemp;
    
    for (int i=0; i<_activeCurrencies.count; i++) {
        currencyTemp = _activeCurrencies[i];
        activeCode = [currencyTemp objectForKey:@"money_code"];
        if ([currentCode isEqualToString:activeCode]) {
            jahies = YES;
            break;
        }
    }
    if (jahies) {
        //cell.accessoryType = UITableViewCellAccessoryNone;
        cell.imageSelected.hidden = YES;
        [_activeCurrencies removeObject:currencyTemp];
    }else{
        //cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.imageSelected.hidden = NO;
        for (NSDictionary *dict in _allCurrencies) {
            NSString *moneyCode = [dict objectForKey:@"money_code"];
            if ([moneyCode isEqualToString:currentCode]) {
                [_activeCurrencies addObject:dict];
                break;
            }
        }
    }
    [[NSUserDefaults standardUserDefaults] setValue:_activeCurrencies forKey:@"activeCurrencies"];
    NSLog(@"\n\nActive Currencies: %lu",(unsigned long)_activeCurrencies.count);
    [_searchBar resignFirstResponder];

}

#pragma  mark - parsinJson

- (NSDictionary *)parseDataFromJsonsToDictionariesfromFilePath:(NSString*)filepath andFormat:(NSString *)formatType{
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:filepath ofType:formatType];
    
    NSData* data = [NSData dataWithContentsOfFile:filePath];
    __autoreleasing NSError* error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSDictionary *output = result;
    
    return  output;
}

#pragma mark -
#pragma mark === UISearchBarDelegate ===
#pragma mark -

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    _searchBarActive = YES;
    if (searchText.length == 0) {
        switch (_sorting) {
            case 0:
                _filteredPopularitySortedCurrencies = _popularitySortedCurrencies;
                break;
            case 1:
                _lettersFilteredSections = _lettersSections;
                _sortedFilteredLetters = [_lettersFilteredSections allKeys];
                break;
            case 2:
                _countriesFilteredSections = _countriesSections;
                _sortedFilteredCountries = _sortedCountries;
                break;
            default:
                break;
        }
    }else{
        NSString *predicateFormat = @"%K CONTAINS[cd] %@";
        NSString *searchAttribute;
        
        switch (_sorting) {
            case 0:{
                searchAttribute = @"money_name";
                NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat, searchAttribute, searchText];
                NSArray *tempArray = [_allCurrencies filteredArrayUsingPredicate:predicate];
                _filteredPopularitySortedCurrencies = tempArray;
                break;
            }
            case 1:{
                searchAttribute = @"money_name";
                NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat, searchAttribute, searchText];
                NSArray *tempArray = [_allCurrencies filteredArrayUsingPredicate:predicate];
                _lettersFilteredSections = [self sortingByLetters:tempArray];
                _sortedFilteredLetters = [_lettersFilteredSections allKeys];
                break;
            }
            case 2:{
                searchAttribute = @"country_name";
                NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat, searchAttribute, searchText];
                NSArray *tempArray = [_allCountries filteredArrayUsingPredicate:predicate];
                _countriesFilteredSections = [self sortingByLetters:tempArray];
                _sortedFilteredCountries = [_countriesFilteredSections allKeys];
                break;
            }
            default:
                break;
        }
    }
    [_currenciesTableView reloadData];
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    _searchBarActive = YES;
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    _searchBarActive = NO;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}


#pragma mark - Sorting methods.

-(NSArray *)sortingByPopularity:(NSArray *)currencies{
    
    NSSortDescriptor  *brandDescriptor = [[NSSortDescriptor alloc] initWithKey:@"popularity" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:brandDescriptor];
    
    NSArray *output = [currencies sortedArrayUsingDescriptors:sortDescriptors];
    return  output;
}

-(NSDictionary *)sortingByLetters:(NSArray *)currencies{
    
    NSSortDescriptor  *brandDescriptor = [[NSSortDescriptor alloc] initWithKey:@"country_region" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:brandDescriptor];
    NSArray *output = [currencies sortedArrayUsingDescriptors:sortDescriptors];
    
    //-----
    NSMutableDictionary *lettersSections = [NSMutableDictionary new];
    
    for (NSDictionary *currency in output) {
        NSRange range = NSMakeRange(0, 1);
        NSString *moneyName = [currency objectForKey:@"money_name"];
        NSString *initialChar = [moneyName substringWithRange:range];
        
        NSMutableArray *currenciesWithThisChar = [lettersSections objectForKey:initialChar];
        if (currenciesWithThisChar == nil) {
            currenciesWithThisChar = [NSMutableArray array];
            [lettersSections setObject:currenciesWithThisChar forKey:initialChar];
        }
        [currenciesWithThisChar addObject:currency];
    }
    return  lettersSections;
}


-(NSDictionary *)sortingByCountry:(NSArray *)currencies{
    NSSortDescriptor  *brandDescriptor = [[NSSortDescriptor alloc] initWithKey:@"country_name" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:brandDescriptor];
    
    NSArray *output = [currencies sortedArrayUsingDescriptors:sortDescriptors];
    
    //----
    NSMutableDictionary *countriesSections = [NSMutableDictionary new];
    
    for (NSDictionary *country in output) {
        NSRange range = NSMakeRange(0, 1);
        NSString *countryName = [country objectForKey:@"country_name"];
        NSString *initialChar = [countryName substringWithRange:range];
        
        NSMutableArray *currenciesWithThisChar = [countriesSections objectForKey:initialChar];
        if (currenciesWithThisChar == nil) {
            currenciesWithThisChar = [NSMutableArray array];
            [countriesSections setObject:currenciesWithThisChar forKey:initialChar];
        }
        [currenciesWithThisChar addObject:country];
    }
    //NSLog(@"%@\n\n",countriesSections);
    
    return  countriesSections;
}

-(void)screenConfiguration{
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    if( screenHeight > 480 && screenHeight < 667 ){
        //NSLog(@"iPhone 5/5s");
        _textCellsFontSize = 15;
        _searchBarFontSize = 13;
        
    } else if ( screenHeight > 480 && screenHeight < 736 ){
        //NSLog(@"iPhone 6");
        _textCellsFontSize = 17;
        _searchBarFontSize = 15;
        
    } else if ( screenHeight > 480 ){
        //NSLog(@"iPhone 6 Plus");
        _textCellsFontSize = 17;
        _searchBarFontSize = 15;
        
    } else {
        //NSLog(@"iPhone 4/4s");
        _textCellsFontSize = 15;
        _searchBarFontSize = 13;

    }
}

#pragma mark - Navigation Actions

-(IBAction)backToListAction{
    [[NSUserDefaults standardUserDefaults] setValue:_activeCurrencies forKey:@"activeCurrencies"];
    [self performSegueWithIdentifier:@"toListSegue" sender:nil];
}
@end
