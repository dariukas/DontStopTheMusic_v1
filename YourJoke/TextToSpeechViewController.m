//
//  TextToSpeechViewController.m
//  YourJoke
//
//  Created by Kristina Šlekytė on 28/11/15.
//  Copyright (c) 2015 Darius Miliauskas. All rights reserved.
//


//https://github.com/dariukas/YourJoke_v1.git

#import "TextToSpeechViewController.h"

#import <OpenEars/OELanguageModelGenerator.h>
#import <OpenEars/OEAcousticModel.h>
#import <OpenEars/OEPocketsphinxController.h>

#import <OpenEars/OEFliteController.h>
#import <OpenEars/OELogging.h>
#import <Slt/Slt.h>

@interface TextToSpeechViewController ()

@property (nonatomic, copy) NSString *lmPath;
@property (nonatomic, copy) NSString *dicPath;

@end

@implementation TextToSpeechViewController

- (void)startListening {
   // [super viewDidLoad];
    
//    NSBundle *mainBundle = [NSBundle mainBundle];
//    NSString *lmPath = [mainBundle pathForResource: @"languageModel" ofType: @"txt"];
  //  NSString *lmPath=[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"languageModel.txt"];
  //  NSLog(@"After %@", lmPath);
//    NSString* filePath = [NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    NSString* fileName = @"myTextFile.txt";
//    NSString* fileAtPath = [filePath stringByAppendingPathComponent:fileName];
    
//    if (![[NSFileManager defaultManager] fileExistsAtPath:lmPath]) {
//        [[NSFileManager defaultManager] createFileAtPath:lmPath contents:nil attributes:nil];
//            NSLog(@"%@", lmPath);
//    }
    
    [self languageModel];
    
    self.openEarsEventsObserver = [[OEEventsObserver alloc] init];
    [self.openEarsEventsObserver setDelegate:self];
    
    [[OEPocketsphinxController sharedInstance] setActive:TRUE error:nil];

    if(![OEPocketsphinxController sharedInstance].isListening) {
         NSLog(@"Starting listening...");
        [[OEPocketsphinxController sharedInstance] startListeningWithLanguageModelAtPath:self.lmPath dictionaryAtPath:self.dicPath acousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:NO];
    }
    else {
        NSLog(@"Its already listening.");
    }
 //   [self startDisplayingLevels];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)languageModel {
    OELanguageModelGenerator *lmGenerator = [[OELanguageModelGenerator alloc] init];

    
    NSArray *words = [NSArray arrayWithObjects:@"WORD", @"STATEMENT", @"OTHER WORD", @"A PHRASE", nil];
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
}

#pragma mark -
#pragma mark OEEventsObserver delegate methods

- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID {
    NSLog(@"The received hypothesis is %@ with a score of %@ and an ID of %@", hypothesis, recognitionScore, utteranceID);
    
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

#pragma mark -
#pragma mark Example for reading out Pocketsphinx and Flite audio levels without locking the UI by using an NSTimer

// What follows are not OpenEars methods, just an approach for level reading
// that I've included with this sample app. My example implementation does make use of two OpenEars
// methods:	the pocketsphinxInputLevel method of OEPocketsphinxController and the fliteOutputLevel
// method of OEFliteController.
//
// The example is meant to show one way that you can read those levels continuously without locking the UI,
// by using an NSTimer, but the OpenEars level-reading methods
// themselves do not include multithreading code since I believe that you will want to design your own
// code approaches for level display that are tightly-integrated with your interaction design and the
// graphics API you choose.
//
// Please note that if you use my sample approach, you should pay attention to the way that the timer is always stopped in
// dealloc. This should prevent you from having any difficulties with deallocating a class due to a running NSTimer process.

//- (void) startDisplayingLevels { // Start displaying the levels using a timer
//    [self stopDisplayingLevels]; // We never want more than one timer valid so we'll stop any running timers first.
//    self.uiUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/kLevelUpdatesPerSecond target:self selector:@selector(updateLevelsUI) userInfo:nil repeats:YES];
//}
//
//- (void) stopDisplayingLevels { // Stop displaying the levels by stopping the timer if it's running.
//    if(self.uiUpdateTimer && [self.uiUpdateTimer isValid]) { // If there is a running timer, we'll stop it here.
//        [self.uiUpdateTimer invalidate];
//        self.uiUpdateTimer = nil;
//    }
//}
//
//- (void) updateLevelsUI { // And here is how we obtain the levels.  This method includes the actual OpenEars methods and uses their results to update the UI of this view controller.
//    
//    self.pocketsphinxDbLabel.text = [NSString stringWithFormat:@"Pocketsphinx Input level:%f",[[OEPocketsphinxController sharedInstance] pocketsphinxInputLevel]];  //pocketsphinxInputLevel is an OpenEars method of the class OEPocketsphinxController.
//    
//    if(self.fliteController.speechInProgress) {
//        self.fliteDbLabel.text = [NSString stringWithFormat:@"Flite Output level: %f",[self.fliteController fliteOutputLevel]]; // fliteOutputLevel is an OpenEars method of the class OEFliteController.
//    }
//}

@end
