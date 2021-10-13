//
//  YNTT14BleBase.h
//  YNTT14BleSDK
//
//  Created by yangli on 2020/6/24.
//  Copyright © 2020 yangli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

typedef NS_ENUM(NSUInteger, BleCallBackType) {
    
    BleCallBackTypeScanPeripheral = 0,///< 搜索到外设
    BleCallBackTypeSDKInit = 1,///< SDK初始化
    BleCallBackTypeBluetoothConnect, ///< 连接蓝牙模块
    BleCallBackTypeBluetoothDisconnet,///< 断开蓝牙连接
    BleCallBackTypeReadBleInfo,///< 读取蓝牙设备信息
    BleCallBackTypeInitKey = 5,///< 初始化电子钥匙
    BleCallBackTypeSetKeytime,///< 设置钥匙时间
    BleCallBackTypeSetKeyOffline,///< 设置钥匙离线
    BleCallBackTypeInitLock,///< 锁具初始化
    BleCallBackTypeReadLockID,///< 读取锁具ID
    BleCallBackTypeUnlock1 = 10,///< 开锁方法1
    BleCallBackTypeUnlock2,///< 开锁方法2
    BleCallBackTypeReadOpenLog,///< 读取钥匙开门日志
    BleCallBackTypeDeleteLog,///< 日志删除
    BleCallBackTypeBluetoothAbnormalDisconnect,///< 蓝牙与设备异常断开
    BleCallBackTypeReadKeyID = 15,///< 读取钥匙编码
    BleCallBackTypeReadLockState,///< 读取锁具状态
};

@protocol  YNTT14BleCallBackDelegate <NSObject>


/// SDK回调方法
/// @param dic 回调内容
/// eg:{
///   ret: (NSNumber *)YES/NO; //返回成功或失败标识
///   idt: (BleCallBackType)BleCallBackTypeSDKInit;//回调标识符
///   msg: (NSString)@"OK"; //成功、失败的信息内容
///   obj: (NSDictionary *)@{}; //其他内容
/// }
-(void)yntt14BleCallBackDelegate:(NSDictionary *)dic;

@end


@interface YNTT14BleBase : NSObject

@property (nonatomic,weak)id <YNTT14BleCallBackDelegate> delegate;

///获取单例对象
+(instancetype)sharedSingleton;

///搜索外设(默认初始化自动调用)
-(void)startScanPeripheralWithResult:(void(^)(CBPeripheral *peripheral,NSDictionary *advertisementData,NSNumber *RSSI))result;

///停止搜索
-(void)stopScan;


/// 连接钥匙蓝牙模块
/// @param peripheral 当前控制器蓝牙周边设备
/// @param secretKey secretKey
/// @param manager  manager
/// @param secretLock secretLock
/// @param userID 用户ID
/// @param isKeyDevice 判断连接设备是蓝牙钥匙还是蓝牙锁
-(void)bleConnectWithPeripheral:(CBPeripheral *)peripheral
                        manager:(CBPeripheralManager *)manager
                      secretKey:(NSString *)secretKey
                     secretLock:(NSString *)secretLock
                         userID:(NSString *)userID
                    isKeyDevice:(BOOL)isKeyDevice;


/// 断开钥匙蓝牙连接
-(void)bleDisConnect;

/// 读取蓝牙信息
-(void)readBleInfo;

/// 锁具初始化
/// @param lockCode 锁具编码
-(void)lockCodeInit:(NSString *)lockCode;

///初始化电子钥匙 （注册电子钥匙）
-(void)keyInit;

/// 设置设备时间
/// @param date 当前时间
-(void)setBleClock:(NSDate *)date;

/// 读取锁具ID
-(void)readLockCode;

/// 读取钥匙编码
-(void)readKeyCode;

/// 获取锁具状态
-(void)readLockState;

/// 开锁(在线)
/// @param lockCode 锁具ID
/// @param startTime 权限开始时间
/// @param endTime 权限结束时间
-(void)openLockWithLockCode:(NSString *)lockCode
                  startTime:(NSDate *)startTime
                     endTime:(NSDate *)endTime;


/// 开锁(离线 同步权限方式)
/// @param lockCodes 锁具ID列表
/// @param areas 区域ID列表
/// @param startTime 任务开始时间
/// @param endTime 任务结束时间
/// @param offLineTime 脱机时间(单位:H)
-(void)setTaskWithLockCodes:(NSArray *)lockCodes
                      areas:(NSArray *)areas
                  startTime:(NSDate *)startTime
                    endTime:(NSDate *)endTime
                offLineTime:(NSInteger)offLineTime;


/// 读取开门日志
-(void)readLog;

/// 日志删除
-(void)removeLog;

@end


