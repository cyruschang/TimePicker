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

@interface ViewController ()<UIPickerViewDataSource, UIPickerViewDelegate> {
    int _currentYear;
    int _currentMonth;
    int _currentDay;
    int _selectedYear;
    int _selectedMonth;
}
@property (nonatomic, strong) NSDate       *date;
@property (nonatomic, strong) UIView       *backgroundView;
@property (nonatomic, strong) UIView       *maskView;
@property (nonatomic, strong) UIPickerView *timePickerView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self initComponent];
    [self initView];
    [self initPickerView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initComponent {
    self.date = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setLocale:[NSLocale localeWithLocaleIdentifier:@"ZH_CN"]];
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *components = [calendar components:unitFlags fromDate:_date];
    
    _currentYear   = (int)[components year];
    _currentMonth  = (int)[components month];
    _currentDay    = (int)[components day];
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

- (void)hideTimePicker {
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
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideTimePicker)];
    [self.maskView addGestureRecognizer:tap];
    
    self.backgroundView.width = SCREEN_WIDTH;
}

- (void)initPickerView {
    self.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 216, SCREEN_WIDTH, 216)];
    self.backgroundView.backgroundColor = [UIColor orangeColor];
    
    UIButton *buttonCancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 46, 30)];
    [buttonCancel setTitle:@"取消" forState:UIControlStateNormal];
    [buttonCancel setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [self.backgroundView addSubview:buttonCancel];
    [buttonCancel addTarget:self action:@selector(cancelClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *buttonSure = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 46, 0, 46, 30)];
    [buttonSure setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [buttonSure setTitle:@"确定" forState:UIControlStateNormal];
    [self.backgroundView addSubview:buttonSure];
    [buttonSure addTarget:self action:@selector(sureClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.timePickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 30, SCREEN_WIDTH, 216 - 30)];
    self.timePickerView.delegate = self;
    self.timePickerView.dataSource = self;
    [self.backgroundView addSubview:self.timePickerView];
    
    // 选定当前的时间
    [self.timePickerView selectRow:0 inComponent:0 animated:YES];
    [self.timePickerView selectRow:_currentMonth - 1 inComponent:1 animated:YES];
    [self.timePickerView selectRow:_currentDay - 1 inComponent:2 animated:YES];
}

- (void)cancelClicked:(UIButton *)button {
    [self hideTimePicker];
}

- (void)sureClicked:(UIButton *)button {
    [self hideTimePicker];
}

#pragma mark - UIPickerViewDataSource, UIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    switch (component) {
        case 0:
        {
            return 2050 - _currentYear + 1;
        }break;
        case 1:
        {
            return 12;
        }break;
        case 2:
        {
            if (_selectedMonth == 0 || _selectedMonth == 2 || _selectedMonth == 4 || _selectedMonth == 6 || _selectedMonth == 7 || _selectedMonth == 9 || _selectedMonth == 11) {
                return 31;
            } else if (_selectedMonth == 1) {
                int yearint = _selectedYear + _currentYear;
                
                if(((yearint % 4 == 0) && (yearint % 100 != 0))||(yearint % 400 == 0)){
                    return 29;
                }
                else {
                    return 28; // or return 29
                }
            } else {
                return 30;
            }

        }break;
        default:
            return 0;
            break;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) {
        _selectedYear = (int)row;
    } else if (component == 1) {
        _selectedMonth = (int)row;
    }
    [pickerView reloadAllComponents];
    
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component == 0) {
        return [NSString stringWithFormat:@"%d年", _currentYear + (int)row];
    } else if (component == 1) {
        return [NSString stringWithFormat:@"%d月", (int)row + 1];
    } else {
        return [NSString stringWithFormat:@"%d日", (int)row + 1];
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel* pickerLabel = (UILabel*)view;
    if (!pickerLabel){
        pickerLabel = [[UILabel alloc] init];
        pickerLabel.adjustsFontSizeToFitWidth = YES;
        [pickerLabel setTextAlignment:NSTextAlignmentCenter];
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
        [pickerLabel setFont:[UIFont systemFontOfSize:13]];
        pickerLabel.layer.cornerRadius = 3;
        pickerLabel.layer.masksToBounds = YES;
        
    }
    pickerLabel.text=[self pickerView:pickerView titleForRow:row forComponent:component];
    return pickerLabel;
}
@end
