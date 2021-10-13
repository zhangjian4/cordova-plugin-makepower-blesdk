//
//  CountAdd.m
//  helloCordova
//
//  Created by 谭泳林 on 2021/9/27.
//

#import "MPBLE.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <YNTT14BleSDK/YNTT14BleBase.h>

@interface MPBLE ()<YNTT14BleCallBackDelegate,CBCentralManagerDelegate, CBPeripheralDelegate>
{
    NSString* discoverPeripheralCallbackId;
    NSString* readCallbackId;//读取方法返回id
    NSDictionary *bluetoothStates;
    NSArray <CBUUID *>*screenUUIDs;//扫描筛选字段
    NSDictionary *bluetoothMacs;
}

@property (strong, nonatomic) NSMutableSet *peripherals;
@property (strong, nonatomic) CBCentralManager *manager;
@property (nonatomic, strong) CBPeripheral *peripheral;//外设
@property (nonatomic, strong) CBCharacteristic *characteristic;//通知

//声明个SDK
@property (nonatomic, strong) YNTT14BleBase *lockSDK;

@end

@implementation MPBLE

@synthesize manager;
@synthesize peripherals;

- (void)pluginInitialize {
    [self InitBlueSDK];
    [super pluginInitialize];
    
    bluetoothStates = [NSDictionary dictionaryWithObjectsAndKeys:
                       @"unknown", @(CBManagerStateUnknown),
                       @"resetting", @(CBManagerStateResetting),
                       @"unsupported", @(CBManagerStateUnsupported),
                       @"unauthorized", @(CBManagerStateUnauthorized),
                       @"off", @(CBManagerStatePoweredOff),
                       @"on", @(CBManagerStatePoweredOn),
                       nil];
}

//扫描连接外设
- (void)scanPeripheral
{
    //不存在进入扫描
    [manager scanForPeripheralsWithServices:screenUUIDs options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];//设为NO不会扫描重复设备
}

#pragma mark - <代理方法初始化>
-(void)InitBlueSDK
{
    self.lockSDK = [[YNTT14BleBase alloc]init];
    self.lockSDK.delegate = self;
}

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
-(void)bleConnect:(CDVInvokedUrlCommand *)command
{
    bluetoothMacs = [command argumentAtIndex:0];
    //启动蓝牙
    manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
}

-(void)openLock:(CDVInvokedUrlCommand *)command
{
    //[self.lockSDK openLockWithLockCode:<#(NSString *)#> startTime:<#(NSDate *)#> endTime:<#(NSDate *)#>];
}

#pragma mark - CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSLog(@"Status of CoreBluetooth central manager changed %@", [self BluetoothScanStatusReturned:central]);
    if(central.state == CBManagerStatePoweredOn){
        [self scanPeripheral];
    }
    if (central.state == CBManagerStateUnsupported){
        
        NSLog(@"WARNING: This hardware does not support Bluetooth Low Energy.");
    }
    
    if (discoverPeripheralCallbackId != nil) {
        CDVPluginResult *pluginResult = nil;
        NSString *state = [bluetoothStates objectForKey:@(central.state)];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:state];
        [pluginResult setKeepCallbackAsBool:TRUE];
        NSLog(@"Report Bluetooth state \"%@\" on callback %@", state, discoverPeripheralCallbackId);
        [self.commandDelegate sendPluginResult:pluginResult callbackId:discoverPeripheralCallbackId];
    }
    
    for (CBPeripheral *peripheral in peripherals) {
        if (peripheral.state == CBPeripheralStateDisconnected) {
            [self centralManager:central didDisconnectPeripheral:peripheral error:nil];
        }
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
    
    if(![self determineBluetoothExists:peripheral]){
        if ([peripheral.name containsString:bluetoothMacs[@"macAddress"]])
        {
            self.peripheral = peripheral;
            [self.manager stopScan];
            //self.peripheral.delegate = self;
            //[self.manager connectPeripheral:peripheral options:nil];
            
            [self.lockSDK bleConnectWithPeripheral:self.peripheral manager:self.manager secretKey:bluetoothMacs[@"secretKey"] secretLock:bluetoothMacs[@"secretLock"] userID:bluetoothMacs[@"userId"] isKeyDevice:bluetoothMacs[@"isKeyDevice"]];
        }
    }
    
   // [peripheral setAdvertisementData:advertisementData RSSI:RSSI];
    
//    if (discoverPeripheralCallbackId) {
//        CDVPluginResult *pluginResult = nil;
//        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[self JsonForCBPeripheralData:peripheral]];
//        NSLog(@"peripheral: %@", [self JsonForCBPeripheralData:peripheral]);
//        [pluginResult setKeepCallbackAsBool:TRUE];
//        [self.commandDelegate sendPluginResult:pluginResult callbackId:discoverPeripheralCallbackId];
//    }
}

//代理方法
-(void)yntt14BleCallBackDelegate:(NSDictionary *)dic
{
    
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
@end
