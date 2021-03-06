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
-(void)laughAtIncorrect;
-(void)praiseForCorrect;

// 現ステージにおいて適用するスピードを得る
-(float)defineMotionSpeed;
// スピードアップを告知する
-(void)alertLevelUp;

// アニメーションの出発地点のワールド座標をランダムに選択
-(CGPoint)getStartPoint;
// アニメーションの終端地点のワールド座標を出発地点のワールド座標から計算
-(CGPoint)getEndPointWithStart:(CGPoint)start;
// ワールド座標からスクリーン座標へ変換
-(CGPoint)translateCoord:(CGPoint)worldPoint;
// viewをスクリーンに表示されない、かつposに一番近いスクリーン座標へ移動させる
-(void)shiftToInvisiblePosition:(UIView*)view pos:(CGPoint)pos;
// 正解の顔がバナーに隠れて見えない領域のみを通らないように調整する（引数の座標を調整したものに変更する）
-(void)adjustEndCoordForBanner:(CGPoint*)start end:(CGPoint*)end;

-(NSArray *)randomPickUp: (int)cnt len:(int)len;
// fromからtoまでのfloat型乱数を得る
-(float)floatRand:(float)from to:(float)to;
@end

@implementation ShapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initAll];
}

- (void)initAll
{
    self.score = 0;
    [self hideChoices];
    [self loadFaceList];
    [self showStartButton];
    self.target.hidden = YES;
    self.tweetBtn.hidden = YES;
    self.correctAnswer.hidden = YES;
    self.afterStartButtonLabel.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// trigger to scene 2
- (IBAction)onStartButtonPressed:(UIButton *)sender {
    [self refreshAnswers];
    [self hideStartButton];
    self.evaluaton.hidden = YES;
    self.tweetBtn.hidden = YES;
    self.correctAnswer.hidden = YES;
    float speed = [self defineMotionSpeed];

    // スタートボタン後のゲーム開始を知らせるテキスト表示
    self.afterStartButtonLabel.hidden = NO;

    // 1秒後に上記テキストを非表示にして、ゲーム開始
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.afterStartButtonLabel.hidden = YES;

        [self displayFace];

        CGPoint startWorld = [self getStartPoint];
        CGPoint endWorld = [self getEndPointWithStart:startWorld];
        CGPoint startScreen = [self translateCoord:startWorld];
        CGPoint endScreen = [self translateCoord:endWorld];
        [self adjustEndCoordForBanner:&startScreen end:&endScreen];
        [self shiftToInvisiblePosition:self.target pos:startScreen];
        [UIView animateWithDuration:speed
                              delay:arc4random() % 3 + 1 // after 1 to 3 sec.
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             [self shiftToInvisiblePosition:self.target pos:endScreen];
                         }
                         completion:^(BOOL finished) {
                             [self hideFace];
                             [self onFaceDead];
                         }];
    });
}
-(float)defineMotionSpeed {
    double base = 2;
    int range = 5;
    int raw_index = self.score / range;
    if (self.score != 0 && self.score % range == 0) {
        [self alertLevelUp];
    }
    double tuned_index = 1 + (-0.3)*raw_index;
    float duration = pow(base, tuned_index);
    return duration;
}
-(void)alertLevelUp {
    UIAlertView *alert =
    [[UIAlertView alloc] initWithTitle:@"( ﾟдﾟ )ｸﾜｯ!!" message:@"ｽﾋﾟーﾄﾞｱｯﾌﾟ" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil ];
    [alert show];
    self.alertFinished = NO;
    while (!self.alertFinished) {
        [[NSRunLoop currentRunLoop]
         runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
    }
}
// delegated method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    self.alertFinished = YES;
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
    // display choices
    [self displayChoices];
}

// trigger to scene 1
- (void)onChoiceTapped {
    [self hideChoices];
    bool result = [self judgeAnswer];
    [self showResultEvaluation: result];
    [self showStartButton];
}
- (void)showResultEvaluation:(bool)result {
    if (result) {
        [self praiseForCorrect];
    } else {
        [self laughAtIncorrect];
    }
    self.scoreDisplay.text = [NSString stringWithFormat:@"STAGE %d", self.score];
}
- (void)praiseForCorrect {
    self.evaluaton.text = @"d(´・ω・`)やるじゃん";
    self.evaluaton.hidden = NO;
    self.score++;
}

- (IBAction)tweetResult:(UIButton *)sender {
    NSString *base_url = @"https://twitter.com/intent/tweet?text=";
    //encoding
    NSString *escaped = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                     NULL,
                                                                                     (CFStringRef) self.tweetText,
                                                                                     NULL,
                                                                                     (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                     kCFStringEncodingUTF8 ));// TODO:動
    NSString *tw_url = [base_url stringByAppendingString:escaped];
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString:tw_url]];
}

- (void)laughAtIncorrect {
    self.evaluaton.text = @"m9｡ﾟ(ﾟ^Д^ﾟ)ﾟザマァ";
    self.evaluaton.hidden = NO;
    self.correctAnswer.text = [@"正解:" stringByAppendingString: self.kaomojilist[self.answer]];
    self.correctAnswer.hidden = NO;
    self.tweetText = [NSString stringWithFormat:@"あんたは%d点：%@", self.score, self.kaomojilist[self.choice]];
    self.tweetText = [self.tweetText stringByAppendingString:@" #speedweary"];
    self.score = 0;
    self.tweetBtn.hidden = NO;
}

