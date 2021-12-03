//
//  CountAdd.m
//  helloCordova
//
//  Created by 谭泳林 on 2021/9/27.
//

#import "MPBLE.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <YNTT14BleSDK/YNTT14BleBase.h>
#import <HNTT01CLProtocol/HNTT01BleLock.h>
#import <gxtt03blesdk/GXTT03BleBase.h>

typedef NS_ENUM(NSInteger,BlueSDKType){
    BlueSDKBleConnect,
    BlueSDKDisConnect,
    BlueSDKGetBleInfo,
    BlueSDKInitKey,
    BlueSDKSetBleClock,
    BlueSDKInitLockCode,
    BlueSDKGetLockCode,
    BlueSDKGetKeyCode,
    BlueSDKGetLockState,
    BlueSDKOpenLock,
    BlueSDKSetTask,
    BlueSDKReadLog,
    BlueSDKRemoveLog,
};

@interface MPBLE ()<YNTT14BleCallBackDelegate,hntt01BleLockCallBackDelegate,gxtt03CallBackDelegate,CBCentralManagerDelegate, CBPeripheralDelegate>
{
    NSString* discoverPeripheralCallbackId;
    NSString* readCallbackIds;//读取方法返回id
    NSString* macAddress;
    NSString* secretKey;
    NSString* secretLock;
    NSString* userID;
    BOOL isKeyDevice;
    NSString* setType;
    NSString* bleConnectCallbackId;
    NSString* bleClock;
    NSString* lockCode;
    NSString* startTime;
    NSString* endTime;
    NSArray* lockCodes;
    NSArray* areas;
    NSArray* openLockCommand;
    NSArray*setTaskCommand;
    NSInteger offLineTime;
    NSDictionary *bluetoothStates;
    NSArray <CBUUID *>*screenUUIDs;//扫描筛选字段
    NSDictionary *bluetoothMacs;
}

@property (strong, nonatomic) NSMutableSet *peripherals;
@property (strong, nonatomic) CBCentralManager *manager;
@property (nonatomic, strong) CBPeripheral *peripheral;//外设
@property (nonatomic, strong) CBCharacteristic *characteristic;//通知

//声明SDK
@property (nonatomic, strong) YNTT14BleBase *yntt14BleLock;
@property (nonatomic, strong) HNTT01BleLock *hntt01BleLock;
@property (nonatomic, strong) GXTT03BleBase *gxtt03BleLock;

//SDK共同对象
@property (nonatomic, strong) id sdkCommon;

@end

@implementation MPBLE

@synthesize manager;
@synthesize peripherals;

- (void)pluginInitialize {
    [super pluginInitialize];
    
    peripherals = [NSMutableSet new];
    bluetoothStates = [NSDictionary dictionaryWithObjectsAndKeys:
                       @"unknown", @(CBManagerStateUnknown),
                       @"resetting", @(CBManagerStateResetting),
                       @"unsupported", @(CBManagerStateUnsupported),
                       @"unauthorized", @(CBManagerStateUnauthorized),
                       @"off", @(CBManagerStatePoweredOff),
                       @"x", @(CBManagerStatePoweredOn),
                       nil];
}

//扫描连接外设
- (void)scanPeripheral
{
    //不存在进入扫描
    [manager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];//设为NO不会扫描重复设备
}

#pragma mark - <代理方法初始化>

-(void)coolMethod:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult* pluginResult = nil;
    NSString* echo = [command.arguments objectAtIndex:0];
    
    if (echo != nil && [echo length] > 0) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:echo];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

#pragma mark - <实现方法>
-(void)scan:(CDVInvokedUrlCommand *)command
{
    
}

//设置厂商编号
-(void)setType:(CDVInvokedUrlCommand *)command
{
    NSLog(@"setType数据%@--- %@",command.arguments,command.callbackId);
    setType = [command.arguments objectAtIndex:0];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setWithBlueSDK];
    });
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

//连接设备
-(void)bleConnect:(CDVInvokedUrlCommand *)command
{
    macAddress = [command.arguments objectAtIndex:0];
    secretKey = [command.arguments objectAtIndex:1];
    secretLock = [command.arguments objectAtIndex:2];
    userID = [command.arguments objectAtIndex:3];
    NSString*keyDevice = [NSString stringWithFormat:@"%@",[command.arguments objectAtIndex:4]];
    
    if ([keyDevice isEqualToString:@"1"]) {
        isKeyDevice = YES;
    }
    bleConnectCallbackId = [command.callbackId copy];
    NSLog(@"数组内容>>%@    设备ID  %@ --%@",command.arguments,command.callbackId,bleConnectCallbackId);
    dispatch_async(dispatch_get_main_queue(), ^{
        self->manager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
    });
}

