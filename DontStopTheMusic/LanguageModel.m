//
//  LanguageModel.m
//  YourJoke
//
//  Created by Kristina Šlekytė on 28/11/15.
//  Copyright (c) 2015 Darius Miliauskas. All rights reserved.
//

#import "LanguageModel.h"
#import <OpenEars/OELanguageModelGenerator.h>
#import <OpenEars/OEAcousticModel.h>

@implementation LanguageModel


//- (instancetype)initWithFrame:(CGRect)rect
//{
//    if ((self = [super initWithFrame:rect])) {
//    }
//    return self;
//}

- (instancetype) init {
    
    NSArray *words;
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *languageModelFile = [mainBundle pathForResource: @"languageModel" ofType: @"txt"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:languageModelFile]){
        NSString *fileContents = [NSString stringWithContentsOfFile:languageModelFile
                                                           encoding:NSUTF8StringEncoding error:nil];
        NSArray *wordsAndEmptyStrings = [fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([wordsAndEmptyStrings count] > 0){
            words = [wordsAndEmptyStrings filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]];
        } else {
            NSLog (@"The file is empty");
        }
        
    }else {
        words = [NSArray arrayWithObjects:@"WORD", @"STATEMENT", @"OTHER WORD", @"FUN", nil];
    }
    
    OELanguageModelGenerator *lmGenerator = [[OELanguageModelGenerator alloc] init];
    
    //NSString *name = @"NameIWantForMyLanguageModelFiles";
    NSString *name = @"MyLanguageModel";
    NSError *err = [lmGenerator generateLanguageModelFromArray:words withFilesNamed:name forAcousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"]];
    
    //    NSString *lmPath = nil;
    //    NSString *dicPath = nil;
    
    if(err == nil) {
        self.lmPath = [lmGenerator pathToSuccessfullyGeneratedLanguageModelWithRequestedName:name];
        self.dicPath = [lmGenerator pathToSuccessfullyGeneratedDictionaryWithRequestedName:name];
        NSLog(@"Dynamic Language Model is at: %@", self.lmPath);
        NSLog(@"Dynamic Dictionary is at: %@", self.dicPath);
    } else {
        NSLog(@"Dynamic language generator reported error %@",[err localizedDescription]);
    }
    return self;
}

@end
