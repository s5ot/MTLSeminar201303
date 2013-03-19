//
//  ViewController.m
//  MTLSeminar201303
//
//  Created by sogo on 3/10/13.
//  Copyright (c) 2013 sogo. All rights reserved.
//

#import "ViewController.h"
#import "GPUImage.h"
#import <AssetsLibrary/AssetsLibrary.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pressFilterBtn:(id)sender {
    NSLog(@"ボタンを押した!");
    
    // GUIで設定した画像を取得する
    UIImage *inputImage = self.imageView.image;
    
    // 画像をGPUImageのフォーマットにする
    GPUImagePicture *imagePicture = [[GPUImagePicture alloc]initWithImage:inputImage];
    
    // セピアフィルターをつくる
    GPUImageSepiaFilter *sepiaFilter = [[GPUImageSepiaFilter alloc]init];
    
    // イメージをセピアフィルターにくっつける
    [imagePicture addTarget:sepiaFilter];
    
    // ぼかしフィルターをつくる
    GPUImageGaussianBlurFilter *blurFilter = [[GPUImageGaussianBlurFilter alloc]init];
    [blurFilter setBlurSize:4];
    
    // イメージをブラーフィルターにくっつける
    [imagePicture addTarget:blurFilter];
    
    
    // iPhoneを表示する
    // iPhoneの画像を用意する
    UIImage *iphone = [UIImage imageNamed:@"iphone.png"];
    GPUImagePicture *iphoneImg = [[GPUImagePicture alloc]initWithImage:iphone];
    
    // 画像を合成するためのブレンドモードをつくる
    GPUImageNormalBlendFilter *normalBlend = [[GPUImageNormalBlendFilter alloc]init];
    
    // iPhoneの画像を変形するためのフィルターをつくる
    GPUImageTransformFilter *transform = [[GPUImageTransformFilter alloc]init];
    
    // 変形をどうするか決める
    CGAffineTransform trans;
    trans = CGAffineTransformMakeScale(0.75, 0.75); // 縮小
    trans = CGAffineTransformTranslate(trans, 0, 0.75); // 移動
    [transform setAffineTransform:trans];
    
    // iPhoneの画像を変形する
    [iphoneImg addTarget:transform];
    
    // ブレンドする
    [blurFilter addTarget:normalBlend];    // こっちがブレンドの下になる画像
    // 変形後のiPhoneのイメージをつなげる
    [transform addTarget:normalBlend atTextureLocation:1]; // こっちが上になる画像
    
    // iPhoneの中に元の画像を入れるためのブレンド
    GPUImageNormalBlendFilter *insideImageBlend = [[GPUImageNormalBlendFilter alloc]init];
    
    // iPhoneの中に画像をいれるための変形
    GPUImageTransformFilter *insideTrans = [[GPUImageTransformFilter alloc]init];
    
    // iPhoneの中に画像を入れるための変形を決める
    CGAffineTransform transImg;
    transImg = CGAffineTransformMakeScale(0.64, 0.64);
    transImg = CGAffineTransformTranslate(transImg, 0.0, 1.05);
    [insideTrans setAffineTransform:transImg];
                
    // セピアを変形させる
    [sepiaFilter addTarget:insideTrans];
    
    // 変形させたものを合成する
    [normalBlend addTarget:insideImageBlend];
    [insideTrans addTarget:insideImageBlend atTextureLocation:1];
                
    // フィルター実行
    [imagePicture processImage];
    [iphoneImg processImage];
    
    
    // 実行したフィルターから画像を取得する
    UIImage *outputImage = [insideImageBlend imageFromCurrentlyProcessedOutput];
    
    self.imageView.image = outputImage;
}

- (IBAction)pressSaveBtn:(id)sender {
    UIImage *image = self.imageView.image;
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc]init];
    [library writeImageToSavedPhotosAlbum:image.CGImage metadata:nil completionBlock:^(NSURL *assetURL, NSError *error){
        if (!error) {
            NSLog(@"保存成功!");
        }
    }
     ];
}
@end
