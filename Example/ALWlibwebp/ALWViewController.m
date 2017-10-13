//
//  ALWViewController.m
//  ALWlibwebp
//
//  Created by lisong on 08/30/2017.
//  Copyright (c) 2017 lisong. All rights reserved.
//

#import "ALWViewController.h"
#import "ALWWebPDecoder.h"

@interface ALWViewController ()

@end

@implementation ALWViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"test6" ofType:@"webp"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    UIImage *image = [ALWWebPDecoder imageWithWebPData:data];
    UIImage *image1 = [ALWWebPDecoder imageNotScaledWithWebPData:data];
    UIImage *image2 = [ALWWebPDecoder imageWithNotScaledWebPImage:image1];
    
    NSLog(@"image: %@", image);
    NSLog(@"image1: %@", image1);
    NSLog(@"image2: %@", image2);
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:scrollView];
    
    UIImageView *iv = [[UIImageView alloc] initWithFrame:scrollView.bounds];
    [iv setImage:image];
    [iv setContentMode:UIViewContentModeScaleAspectFit];
    [scrollView addSubview:iv];
    
    scrollView.contentSize = iv.frame.size;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
