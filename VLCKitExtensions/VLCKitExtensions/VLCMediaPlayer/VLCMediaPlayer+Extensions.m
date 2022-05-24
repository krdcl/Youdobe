//
//  VLCMediaPlayerExtensions.m
//  VLCKitExtensions
//
//  Created by Yurii Samoienko on 16.05.2022.
//

#import "VLCMediaPlayer+Extensions.h"
//#import "MobileVLCKit/MobileVLCKit.h" //"MobileVLCKit/

//#import <vlc/vlc.h>
#import "vlc.h"
//#import "libvlc/vlc/include/libvlc_media_player.h"
//#import "MobileVLCKit/libvlc_media_player.h"
//#import "include/vlc/libvlc_media_player.h"
//#import "headers/libvlc_media_player.h"

@interface VLCMediaPlayer()
{
    
}
- (void *)libVLCMediaPlayer; // private method
@end

@implementation VLCMediaPlayer(extensions)

- (int64_t)getTimeMsec {
    libvlc_media_player_t * _playerInstance = [self libVLCMediaPlayer];
    int64_t time = libvlc_media_player_get_time(_playerInstance);
    return time;
}

- (void)setTimeMsec:(int64_t)time {
    libvlc_media_player_t * _playerInstance = [self libVLCMediaPlayer];
    libvlc_media_player_set_time(_playerInstance, time, true);
}

- (void)clearPlaybackSlaves {
    libvlc_media_player_t * _playerInstance = [self libVLCMediaPlayer];
    int64_t time = libvlc_media_player_get_time(_playerInstance);
    libvlc_media_t *media = libvlc_media_player_get_media(_playerInstance);
    libvlc_media_slaves_clear(media);
    
//    [self play];
    libvlc_media_player_set_media(_playerInstance, media);
//    libvlc_media_slaves_add(media, libvlc_media_slave_type_audio, 0, "https://rr2---sn-x8xgxnu05-8poe.googlevideo.com/videoplayback?expire=1652988483&ei=40WGYoGYL7CD0u8P5aCtuA0&ip=141.138.126.113&id=o-AI0M7-FZAbHBfiNXUPvKfk_Bsg28PFqgEOrWdybLRcks&itag=251&source=youtube&requiressl=yes&mh=gp&mm=31%2C29&mn=sn-x8xgxnu05-8poe%2Csn-3c27snee&ms=au%2Crdu&mv=m&mvi=2&pl=19&initcwndbps=672500&vprv=1&mime=audio%2Fwebm&gir=yes&clen=3975038&dur=212.641&lmt=1630381555841817&mt=1652966471&fvip=2&keepalive=yes&fexp=24001373%2C24007246&c=ANDROID&txp=1432434&sparams=expire%2Cei%2Cip%2Cid%2Citag%2Csource%2Crequiressl%2Cvprv%2Cmime%2Cgir%2Cclen%2Cdur%2Clmt&sig=AOq0QJ8wRAIgQaOEVNNj9VYFJ2mqtv7L934eWCUkxz1wdKRdLkmgjMICIDKyNFYQFtLTi7k-EUxcMTFIjj_9qv8ac-hc86gDX1Gu&lsparams=mh%2Cmm%2Cmn%2Cms%2Cmv%2Cmvi%2Cpl%2Cinitcwndbps&lsig=AG3C_xAwRAIgLtiHEO76cfzP2Mom2unWOL7ClhhosjPhfjAsb5bmxmYCICeSmSXJ13lcK91qlVP4X4uqSruu_6BqfIdgsPAH0zxW");
//   libvlc_media_player_set_media(_playerInstance, media);
    
//    return;
//    self.time = time;
    libvlc_media_player_set_time(_playerInstance, time, true);
    [self play];
//    libvlc_media_player_set_time(_playerInstance, time, true);
}
@end
