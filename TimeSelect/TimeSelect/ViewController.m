//
//  ViewController.m
//  TimeSelect
//
//  Created by ZuoShou on 16/1/4.
//  Copyright © 2016年 ZuoShou. All rights reserved.
//

#import "ViewController.h"
#import "MacroDefinition.h"
#import "UIView+RGSize.h"

@interface ViewController ()
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIPickerView *timePickerView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self initView];
    [self initPickerView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)timeButtonClicked:(id)sender {
    [self.view addSubview:self.maskView];
    [self.view addSubview:self.backgroundView];
    self.maskView.alpha = 0;
    self.backgroundView.top = self.view.height;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.maskView.alpha = 0.3;
        self.backgroundView.bottom = self.view.height;
    }];
}

- (void)hideTimePicker:(UITapGestureRecognizer *)tap {
    [UIView animateWithDuration:0.3 animations:^{
        self.maskView.alpha = 0;
        self.backgroundView.top = self.view.height;
    } completion:^(BOOL finished) {
        [self.maskView removeFromSuperview];
    }];
}

- (void)initView {
    self.maskView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.maskView.backgroundColor = [UIColor blackColor];
    self.maskView.alpha = 0;
    self.maskView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideTimePicker:)];
    [self.maskView addGestureRecognizer:tap];
    
    self.backgroundView.width = SCREEN_WIDTH;
}

- (void)initPickerView {
    self.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 216, SCREEN_WIDTH, 216)];
    self.backgroundView.backgroundColor = [UIColor orangeColor];
}
@end
