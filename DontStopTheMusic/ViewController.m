//
//  ViewController.m
//  YourJoke
//
//  Created by Kristina Šlekytė on 28/11/15.
//  Copyright (c) 2015 Darius Miliauskas. All rights reserved.
//

#import "ViewController.h"

#import "LanguageModel.h"
#import <OpenEars/OEAcousticModel.h>
#import <OpenEars/OEPocketsphinxController.h>
#import "MainModel.h"

#import "XCDYouTubeVideoPlayerViewController.h"

@interface ViewController ()

@property (nonatomic, copy) NSString *lmPath;
@property (nonatomic, copy) NSString *dicPath;
@property (nonatomic, strong) NSMutableArray *detectedWordsArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blueColor];
     [self run];
}


-(void) run {
//    TextToSpeechViewController *ttvc = [[TextToSpeechViewController alloc]init];
//    [ttvc startListening];
    self.detectedWordsArray = [[NSMutableArray alloc] init];
    LanguageModel *lm = [[LanguageModel alloc] init];
    self.lmPath = lm.lmPath;
    self.dicPath = lm.dicPath;
    
    self.openEarsEventsObserver = [[OEEventsObserver alloc] init];
    [self.openEarsEventsObserver setDelegate:self];
    [[OEPocketsphinxController sharedInstance] setActive:TRUE error:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




-(NSMutableDictionary *)fillWordsDictionary {
    
    NSMutableDictionary *detectedWords = [[NSMutableDictionary alloc] init];
    id value = nil;
    NSNumber *occurrences = 0;
    for (NSString *word in self.detectedWordsArray){
        value = [detectedWords objectForKey:word];
        if (value){
            // occurrences = (int)[value integerValue]+1;
            occurrences = @([value integerValue]+1);
            [detectedWords setValue:occurrences forKey:word];
        } else{
            [detectedWords setValue:@"1" forKey:word];
        }
        //occurrences += ([word isEqualToString:xword]?1:0);
    }
    return detectedWords;
}

-(NSString *) findMostPopularWord: (NSDictionary *) words {

//    NSMutableArray *orderedKeys = [words keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2){
//        return [obj1 compare:obj2];
//    }];
//    NSLog(@"The array is %@", orderedKeys);

    
    NSArray *orderedKeys = [words keysSortedByValueUsingComparator: ^(id obj1, id obj2) {
        
        if ([obj1 integerValue] > [obj2 integerValue]) {
            
            return (NSComparisonResult)NSOrderedDescending;
        }
        if ([obj1 integerValue] < [obj2 integerValue]) {
            
            return (NSComparisonResult)NSOrderedAscending;
        }
        
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    NSLog(@"The first is %@", [orderedKeys lastObject]);
    return [orderedKeys lastObject];
}

#pragma mark -
#pragma mark OEEventsObserver delegate methods

- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID
{
   NSLog(@"The received hypothesis is %@ with a score of %@ and an ID of %@", hypothesis, recognitionScore, utteranceID);
    //Several Words Issue
    NSArray *wordsAndEmptyStrings = [hypothesis componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([wordsAndEmptyStrings count] > 1){
        NSArray *words = [wordsAndEmptyStrings filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]];
        [self.detectedWordsArray addObjectsFromArray:words];
    }else{
        [self.detectedWordsArray addObject:hypothesis];
    }
    // self.heardTextView.text = [NSString stringWithFormat:@"Heard: \"%@\"", hypothesis]; // Show it in the status box.
    //  [self.fliteController say:[NSString stringWithFormat:@"You said %@",hypothesis] withVoice:self.slt];
}

- (void) pocketsphinxDidStartListening {
    NSLog(@"Pocketsphinx is now listening.");
}

- (void) pocketsphinxDidDetectSpeech {
    NSLog(@"Pocketsphinx has detected speech.");
}

- (void) pocketsphinxDidDetectFinishedSpeech {
    NSLog(@"Pocketsphinx has detected a period of silence, concluding an utterance.");
}

- (void) pocketsphinxDidStopListening {
    NSLog(@"Pocketsphinx has stopped listening.");
}

- (void) pocketsphinxDidSuspendRecognition {
    NSLog(@"Pocketsphinx has suspended recognition.");
}

- (void) pocketsphinxDidResumeRecognition {
    NSLog(@"Pocketsphinx has resumed recognition.");
}

- (void) pocketsphinxDidChangeLanguageModelToFile:(NSString *)newLanguageModelPathAsString andDictionary:(NSString *)newDictionaryPathAsString {
    NSLog(@"Pocketsphinx is now using the following language model: \n%@ and the following dictionary: %@",newLanguageModelPathAsString,newDictionaryPathAsString);
}

- (void) pocketSphinxContinuousSetupDidFailWithReason:(NSString *)reasonForFailure {
    NSLog(@"Listening setup wasn't successful and returned the failure reason: %@", reasonForFailure);
}

- (void) pocketSphinxContinuousTeardownDidFailWithReason:(NSString *)reasonForFailure {
    NSLog(@"Listening teardown wasn't successful and returned the failure reason: %@", reasonForFailure);
}

- (void) testRecognitionCompleted {
    NSLog(@"A test file that was submitted for recognition is now complete.");
}


- (IBAction)startDetecting:(id)sender {
    if(![OEPocketsphinxController sharedInstance].isListening) {
        [[OEPocketsphinxController sharedInstance] startListeningWithLanguageModelAtPath:self.lmPath dictionaryAtPath:self.dicPath acousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:NO];
    }
    else {
        NSLog(@"Its already listening.");
    }
}

- (IBAction)stopDetecting:(id)sender {
    
    NSError *error = [[OEPocketsphinxController sharedInstance] stopListening];

    if (error==nil) {
        NSLog(@"The dictionary is %@", [self fillWordsDictionary]);
        NSString *mpword = [self findMostPopularWord:[self fillWordsDictionary]];
        MainModel *mm = [[MainModel alloc] init];
        NSString *title = [mm mainW:mpword];
        NSLog(@"Its already: %@", title);
        [self playVideo:title];
    } else {
        NSLog(@"While stopping an error occured: %@",[error localizedDescription]);
    }
}

- (void) playVideo: (NSString *)idenifier
{
    XCDYouTubeVideoPlayerViewController *vpvc =[[XCDYouTubeVideoPlayerViewController alloc] initWithVideoIdentifier:idenifier];
    //@"9bZkp7q19f0"
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerPlaybackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:vpvc.moviePlayer];
    [self presentMoviePlayerViewControllerAnimated:vpvc];
}

- (void) moviePlayerPlaybackDidFinish:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:notification.object];
    MPMovieFinishReason finishReason = [notification.userInfo[MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] integerValue];
    if (finishReason == MPMovieFinishReasonPlaybackError)
    {
        NSError *error = notification.userInfo[XCDMoviePlayerPlaybackDidFinishErrorUserInfoKey];
        // Handle error
    }
}


@end
