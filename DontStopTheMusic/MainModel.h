//
//  MainModel.h
//  YourJoke
//
//  Created by Kristina Šlekytė on 28/11/15.
//  Copyright (c) 2015 Darius Miliauskas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MainModel : NSObject

-(NSMutableArray *) main: (NSArray *) popularWords;
-(NSString *) mainW: (NSString*)popularWord;

@end
