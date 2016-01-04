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
    int _currentHour;
    int _currentMin;
    
    int _selectedYear;
    int _selectedMonth;
    int _selectedDay;
    int _selectedHour;
    int _selectedMin;
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
    
    _currentYear  = (int)[components year];
    _currentMonth = (int)[components month];
    _currentDay   = (int)[components day];
    _currentHour  = (int)[components hour];
    _currentMin   = (int)[components minute];
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
    self.backgroundView.backgroundColor = [UIColor whiteColor];
    
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
    [self.timePickerView selectRow:_currentHour inComponent:3 animated:YES];
    [self.timePickerView selectRow:_currentMin inComponent:4 animated:YES];
}

- (void)cancelClicked:(UIButton *)button {
    [self hideTimePicker];
}

- (void)sureClicked:(UIButton *)button {
    [self hideTimePicker];
    
    // 得到选择的时间
    int year  = (int)[self.timePickerView selectedRowInComponent:0];
    int month = (int)[self.timePickerView selectedRowInComponent:1];
    int day   = (int)[self.timePickerView selectedRowInComponent:2];
    int hour  = (int)[self.timePickerView selectedRowInComponent:3];
    int min   = (int)[self.timePickerView selectedRowInComponent:4];
    
    DLog(@"%d-%d-%d", year, month, day);
    int realYear = _currentYear + year;
    int realMonth = month + 1;
    int realDay = day + 1;
    int realHour = hour;
    int realMin = min;
    
    NSString *timeStr = [NSString stringWithFormat:@"%d-%02d-%02d %02d:%02d", realYear, realMonth, realDay, realHour, realMin];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm";
    NSDate *date = [formatter dateFromString:timeStr];
    date = [self getNowDateFromatAnDate:date];
    DLog(@"%@", date);
}

//  IOS 世界标准时间UTC /GMT 转为当前系统时区对应的时间
//  引用 http://blog.csdn.net/fengsh998/article/details/9731617
- (NSDate *)getNowDateFromatAnDate:(NSDate *)anyDate
{
    //设置源日期时区
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];//或GMT
    //设置转换后的目标日期时区
    NSTimeZone* destinationTimeZone = [NSTimeZone localTimeZone];
    //得到源日期与世界标准时间的偏移量
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:anyDate];
    //目标日期与本地时区的偏移量
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:anyDate];
    //得到时间偏移量的差值
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    //转为现在时间
    NSDate* destinationDateNow = [[NSDate alloc] initWithTimeInterval:interval sinceDate:anyDate];
    return destinationDateNow;
}

#pragma mark - UIPickerViewDataSource, UIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 5;
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
        case 3:
        {
            return 24;
        }break;
        case 4:
        {
            return 60;
        }
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
    } else if (component == 2) {
        _selectedDay = (int)row;
    } else if (component == 3) {
        _selectedHour = (int)row;
    } else {
        _selectedMin = (int)row;
    }
    [pickerView reloadAllComponents];
    
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component == 0) {
        return [NSString stringWithFormat:@"%d年", _currentYear + (int)row];
    } else if (component == 1) {
        return [NSString stringWithFormat:@"%d月", (int)row + 1];
    } else if (component == 2){
        return [NSString stringWithFormat:@"%d日", (int)row + 1];
    } else if (component == 3) {
        return [NSString stringWithFormat:@"%d时", (int)row];
    } else {
        return [NSString stringWithFormat:@"%d分", (int)row];
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
