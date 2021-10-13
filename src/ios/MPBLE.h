//
//  CountAdd.h
//  helloCordova
//
//  Created by 谭泳林 on 2021/9/27.
//

#import <Cordova/CDV.h>

NS_ASSUME_NONNULL_BEGIN

@interface MPBLE : CDVPlugin

//实现SDK功能
-(void)coolMethod:(CDVInvokedUrlCommand *)command;
- (void)scan:(CDVInvokedUrlCommand*)command;//扫描设备
- (void)bleConnect:(CDVInvokedUrlCommand*)command;//连接设备
- (void)disConnect:(CDVInvokedUrlCommand *)command;//断开连接
- (void)getBleInfo:(CDVInvokedUrlCommand *)command;//读取蓝牙信息
- (void)initKey:(CDVInvokedUrlCommand *)command;//初始化电子钥匙
- (void)setBleClock:(CDVInvokedUrlCommand *)command;//设置设备时间
- (void)initLockCode:(CDVInvokedUrlCommand *)command;//锁具初始化
- (void)getLockCode:(CDVInvokedUrlCommand *)command;//读取锁具ID
- (void)getKeyCode:(CDVInvokedUrlCommand *)command;//读取钥匙编码
- (void)getLockState:(CDVInvokedUrlCommand *)command;//获取锁具状态
- (void)openLock:(CDVInvokedUrlCommand *)command;//在线开锁
- (void)setTask:(CDVInvokedUrlCommand *)command;//离线开锁
- (void)readLog:(CDVInvokedUrlCommand *)command;//读取开门日志
- (void)removeLog:(CDVInvokedUrlCommand *)command;//日志删除

@end

NS_ASSUME_NONNULL_END
