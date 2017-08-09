//
//  Macro.h
//  EveryDayTravel
//
//  Created by 王一成 on 15/11/6.
//  Copyright © 2015年 王一成. All rights reserved.
//55b9e0450cf2426135b79cc9


#ifndef Macro_h
#define Macro_h



/**
 *  自定义单例.h
 */
#define DEFINE_SINGLETON_FOR_HEADER(className) \
\
+ (className *)shared##className;
/**
 *  自定义单例.m
 */
#define DEFINE_SINGLETON_FOR_CLASS(className) \
\
+ (className *)shared##className { \
static className *shared##className = nil; \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
shared##className = [[self alloc] init]; \
}); \
return shared##className; \
}



//机器版本
#define systemDevice [[UIDevice currentDevice]systemVersion].floatValue

//商户id-账号id
#define PARTNER    @"2088102169698211"
#define SELLER     @"wwpswo5851@sandbox.com"

#define APPID       @"2017041906817095";

//下载公钥
#define PUBLICKEY @"MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAqSqlgt1BiO5cRkhJ/vaw1g0X9N/TBwBVMGY2Mf5sXW3WKngyiuCFBfAsmp3cxPN7GuYhB457kbGdz8EOSWJGwN+XmyCzXJWMPCPuQMkjIiO/BQPVTal012gISYDvVNu1zzXDQlcV/Hxtv5S88xpdACGqodXOAOLM5clHGVyqqmt9EONQ1GIjUyPfONQV3bedwK8tRwVquXfGKZFRMi68orQ6ErZ+aGRJWQZKYKR4QWRN+okB7AKwCozJ91yZNLP1cKISHP9h2haE+aAMxog4/NSOikSsHqzOcL6yU2kPkthEsiN5AhD1zzYTavJOUHK4NaMjWT14Sj+5BSf1Me70PQIDAQAB"

//下载私钥
#define PRIVATEKEY  @"MIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQCpKqWC3UGI7lxGSEn+9rDWDRf039MHAFUwZjYx/mxdbdYqeDKK4IUF8CyandzE83sa5iEHjnuRsZ3PwQ5JYkbA35ebILNclYw8I+5AySMiI78FA9VNqXTXaAhJgO9U27XPNcNCVxX8fG2/lLzzGl0AIaqh1c4A4szlyUcZXKqqa30Q41DUYiNTI9841BXdt53Ary1HBWq5d8YpkVEyLryitDoStn5oZElZBkpgpHhBZE36iQHsArAKjMn3XJk0s/VwohIc/2HaFoT5oAzGiDj81I6KRKwerM5wvrJTaQ+S2ESyI3kCEPXPNhNq8k5Qcrg1oyNZPXhKP7kFJ/Ux7vQ9AgMBAAECggEBAJvdj2JkOl3QQXUAZi1lXsnahpg5IlbxF4zgoE6v/WiYKxw2Y1tSQz6VbIOJsEBHlsXSA9zSi0hSPvWNC3zR8B8F5Mop9xj3MZ63/G305UovZXFZds93sxBF6lzPT7UAOyQQhTg6xSc9/mDmyrGzOL1GR9GVDZoDXobaTYgwuY8Kt4b3vUbcDFVEiRLn3VR7G81DyegkU5JK+2CERYgjS2P+ZsZo5U8EqTB8WLNGfHVKXUr4jkHhzYTF3gIlwbJIo6OY+dPoMjePidVwH7z14I+UJTlsSCYnCBSJtzY/RPP7pSutpWQzmNV3ZhIQaWO2SOt33xIqiv9i6Eao616rrAECgYEA741cPi/j6RK25/7j0OObBXKBBfuCTOf7msmUOMFGNbuYbx+Uw2cy2Z4lAg4jhS84hR3dBnVd7BTN/zy0Dv4Z8KfIokpIcywrYyP0cWxJ/4lEIvLbvLVejJW5yft5iPYQoWA6PCiyM4LV22twE1E5K3HF0oqCaLT8cAAouvO98hUCgYEAtMgcA9xqVs23lqtIYgZahlyyvFceeJ41s4iwjgKTPxrkH9sNd3pMvPgtWgc2idASvlNJPy8UfPquxYo1wD3iPDg+p2QjkviG3qjKct5sxJ7joWSY0XykNWSkzpE6Brv68snlGGpKST8lxBmYxSeEyll/7vNRy/rRKI4U24Q7i4kCgYEArXZPNTi4cC19BMEtdjVaK7eedhaJY+cX6h3Nlstda8tLtivILTatO6eoZLSYQ/jNlJbrVaHnQOxPvmLWf4TAg+L7BYmErOFvCXsfpoIjk0ZycFwrgZpTvLkur3PJrcOAh1qG0MknQOWctiY2IcbO/waDmNFzXR6xLOjwlW+qO4ECgYAhJ23T23F5F+Mqc6EjsQybBZcV6VhCQKmSkmfms1wzv4fEu9Sda8V1BoKytw3uekVluDp/pu+39/VjbvRqnC7IYnxDEJ9hjciWPxhZtqb17DnM2HkaOiSXUizTYVjl8UWVjyc/sgaLplQTwan9xkCZJ47J0L/Yi9gd+uiiVX7iGQKBgQCwvk2T70igbsMgsK7Gl7LfWZYVecxsmC5C2qJx1Ko8qn9H/4XpNFoXHHLJ5X8P564IKWtO+ugjqEMZGfmayeux0nP7pbr2LHnhM2PpYQ8RQDhIwFHWEvxenGls7AG1y1v3NOIcRlHYDMAJA5Xm8oLxf1UwxBCBcAzPn0GHidwv1w=="


/**
 适配宏
 */
#define ScreenMultiple  ([UIScreen mainScreen].bounds.size.width/320)

/**
 * UI常用
 */
#define NavigationBar_HEIGHT 44.0f
#define Tabbar_HEIGHT 49.0f
#define WIDTH [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height


#define kRect(_x, _y, _w, _h) CGRectMake((_x), (_y), (_w), (_h))
#define ImageNamed(_name)     [UIImage imageNamed:_name]

/**
 * 在debug模式下启用DLog
 */
#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)
#endif

#ifdef DEBUG  // 调试状态
// 打开LOG功能
#define HS_Log(...) NSLog(__VA_ARGS__)
#endif

//#import "Visitor+AppFunction.h"
//#import "Visitor+HUD.h"
//#import "Visitor+MD5.h"
//#import "Visitor+DateTool.h"
//#import "Visitor+ColorTool.h"
//#import "Visitor+SandBoxTool.h"
//#import "Visitor+UICommon.h"

#endif /* Macro_h */

