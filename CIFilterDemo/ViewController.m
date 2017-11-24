//
//  ViewController.m
//  CIFilterDemo
//
//  Created by 陆久银 on 2017/7/31.
//  Copyright © 2017年 lujiuyin. All rights reserved.
//

#import "ViewController.h"
#import <CoreImage/CoreImage.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *originalImg;
@property (weak, nonatomic) IBOutlet UIImageView *editedImg;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgHeight;


@property (nonatomic, strong) CIImage *ciImage;
@property (nonatomic, strong) CIContext *ciContext;
@property (nonatomic, strong) CIFilter *ciFilter;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureImg:@"1.jpg"];
    
    NSArray *properties = [CIFilter filterNamesInCategory:kCICategoryBuiltIn];
    NSLog(@"%@",properties);
    
    for (NSString *filterName in properties) {
        CIFilter *filter = [CIFilter filterWithName:filterName];
        NSLog(@"%@",filter.attributes);
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)configureImg:(NSString *)imageName {
    UIImage *image = [UIImage imageNamed:imageName];
    self.originalImg.image = image;
    CGFloat height = [UIScreen mainScreen].bounds.size.width / 2 * image.size.height / image.size.width;
    self.imgHeight.constant = height;
    
    
    self.ciImage = [CIImage imageWithCGImage:image.CGImage];
    
    self.ciContext = [CIContext contextWithOptions:nil];
    
//    self.ciFilter = [CIFilter filterWithName:@"CISepiaTone"];
//    [self.ciFilter setValue:self.ciImage forKey:kCIInputImageKey];
//    [self.ciFilter setValue:@1.0 forKey:kCIInputIntensityKey];
//    
//    CGImageRef cgImage = [self.ciContext createCGImage:self.ciFilter.outputImage fromRect:self.ciFilter.outputImage.extent];
//    UIImage *newImage = [UIImage imageWithCGImage:cgImage];
//    self.editedImg.image = newImage;

    CIImage *ciimage = [self oldPhoto:self.ciImage intensity:0.9];
    UIImage *newImage = [UIImage imageWithCIImage:ciimage];
    self.editedImg.image = newImage;
}

- (void)savePhoto:(UIImage *)newImage {
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest *req = [PHAssetChangeRequest creationRequestForAssetFromImage:newImage];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        
    }];
}

//组合滤镜
- (CIImage *)oldPhoto:(CIImage *)ciImage intensity:(CGFloat)intensity {
    //棕色滤镜
    CIFilter *sepiaFilter = [CIFilter filterWithName:@"CISepiaTone"];
    [sepiaFilter setValue:ciImage forKey:kCIInputImageKey];
    [sepiaFilter setValue:[NSNumber numberWithFloat:intensity] forKey:kCIInputIntensityKey];
    
    //随机点滤镜
    CIFilter *randomFilter = [CIFilter filterWithName:@"CIRandomGenerator"];
    
    //亮度滤镜
    CIFilter *lightenFilter = [CIFilter filterWithName:@"CIColorControls"];
    [lightenFilter setValue:randomFilter.outputImage forKey:kCIInputImageKey];
    [lightenFilter setValue:[NSNumber numberWithFloat:1-intensity] forKey:@"inputBrightness"];
    [lightenFilter setValue:@0 forKey:@"inputSaturation"];
    
    //裁剪
    CIImage *croppedImage = [lightenFilter.outputImage imageByCroppingToRect:self.ciImage.extent];
    
    CIFilter *composite = [CIFilter filterWithName:@"CIHardLightBlendMode"];
    [composite setValue:sepiaFilter.outputImage forKey:kCIInputImageKey];
    [composite setValue:croppedImage forKey:kCIInputBackgroundImageKey];
    
    CIFilter *vignette = [CIFilter filterWithName:@"CIVignette"];
    [vignette setValue:composite.outputImage forKey:kCIInputImageKey];
    [vignette setValue:[NSNumber numberWithFloat:intensity * 2] forKey:@"inputIntensity"];
    [vignette setValue:[NSNumber numberWithFloat:intensity * 30] forKey:@"inputRadius"];
    
    return vignette.outputImage;
}
@end
