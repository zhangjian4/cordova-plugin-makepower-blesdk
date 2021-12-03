//
//  HNTT01BleLock.h
//  BluetoothSDK2
//
//  Created by 陈志勇 on 2017/7/26.
//  Copyright © 2017年 陈志勇. All rights reserved.
//  1021更新

#import <Foundation/Foundation.h>

@class CBCentralManager;
@class CBPeripheral;
@protocol hntt01BleLockCallBackDelegate <NSObject>

- (void)hntt01BleLockCallBackDelegate:(NSDictionary*)dic;

@end

@interface HNTT01BleLock : NSObject
/** 代理 */
@property (weak, nonatomic) id<hntt01BleLockCallBackDelegate> delegate;



/**
 蓝牙连接外设
 
 @param peripheral 蓝牙外设
 @param manager 蓝牙管理者
 @param secretKey 蓝牙钥匙秘钥
 @param secretLock 蓝牙锁秘钥
 @param userID 用户ID 2个字节
 @param isKeyDevice YES 钥匙 ： NO 蓝牙锁
 */
- (void)bleConnectWithPeripheral:(CBPeripheral *)peripheral
                         manager:(CBCentralManager *)manager
                       secretKey:(NSString *)secretKey
                      secretLock:(NSString *)secretLock
                          userID:(NSString *)userID
                     isKeyDevice:(BOOL)isKeyDevice;

/**
 断开蓝牙连接
 */
- (void)bleDisConnect;

/**
 读取蓝牙设备信息：电池电量、时钟时间、硬件版本、软件版本、脱机时间（扩展）
 */
- (void)readBleInfo;

/**
 初始化钥匙
 */
- (void)keyInit;

/**
 设置蓝牙设备时钟
 
 @param currentDate 服务器时间
 */
- (void)setBleClock:(NSDate *)currentDate;

/**
 锁具初始化
 
 @param lockCode 锁具ID
 */
- (void)lockCodeInit:(NSString*)lockCode;

/**
 读取锁具ID
 */
- (void)readLockCode;

/**
 读取钥匙ID
 */
- (void)readKeyCode;

/**
 读取锁具状态：门磁状态、锁舌状态、门状态
 */
- (void)readLockState;

/**
 在线开门
 
 @param lockCode 锁具ID
 @param startTime 权限开始时间
 @param endTime 权限结束时间
 */
- (void)openLockWithLockCode:(NSString *)lockCode
                   startTime:(NSDate *)startTime
                     endTime:(NSDate *)endTime;

/**
 离线、同步授权开门
 
 @param lockCodes 锁具列表
 @param areas 区域列表
 @param startTime 授权开始时间
 @param endTime 授权结束时间
 @param offlineTime 任务脱机有效时间
 */
- (void)setTaskWithLockCodes:(NSArray *)lockCodes
                       areas:(NSArray *)areas
                   startTime:(NSDate *)startTime
                     endTime:(NSDate *)endTime
                 offLineTime:(NSInteger)offlineTime;

/**
 读取日志
 */
- (void)readLog;

/**
 删除日志
 */
- (void)removeLog;


/**
 授权执行器
 
 @param time 授权时效
 @param addressArray 执行器地址数组（NSNumber)
 */
- (void)empowerControllerTime:(NSInteger)time addressArray:(NSArray *)addressArray;



//+(NSData *)hexStringToData:(NSString *)hexString;
////sdk初始化
///*输入：(nsstring PlatformID ,nsstring  TimesStamp,nsstring secretKey)平台识别号密文，时间戳明文,钥匙密钥
// 说明：PlatformID，平台唯一识别码，sdk一次验证调用的合法性；
// TimesStamp，时间戳明文，PlatformID里包含了时间戳；
// secretKey，临时保存，类似钥匙密钥、系统码等，用于SDK方法与硬件通讯时的验证，结束sdk调用是销毁。
//
// 输出：供应商标识，SDK版本，SDK发布时间
// */
//-(void)SDKInit:(NSString*)PlatformID TimesStamp:(NSString*)TimesStamp secretKey:(NSString*)secretKey userid:(NSString*)userid;
//
////连接蓝牙
///*CBCentralManager manager//当前控制器蓝牙中心设备，CBPeripheral peripheral         //当前控制器蓝牙周边设备
// */
//-(void)BleConnect:(CBPeripheral*)Peripheral manager:(CBCentralManager*)manager;
//
//
////读取钥匙信息
///**/
//-(void)readModInfo;
//
//
////钥匙初始化
///**/
//-(void)Keyinit;
//
//
////设置钥匙时间
///*输入：nsstring CurrentDate //当前时间，时间格式"yyyy-MM-dd HH:mm:ss.SSS"
// */
//-(void)issuedKeyClock:(NSString*)destDateString;
//
//
////设置钥匙离线时间
///*输入： nsstring  time //time ，可输入：0～65535，单位：分钟
// */
//-(void)setOfflineTime:(NSString*)time;
//
//
////锁具初始化
///*输入：nsstring LockCode,nsstring secretLock //锁具编码，锁具密钥
// ※可引用SDK初始化 方法里获取的 钥匙密钥“secretKey”。
// 注：锁具初始化输入参数可为空，供应商根据自身业务下发编码或上发编码自行处理。
// */
//-(void)LockCodeinit:(NSString*)LockCode secretLock:(NSString*)secretLock;
//
//
////下发开门指令（数组形式）
///*输入：nsarray <String> lockCodes，nsarray<String> Areas，nsstring startTime(如：16年2月23日17时17分，传1602231717)，nsstring endTime，nsstring secretLock，nsstring userID
// //锁具ID列表，区域ID列表,任务开始时间，任务结束时间,钥匙密钥，开锁人ID（2个字节）
// */
//-( void)openLock:(NSArray*)lockCodes Areas:(NSArray*)Areas startTime:(NSString*)startTime endTime:(NSString*)endTime secretLock:(NSString*)secretLock userID:(NSString*)userID;
//
//-( void)openLock:(NSArray*)lockCodes Areas:(NSArray*)Areas startTime:(NSString*)startTime endTime:(NSString*)endTime secretLock:(NSString*)secretLock userID:(NSString*)userID offlineTime:(NSString *)time;
//
//
////下发开门指令（非数组形式）
///*
// 输入： nsstring lockCode ，nsstring secretLock，String userID ，nsstring startTime(如：16年2月23日17时17分，传1602231717)，nsstring endTime， //锁具ID，锁具密钥, 开锁人ID（2个字节），权限开始时间，权限结束时间
// */
//-(void)OpenLock:(NSString*)LockCode secretKey:(NSString*)secretKey userID:(NSString*)userID startTime:(NSString*)startTime endTime:(NSString*)endTime;
//
//
////读取日志
//-(void)ReadLog;
//
//
////日志删除
//-(void)RemoveLog;
//
//
////断开蓝牙
///*输入：CBCentralManager manager  //蓝牙中心设备
// */
//-(void)BleDisConnect:(CBCentralManager*)manager;
////读锁具ID
//-(void)ReadLockID;
////握手
//-(void)Shakehand;
//-(void)callback1;
//
//- (void)readLockDeatil;

@end
