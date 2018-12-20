//
//  TestViewController.m
//  QinLin
//
//  Created by 肖遥 on 2018/12/19.
//  Copyright © 2018 肖遥. All rights reserved.
//

#import "TestViewController.h"
#import "TXLiteAVSDK_Professional/TXLivePush.h"
#import "TXLiteAVSDK_Professional/TXLivePlayer.h"
#import "TXLiteAVSDK_Professional/TXLivePlayListener.h"
#import "LiveRoom/LiveRoom/LiveRoom.h"
#import "TXLiveSDKTypeDef.h"
#import "LiveRoomMsgListTableView.h"
#import "LiveRoomListViewController.h"
#import "LiveRoomPlayerItemView.h"
#import "BeautySettingPanel.h"

#define kHttpServerAddrDomain           @"https://room.qcloud.com/weapp/live_room"
typedef NS_ENUM(NSInteger, PKStatus) {
    PKStatus_IDLE,         // 空闲状态
    PKStatus_REQUESTING,   // 请求PK中
    PKStatus_BEING,        // PK中
};
@interface TestViewController ()<LiveRoomListener,UITextFieldDelegate, UITableViewDelegate,
UITableViewDataSource>
{
    TXLivePushConfig* _config;
    TXLivePush *_txLivePush;
    
    
    TXLivePlayer *_txLivePlayer;

    PKStatus                 _pkStatus;             // PK状态

}
@property(nonatomic ,strong) LiveRoom *liveRoom;
@property (nonatomic ,assign) BOOL hasPendingRequest;//


@property (weak, nonatomic) IBOutlet UIView *liveView;

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"SDK Version = %@", [TXLiveBase getSDKVersionStr]);

//推流
    // 创建 LivePushConfig 对象，该对象默认初始化为基础配置
    _config = [[TXLivePushConfig alloc] init];
    //    _config.enablePureAudioPush = YES;   // true 为启动纯音频推流，而默认值是 false；
    //在 _config中您可以对推流的参数（如：美白，硬件加速，前后置摄像头等）做一些初始化操作，需要注意 _config不能为nil
    _txLivePush = [[TXLivePush alloc] initWithConfig: _config];
    
//直播
    _txLivePlayer = [[TXLivePlayer alloc] init];
    
    
//连麦
    _liveRoom = [[LiveRoom alloc]init];
    _liveRoom.delegate = self;
}
- (IBAction)liveButtonClicked:(UIButton *)sender {
    
    [self InRoom];
}
- (IBAction)stopLive:(UIButton *)sender {
    
    [self exitRoom];
}


#pragma mark ==================== 推流  ======================
- (void)startPush {
    NSString* rtmpUrl = @"rtmp://31519.livepush.myqcloud.com/live/d71f0e3551?bizid=31519&txSecret=be487855df63ff79238dced9ec1eda6b&txTime=5C1A6AFF";
    [_txLivePush startPreview:self.liveView];  //_myView 就是step2中需要您指定的view
    [_txLivePush startPush:rtmpUrl];
}
- (void)stopPush {
    [_txLivePush stopPreview];
    [_txLivePush stopPush];
    _txLivePush.delegate = nil;
}


#pragma mark ==================== 直播  ======================
- (void)startLive {
    [_txLivePlayer setupVideoWidget:CGRectMake(0, 0, 0, 0) containView:self.liveView insertIndex:0];
    [_txLivePlayer startPlay:@"http://2157.liveplay.myqcloud.com/live/2157_xxxx.flv" type:PLAY_TYPE_LIVE_FLV];
}
- (void)stopLive {
    // 停止播放
    [_txLivePlayer stopPlay];
    [_txLivePlayer removeVideoWidget]; // 记得销毁view控件
}


#pragma mark ==================== 连麦  ======================
- (void)InRoom {
    
    LoginInfo *loginInfo = [LoginInfo new];
    loginInfo.userID = @"user_7584d6e1_c091";
    loginInfo.sdkAppID = 1400047134;
    loginInfo.userName = @"肖遥";
    loginInfo.userSig = @"eJxtjc1SgzAYRd8lWx0n0ADBGRflp7WkzIiFRd1kKElrphLSJIg-47uLiDs3d3HP9537Ccrt7qZWSjBaW7rQDNwCB0EIUeAsELj*5U3T9dJS*674D8c*CmYkGJdWHAXXI*gN1zTwMGI*d2gDQ2e*MuxMp5H-7Fa0k9VDnhuMCeeevymhOa2PdpK7XuiOn39GcRq7PK3iTZFscX1Pmqt25yY4XptoWPf7Ln1quuy8Ci-SZmpp-PaC5EuxOS3JKyoys8qHAcmP1sLDIzk866iUeZxWZI*LKCEPZQVRcQe*vgG5l1YT";
    loginInfo.accType = @"18647";
    loginInfo.userAvatar = @"";
    WEAK
    [self.liveRoom login:kHttpServerAddrDomain loginInfo:loginInfo withCompletion:^(int errCode, NSString *errMsg) {
        NSLog(@"init LiveRoom errCode[%d] errMsg[%@]", errCode, errMsg);
        if (errCode == 0) {
            NSLog(@"成功------------------成功");
            dispatch_async(dispatch_get_main_queue(), ^{
                STRONG
                // 开启推流和本地预览
                [self.liveRoom startLocalPreview:self.liveView];
                [self.liveRoom createRoom:@"" roomInfo:@"31" withCompletion:^(int errCode, NSString *errMsg) {
                    NSLog(@"createRoom: errCode[%d] errMsg[%@]", errCode, errMsg);
                    NSLog(@"创建成功------------------创建成功");
                }];
//                [self.liveRoom getRoomList:0 cnt:20 withCompletion:^(int errCode, NSString *errMsg, NSArray<RoomInfo *> *roomInfoArray) {
//                    if (errCode == 0) {
//                        NSLog(@"拉取成功------------------拉取成功");//拉取成功
//                        //创建直播间createRoom
//                        [self.liveRoom createRoom:@"" roomInfo:@"31" withCompletion:^(int errCode, NSString *errMsg) {
//                            NSLog(@"createRoom: errCode[%d] errMsg[%@]", errCode, errMsg);
//                            NSLog(@"创建成功------------------创建成功");
//                        }];
//                    } else {
//                        NSLog(@"拉取失败------------------拉取失败");//拉取失败
//                    }
//                }];
            });
        } else {
            NSLog(@"失败------------------失败");
        }
    }];
    
   
}
- (void)exitRoom {
    [self.liveRoom exitRoom:^(int errCode, NSString *errMsg) {
        NSLog(@"exitRoom: errCode[%d] errMsg[%@]", errCode, errMsg);
        NSLog(@"退出房间");
    }];
}

/**
 大主播收到连麦请求
 */
- (void)onRecvJoinPusherRequest:(NSString *)userID userName:(NSString *)userName userAvatar:(NSString *)userAvatar {
    if (_hasPendingRequest || _pkStatus != PKStatus_IDLE) {
        [_liveRoom rejectJoinPusher:userID reason:@"请稍后，主播正忙"];
        return;
    }
    _hasPendingRequest = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *msg = [NSString stringWithFormat:@"[%@]请求连麦", userName];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:msg preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"拒绝" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.hasPendingRequest = NO;
            [self.liveRoom rejectJoinPusher:userID reason:@"主播不同意您的连麦"];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"接受" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.hasPendingRequest = NO;
            [self.liveRoom acceptJoinPusher:userID];
        }]];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.hasPendingRequest = NO;
            [alertController dismissViewControllerAnimated:NO completion:nil];
        });
    });
}





/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
