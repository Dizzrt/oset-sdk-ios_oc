//
//  Test.m
//  Oset
//
//  Created by Dizzrt on 2023/3/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ETReporter : NSObject

@property (nonatomic, strong)NSString *accessKey;
@property (nonatomic, strong)NSString *secretKey;
@property (nonatomic, strong)NSString *content;

+ (instancetype)sharedReporter;
+ (id)allocWithZone:(struct _NSZone *)zone;
- (nonnull id)copyWithZone:(nullable NSZone *)zone;
- (nonnull id)mutableCopyWithZone:(nullable NSZone *)zone;

- (void)initWithAccessKey:(NSString *)ak secretKey:(NSString *)secretKey content:(NSString *)content;
- (void)reportEvent:(NSString *)event data:(NSDictionary *)data did:(NSInteger)did;

@end

NS_ASSUME_NONNULL_END
