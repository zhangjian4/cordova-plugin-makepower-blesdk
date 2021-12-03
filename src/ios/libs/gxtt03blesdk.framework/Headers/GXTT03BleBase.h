//
//  GXTT04BleBase.h
//  TestBLESDKDemo
//
//  Created by Mac on 17/9/6.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
@protocol gxtt03CallBackDelegate<NSObject>
-(void)gxttm03BCallBackDelegate:(NSDictionary *)dic;
@end
@interface GXTT03BleBase : NSObject<CBPeripheralDelegate,CBCentralManagerDelegate>
@property(nonatomic,assign)id<gxtt03CallBackDelegate>delegate;
/**
*断开BLE连接
*/
-(void)bleDisConnect;

-(void)readBleInfo;
/**
 *断开BLE连接
 */
-(void)readLockState;

-(void)keyInit;

-(void)setBleClock:(NSDate *)date;

-(void)lockCodeInit:(NSString *)lockCode;
-(void)bleConnectWithPeripheral:(CBPeripheral *)peripheral manager:(CBCentralManager *)manager secretKey:(NSString *)secretKey secretLock:(NSString *)secretLock userID:(NSString *)userID isKeyDevice:(BOOL)isKeyDevice;






-(void)openLockWithLockCode:(NSString *)lockCode
                   startTime:(NSDate *)startTime
                     endTime:(NSDate *)endTime;

-(void)readLog;

-(void)setTaskWithLockCodes:(NSArray *)lockCodes
                       areas:(NSArray *)areas
                   startTime:(NSDate *)startTime
                     endTime:(NSDate *)endTime
                 offLineTime:(NSInteger)offLineTime;


-(void)readLockCode;

-(void)readKeyCode;





@end
