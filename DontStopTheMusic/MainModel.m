//
//  MainModel.m
//  YourJoke
//
//  Created by Kristina Šlekytė on 28/11/15.
//  Copyright (c) 2015 Darius Miliauskas. All rights reserved.
//

#import "MainModel.h"

@implementation MainModel

-(NSMutableArray *) main: (NSArray *) popularWords {
    NSMutableDictionary *songArraysDictionary = [self arraysDictionaryFrom:[self createSongsDictionaryFromFile:@"songsModel"]];
    NSMutableArray *titles = [[NSMutableArray alloc] init];
    for (NSString *word in popularWords){
        [titles addObject:[self findTheItem:word in:songArraysDictionary]];
    }
    return titles;
}

-(NSString *) mainW: (NSString*)popularWord {
    NSMutableDictionary *songArraysDictionary = [self arraysDictionaryFrom:[self createSongsDictionaryFromFile:@"songsModel"]];
    NSString *title = [self findTheItem:popularWord in:songArraysDictionary];
     return title;
}

//transfer songs from file to dictionary
-(NSMutableDictionary *) createSongsDictionaryFromFile: (NSString *) fileName {
    NSMutableDictionary *songsDictionary = [[NSMutableDictionary alloc] init];
    
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *songsModelFile = [mainBundle pathForResource: fileName ofType: @"txt"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:songsModelFile]){
        NSString *fileContents = [NSString stringWithContentsOfFile:songsModelFile
                                                           encoding:NSUTF8StringEncoding error:nil];
        __block bool isTitle = true;
        __block NSString *key = @"";
        [fileContents enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
            if (isTitle==true){
                key = line;
                isTitle= false;
            } else {
                [songsDictionary setObject:line forKey:key];
                isTitle = true;
            }
        }];
    }
    return songsDictionary;
}

//divide the songs into list of words, and makes the dictionary of these lists, to make later iterations faster
-(NSMutableDictionary *) arraysDictionaryFrom: (NSMutableDictionary *) songsDict {
    
    __block NSArray *wordsAndEmptyStrings = [[NSArray alloc] init];
    __block NSArray *words = [[NSArray alloc] init];
    NSMutableDictionary *arraysDictionary = [[NSMutableDictionary alloc] init];
    
    [songsDict enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL* stop) {
        //NSLog(@"%@ => %@", key, value);
        value = [self removesPunctuationfrom:value]; //remove the punctuations to avoid the case like "good,"
        wordsAndEmptyStrings = [value componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        words = [wordsAndEmptyStrings filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 1"]]; //excludes "I";
        [arraysDictionary setObject:words forKey:key];
    }];
    return arraysDictionary;
}

//find the most popular song for the word
-(NSString *)findTheItem: (NSString *)word in: (NSMutableDictionary *)songArraysDictionary {
    
    __block NSString *title=@"";
    [songArraysDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL* stop) {
        __block int i = 0;
        int max = 0;
        [value enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([word caseInsensitiveCompare:obj]){
                i=i+1;
            }
        }];
        if (i>max)
        {
            max = i;
            title = [NSString stringWithFormat: @"%@", key];
        }
    }];
    return title;
}

//remove pronouns and articles
-(NSMutableArray *)removeArticlesAndPronounsFrom: (NSMutableArray *) words
{
    NSArray *articlesAndPronouns = [[NSArray alloc]initWithObjects:@"a", @"an", @"the", @"I", @"you", @"he", @"she", @"it", @"we", @"they", @"me", @"my", @"your", @"him", @"her", @"our", @"us", @"their", @"them", nil];
    [articlesAndPronouns enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        [words removeObjectIdenticalTo: obj];
    }];
    return words;
}

//leave just letters and numbers
-(NSString *)removesPunctuationfrom: (NSString *) text {
    NSCharacterSet *charactersToRemove = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    text = [[text componentsSeparatedByCharactersInSet:charactersToRemove] componentsJoinedByString:@""];
    //text = [text stringByReplacingOccurrencesOfString:@"," withString:@""];
    return text;
}



@end
