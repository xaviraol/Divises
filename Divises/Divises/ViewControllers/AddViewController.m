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



//constraints i font sizes:

@end

@implementation AddViewController{
    
    NSMutableArray *allCurrencies;
    
    NSArray *alreadyActiveCurrencies;
    NSMutableArray *activeCurrencies;
    
    NSArray *popularitySortedCurrencies;
    NSArray *filteredPopularitySortedCurrencies;
    
    
    NSDictionary *lettersSections;
    NSArray *sortedLetters;
    NSDictionary *lettersFilteredSections;
    NSArray *sortedFilteredLetters;
    
    NSArray *allCountries;
    NSDictionary *countriesSections;
    NSArray *sortedCountries;
    NSDictionary *countriesFilteredSections;
    NSArray *sortedFilteredCountries;
    
    NSArray *filteredCountries;
    
    int sorting;
    BOOL searchBarActive;
    
    int searchBarFontSize;
    int textCellsFontSize; //ha d'anara a la cel·la
}

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
    [searchField setFont:[UIFont fontWithName:@"Avenir" size:searchBarFontSize]];
    searchField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Search Currencies"];



    // -------------------------------------------------------------
    
    // UISegmentedControl Appearance
    //--------------------------------------------------------------
    _segmentedControl.tintColor = UIColorFromRGB(0xF5F5F5);
    _segmentedControl.backgroundColor = UIColorFromRGB(0xF5F5F5);
    [_segmentedControl setTitleTextAttributes: @{NSForegroundColorAttributeName:[UIColor blackColor],
                                                 NSFontAttributeName:[UIFont fontWithName:@"Avenir" size:textCellsFontSize]} forState:UIControlStateNormal];
    [_segmentedControl setTitleTextAttributes: @{NSForegroundColorAttributeName:UIColorFromRGB(0xFF4543),
                                                 NSFontAttributeName:[UIFont fontWithName:@"Avenir" size:textCellsFontSize]} forState:UIControlStateSelected];

    //--------------------------------------------------------------
    
    searchBarActive = NO;

    // agafem les currencies:
    NSDictionary *currenciesDictionary = [self parseDataFromJsonsToDictionariesfromFilePath:@"RegionCountriesCurrency" andFormat:@".json"];
    allCurrencies = [NSMutableArray new];
    
    for (NSString *key in [currenciesDictionary allKeys]) {
        NSDictionary *currency = [currenciesDictionary objectForKey:key];
        [allCurrencies addObject:currency];
    }
    
    // agafem tots els paisos:
    NSDictionary *countriesDictionary = [self parseDataFromJsonsToDictionariesfromFilePath:@"Countries" andFormat:@".json"];
    NSMutableArray *unsortedCountries = [NSMutableArray new];
    allCountries = [NSArray new];
    
    for (NSString *key in [countriesDictionary allKeys]) {
        NSDictionary *currency = [countriesDictionary objectForKey:key];
        [unsortedCountries addObject:currency];
    }
    allCountries = unsortedCountries;
    
    activeCurrencies = [NSMutableArray new];
    alreadyActiveCurrencies = [[NSUserDefaults standardUserDefaults] objectForKey:@"activeCurrencies"];
    activeCurrencies = [NSMutableArray arrayWithArray:alreadyActiveCurrencies];
    
    sorting = 0;
    //popularity
    popularitySortedCurrencies = [self sortingByPopularity:allCurrencies];
    
    //letters
    lettersSections = [self sortingByLetters:allCurrencies];
    NSArray *unsortedLetters = [lettersSections allKeys];
    sortedLetters = [unsortedLetters sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

    //countries
    countriesSections = [self sortingByCountry:allCountries];
    NSArray *unCountries = [countriesSections allKeys];
    sortedCountries = [unCountries sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)segmentAction:(id)sender{
    sorting = (int)_segmentedControl.selectedSegmentIndex;
    if (searchBarActive) {
        searchBarActive = NO;
        _searchBar.text = @"";
    }
    [_currenciesTableView reloadData];
}

#pragma mark - Table View Delegate Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (searchBarActive){
        if (sorting == 1) {
            return lettersFilteredSections.count;
        }else if (sorting ==2 ){
            return countriesFilteredSections.count;
        }else{
            return 1;
        }
    }else{
        if (sorting == 1) {
            return lettersSections.count;
        }else if (sorting == 2){
            return countriesSections.count;
        }else{
            return 1;
        }
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (searchBarActive) {
        switch (sorting) {
            case 0:
                return filteredPopularitySortedCurrencies.count;
                break;
            case 1:{
                NSString *initialChar = [sortedFilteredLetters objectAtIndex:section];
                NSArray *currenciesWithThisChar = [lettersFilteredSections objectForKey:initialChar];
                return [currenciesWithThisChar count];
                break;
            }case 2:{
                NSString *initialChar = [sortedFilteredCountries objectAtIndex:section];
                NSArray *currenciesWithThisChar = [countriesFilteredSections objectForKey:initialChar];
                return [currenciesWithThisChar count];
                break;
            }default:
                return filteredCountries.count;
                break;
        }
    }else{
        if(sorting == 1 ){
            
            NSString *initialChar = [sortedLetters objectAtIndex:section];
            NSArray *currenciesWithThisChar = [lettersSections objectForKey:initialChar];
            return [currenciesWithThisChar count];
            
        }else if (sorting==2) {
            
            NSString *initialChar = [sortedCountries objectAtIndex:section];
            NSArray *currenciesWithThisChar = [countriesSections objectForKey:initialChar];
            return [currenciesWithThisChar count];
            
        }else{
            return allCurrencies.count;
        }
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (sorting==1) {
        return 40;
    }else if (sorting==2){
        return 40;
    }else{
        return 0;
    }
}
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UITableViewHeaderFooterView *av=[[UITableViewHeaderFooterView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    av.backgroundColor = UIColorFromRGB(0xF5F5F5);
    if (sorting == 1) {
        NSString *initialChar;
        if (searchBarActive){
            initialChar = [sortedFilteredLetters objectAtIndex:section];
        }else{
            initialChar = [sortedLetters objectAtIndex:section];
        }
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 7, 200, 30)];
        [titleLabel setText:initialChar];
        [av addSubview:titleLabel];
        
        return av;
    }else if (sorting == 2){
        
        NSString *initialChar;
        if (searchBarActive){
            initialChar = [sortedFilteredCountries objectAtIndex:section];
        }else{
            initialChar = [sortedCountries objectAtIndex:section];
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
    
    AddCurrencyCell *cell = (AddCurrencyCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    NSDictionary *currency = [NSDictionary new];

    cell.accessoryType = UITableViewCellAccessoryNone;
    [cell.labelName setFont:[UIFont fontWithName:@"Avenir-Heavy" size:textCellsFontSize]];
    if (searchBarActive) {
        switch (sorting) {
            case 0:{
                currency = filteredPopularitySortedCurrencies[indexPath.row];
                cell.labelName.text = [NSString stringWithFormat:@"%@ - %@", [currency objectForKey:@"money_symbol"],[currency objectForKey:@"money_name"]];
                break;
            }case 1:{
                
                NSString *initialChar = [sortedFilteredLetters objectAtIndex:indexPath.section];
                NSArray *currenciesWithThisChar = [lettersFilteredSections objectForKey:initialChar];
                currency = [currenciesWithThisChar objectAtIndex:indexPath.row];
                cell.labelName.text = [NSString stringWithFormat:@"%@ - %@", [currency objectForKey:@"money_symbol"],[currency objectForKey:@"money_name"]];
                break;
            }case 2:{
                NSString *initialChar = [sortedFilteredCountries objectAtIndex:indexPath.section];
                NSArray *currenciesWithThisChar = [countriesFilteredSections objectForKey:initialChar];
                currency = [currenciesWithThisChar objectAtIndex:indexPath.row];
                cell.labelName.text = [NSString stringWithFormat:@"%@ - %@",[currency objectForKey:@"country_name"],[currency objectForKey:@"money_symbol"]];
                break;
            }default:
                break;
        }
    }else{
        switch (sorting) {
            case 0:{
                currency = popularitySortedCurrencies[indexPath.row];
                cell.labelName.text = [NSString stringWithFormat:@"%@ - %@", [currency objectForKey:@"money_symbol"],[currency objectForKey:@"money_name"]];
                break;
            }case 1:{
                NSString *initialChar = [sortedLetters objectAtIndex:indexPath.section];
                NSArray *currenciesWithThisChar = [lettersSections objectForKey:initialChar];
                currency = [currenciesWithThisChar objectAtIndex:indexPath.row];
                cell.labelName.text = [NSString stringWithFormat:@"%@ - %@", [currency objectForKey:@"money_symbol"],[currency objectForKey:@"money_name"]];
                break;
            }case 2:{
                NSString *initialChar = [sortedCountries objectAtIndex:indexPath.section];
                NSArray *currenciesWithThisChar = [countriesSections objectForKey:initialChar];
                currency = [currenciesWithThisChar objectAtIndex:indexPath.row];
                cell.labelName.text = [NSString stringWithFormat:@"%@ - %@",[currency objectForKey:@"country_name"],[currency objectForKey:@"money_symbol"]];
                break;
                
            }default:
                break;
        }
    }
    NSString *currentCode = [currency objectForKey:@"money_code"];
    cell.imageSelected.hidden = YES;
    for (NSDictionary *dict in activeCurrencies) {
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
    
    if (searchBarActive) {
        switch (sorting) {
            case 0:
                currency = filteredPopularitySortedCurrencies[indexPath.row];
                break;
            case 1:{
                NSString *initialChar = [sortedFilteredLetters objectAtIndex:indexPath.section];
                NSArray *currenciesWithThisChar = [lettersFilteredSections objectForKey:initialChar];
                currency = [currenciesWithThisChar objectAtIndex:indexPath.row];
                break;
            }case 2:{
                NSString *initialChar = [sortedFilteredCountries objectAtIndex:indexPath.section];
                NSArray *currenciesWithThisChar = [countriesFilteredSections objectForKey:initialChar];
                currency = [currenciesWithThisChar objectAtIndex:indexPath.row];
                break;
            }default:
                break;
        }
    }else{
        switch (sorting) {
            case 0:
                currency = popularitySortedCurrencies[indexPath.row];
                break;
            case 1:{
                NSString *initialChar = [sortedLetters objectAtIndex:indexPath.section];
                NSArray *currenciesWithThisChar = [lettersSections objectForKey:initialChar];
                currency = [currenciesWithThisChar objectAtIndex:indexPath.row];
                break;
            }case 2:{
                NSString *initialChar = [sortedCountries objectAtIndex:indexPath.section];
                NSArray *currenciesWithThisChar = [countriesSections objectForKey:initialChar];
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
    
    for (int i=0; i<activeCurrencies.count; i++) {
        currencyTemp = activeCurrencies[i];
        activeCode = [currencyTemp objectForKey:@"money_code"];
        if ([currentCode isEqualToString:activeCode]) {
            jahies = YES;
            break;
        }
    }
    if (jahies) {
        //cell.accessoryType = UITableViewCellAccessoryNone;
        cell.imageSelected.hidden = YES;
        [activeCurrencies removeObject:currencyTemp];
    }else{
        //cell.accessoryType = UITableViewCellAccessoryCheckmark;
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
    //NSLog(@"\n\nActive Currencies: %lu",(unsigned long)_activeCurrencies.count);
    [_searchBar resignFirstResponder];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    //[_searchBar resignFirstResponder];

    NSDictionary *currency = [NSDictionary new];

    AddCurrencyCell *cell = (AddCurrencyCell*)[_currenciesTableView cellForRowAtIndexPath:indexPath];
    
    if (searchBarActive) {
        switch (sorting) {
            case 0:
                currency = filteredPopularitySortedCurrencies[indexPath.row];
                break;
            case 1:{
                NSString *initialChar = [sortedFilteredLetters objectAtIndex:indexPath.section];
                NSArray *currenciesWithThisChar = [lettersFilteredSections objectForKey:initialChar];
                currency = [currenciesWithThisChar objectAtIndex:indexPath.row];
                break;
            }case 2:{
                NSString *initialChar = [sortedFilteredCountries objectAtIndex:indexPath.section];
                NSArray *currenciesWithThisChar = [countriesFilteredSections objectForKey:initialChar];
                currency = [currenciesWithThisChar objectAtIndex:indexPath.row];
                break;
                
            }default:
                break;
        }
    }else{
        switch (sorting) {
            case 0:
                currency = popularitySortedCurrencies[indexPath.row];
                break;
            case 1:{
                NSString *initialChar = [sortedLetters objectAtIndex:indexPath.section];
                NSArray *currenciesWithThisChar = [lettersSections objectForKey:initialChar];
                currency = [currenciesWithThisChar objectAtIndex:indexPath.row];
                break;
            }case 2:{
                NSString *initialChar = [sortedCountries objectAtIndex:indexPath.section];
                NSArray *currenciesWithThisChar = [countriesSections objectForKey:initialChar];
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
    
    for (int i=0; i<activeCurrencies.count; i++) {
        currencyTemp = activeCurrencies[i];
        activeCode = [currencyTemp objectForKey:@"money_code"];
        if ([currentCode isEqualToString:activeCode]) {
            jahies = YES;
            break;
        }
    }
    if (jahies) {
        //cell.accessoryType = UITableViewCellAccessoryNone;
        cell.imageSelected.hidden = YES;
        [activeCurrencies removeObject:currencyTemp];
    }else{
        //cell.accessoryType = UITableViewCellAccessoryCheckmark;
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
    searchBarActive = YES;
    if (searchText.length == 0) {
        switch (sorting) {
            case 0:
                filteredPopularitySortedCurrencies = popularitySortedCurrencies;
                break;
            case 1:
                lettersFilteredSections = lettersSections;
                sortedFilteredLetters = [lettersFilteredSections allKeys];
                break;
            case 2:
                countriesFilteredSections = countriesSections;
                sortedFilteredCountries = sortedCountries;
                break;
            default:
                break;
        }
    }else{
        NSString *predicateFormat = @"%K CONTAINS[cd] %@";
        NSString *searchAttribute;
        
        switch (sorting) {
            case 0:{
                searchAttribute = @"money_name";
                NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat, searchAttribute, searchText];
                NSArray *tempArray = [allCurrencies filteredArrayUsingPredicate:predicate];
                filteredPopularitySortedCurrencies = tempArray;
                break;
            }
            case 1:{
                searchAttribute = @"money_name";
                NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat, searchAttribute, searchText];
                NSArray *tempArray = [allCurrencies filteredArrayUsingPredicate:predicate];
                lettersFilteredSections = [self sortingByLetters:tempArray];
                sortedFilteredLetters = [lettersFilteredSections allKeys];
                break;
            }
            case 2:{
                searchAttribute = @"country_name";
                NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat, searchAttribute, searchText];
                NSArray *tempArray = [allCountries filteredArrayUsingPredicate:predicate];
                countriesFilteredSections = [self sortingByLetters:tempArray];
                sortedFilteredCountries = [countriesFilteredSections allKeys];
                break;
            }
            default:
                break;
        }
    }
    [_currenciesTableView reloadData];
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    searchBarActive = YES;
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    searchBarActive = NO;
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
    
    //----
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
    //NSLog(@"%@\n\n",countriesSections);
    
    return  countriesSectionsDict;
}

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