//断开连接
-(void)disConnect:(CDVInvokedUrlCommand *)command
{
    [self ConnectBluetoothDeviceWithType:BlueSDKDisConnect readCallbackId:command.callbackId];
}

//读取蓝牙信息
-(void)getBleInfo:(CDVInvokedUrlCommand *)command
{
    [self ConnectBluetoothDeviceWithType:BlueSDKGetBleInfo readCallbackId:command.callbackId];
}

//初始化电子钥匙
-(void)initKey:(CDVInvokedUrlCommand *)command
{
    [self ConnectBluetoothDeviceWithType:BlueSDKInitKey readCallbackId:command.callbackId];
}

//设置设备时间
-(void)setBleClock:(CDVInvokedUrlCommand *)command
{
    bleClock = [command.arguments objectAtIndex:0];
    NSLog(@"设置设备时间>>%@",bleClock);
    [self ConnectBluetoothDeviceWithType:BlueSDKSetBleClock readCallbackId:command.callbackId];
}

//锁具初始化
-(void)initLockCode:(CDVInvokedUrlCommand *)command
{
    lockCode = [command.arguments objectAtIndex:0];
    NSLog(@"锁具初始化>>%@",lockCode);
    [self ConnectBluetoothDeviceWithType:BlueSDKInitLockCode readCallbackId:command.callbackId];
}

//读取锁具ID
-(void)getLockCode:(CDVInvokedUrlCommand *)command
{
    [self ConnectBluetoothDeviceWithType:BlueSDKGetLockCode readCallbackId:command.callbackId];
}

//读取钥匙编码
-(void)getKeyCode:(CDVInvokedUrlCommand *)command
{
    [self ConnectBluetoothDeviceWithType:BlueSDKGetKeyCode readCallbackId:command.callbackId];
}

//获取锁具状态
-(void)getLockState:(CDVInvokedUrlCommand *)command
{
    [self ConnectBluetoothDeviceWithType:BlueSDKGetLockState readCallbackId:command.callbackId];
}

//在线开锁
-(void)openLock:(CDVInvokedUrlCommand *)command
{
    openLockCommand = command.arguments;
    lockCode = [command.arguments objectAtIndex:0];
    startTime = [command.arguments objectAtIndex:1];
    endTime = [command.arguments objectAtIndex:2];
    NSLog(@"在线开锁内容%@",openLockCommand);
    [self ConnectBluetoothDeviceWithType:BlueSDKOpenLock readCallbackId:command.callbackId];
}

//离线开锁
-(void)setTask:(CDVInvokedUrlCommand *)command
{
    setTaskCommand = command.arguments;
    lockCodes = (NSArray *)[command.arguments objectAtIndex:0];
    areas = (NSArray *)[command.arguments objectAtIndex:1];
    startTime = [command.arguments objectAtIndex:2];
    endTime = [command.arguments objectAtIndex:3];
    NSString *offLineTimeStr = command.arguments[4];
    offLineTime = [offLineTimeStr integerValue];
    
    NSLog(@"离线开锁内容%@",setTaskCommand);
    [self ConnectBluetoothDeviceWithType:BlueSDKSetTask readCallbackId:command.callbackId];
}

//读取开门日志
-(void)readLog:(CDVInvokedUrlCommand *)command
{
    [self ConnectBluetoothDeviceWithType:BlueSDKReadLog readCallbackId:command.callbackId];
}

//日志删除
-(void)removeLog:(CDVInvokedUrlCommand *)command
{
    [self ConnectBluetoothDeviceWithType:BlueSDKRemoveLog readCallbackId:command.callbackId];
}

