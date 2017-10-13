//
//  ALWWebPDecoder.m
//  Pods
//
//  Created by lisong on 2017/10/13.
//
//

#import "ALWWebPDecoder.h"

#import "decode.h"
#import "mux_types.h"
#import "demux.h"

// Callback for CGDataProviderRelease
static void FreeImageData(void *info, const void *data, size_t size) {
    free((void *)data);
}

@implementation ALWWebPDecoder

+ (NSInteger)frameCountWithWebPData:(nullable NSData *)data
{
    if (!data) {
        return 0;
    }
    
    WebPData webpData;
    WebPDataInit(&webpData);
    webpData.bytes = data.bytes;
    webpData.size = data.length;
    WebPDemuxer *demuxer = WebPDemux(&webpData);
    if (!demuxer) {
        return 0;
    }
    
    WebPIterator iter;
    if (!WebPDemuxGetFrame(demuxer, 1, &iter)) {
        WebPDemuxReleaseIterator(&iter);
        WebPDemuxDelete(demuxer);
        return 0;
    }
    
    NSInteger loopCount = WebPDemuxGetI(demuxer, WEBP_FF_LOOP_COUNT);
    
    return loopCount;
}

+ (NSInteger)loopCountWithWebPData:(nullable NSData *)data
{
    if (!data) {
        return 0;
    }
    
    WebPData webpData;
    WebPDataInit(&webpData);
    webpData.bytes = data.bytes;
    webpData.size = data.length;
    WebPDemuxer *demuxer = WebPDemux(&webpData);
    if (!demuxer) {
        return 0;
    }
    
    WebPIterator iter;
    if (!WebPDemuxGetFrame(demuxer, 1, &iter)) {
        WebPDemuxReleaseIterator(&iter);
        WebPDemuxDelete(demuxer);
        return 0;
    }
    
    NSInteger frameCount = WebPDemuxGetI(demuxer, WEBP_FF_FRAME_COUNT);
    
    return frameCount;
}

+ (nullable UIImage *)imageWithWebPData:(nullable NSData *)data
{
    UIImage *notScaledWebPImage = [self imageNotScaledWithWebPData:data];
    
    return [self imageWithNotScaledWebPImage:notScaledWebPImage];
}

