//
//  ShapViewController.h
//  speedweary
//
//  Created by otiai10 on 2013/07/18.
//  Copyright (c) 2013年 shap. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShapViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIButton *startButton;
@property (strong, nonatomic) NSArray *kaomojilist;
@property (strong, nonatomic) IBOutlet UITextField *target;
@property (strong, nonatomic) IBOutlet UILabel *scoreDisplay;
@property (strong, nonatomic) IBOutlet UILabel *evaluaton;


@property (strong, nonatomic) IBOutlet UIButton *altBtn0;
@property (strong, nonatomic) IBOutlet UIButton *altBtn1;
@property (strong, nonatomic) IBOutlet UIButton *altBtn2;
@property (strong, nonatomic) IBOutlet UIButton *tweetBtn;
@property (strong, nonatomic) IBOutlet UILabel *correctAnswer;

@property int score;
@property int answer;
@property int choice;

@property NSString *tweetText;

@property int alternative0;
@property int alternative1;
@property int alternative2;

@property (nonatomic, assign)BOOL alertFinished;

@end
