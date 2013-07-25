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
-(void)initAll;
-(void)refreshAnswers;
-(void)showResultEvaluation: (bool)result;
-(NSArray *)randomPickUp: (int)cnt len:(int)len;
@end

@implementation ShapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadFaceList];
    self.score = 0;
    [self initAll];
}

- (void)initAll
{
    [self hideChoices];
    [self showStartButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// trigger to scene 2
- (IBAction)onStartButtonPressed:(UIButton *)sender {
    [self refreshAnswers];
    [self displayFace];
    [self hideStartButton];
    // pseudo timer
    [self performSelector:@selector(pseudoTargetMotionEnd) withObject:nil afterDelay:0.5];
}
- (IBAction)onAltBtn0Tapped:(UIButton *)sender {
    self.choice = self.alternative0;
    [self onChoiceTapped];
}
- (IBAction)onAltBtn1Tapped:(UIButton *)sender {
    self.choice = self.alternative1;
    [self onChoiceTapped];
}
- (IBAction)onAltBtn2Tapped:(UIButton *)sender {
    self.choice = self.alternative2;
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
    [self showResultEvaluation: result];
    [self showStartButton];
}
- (void)showResultEvaluation:(bool)result {
    if (result) {
        self.score++;
    } else {
        self.score = 0;
    }
    self.scoreDisplay.text = [NSString stringWithFormat:@"%d", self.score];
}

- (void)refreshAnswers {
    NSArray *idxs = [self randomPickUp:3 len:self.kaomojilist.count];
    //self.answer = random() % self.kaomojilist.count;
    self.choice = -1;
    self.alternative0 = [idxs[0] intValue];
    self.alternative1 = [idxs[1] intValue];
    self.alternative2 = [idxs[2] intValue];
    int a = random() % idxs.count;
    self.answer       = [idxs[a] intValue];

}

// lenの幅を持った数値列からcntだけ要素をかぶらずランダムに抽出するメソッド
// とりわけcnt==lenの場合、array_shuffleのようなもの
- (NSArray *)randomPickUp:(int)cnt len:(int)len {
    NSMutableArray *res = [NSMutableArray array];
    while (true){
        int tmp = random() % len;
        if ([res containsObject:[NSNumber numberWithInt:tmp]] == false) {
            [res addObject:[NSNumber numberWithInt:tmp]];
        }//else かぶった
        if (res.count == cnt) {
            break;
        }
    }
    return res;
}

- (void)displayFace {
    self.target.hidden = NO;
    self.target.text = self.kaomojilist[self.answer];
}

- (void)hideFace {
    self.target.hidden = YES;
}

- (void)hideStartButton {
    self.startButton.hidden = YES;
}
- (void)showStartButton {
    self.startButton.hidden = NO;
}

- (void)displayChoices {
    self.altBtn0.hidden = NO;
    self.altBtn1.hidden = NO;
    self.altBtn2.hidden = NO;
    [self.altBtn0 setTitle:self.kaomojilist[self.alternative0] forState:UIControlStateNormal];
    [self.altBtn1 setTitle:self.kaomojilist[self.alternative1] forState:UIControlStateNormal];
    [self.altBtn2 setTitle:self.kaomojilist[self.alternative2] forState:UIControlStateNormal];
    //NSLog(@"%@ is not displayed", self.kaomojilist[self.alternative2]);
}

- (void)hideChoices {
    self.altBtn0.hidden = YES;
    self.altBtn1.hidden = YES;
    self.altBtn2.hidden = YES;
}

- (void)pseudoTargetMotionEnd {
    [self hideFace];
    [self onFaceDead];
}

- (BOOL)judgeAnswer {
    if (self.choice == self.answer) {
        return YES;
    }
    return NO;
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
