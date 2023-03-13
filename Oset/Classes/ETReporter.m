//
//  Test.m
//  Oset
//
//  Created by Dizzrt on 2023/3/7.
//

#import "ETReporter.h"
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonCryptor.h>

@interface ETReporter ()

@property (nonatomic, strong)NSString *signature;

@end
static ETReporter *instance = nil;

@implementation ETReporter

#pragma mark - life
+ (instancetype)sharedReporter {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    return instance;
}

- (nonnull id)mutableCopyWithZone:(nullable NSZone *)zone {
    return instance;
}

- (void)initWithAccessKey:(NSString *)ak secretKey:(NSString *)sk content:(NSString *)content {
    self.accessKey = ak;
    self.secretKey = sk;
    self.content = content;
    
    const char *csk = [sk cStringUsingEncoding:NSASCIIStringEncoding];
    const char *ccontent = [content cStringUsingEncoding:NSASCIIStringEncoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, csk, strlen(csk), ccontent, strlen(ccontent), cHMAC);
    NSData *HMACData = [NSData dataWithBytes:cHMAC length:sizeof(cHMAC)];
    const unsigned char *buffer = (const unsigned char *)[HMACData bytes];
    
    NSMutableString *HMAC = [NSMutableString stringWithCapacity:HMACData.length * 2];
    for (int i = 0; i < HMACData.length; i++) {
        [HMAC appendFormat:@"%02x", buffer[i]];
    }
    
    self.signature = HMAC;
}

#pragma mark - public method
- (void)reportEvent:(NSString *)event data:(NSDictionary *)data did:(NSInteger)did {
    NSString *urlStr = [NSString stringWithFormat:@"http://127.0.0.1:8080/event/report/1008"];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    NSInteger timestamp = [[NSDate date] timeIntervalSince1970];
    
    [request setValue:self.accessKey forHTTPHeaderField:@"x-auth-accesskey"];
    [request setValue:self.signature forHTTPHeaderField:@"x-auth-signature"];
    [request setValue:self.content forHTTPHeaderField:@"x-auth-content"];
    [request setValue:[NSString stringWithFormat:@"%ld",timestamp] forHTTPHeaderField:@"x-auth-timestamp"];
    
    NSMutableDictionary *mdic = [[NSMutableDictionary alloc] init];
    NSError *error;
    NSString *dataStr;
    NSData *json = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:&error];
    if (!json) {
        NSLog(@"Got an error: %@", error);
    } else {
        dataStr = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
    }
    
    
    [mdic setObject:dataStr forKey:@"data"];
    [mdic setObject:event forKey:@"event"];
    [mdic setObject:@(did) forKey:@"did"];
    
    json = nil;
    NSString *bodyStr;
    json = [NSJSONSerialization dataWithJSONObject:mdic options:NSJSONWritingPrettyPrinted error:&error];
    if (!json) {
        NSLog(@"Got an error: %@", error);
    } else {
        bodyStr = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
    }
    request.HTTPBody = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
        NSLog(@"%@\n%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding],res.allHeaderFields);
    }];
    
    [task resume];
}

@end
