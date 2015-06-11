//
//  MVEditVideoViewController.m
//  wantVideoEngineDemo
//
//  Created by ghost on 15-6-2.
//  Copyright (c) 2015年 ghost. All rights reserved.
//

#import "MVEditVideoViewController.h"
#import "MVVideoEffectPlayerModel.h"
#import "MVVideoEffectDefines.h"
#import "MVVideoViewConfig.h"
#import "MVVideoEffectPlayerV2.h"
#import "GPUImageView.h"
#import "UIView+Addtion.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "CTAssetsPickerController.h"
#import "MVEffectVideoSettingViewController.h"

#define VIDEO_PREVIEW_TOP_MARGIN 64
#define BUTTON_WIDTH 100
#define BUTTON_HEIGHT 30
#define BUTTON_LEFT_MARGIN 20
#define BUTTON_RIGHT_MARGIN 20
#define BUTTON_MIDDLE_MARGIN (VIDEO_PREVIEW_WIDTH - BUTTON_LEFT_MARGIN - BUTTON_RIGHT_MARGIN - BUTTON_WIDTH*2)
#define BUTTON_TOP_MARGIN 30

@interface MVEditVideoViewController ()<UINavigationControllerDelegate,CTAssetsPickerControllerDelegate>

//播放器
@property (nonatomic, strong) MVVideoEffectPlayerV2 *effectPlayer;
@property (nonatomic, strong) UIView *preview;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *imgSelectButton;
@property (nonatomic, strong) UIButton *imgSettingButton;
@property (nonatomic, strong) NSMutableArray *videoAssets;

@end

@implementation MVEditVideoViewController

- (void)dealloc{
    [self.effectPlayer cancelPlay];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _effectPlayer = [[MVVideoEffectPlayerV2 alloc] init];
    }
    
    return self;
}

- (instancetype)initWithOriginalVideoPath:(NSString *)originalVideoPath
{
    if (!originalVideoPath) {
        return nil;
    }
    
    MVCompositiongDataVideoType type = MVCompositiongDataVideoShortType;
    
    return [self initWithOriginalVideoPath:originalVideoPath videoType:type];
    
}

- (instancetype)initWithOriginalVideoPath:(NSString *)originalVideoPath
                                videoType:(MVCompositiongDataVideoType)videoType
{
    self = [self init];
    if (self)
    {
        _effectModel = [[MVVideoEffectModel alloc] init];
        _effectModel.originVideoPath = originalVideoPath;
        _effectModel.videoType = videoType;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    [self renderUI];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self playVideo];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)playVideo{
    __weak typeof(self) wself = self;
    
    [self.effectPlayer loadEffectModel:[self createEffectplayerModel] completion:^(NSError *error) {
        typeof(self) sself = wself;
        if (!error) {
            [sself.effectPlayer startPlay];
        }
    }];
}

#pragma mark - effect player model function

- (MVVideoEffectPlayerModel *)createEffectplayerModel
{
    NSString *noneId = [NSString stringWithFormat:@"%@", @(MVConfigurationNone)];
    
    MVVideoEffectPlayerModel *effectPlayerModel = [[MVVideoEffectPlayerModel alloc] init];
    effectPlayerModel.originVideoPath = self.effectModel.originVideoPath;
    effectPlayerModel.originAsset = self.effectModel.originAsset;
    effectPlayerModel.effectVideoPath = self.effectModel.effectVideoPath;
    effectPlayerModel.finalVideoPath = self.effectModel.finalVideoPath;
    effectPlayerModel.musicPath = self.effectModel.musicPath;
    effectPlayerModel.musicVolume = self.effectModel.musicVolume;
    effectPlayerModel.isSilent = self.effectModel.isSilent;
    effectPlayerModel.effectUserData = self.effectModel.effectUserData;
    effectPlayerModel.isLongVideo = self.effectModel.videoType == MVCompositiongDataVideoLongType; //支持拖动
    
    if (self.effectModel.filterID && ![self.effectModel.filterID isEqualToString:noneId]) {
        effectPlayerModel.effectUserData = self.effectModel.effectUserData;
    }else if(self.effectModel.beautyFilterID && ![self.effectModel.beautyFilterID isEqualToString:noneId]){
        effectPlayerModel.effectUserData = self.effectModel.beautyUserData;
    }else{
        // Do nothing
    }
    
    return effectPlayerModel;
}

#pragma mark - private

- (void)renderUI{
    self.navigationController.navigationBarHidden = YES;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self buildPlayerView];
    [self buildButtons];
}

- (void)updateEffectModel:(AVAsset *)originalVideoAsset{
    _effectModel.originAsset = originalVideoAsset;
    _effectModel.videoType = MVCompositiongDataVideoShortType;
}

