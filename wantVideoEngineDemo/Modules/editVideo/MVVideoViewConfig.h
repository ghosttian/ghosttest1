//
//  MVVideoViewConfig.h
//  wantVideoEngineDemo
//
//  Created by ghost on 15-6-2.
//  Copyright (c) 2015年 ghost. All rights reserved.
//

#ifndef wantVideoEngineDemo_MVVideoViewConfig_h
#define wantVideoEngineDemo_MVVideoViewConfig_h

#define BOTTOM_BAR_BTN_BOTTOM_MARGIN   (IPHONE5 ? 67 : 45)
#define BOTTOM_BAR_BTN_WIDTH_MARGIN    15

#define VIDEO_PREVIEW_TOP_BAR_HEIGHT      44
#define VIDEO_BOTTOM_TOOL_BAR_HEIGHT      (BOTTOM_BAR_BTN_BOTTOM_MARGIN + 100)
#define VIDEO_PREVIEW_WIDTH           ([[UIScreen mainScreen] bounds].size.width)
#define VIDEO_PREVIEW_HEIGHT          ([[UIScreen mainScreen] bounds].size.width)
#define VIDEO_PREVIEW_HEIGHT2         (VIDEO_PREVIEW_WIDTH / 4 * 3)

#define VIDEO_MIDDLE_CONTAINER_TOP (IPHONE5 ? VIDEO_PREVIEW_TOP_BAR_HEIGHT : 0)


#define TOP_BAR_BTN_TOP_MARGIN      4.5
#define TOP_BAR_TIMER_TOP_MARGIN    8
#define TOP_BAR_BTN_WIDTH_MARGIN    10
#define TOP_BAR_BTN_SPACE_MARGIN    16


#define PROGRESS_BAR_PREVIEW_SPACE_MARGIN 2
#define PROGRESS_BAR_HEIGHT 13
#define PROGRESS_BAR_TRANSITION_DROP_ORIGIN_Y (8)

//动画引用
#define kShootTopContainerViewTag (33000)
#define kShootProgressBarTag      (33001)
#define kShootDeleteButtonTag     (33002)
#define kShootNextButtonTag       (33003)
#define kShootVideoPreviewTag     (33004)
#define kShootBottomContainerViewTag (33005)
#define kShootVideoSourceModeSelectButtonTag (33006)
#define kShootVideoModeNameTipLabelTag (33007)


#define kEditNavigationBarTag                  (44000)
#define kEditVideoPreviewTag		           (44001)
#define kEditBottomViewTag                     (44002)
#define kEditResourceBarTag                    (44003)

#endif
