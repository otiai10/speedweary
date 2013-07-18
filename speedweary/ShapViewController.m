//
//  ShapViewController.m
//  speedweary
//
//  Created by otiai10 on 2013/07/18.
//  Copyright (c) 2013年 shap. All rights reserved.
//

#import "ShapViewController.h"

@interface ShapViewController ()
-(void)displayKao;
-(void)hideStartButton;
-(void)showStartButton;
@end

@implementation ShapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.kaomojilist = [[NSArray alloc] initWithObjects:@"ヽ(ﾟ∀｡)ﾉｳｪー", @"( ﾟДﾟ)", @"（☝ ՞ਊ ՞）☝",nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)startGame:(UIButton *)sender {
    [self displayKao];
    [self hideStartButton];
    [self showStartButton];
}

- (void)displayKao {
    NSLog (@"displayKao");
    int i = random() % self.kaomojilist.count;
    self.target.text = self.kaomojilist[i];
}

- (void)hideStartButton {
    NSLog (@"hide");
    self.startButton.hidden = YES;
}
- (void)showStartButton {
    NSLog (@"show");
    self.startButton.hidden = NO;
}

@end
