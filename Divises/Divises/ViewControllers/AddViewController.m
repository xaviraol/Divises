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

@end

@implementation AddViewController{
    
    NSDictionary *tableSections;
    NSArray *tableRows;
    
    NSMutableArray *allCurrencies;
    NSArray *allCountries;
    
    NSArray *alreadyActiveCurrencies;
    NSMutableArray *activeCurrencies;
    
    int sorting;
    
    int searchBarFontSize;
    int textCellsFontSize;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self screenConfiguration];
    
    //--------------------------------------------------------------
    // UINavigationBar Appearance
    //--------------------------------------------------------------
    
    _navigationBar.translucent = NO;
    _navigationBar.tintColor = UIColorFromRGB(0xFF4543);
    _navigationBar.backgroundColor = UIColorFromRGB(0xF5F5F5);
    [_navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor blackColor],
       NSFontAttributeName:[UIFont fontWithName:@"Avenir-Heavy" size:21]}];
    
    
    //--------------------------------------------------------------
    // RightBarButton Appearance
    //--------------------------------------------------------------
    
    [_barButton setTitleTextAttributes:@{NSForegroundColorAttributeName:UIColorFromRGB(0xFF4543),
                                         NSFontAttributeName:[UIFont fontWithName:@"Avenir-Heavy" size:17]} forState:UIControlStateNormal];
    
    //--------------------------------------------------------------
    // UISearchBar Appearance
    //--------------------------------------------------------------
    
    _searchBar.layer.borderWidth = 1;
    _searchBar.layer.borderColor = UIColorFromRGB(0xF5F5F5).CGColor;
    _searchBar.barTintColor = UIColorFromRGB(0xF5F5F5);
    _searchBar.backgroundColor = UIColorFromRGB(0xF5F5F5);
    UITextField *searchField = [_searchBar valueForKey:@"searchField"];
    searchField.backgroundColor = [UIColor whiteColor];
    searchField.textColor = [UIColor grayColor];
    [searchField setFont:[UIFont fontWithName:@"Avenir" size:searchBarFontSize]];
    searchField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Search"];
    
    //--------------------------------------------------------------
    // UISegmentedControl Appearance
    //--------------------------------------------------------------
    
    _segmentedControl.tintColor = UIColorFromRGB(0xF5F5F5);
    _segmentedControl.backgroundColor = UIColorFromRGB(0xF5F5F5);
    [_segmentedControl setTitleTextAttributes: @{NSForegroundColorAttributeName:[UIColor blackColor],
                                                 NSFontAttributeName:[UIFont fontWithName:@"Avenir" size:textCellsFontSize]} forState:UIControlStateNormal];
    [_segmentedControl setTitleTextAttributes: @{NSForegroundColorAttributeName:UIColorFromRGB(0xFF4543),
                                                 NSFontAttributeName:[UIFont fontWithName:@"Avenir" size:textCellsFontSize]} forState:UIControlStateSelected];
    
    //currencies from the json file.
    NSDictionary *currenciesDictionary = [self parseDataFromJsonsToDictionariesfromFilePath:@"RegionCountriesCurrency" andFormat:@".json"];
    allCurrencies = [NSMutableArray new];
    
    for (NSString *key in [currenciesDictionary allKeys]) {
        NSDictionary *currency = [currenciesDictionary objectForKey:key];
        [allCurrencies addObject:currency];
    }
    
    //sountries from the json file.
    NSDictionary *countriesDictionary = [self parseDataFromJsonsToDictionariesfromFilePath:@"Countries" andFormat:@".json"];
    NSMutableArray *unsortedCountries = [NSMutableArray new];
    allCountries = [NSArray new];
    
    for (NSString *key in [countriesDictionary allKeys]) {
        NSDictionary *currency = [countriesDictionary objectForKey:key];
        [unsortedCountries addObject:currency];
    }
    allCountries = unsortedCountries;
    
    //activeCurrencies from NSUserDefaults
    activeCurrencies = [NSMutableArray new];
    alreadyActiveCurrencies = [[NSUserDefaults standardUserDefaults] objectForKey:@"activeCurrencies"];
    activeCurrencies = [NSMutableArray arrayWithArray:alreadyActiveCurrencies];
    
    sorting = 0;
    [self sortAndfFilterArray:allCurrencies withSorting:sorting andFilterText:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Segment Controller ValueChanged Action
-(IBAction)segmentAction:(id)sender{
    
    sorting = (int)_segmentedControl.selectedSegmentIndex;
    [_searchBar resignFirstResponder];
    _searchBar.text = @"";
    
    if (sorting == 2) {
        //countries
        [self sortAndfFilterArray:allCountries withSorting:sorting andFilterText:nil];
    }else{
        //currencies
        [self sortAndfFilterArray:allCurrencies withSorting:sorting andFilterText:nil];
    }
    [_currenciesTableView reloadData];
}

#pragma mark - Table View Delegate Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (sorting == 0) {
        return 1;
    }else{
        return tableSections.count;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (sorting == 0) {
        return tableRows.count;
    }else{
        NSString *initialChar = [tableRows objectAtIndex:section];
        NSArray *currenciesWithThisChar = [tableSections objectForKey:initialChar];
        return [currenciesWithThisChar count];
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (sorting == 0){
        return 0;
    }else{
        return 40;
    }
}
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UITableViewHeaderFooterView *av=[[UITableViewHeaderFooterView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    av.contentView.backgroundColor = UIColorFromRGB(0xF5F5F5);
    
    if (sorting == 0) {
        return nil;
    }else{
        NSString *initialChar = [tableRows objectAtIndex:section];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 7, 200, 30)];
        [titleLabel setText:initialChar];
        [av addSubview:titleLabel];
        
        return av;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"addCurrencyCell";
    
    AddCurrencyCell *cell = (AddCurrencyCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    NSDictionary *currency = [NSDictionary new];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    [cell.labelName setFont:[UIFont fontWithName:@"Avenir-Heavy" size:textCellsFontSize]];
    
    switch (sorting) {
        case 0:{
            currency = tableRows[indexPath.row];
            cell.labelName.text = [NSString stringWithFormat:@"%@ - %@", [currency objectForKey:@"money_symbol"],[currency objectForKey:@"money_name"]];
            break;
        }case 1:{
            NSString *initialChar = [tableRows objectAtIndex:indexPath.section];
            NSArray *currenciesWithThisChar = [tableSections objectForKey:initialChar];
            currency = [currenciesWithThisChar objectAtIndex:indexPath.row];
            cell.labelName.text = [NSString stringWithFormat:@"%@ - %@", [currency objectForKey:@"money_symbol"],[currency objectForKey:@"money_name"]];
            break;
        }case 2:{
            NSString *initialChar = [tableRows objectAtIndex:indexPath.section];
            NSArray *currenciesWithThisChar = [tableSections objectForKey:initialChar];
            currency = [currenciesWithThisChar objectAtIndex:indexPath.row];
            cell.labelName.text = [NSString stringWithFormat:@"%@ - %@",[currency objectForKey:@"country_name"],[currency objectForKey:@"money_symbol"]];
            break;
            
        }default:
            break;
    }
    
    NSString *currentCode = [currency objectForKey:@"money_code"];
    cell.imageSelected.hidden = YES;
    for (NSDictionary *dict in activeCurrencies) {
        NSString *activeCode = [dict objectForKey:@"money_code"];
        if([currentCode isEqualToString:activeCode]){
            cell.imageSelected.hidden = NO;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *currency = [NSDictionary new];
    AddCurrencyCell *cell = (AddCurrencyCell*)[_currenciesTableView cellForRowAtIndexPath:indexPath];
    
    if (sorting == 0){
        currency = tableRows[indexPath.row];
    }else{
        NSString *initialChar = [tableRows objectAtIndex:indexPath.section];
        NSArray *currenciesWithThisChar = [tableSections objectForKey:initialChar];
        currency = [currenciesWithThisChar objectAtIndex:indexPath.row];
    }
    
    BOOL jahies = NO;
    NSString *currentCode = [currency objectForKey:@"money_code"];
    NSString *activeCode;
    NSDictionary *currencyTemp;
    
    for (int i=0; i<activeCurrencies.count; i++) {
        currencyTemp = activeCurrencies[i];
        activeCode = [currencyTemp objectForKey:@"money_code"];
        if ([currentCode isEqualToString:activeCode]) {
            jahies = YES;
            break;
        }
    }
    if (jahies) {
        cell.imageSelected.hidden = YES;
        [activeCurrencies removeObject:currencyTemp];
    }else{
        cell.imageSelected.hidden = NO;
        for (NSDictionary *dict in allCurrencies) {
            NSString *moneyCode = [dict objectForKey:@"money_code"];
            if ([moneyCode isEqualToString:currentCode]) {
                [activeCurrencies addObject:dict];
                break;
            }
        }
    }
    [[NSUserDefaults standardUserDefaults] setValue:activeCurrencies forKey:@"activeCurrencies"];
    [_searchBar resignFirstResponder];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *currency = [NSDictionary new];
    
    AddCurrencyCell *cell = (AddCurrencyCell*)[_currenciesTableView cellForRowAtIndexPath:indexPath];
    
    if (sorting == 0){
        currency = tableRows[indexPath.row];
        
    }else{
        
        NSString *initialChar = [tableRows objectAtIndex:indexPath.section];
        NSArray *currenciesWithThisChar = [tableSections objectForKey:initialChar];
        currency = [currenciesWithThisChar objectAtIndex:indexPath.row];
        
    }
    BOOL jahies = NO;
    NSString *currentCode = [currency objectForKey:@"money_code"];
    NSString *activeCode;
    NSDictionary *currencyTemp;
    
    for (int i=0; i<activeCurrencies.count; i++) {
        currencyTemp = activeCurrencies[i];
        activeCode = [currencyTemp objectForKey:@"money_code"];
        if ([currentCode isEqualToString:activeCode]) {
            jahies = YES;
            break;
        }
    }
    if (jahies) {
        cell.imageSelected.hidden = YES;
        [activeCurrencies removeObject:currencyTemp];
    }else{
        cell.imageSelected.hidden = NO;
        for (NSDictionary *dict in allCurrencies) {
            NSString *moneyCode = [dict objectForKey:@"money_code"];
            if ([moneyCode isEqualToString:currentCode]) {
                [activeCurrencies addObject:dict];
                break;
            }
        }
    }
    [[NSUserDefaults standardUserDefaults] setValue:activeCurrencies forKey:@"activeCurrencies"];
    NSLog(@"\n\nActive Currencies: %lu",(unsigned long)activeCurrencies.count);
    [_searchBar resignFirstResponder];
    
}

#pragma mark - parsingJson

- (NSDictionary *)parseDataFromJsonsToDictionariesfromFilePath:(NSString*)filepath andFormat:(NSString *)formatType{
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:filepath ofType:formatType];
    
    NSData* data = [NSData dataWithContentsOfFile:filePath];
    __autoreleasing NSError* error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSDictionary *output = result;
    
    return  output;
}

#pragma mark - UISearchBarDelegate

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    if (sorting == 2){
        [self sortAndfFilterArray:allCountries withSorting:sorting andFilterText:searchText];
    }else{
        [self sortAndfFilterArray:allCurrencies withSorting:sorting andFilterText:searchText];
    }
    
    [_currenciesTableView reloadData];
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}


#pragma mark - Sorting and Filtering methods.

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
    
    NSMutableDictionary *lettersSectionsDict = [NSMutableDictionary new];
    
    for (NSDictionary *currency in output) {
        NSRange range = NSMakeRange(0, 1);
        NSString *moneyName = [currency objectForKey:@"money_name"];
        NSString *initialChar = [moneyName substringWithRange:range];
        
        NSMutableArray *currenciesWithThisChar = [lettersSectionsDict objectForKey:initialChar];
        if (currenciesWithThisChar == nil) {
            currenciesWithThisChar = [NSMutableArray array];
            [lettersSectionsDict setObject:currenciesWithThisChar forKey:initialChar];
        }
        [currenciesWithThisChar addObject:currency];
    }
    return  lettersSectionsDict;
}


-(NSDictionary *)sortingByCountry:(NSArray *)currencies{
    NSSortDescriptor  *brandDescriptor = [[NSSortDescriptor alloc] initWithKey:@"country_name" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:brandDescriptor];
    
    NSArray *output = [currencies sortedArrayUsingDescriptors:sortDescriptors];
    NSMutableDictionary *countriesSectionsDict = [NSMutableDictionary new];
    
    for (NSDictionary *country in output) {
        NSRange range = NSMakeRange(0, 1);
        NSString *countryName = [country objectForKey:@"country_name"];
        NSString *initialChar = [countryName substringWithRange:range];
        
        NSMutableArray *currenciesWithThisChar = [countriesSectionsDict objectForKey:initialChar];
        if (currenciesWithThisChar == nil) {
            currenciesWithThisChar = [NSMutableArray array];
            [countriesSectionsDict setObject:currenciesWithThisChar forKey:initialChar];
        }
        [currenciesWithThisChar addObject:country];
    }
    return  countriesSectionsDict;
}


-(void)sortAndfFilterArray:(NSArray *)allItems withSorting:(int)sortingWay andFilterText:(NSString *)textString{
    
    if (textString.length != 0) {
        
        static NSString *predicateFormat = @"%K CONTAINS[cd] %@";
        NSString *searchAttribute;
        
        switch (sortingWay) {
            case 0:{
                searchAttribute = @"money_name";
                NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat, searchAttribute, textString];
                NSArray *tempArray = [allItems filteredArrayUsingPredicate:predicate];
                tableRows = [self sortingByPopularity:tempArray];
                break;
            }
            case 1:{
                searchAttribute = @"money_name";
                NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat, searchAttribute, textString];
                NSArray *tempArray = [allItems filteredArrayUsingPredicate:predicate];
                tableSections = [self sortingByLetters:tempArray];
                tableRows = [tableSections allKeys];
                break;
            }
            case 2:{
                searchAttribute = @"country_name";
                NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat, searchAttribute, textString];
                NSArray *tempArray = [allItems filteredArrayUsingPredicate:predicate];
                tableSections = [self sortingByLetters:tempArray];
                tableRows = [tableSections allKeys];
                break;
            }
            default:
                break;
        }
    }else{
        
        switch (sortingWay) {
            case 0:  //money popularity
                tableRows = [self sortingByPopularity:allItems];
                break;
            case 1:{ //money letter
                tableSections = [self sortingByLetters:allItems];
                NSArray *unsortedTableRows = [tableSections allKeys];
                tableRows = [unsortedTableRows sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
                
                break;
            }case 2:{ //country letter
                tableSections = [self sortingByCountry:allItems];
                NSArray *unsortedTableRows = [tableSections allKeys];
                tableRows = [unsortedTableRows sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
                break;
            }default:
                break;
        }
    }
    [_currenciesTableView reloadData];
}

#pragma mark - Screen Sizes Configuration
-(void)screenConfiguration{
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    if( screenHeight > 480 && screenHeight < 667 ){
        //NSLog(@"iPhone 5/5s");
        textCellsFontSize = 15;
        searchBarFontSize = 13;
        
    } else if ( screenHeight > 480 && screenHeight < 736 ){
        //NSLog(@"iPhone 6");
        textCellsFontSize = 17;
        searchBarFontSize = 15;
        
    } else if ( screenHeight > 480 ){
        //NSLog(@"iPhone 6 Plus");
        textCellsFontSize = 17;
        searchBarFontSize = 15;
        
    } else {
        //NSLog(@"iPhone 4/4s");
        textCellsFontSize = 15;
        searchBarFontSize = 13;
    }
}

#pragma mark - Navigation Actions

-(IBAction)backToListAction{
    [[NSUserDefaults standardUserDefaults] setValue:activeCurrencies forKey:@"activeCurrencies"];
    [self performSegueWithIdentifier:@"toListSegue" sender:nil];
}


@end
