//
//  ShapViewController.m
//  speedweary
//
//  Created by otiai10 on 2013/07/18.
//  Copyright (c) 2013年 shap. All rights reserved.
//

#import "ShapViewController.h"

@interface ShapViewController ()
-(void)displayFace;
-(void)hideStartButton;
-(void)showStartButton;
-(void)onFaceDead;
-(void)hideFace;
-(void)displayChoices;
-(void)hideChoices;
-(void)pseudoTargetMotionEnd;
-(BOOL)judgeAnswer;
-(void)loadFaceList;
@end

@implementation ShapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadFaceList];
    self.score = 0;
    [self onChoiceTapped];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// trigger to scene 2
- (IBAction)onStartButtonPressed:(UIButton *)sender {
    [self displayFace];
    [self hideStartButton];
    // pseudo timer

    [self performSelector:@selector(pseudoTargetMotionEnd) withObject:nil afterDelay:2];
}

- (IBAction)onChoice01Tapped:(UIButton *)sender {
    [self onChoiceTapped];
}

- (IBAction)onChoice02Tapped:(UIButton *)sender {
    [self onChoiceTapped];
}

// trigger to scene 3
- (void)onFaceDead {
    NSLog(@"onFaceDead");
    // display choices
    [self displayChoices];
}

// trigger to scene 1
- (void)onChoiceTapped {
    NSLog(@"onChoiceTapped");
    [self hideChoices];
    bool result = [self judgeAnswer];
    if (result) {
        self.score++;
        self.scoreDisplay.text = [NSString stringWithFormat:@"%d", self.score];
    } else {
        self.score = 0;
    }
    [self showStartButton];
}

- (void)displayFace {
    NSLog (@"displayFace");
    int i = random() % self.kaomojilist.count;
    self.target.hidden = NO;
    self.target.text = self.kaomojilist[i];
}

- (void)hideFace {
    self.target.hidden = YES;
}

- (void)hideStartButton {
    NSLog (@"hideStartButton");
    self.startButton.hidden = YES;
}
- (void)showStartButton {
    NSLog (@"showStartButton");
    self.startButton.hidden = NO;
}

- (void)displayChoices {
    self.choice01.hidden = NO;
    self.choice02.hidden = NO;
}

- (void)hideChoices {
    self.choice01.hidden = YES;
    self.choice02.hidden = YES;
}

- (void)pseudoTargetMotionEnd {
    [self hideFace];
    [self onFaceDead];
}

- (BOOL)judgeAnswer {
    return YES;
}

- (void)loadFaceList {
    NSString *fpath = [[NSBundle mainBundle] pathForResource:@"_facelist" ofType:@"txt"];
    NSString *fdata;
    NSError  *ferr = nil;
    fdata = [NSString stringWithContentsOfFile:fpath encoding:NSUTF8StringEncoding error:&ferr];
    if (ferr) NSLog(@"%@", ferr);
    self.kaomojilist = [fdata componentsSeparatedByString:@"\n"];
    //TODO: fpathなどの変数は開放される？
}

@end
