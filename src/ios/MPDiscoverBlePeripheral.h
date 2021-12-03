//
//  MPDiscoverBlePeripheral.h
//  helloCordova
//
//  Created by 谭泳林 on 2021/11/29.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@interface MPDiscoverBlePeripheral : NSObject
/** 外设 */
@property(nonatomic,strong) CBPeripheral *peripheral;
/** 广播蓝牙名称名称 */
@property(nonatomic,copy) NSString *adverName;
@end

NS_ASSUME_NONNULL_END