- (void)refreshAnswers {
    NSArray *idxs = [self randomPickUp:3 len:self.kaomojilist.count];
    //self.answer = random() % self.kaomojilist.count;
    self.choice = -1;
    self.alternative0 = [idxs[0] intValue];
    self.alternative1 = [idxs[1] intValue];
    self.alternative2 = [idxs[2] intValue];
    [self.altBtn0 setTitle:self.kaomojilist[self.alternative0] forState:UIControlStateNormal];
    [self.altBtn1 setTitle:self.kaomojilist[self.alternative1] forState:UIControlStateNormal];
    [self.altBtn2 setTitle:self.kaomojilist[self.alternative2] forState:UIControlStateNormal];
    int a = arc4random() % idxs.count;
    self.answer       = [idxs[a] intValue];

}

// lenの幅を持った数値列からcntだけ要素をかぶらずランダムに抽出するメソッド
// とりわけcnt==lenの場合、array_shuffleのようなもの
- (NSArray *)randomPickUp:(int)cnt len:(int)len {
    NSMutableArray *res = [NSMutableArray array];
    while (true){
        int tmp = arc4random() % len;
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

// アニメーションの出発地点のワールド座標をランダムに選択
- (CGPoint)getStartPoint
{
    // 出発地点の条件
    // -1 <= x, y <= 1
    // and
    // |x| == 1 or |y| == 1
    float x = [self floatRand:-1 to:1];
    float y = [self floatRand:-1 to:1];
    if (arc4random() % 2) {
        x = pow(-1, arc4random() % 2);
    } else {
        y = pow(-1, arc4random() % 2);
    }
    return CGPointMake(x, y);
}

// アニメーションの終端地点のワールド座標を出発地点のワールド座標から計算
- (CGPoint)getEndPointWithStart:(CGPoint)start
{
    // 終端地点の条件
    // -1 <= x', y' <= 1
    // and
    // x' = -x (if |x| == 1)   （出発地点が左右の端だったら）
    // and
    // y' = -y (if |y| == 1)   （出発地点が上下の端だったら）
    float x = [self floatRand:-1 to:1];
    float y = [self floatRand:-1 to:1];
    // floatの近似等値比較（小数点第6位の精度）
    if (abs(abs(start.x) - 1.f) < 0.000001f) {
        x = -start.x;
    }
    // floatの近似等値比較（小数点第6位の精度）
    if (abs(abs(start.y) - 1.f) < 0.000001f) {
        y = -start.y;
    }
    return CGPointMake(x, y);
}

// ワールド座標からスクリーン座標へ変換
- (CGPoint)translateCoord:(CGPoint)worldPoint
{
    CGRect screen = [[UIScreen mainScreen] bounds];
    float x = (worldPoint.x + 1) * (screen.size.width / 2.0);
    float y = (-worldPoint.y + 1) * (screen.size.height / 2.0);
    return CGPointMake(x, y);
}

// viewをスクリーンに表示されない、かつposに一番近いスクリーン座標へ移動させる
- (void)shiftToInvisiblePosition:(UIView *)view pos:(CGPoint)pos
{
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGSize viewSize = [view bounds].size;
    // floatの近似等値比較（小数点第6位の精度）
    if (abs(pos.x) < 0.000001f) {
        pos.x -= viewSize.width;
    } else if (abs(pos.x - screenSize.width) < 0.000001f){
        pos.x += viewSize.width;
    }
    if (abs(pos.y) < 0.000001f) {
        pos.y -= viewSize.height;
    } else if (abs(pos.y - screenSize.height) < 0.000001f) {
        pos.y += viewSize.height;
    }
    view.center = pos;
}

// 正解の顔がバナーに隠れて見えない領域のみを通らないように調整する
-(void)adjustEndCoordForBanner:(CGPoint*)start end:(CGPoint*)end
{
    CGRect screenRect = [UIScreen mainScreen].bounds;
    // 画面の上下端を通るような場合は変更しない
    if (abs(start->y - end->y) >= screenRect.size.height) {
        return;
    }

    CGRect bannerRect = self.adView.frame;
    // バナーの上端y座標
    CGFloat bannerUpperY = bannerRect.origin.y;
    // バナーの下端y座標
    CGFloat bannerBottomY = bannerUpperY + bannerRect.size.height;
    // startがバナー範囲内か
    BOOL startIsInBanner = (start->y >= bannerUpperY) && (start->y <= bannerBottomY);
    // endがバナー範囲内か
    BOOL endIsInBanner = (end->y >= bannerUpperY) && (end->y <= bannerBottomY);

    // startやendのどちらかがバナー領域を通っていなければ変更しない
    if (!startIsInBanner || !endIsInBanner) {
        return;
    }

    // 画面対角線上に移動する（確実に可視領域を通る）ように調整
    *start = CGPointMake(0, 0);
    *end = CGPointMake(screenRect.size.width, screenRect.size.height);
}

// fromからtoまでの範囲で、float型の乱数を得るユーティリティ関数
// 参考：http://qiita.com/shu223/items/489b1b9193dc1b53308b
- (float)floatRand:(float)from to:(float)to
{
    const static long long ARC4RANDOM_MAX = 0x100000000;
    return ((to-from)*((float)arc4random()/ARC4RANDOM_MAX))+from;
}

// ADBannerViewDelegate実装
// バナーがロードされたときの処理
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    // 表示
    banner.hidden = NO;
}

// バナークリック時の処理
- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    return YES;
}

// 広告のロード前の処理
- (void)bannerViewWillLoadAd:(ADBannerView *)banner
{
}

// 広告表示終了後、アプリに戻ったときの処理
- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
}

// ロードするバナーがなかったときの処理
- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    // 非表示
    banner.hidden = YES;
}
@end