-(void)ConnectBluetoothDeviceWithType:(BlueSDKType)type readCallbackId:(NSString *)readCallbackId
{
    readCallbackIds = [readCallbackId copy];
    NSLog(@"huidiao>>>%@--%@",readCallbackIds,readCallbackId);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
            {
            switch (type) {
                case BlueSDKBleConnect:
                    [self.sdkCommon bleConnectWithPeripheral:self.peripheral manager:self.manager secretKey:self->secretKey secretLock:self->secretLock userID:self->userID isKeyDevice:self->isKeyDevice];
                    break;;
                case BlueSDKDisConnect:
                    [self.sdkCommon bleDisConnect];
                    break;
                case BlueSDKGetBleInfo:
                    [self.sdkCommon readBleInfo];
                    break;
                case BlueSDKInitKey:
                    [self.sdkCommon keyInit];
                    break;
                case BlueSDKSetBleClock:
                    [self.sdkCommon setBleClock:[self dateWithString:self->bleClock format:@"yyyy-MM-dd HH:mm:ss"]];
                    break;
                case BlueSDKInitLockCode:
                    [self.sdkCommon lockCodeInit:self->lockCode];
                    break;
                case BlueSDKGetLockCode:
                    [self.sdkCommon readLockCode];
                    break;
                case BlueSDKGetKeyCode:
                    [self.sdkCommon readKeyCode];
                    break;
                case BlueSDKGetLockState:
                    [self.sdkCommon readLockState];
                    break;
                case BlueSDKOpenLock:
                    [self.sdkCommon openLockWithLockCode:self->lockCode startTime:[self dateWithString:self->startTime format:@"yyyy-MM-dd HH:mm:ss"] endTime:[self dateWithString:self->endTime format:@"yyyy-MM-dd HH:mm:ss"]];
                    break;
                case BlueSDKSetTask:
                    [self.sdkCommon setTaskWithLockCodes:self->lockCodes areas:self->areas startTime:[self dateWithString:self->startTime format:@"yyyy-MM-dd HH:mm:ss"] endTime:[self dateWithString:self->endTime format:@"yyyy-MM-dd HH:mm:ss"] offLineTime:self->offLineTime];
                    break;
                case BlueSDKReadLog:
                    [self.sdkCommon readLog];
                    break;
                case BlueSDKRemoveLog:
                    [self.sdkCommon removeLog];
                    break;
                default:
                    break;
            }
        });
    });
}

#pragma mark - CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSLog(@"Status of CoreBluetooth central manager changed %@", [self BluetoothScanStatusReturned:central]);
    switch (central.state) {
        case CBManagerStatePoweredOn: {
            NSLog(@"蓝牙打开成功，开始扫描设备 . . .");
            [self scanPeripheral];
        }
            break;
            
        case CBManagerStateUnsupported: {
            NSLog(@"模拟器不支持蓝牙扫描");
        }
            break;
            
        case CBManagerStatePoweredOff: {
            NSLog(@"蓝牙未开启，请开启蓝牙后重试");
            [self stopScan];
        }
            break;
        case CBManagerStateUnauthorized: {
            NSLog(@"未能正常获取权限，请去设置中允许应用使用蓝牙");
        }
            break;
            
        default:
            break;
    }
}

- (NSString *)BluetoothScanStatusReturned:(CBCentralManager *)central{
    switch (central.state)
    {
        case CBManagerStatePoweredOn://蓝牙已开启
        {
            return @"蓝牙已开启<CBManagerStatePoweredOn>";
        }
            break;
            
        case CBManagerStateUnsupported://不支持蓝牙
        {
            return @"模拟器不支持蓝牙扫描<CBManagerStateUnsupported>";
        }
            break;
            
        case CBManagerStatePoweredOff://蓝牙未开启
        {
            return @"蓝牙未开启<CBManagerStatePoweredOff>";
        }
            break;
        case CBManagerStateUnauthorized://获取权限失败
        {
            return @"未能正常获取权限<CBManagerStateUnauthorized>";
        }
            break;
        default:
            break;
    }
    return @"未知错误类型！";
}

//发现外设
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
    //连接指定外设
    if (macAddress != nil) {
        if ([peripheral.identifier.UUIDString containsString:macAddress])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.peripheral = peripheral;
                [self stopScan];
            });
           
            [self ConnectBluetoothDeviceWithType:BlueSDKBleConnect readCallbackId:bleConnectCallbackId];
        }
    }
}

#pragma mark - 蓝牙连接
-(void)setWithBlueSDK
{
    if ([setType isEqualToString:@"hntt01"]) {
        self.hntt01BleLock = [[HNTT01BleLock alloc]init];
        self.hntt01BleLock.delegate = self;
        self.sdkCommon = self.hntt01BleLock;
    }
    else if ([setType isEqualToString:@"yntt14"])
    {
        self.yntt14BleLock = [[YNTT14BleBase alloc]init];
        self.yntt14BleLock.delegate = self;
        self.sdkCommon = self.yntt14BleLock;
    }
    else if ([setType isEqualToString:@"gxtt03"])
    {
        self.gxtt03BleLock = [[GXTT03BleBase alloc]init];
        self.gxtt03BleLock.delegate = self;
        self.sdkCommon = self.gxtt03BleLock;
    }
    else
    {
        self.hntt01BleLock = [[HNTT01BleLock alloc]init];
        self.hntt01BleLock.delegate = self;
        self.sdkCommon = self.hntt01BleLock;
    }
}

