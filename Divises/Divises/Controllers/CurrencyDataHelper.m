//
//  CurrencyDataHelper.m
//  Divises
//
//  Created by Xavier Ramos Oliver on 31/5/16.
//  Copyright © 2016 Xavier Ramos. All rights reserved.
//

#import "CurrencyDataHelper.h"

@implementation CurrencyDataHelper

//TODO: practicament fer el mateix que en el sense-ios-sdk a l'hoar de passar de JSON a dictionary.

+ (NSDictionary *)parseDataFromJsonsToDictionariesfromFilePath:(NSString*)filepath andFormat:(NSString *)formatType{
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:filepath ofType:formatType];
    
    NSData* data = [NSData dataWithContentsOfFile:filePath];
    __autoreleasing NSError* error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSDictionary *output = result;
    
    return  output;
}

+ (double) calculateChange:(NSNumber *)value fromCurrentCurrency:(NSString *)currentCurrencyCode toMainCurrency:(NSString *)mainCurrencyCode{
    //TODO: fer-ho més maco, valor1, resultat2... és lleig.
    NSDictionary *currencyUpdated = [[NSUserDefaults standardUserDefaults] objectForKey:@"currencyUpdated"];
    NSNumber *valor1 = [currencyUpdated objectForKey:currentCurrencyCode];
    double resultat = [valor1 doubleValue] / [value doubleValue];
    
    NSNumber *valor2 = [currencyUpdated objectForKey:mainCurrencyCode];
    double resultat2 = [valor2 doubleValue] / resultat;
    
    return resultat2;
}

@end
