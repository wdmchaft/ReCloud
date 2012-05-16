//
//  Constants.h
//  ReCloud
//
//  Created by hanl on 12-4-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TAG_SLIDER_VIEW 10
#define TAG_SLIDER_BACK_VIEW 11
#define TAG_BLOCK_VIEW 20
#define TAG_TAGSLIDERVIEW_PROGRESS_LABEL 21
#define TAG_TAGVIEW_COUNTLABEL 30
#define TAG_TAGVIEW_TIMELABEL 31
#define TAG_TAGVIEW_POINT 32
#define TAG_WAITINGVIEW_ACTIVITY_INDICATOR 40
#define TAG_CELL_BG 49
#define TAG_COUNTLABEL 50
#define TAG_TIMELABEL 51
#define TAG_TITLELABEL 52
#define TAG_EDITING_BUTTON1 53
#define TAG_UPLOAD_BUTTON1 54
#define TAG_EDITING_BUTTON2 55
#define TAG_DELETING_BUTTON2 56
#define TAG_EDITVIEW_TEXTVIEW 60
#define TAG_EDITVIEW_OK_BUTTON 61
#define TAG_EDITVIEW_CANCEL_BUTTON 62
#define TAG_OVERLAY_MESSAGE_LABEL_PORT 63
#define TAG_OVERLAY_MESSAGE_LABEL_LAND 64
#define TAG_TAGSLIDERVIEW_TIMELABEL 100
#define TAG_TAGSLIDERVIEW_SQUARE 101
#define TAG_TAGSLIDERVIEW_LINE 102
#define TAG_TIME_LABEL 1000
#define TAG_DATE_LABEL 1001
#define TAG_TITLE_LABEL 1002
#define TAG_DURATION_LABEL 1003
#define TAG_SIZE_LABEL 1004
#define BASE_TAG_PLAYBACK_TAGVIEW 7000
#define BASE_TAG_SPECTRUM_ITEMVIEW 2000

#define kDate @"Date"
#define kTime @"Time"
#define kTitle @"Title"
#define kDuration @"Duration"
#define kSize @"Size"
#define kFilename @"Filename"
#define kIdleTime @"IdleTime"
#define kTag @"Tag"
#define kCurrentTime @"CurrentTime"
#define kTagTitle @"TagTitle"
#define kSliderViewBlockXpos @"SliderViewBlockXpos"

#define CUSTOM_COLOR(R, G, B) [UIColor colorWithRed:R / 255 green:G / 255 blue:B / 255 alpha:1.0] 

#define SPECTRUM_ITEM_COUNT 10

#define AUDIO_DIR @"data"
#define SAMPLE_DIR @"sample"
#define INDEX_DIR @"index"

#define NOTIFY_WILL_SLIDE @"nWillSlideSliderView"
#define NOTIFY_END_SLIDE @"nEndSlideSliderView"
#define NOTIFY_SLIDING @"nSlidingSliderView"
#define NOTIFY_SLIDERVIEW_X_CHANGED @"nSliderViewXposChanged"