- (void)stopScan {
    [manager stopScan];
}

#pragma mark SDK代理方法
-(void)yntt14BleCallBackDelegate:(NSDictionary *)dic
{
    NSLog(@"yntt14BleCallBack代理回调内容%@ --- %@",dic,dic[@"msg"]);
    [self setBleLockCallBackDelegateDic:dic];
    
}

-(void)gxttm03BCallBackDelegate:(NSDictionary *)dic
{
    NSLog(@"gxttm03BCallBack代理回调内容%@ --- %@",dic,dic[@"msg"]);
    [self setBleLockCallBackDelegateDic:dic];
}

-(void)hntt01BleLockCallBackDelegate:(NSDictionary *)dic
{
    NSLog(@"hntt01BleLock代理回调内容%@ --- %@---%@ ",dic,dic[@"msg"],readCallbackIds);
//    NSString *idt = dic[@"idt"];
//    if ([idt isEqualToString:@"0202"]) {
//        [self.hntt01BleLock openLockWithLockCode:@"330304010298B002" startTime:[NSDate date] endTime:[NSDate dateWithTimeInterval:24*60*60 sinceDate:[NSDate date]]];
//    }
    [self setBleLockCallBackDelegateDic:dic];
}

//回调出去
-(void)setBleLockCallBackDelegateDic:(NSDictionary *)dic
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSString *idt = dic[@"idt"];
        NSString *msg = dic[@"msg"];
        if ([msg containsString:@"成功"])
        {
            //读取锁具ID
            if ([idt hasPrefix:@"09"])
            {
                NSDictionary *obj = dic[@"obj"];
                NSString *lockCode = obj[@"lockCode"];
                [self resultWithStatusStr:CDVCommandStatus_OK messageAsString:lockCode];
            }
            
            //连接成功
            if ([idt hasPrefix:@"02"])
            {
                
                [self resultWithStatusStr:CDVCommandStatus_OK messageAsString:msg];
            }
            
            //断开蓝牙连接
            if ([idt hasPrefix:@"03"])
            {
                [self resultWithStatusStr:CDVCommandStatus_OK messageAsString:msg];
            }
            
            //读取蓝牙设备信息
            if ([idt hasPrefix:@"04"])
            {
                NSDictionary *obj = dic[@"obj"];
                NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
                [dictionary setValue:obj[@"batteryPower"] forKey:@"batteryPower"];
                [dictionary setValue:obj[@"hardwareVersion"] forKey:@"hardwareVersion"];
                [dictionary setValue:obj[@"firmwareVersion"] forKey:@"firmwareVersion"];
                [dictionary setValue:obj[@"validityPeriod"] forKey:@"validityPeriod"];
                [dictionary setValue:obj[@"hardwareVersion"] forKey:@"hardwareVersion"];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                [dictionary setValue:[dateFormatter stringFromDate:obj[@"clock"]] forKey:@"clock"];
                
                [self resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dictionary];
            }
            
            //初始化电子钥匙
            if ([idt hasPrefix:@"05"])
            {
                NSDictionary *obj = dic[@"obj"];
                NSString *keyCode = obj[@"keyCode"];
                [self resultWithStatusStr:CDVCommandStatus_OK messageAsString:keyCode];
            }
            
            //设置钥匙时间
            if ([idt hasPrefix:@"06"])
            {
                [self resultWithStatusStr:CDVCommandStatus_OK messageAsString:msg];
            }
            
            //锁具初始化
            if ([idt hasPrefix:@"08"])
            {
                NSDictionary *obj = dic[@"obj"];
                NSString *lockCode = obj[@"lockCode"];
                [self resultWithStatusStr:CDVCommandStatus_OK messageAsString:lockCode];
            }
            
            //开锁方法在线Or离线
            if ([idt hasPrefix:@"10"] || [idt hasPrefix:@"11"])
            {
                [self resultWithStatusStr:CDVCommandStatus_OK messageAsString:msg];
            }
            
            //读取日志
            if ([idt hasPrefix:@"12"])
            {
                NSMutableArray *objArray = [NSMutableArray array];
                for (NSDictionary *obj in dic[@"obj"])
                {
                    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
                    [dictionary setValue:obj[@"lockCode"] forKey:@"lockCode"];
                    [dictionary setValue:obj[@"userId"] forKey:@"userId"];
                    [dictionary setValue:obj[@"logType"] forKey:@"logType"];
                    [dictionary setValue:obj[@"isSuccess"] forKey:@"isSuccess"];
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    [dictionary setValue:[dateFormatter stringFromDate:obj[@"actionDate"]] forKey:@"actionDate"];
                    [objArray addObject:dictionary];
                    
                }
                [self resultWithStatusArray:CDVCommandStatus_OK messageAsArray:objArray];
            }
            
            //日志删除
            if ([idt hasPrefix:@"13"])
            {
                [self resultWithStatusStr:CDVCommandStatus_OK messageAsString:msg];
            }
            
            //异常断开
            if ([idt hasPrefix:@"14"])
            {
                [self resultWithStatusStr:CDVCommandStatus_ERROR messageAsString:msg];
            }
            
            //读取钥匙编码
            if ([idt hasPrefix:@"15"])
            {
                NSDictionary *obj = dic[@"obj"];
                NSString *keyCode = obj[@"keyCode"];
                [self resultWithStatusStr:CDVCommandStatus_OK messageAsString:keyCode];
            }
            
            //获取锁具状态
            if ([idt hasPrefix:@"16"])
            {
                [self resultWithStatusStr:CDVCommandStatus_OK messageAsString:msg];
            }
        }
        else
        {
            [self resultWithStatusStr:CDVCommandStatus_ERROR messageAsString:msg];
           
        }
    });
}