+ (nullable UIImage *)imageWithNotScaledWebPImage:(nullable UIImage *)webPImage
{
    if (!webPImage) {
        return nil;
    }
    
    CGImageRef imageRef = webPImage.CGImage;
    UIImage *scaleImage = [UIImage imageWithCGImage:imageRef scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    
    return scaleImage;
}

+ (nullable UIImage *)imageNotScaledWithWebPData:(nullable NSData *)data
{
    if (!data) {
        return nil;
    }
    
    WebPData webpData;
    WebPDataInit(&webpData);
    webpData.bytes = data.bytes;
    webpData.size = data.length;
    WebPDemuxer *demuxer = WebPDemux(&webpData);
    if (!demuxer) {
        return nil;
    }
    
    uint32_t flags = WebPDemuxGetI(demuxer, WEBP_FF_FORMAT_FLAGS);
    if (!(flags & ANIMATION_FLAG)) {
        // for static single webp image
        UIImage *staticImage = [self rawWebpImageWithData:webpData];
        WebPDemuxDelete(demuxer);
        return staticImage;
    }
    
    WebPIterator iter;
    if (!WebPDemuxGetFrame(demuxer, 1, &iter)) {
        WebPDemuxReleaseIterator(&iter);
        WebPDemuxDelete(demuxer);
        return nil;
    }
    
    //    int loopCount = WebPDemuxGetI(demuxer, WEBP_FF_LOOP_COUNT);
    int frameCount = WebPDemuxGetI(demuxer, WEBP_FF_FRAME_COUNT);
    
    int canvasWidth = WebPDemuxGetI(demuxer, WEBP_FF_CANVAS_WIDTH);
    int canvasHeight = WebPDemuxGetI(demuxer, WEBP_FF_CANVAS_HEIGHT);
    CGBitmapInfo bitmapInfo;
    if (!(flags & ALPHA_FLAG)) {
        bitmapInfo = kCGBitmapByteOrder32Big | kCGImageAlphaNoneSkipLast;
    } else {
        bitmapInfo = kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast;
    }
    CGContextRef canvas = CGBitmapContextCreate(NULL, canvasWidth, canvasHeight, 8, 0, DYCGColorSpaceGetDeviceRGB(), bitmapInfo);
    if (!canvas) {
        WebPDemuxReleaseIterator(&iter);
        WebPDemuxDelete(demuxer);
        return nil;
    }
    
    NSMutableArray<UIImage *> *images = [NSMutableArray array];
    
    NSTimeInterval totalDuration = 0;
    int durations[frameCount];
    
    do {
        UIImage *image;
        if (iter.blend_method == WEBP_MUX_BLEND) {
            image = [self blendWebpImageWithCanvas:canvas iterator:iter];
        } else {
            image = [self nonblendWebpImageWithCanvas:canvas iterator:iter];
        }
        
        if (!image) {
            continue;
        }
        
        [images addObject:image];
        
        int duration = iter.duration;
        if (duration <= 10) {
            // WebP standard says 0 duration is used for canvas updating but not showing image, but actually Chrome and other implementations set it to 100ms if duration is lower or equal than 10ms
            // Some animated WebP images also created without duration, we should keep compatibility
            duration = 100;
        }
        totalDuration += duration;
        size_t count = images.count;
        durations[count - 1] = duration;
    } while (WebPDemuxNextFrame(&iter));
    
    WebPDemuxReleaseIterator(&iter);
    WebPDemuxDelete(demuxer);
    CGContextRelease(canvas);
    
    UIImage *finalImage = nil;
    
    NSArray<UIImage *> *animatedImages = [self animatedImagesWithImages:images durations:durations totalDuration:totalDuration];
    finalImage = [UIImage animatedImageWithImages:animatedImages duration:totalDuration / 1000.0];
    
    return finalImage;
}


+ (nullable UIImage *)blendWebpImageWithCanvas:(CGContextRef)canvas iterator:(WebPIterator)iter
{
    UIImage *image = [self rawWebpImageWithData:iter.fragment];
    if (!image) {
        return nil;
    }
    
    size_t canvasWidth = CGBitmapContextGetWidth(canvas);
    size_t canvasHeight = CGBitmapContextGetHeight(canvas);
    CGSize size = CGSizeMake(canvasWidth, canvasHeight);
    CGFloat tmpX = iter.x_offset;
    CGFloat tmpY = size.height - iter.height - iter.y_offset;
    CGRect imageRect = CGRectMake(tmpX, tmpY, iter.width, iter.height);
    
    CGContextDrawImage(canvas, imageRect, image.CGImage);
    CGImageRef newImageRef = CGBitmapContextCreateImage(canvas);
    
    image = [UIImage imageWithCGImage:newImageRef];
    
    CGImageRelease(newImageRef);
    
    if (iter.dispose_method == WEBP_MUX_DISPOSE_BACKGROUND) {
        CGContextClearRect(canvas, imageRect);
    }
    
    return image;
}

+ (nullable UIImage *)nonblendWebpImageWithCanvas:(CGContextRef)canvas iterator:(WebPIterator)iter
{
    UIImage *image = [self rawWebpImageWithData:iter.fragment];
    if (!image) {
        return nil;
    }
    
    size_t canvasWidth = CGBitmapContextGetWidth(canvas);
    size_t canvasHeight = CGBitmapContextGetHeight(canvas);
    CGSize size = CGSizeMake(canvasWidth, canvasHeight);
    CGFloat tmpX = iter.x_offset;
    CGFloat tmpY = size.height - iter.height - iter.y_offset;
    CGRect imageRect = CGRectMake(tmpX, tmpY, iter.width, iter.height);
    
    CGContextClearRect(canvas, imageRect);
    CGContextDrawImage(canvas, imageRect, image.CGImage);
    CGImageRef newImageRef = CGBitmapContextCreateImage(canvas);
    
    image = [UIImage imageWithCGImage:newImageRef];
    
    CGImageRelease(newImageRef);
    
    if (iter.dispose_method == WEBP_MUX_DISPOSE_BACKGROUND) {
        CGContextClearRect(canvas, imageRect);
    }
    
    return image;
}

+ (nullable UIImage *)rawWebpImageWithData:(WebPData)webpData
{
    WebPDecoderConfig config;
    if (!WebPInitDecoderConfig(&config)) {
        return nil;
    }
    
    if (WebPGetFeatures(webpData.bytes, webpData.size, &config.input) != VP8_STATUS_OK) {
        return nil;
    }
    
    config.output.colorspace = config.input.has_alpha ? MODE_rgbA : MODE_RGB;
    config.options.use_threads = 1;
    
    // Decode the WebP image data into a RGBA value array
    if (WebPDecode(webpData.bytes, webpData.size, &config) != VP8_STATUS_OK) {
        return nil;
    }
    
    int width = config.input.width;
    int height = config.input.height;
    if (config.options.use_scaling) {
        width = config.options.scaled_width;
        height = config.options.scaled_height;
    }
    
    // Construct a UIImage from the decoded RGBA value array
    CGDataProviderRef provider =
    CGDataProviderCreateWithData(NULL, config.output.u.RGBA.rgba, config.output.u.RGBA.size, FreeImageData);
    CGColorSpaceRef colorSpaceRef = DYCGColorSpaceGetDeviceRGB();
    CGBitmapInfo bitmapInfo = config.input.has_alpha ? kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast : kCGBitmapByteOrder32Big | kCGImageAlphaNoneSkipLast;
    size_t components = config.input.has_alpha ? 4 : 3;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    CGImageRef imageRef = CGImageCreate(width, height, 8, components * 8, components * width, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
    
    CGDataProviderRelease(provider);
    
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    
    CGImageRelease(imageRef);
    
    return image;
}

+ (NSArray<UIImage *> *)animatedImagesWithImages:(NSArray<UIImage *> *)images durations:(int const * const)durations totalDuration:(NSTimeInterval)totalDuration
{
    // [UIImage animatedImageWithImages:duration:] only use the average duration for per frame
    // divide the total duration to implement per frame duration for animated WebP
    NSUInteger count = images.count;
    if (!count) {
        return nil;
    }
    if (count == 1) {
        return images;
    }
    
    int const gcd = gcdArray(count, durations);
    NSMutableArray<UIImage *> *animatedImages = [NSMutableArray arrayWithCapacity:count];
    [images enumerateObjectsUsingBlock:^(UIImage * _Nonnull image, NSUInteger idx, BOOL * _Nonnull stop) {
        int duration = durations[idx];
        int repeatCount;
        if (gcd) {
            repeatCount = duration / gcd;
        } else {
            repeatCount = 1;
        }
        for (int i = 0; i < repeatCount; ++i) {
            [animatedImages addObject:image];
        }
    }];
    
    return animatedImages;
}

static CGColorSpaceRef DYCGColorSpaceGetDeviceRGB() {
    static CGColorSpaceRef space;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        space = CGColorSpaceCreateDeviceRGB();
    });
    return space;
}

static int gcdArray(size_t const count, int const * const values) {
    int result = values[0];
    for (size_t i = 1; i < count; ++i) {
        result = gcd(values[i], result);
    }
    return result;
}

static int gcd(int a,int b) {
    int c;
    while (a != 0) {
        c = a;
        a = b % a;
        b = c;
    }
    return b;
}

@end
