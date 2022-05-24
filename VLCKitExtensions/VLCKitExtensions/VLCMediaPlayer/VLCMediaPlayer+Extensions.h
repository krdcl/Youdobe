//
//  VLCMediaPlayerExtensions.h
//  VLCKitExtensions
//
//  Created by Yurii Samoienko on 16.05.2022.
//

#import <Foundation/Foundation.h>
@import MobileVLCKit;
//#import "MobileVLCKit/MobileVLCKit.h"

NS_ASSUME_NONNULL_BEGIN

@interface VLCMediaPlayer (extensions)
- (int64_t)getTimeMsec;
- (void)setTimeMsec:(int64_t)time;
- (void)clearPlaybackSlaves;
@end

NS_ASSUME_NONNULL_END
