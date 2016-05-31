//
//  CurrencyDataHelper.h
//  Divises
//
//  Created by Xavier Ramos Oliver on 31/5/16.
//  Copyright © 2016 Xavier Ramos. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CurrencyDataHelper : NSObject

- (NSDictionary *)parseDataFromJsonsToDictionariesfromFilePath:(NSString*)filepath andFormat:(NSString *)formatType;

@end
