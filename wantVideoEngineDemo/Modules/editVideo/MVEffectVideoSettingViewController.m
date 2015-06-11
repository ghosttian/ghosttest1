//
//  MVEffectVideoSettingViewController.m
//  wantVideoEngineDemo
//
//  Created by ghost on 15-6-3.
//  Copyright (c) 2015年 ghost. All rights reserved.
//

#import "MVEffectVideoSettingViewController.h"

#define PANEL_VIEW_TOP_MARGIN 20
#define PANEL_VIEW_HEIGHT 120
#define PANEL_LABEL_LEFT_MARGIN 20
#define PANEL_TIMEPOINT_LABEL_TOP_MARGIN 10
#define PANEL_LABEL_WIDTH 50
#define PANEL_LABEL_HEIGHT 30
#define PANEL_TEXTFIELD_LEFT_MARGIN 20
#define PANEL_TEXTFIELD_WIDTH 30
#define PANEL_TEXTFIELD_HEIGHT 30
#define PANEL_BUTTON_LEFT_MARGIN 200
#define PANEL_BUTTON_WIDTH 50
#define PANEL_BUTTON_HEIGHT 50

@interface MVEffectVideoSettingViewController ()

@property (nonatomic,strong)UITableView *settingTableView;
@property (nonatomic,strong)UIButton *addEffectButton;

@end

@implementation MVEffectVideoSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self createTableView];
    
    [self createStaticEffectPanel];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private

- (void)createTableView{
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, self.view.width)];
    tableView.backgroundColor = [UIColor whiteColor];
    _settingTableView = tableView;
    
    [self.view addSubview:tableView];
}

- (void)createStaticEffectPanel{
    UIView *panelView = [[UIView alloc]initWithFrame:CGRectMake(0, _settingTableView.ginBottom + PANEL_VIEW_TOP_MARGIN, self.view.width, PANEL_VIEW_HEIGHT)];
    
    UILabel *timePointLabel = [[UILabel alloc]initWithFrame:CGRectMake(PANEL_LABEL_LEFT_MARGIN, PANEL_TIMEPOINT_LABEL_TOP_MARGIN, PANEL_LABEL_WIDTH, PANEL_LABEL_HEIGHT)];
    [timePointLabel setBackgroundColor:[UIColor lightGrayColor]];
    [timePointLabel setText:@"时间点"];
    
    UILabel *timeLengthLabel = [[UILabel alloc]initWithFrame:CGRectMake(PANEL_LABEL_LEFT_MARGIN, timePointLabel.ginBottom + PANEL_TIMEPOINT_LABEL_TOP_MARGIN, PANEL_LABEL_WIDTH, PANEL_LABEL_HEIGHT)];
    [timeLengthLabel setBackgroundColor:[UIColor lightGrayColor]];
    [timeLengthLabel setText:@"长度"];
    
    UITextField *timePointField = [[UITextField alloc]initWithFrame:CGRectMake(timePointLabel.ginRight + PANEL_TEXTFIELD_LEFT_MARGIN, PANEL_TIMEPOINT_LABEL_TOP_MARGIN, PANEL_TEXTFIELD_WIDTH, PANEL_TEXTFIELD_HEIGHT)];
    [timePointField setBackgroundColor:[UIColor lightGrayColor]];
    
    UITextField *timeLengthField = [[UITextField alloc]initWithFrame:CGRectMake(timeLengthLabel.ginRight + PANEL_TEXTFIELD_LEFT_MARGIN, timeLengthLabel.ginBottom + PANEL_TIMEPOINT_LABEL_TOP_MARGIN, PANEL_TEXTFIELD_WIDTH, PANEL_TEXTFIELD_HEIGHT)];
    [timeLengthField setBackgroundColor:[UIColor lightGrayColor]];
    
    UIButton *addEffectButton = [[UIButton alloc]initWithFrame:CGRectMake(PANEL_BUTTON_LEFT_MARGIN, (panelView.height - PANEL_BUTTON_HEIGHT)/2, PANEL_BUTTON_WIDTH, PANEL_BUTTON_HEIGHT)];
    [addEffectButton setTitle:@"添加" forState:UIControlStateNormal];
    [addEffectButton setBackgroundColor:[UIColor lightGrayColor]];
    _addEffectButton = addEffectButton;
    
    [panelView addSubview:timePointLabel];
    [panelView addSubview:timePointField];
    [panelView addSubview:timeLengthLabel];
    [panelView addSubview:timeLengthField];
    [panelView addSubview:addEffectButton];
    
    [self.view addSubview:panelView];
    
}
@end
