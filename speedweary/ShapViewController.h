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
@property (strong, nonatomic) IBOutlet UIButton *choice01;
@property (strong, nonatomic) IBOutlet UIButton *choice02;
@property int score;
@property (strong, nonatomic) IBOutlet UILabel *scoreDisplay;

@end
