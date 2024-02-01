#import "DynamicIconFlutterPlugin.h"

@implementation DynamicIconFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"dynamic_icon_flutter"
                                     binaryMessenger:[registrar messenger]];
    [channel setMethodCallHandler:^(FlutterMethodCall *call, FlutterResult result) {
        if ([@"mSupportsAlternateIcons" isEqualToString:call.method]) {
            if (@available(iOS 10.3, *)) {
                result(@(UIApplication.sharedApplication.supportsAlternateIcons));
            } else {
                result([FlutterError errorWithCode:@"UNAVAILABLE"
                                        message:@"Not supported on iOS ver < 10.3"
                                        details:nil]);
            }
        } else if ([@"mGetAlternateIconName" isEqualToString:call.method]) {
            if (@available(iOS 10.3, *)) {
                result(UIApplication.sharedApplication.alternateIconName);
            } else {
                result([FlutterError errorWithCode:@"UNAVAILABLE"
                                        message:@"Not supported on iOS ver < 10.3"
                                        details:nil]);
            }
        } else if ([@"mSetAlternateIconName" isEqualToString:call.method]) {
            if (@available(iOS 10.3, *)) {
                @try {
                    NSString *iconName = call.arguments[@"iconName"];
                    if (iconName == [NSNull null]) {
                        iconName = nil;
                    }
                    if ([[UIApplication sharedApplication] respondsToSelector:@selector(supportsAlternateIcons)] && 
                        [[UIApplication sharedApplication] supportsAlternateIcons])
                    {
                        NSMutableString *selectorString = [[NSMutableString alloc] initWithCapacity:40];
                        [selectorString appendString:@"_setAlternate"];
                        [selectorString appendString:@"IconName:"];
                        [selectorString appendString:@"completionHandler:"];

                        SEL selector = NSSelectorFromString(selectorString);
                        IMP imp = [[UIApplication sharedApplication] methodForSelector:selector];
                        void (*func)(id, SEL, id, id) = (void *)imp;
                        if (func)
                        {
                            func([UIApplication sharedApplication], selector, iconName, ^(NSError * _Nullable error) {});
                        }
                    } else {
                        result([FlutterError errorWithCode:@"UNAVAILABLE"
                                                message:@"Failed to set icon"
                                                details:nil]);
                    }
                }
                @catch (NSException *exception) {
                    NSLog(@"%@", exception.reason);
                    result([FlutterError errorWithCode:@"Failed to set icon"
                                            message:exception.reason
                                            details:nil]);
                }
            } else {
                result([FlutterError errorWithCode:@"UNAVAILABLE"
                                        message:@"Not supported on iOS ver < 10.3"
                                        details:nil]);
            }
        } else {
            result(FlutterMethodNotImplemented);
        }
    }];
}

@end