#pragma mark - build functions

- (void)buildPlayerView{
    
    CGRect playerViewRect = CGRectMake(0, VIDEO_PREVIEW_TOP_MARGIN, VIDEO_PREVIEW_WIDTH, VIDEO_PREVIEW_HEIGHT);
    self.effectPlayer.ginPreviewView.frame = playerViewRect;
    self.effectPlayer.ginPreviewView.tag = kEditVideoPreviewTag;
    [self.view addSubview:self.effectPlayer.ginPreviewView];
    self.preview = self.effectPlayer.ginPreviewView;
    
    WEAK_SELF(wself);
    [self.effectPlayer.ginPreviewView setTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
        [wself onClickVideoPlayPreview];
    }];
    
    //Play button
    self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.playButton setImage:[UIImage imageNamed:@"home_tl_btn_play_nor"] forState:UIControlStateNormal];
    self.playButton.hidden = YES;
    [self.playButton sizeToFit]; //???
    self.playButton.center = CGPointMake(VIDEO_PREVIEW_WIDTH/2.0, VIDEO_PREVIEW_HEIGHT/2.0);//???
    [self.effectPlayer.ginPreviewView addSubview:self.playButton];
    [self.playButton addTarget:self action:@selector(onClickPlayVideoBtn:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)buildButtons{
    UIButton *imgSelectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [imgSelectBtn setTitle:@"选视频" forState:UIControlStateNormal];
    imgSelectBtn.width = BUTTON_WIDTH;
    imgSelectBtn.height = BUTTON_HEIGHT;
    imgSelectBtn.origin = CGPointMake((self.view.width - BUTTON_WIDTH)/2, self.preview.ginBottom + BUTTON_TOP_MARGIN);
    [imgSelectBtn setBackgroundColor:[UIColor grayColor]];
    [imgSelectBtn addTarget:self action:@selector(onSelectVideo:) forControlEvents:UIControlEventTouchUpInside];
    _imgSelectButton = imgSelectBtn;
    
//    UIButton *imgSettingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [imgSettingBtn setTitle:@"设置定帧" forState:UIControlStateNormal];
//    imgSettingBtn.width = BUTTON_WIDTH;
//    imgSettingBtn.height = BUTTON_HEIGHT;
//    imgSettingBtn.origin = CGPointMake(imgSelectBtn.ginRight + BUTTON_MIDDLE_MARGIN, self.preview.ginBottom + BUTTON_TOP_MARGIN);
//    [imgSettingBtn setBackgroundColor:[UIColor grayColor]];
//    [imgSettingBtn addTarget:self action:@selector(onSetStaticSetting:) forControlEvents:UIControlEventTouchUpInside];
//    _imgSettingButton = imgSettingBtn;
    
    
    [self.view addSubview:_imgSelectButton];
//    [self.view addSubview:_imgSettingButton];
}

#pragma mark - event handler
- (void)onSelectVideo:(id)sender{
    
    [self.effectPlayer pausePlay];
    
    if (!_videoAssets) {
        _videoAssets = [NSMutableArray arrayWithCapacity:10];
    }
    
    CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
    picker.maximumNumberOfSelection = 1;
    picker.assetsFilter = [ALAssetsFilter allVideos];
    picker.delegate = self;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)onSetStaticSetting:(id)sender{
    MVEffectVideoSettingViewController *controller = [[MVEffectVideoSettingViewController alloc]init];
    
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)onClickPlayVideoBtn:(id)sender{
    self.playButton.hidden = YES;
    
    // 处理完成  或者 没开始
    if ([self.effectPlayer isProcessingCompleted] || !self.effectPlayer.didProcessedFirstFrame) {
        [self playVideo];
    } else {
        [self.effectPlayer resumePlay];
    }
}

- (void)onClickVideoPlayPreview
{
    if ([self.effectPlayer isPlaying]) {
        self.playButton.hidden = NO;
        [self.effectPlayer pausePlay];
    } else {
        self.playButton.hidden = YES;
        
        if ([self.effectPlayer isProcessingCompleted]) {
            [self playVideo];
        } else {
            [self.effectPlayer resumePlay];
        }
    }
}

#pragma mark - CTAssetsPickerControllerDelegate

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (assets && [assets count] > 0) {
            ALAsset *videoAsset = [assets objectAtIndex:0];
            
            NSURL *assetURL = videoAsset.defaultRepresentation.url;
            AVAsset *asset = [AVAsset assetWithURL:assetURL];
            if (asset) {
                [self updateEffectModel:asset];
                
                [self.effectPlayer cancelPlay];
                [self playVideo];
            }
            
        }
    });
}

- (void)assetsPickerControllerDidCancel:(CTAssetsPickerController *)picker{
    ;
}

@end
