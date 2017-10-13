//
//  ALWWebPDecoder.h
//  Pods
//
//  Created by lisong on 2017/10/13.
//
//

#import <Foundation/Foundation.h>

@interface ALWWebPDecoder : NSObject

///获取WebP图片的UIImage对象；特别注意：获取到的UIImage对象的size已经转换为当前屏幕的scale对应的大小，下面提供了未转换方法
+ (nullable UIImage *)imageWithWebPData:(nullable NSData *)data;

///获取未scale的WebP图像
+ (nullable UIImage *)imageNotScaledWithWebPData:(nullable NSData *)data;

///将未scale的webP图像根据当前屏幕的scale进行转换
+ (nullable UIImage *)imageWithNotScaledWebPImage:(nullable UIImage *)webPImage;

///动态WebP图片的帧数
+ (NSInteger)frameCountWithWebPData:(nullable NSData *)data;

///动态WebP图片的循环次数
+ (NSInteger)loopCountWithWebPData:(nullable NSData *)data;

@end