-(void)resultWithStatus:(CDVCommandStatus)Status messageAsDictionary:(NSDictionary *)resultsDic
{
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:Status messageAsDictionary:resultsDic];
    //将 CDVPluginResult.keepCallback 设置为 true ,则不会销毁callback
  //[pluginResult setKeepCallbackAsBool:YES];
    [self resultWithPluginResult:pluginResult];
}

-(void)resultWithStatusStr:(CDVCommandStatus)status messageAsString:(NSString *)str{
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:status messageAsString:str];
    //将 CDVPluginResult.keepCallback 设置为 true ,则不会销毁callback
  //[pluginResult setKeepCallbackAsBool:YES];
    [self resultWithPluginResult:pluginResult];
}

-(void)resultWithStatusArray:(CDVCommandStatus)status messageAsArray:(NSArray *)array{
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:status messageAsArray:array];
    //将 CDVPluginResult.keepCallback 设置为 true ,则不会销毁callback
  //[pluginResult setKeepCallbackAsBool:YES];
    [self resultWithPluginResult:pluginResult];
}

-(void)resultWithPluginResult:(CDVPluginResult *)pluginResult
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self->readCallbackIds];
    });
}

//不重复添加设备
-(BOOL)determineBluetoothExists:(CBPeripheral *)newPeripheral{
    for (CBPeripheral *peripheral in peripherals) {
        if(peripheral == newPeripheral){
            return YES;
        }
    }
    return NO;
    
}

- (NSDictionary *)JsonForCBPeripheralData:(CBPeripheral *)peripheral{
    NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
    [dataDic setValue:peripheral.name forKey:@"name"];
    [dataDic setValue:peripheral.RSSI forKey:@"rssi"];
    return dataDic;
    
}

- (NSDate *)dateWithString:(NSString *)dateString format:(NSString *)format {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    return [formatter dateFromString:[self changeStringToDate:dateString]];
}

-(NSString *)changeStringToDate:(NSString *)string {

    //带有T的时间格式，是前端没有处理包含时区的，强转后少了8个小时，date是又少了8个小时，所有要加16个小时。
    NSString *str =[string stringByReplacingOccurrencesOfString:@"T"withString:@" "];
    NSString *sss =[str substringToIndex:19];
    //    NSString *str1 =[str stringByReplacingOccurrencesOfString:@".000Z" withString:@""];
    NSDateFormatter *dateFromatter = [[NSDateFormatter alloc] init];
    [dateFromatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [dateFromatter setTimeZone:timeZone];
    
    NSDate *date = [dateFromatter dateFromString:sss];
    NSDate *newdate = [[NSDate date] initWithTimeInterval:8 * 60 * 60 sinceDate:date];//
    NSDate *newdate1 = [[NSDate date] initWithTimeInterval:8 * 60 * 60 sinceDate:newdate];
    NSString *newstr =[[NSString stringWithFormat:@"%@",newdate1] substringToIndex:19];

    return newstr;
}

-(void)stopManager
{
    self.peripheral = nil;
    self.manager = nil;
}

@end
