//
//  MPDiscoverBlePeripheral.m
//  helloCordova
//
//  Created by 谭泳林 on 2021/11/29.
//

#import "MPDiscoverBlePeripheral.h"

@implementation MPDiscoverBlePeripheral
- (BOOL)isEqualToDiscoverBlePeripheral:(MPDiscoverBlePeripheral *)per {
    if (!per) {
        return NO;
    }

    BOOL bIsEqualAges = self.peripheral == per.peripheral;

    return bIsEqualAges;
}

#pragma mark - 重载isEqual方法

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[MPDiscoverBlePeripheral class]]) {
        return NO;
    }
    
    MPDiscoverBlePeripheral *per = (MPDiscoverBlePeripheral *)object;
    
    return [self isEqualToDiscoverBlePeripheral:per];
    
}

@end
