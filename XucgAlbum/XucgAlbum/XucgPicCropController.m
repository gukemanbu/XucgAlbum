//
//  XucgPicCropController.m
//  XucgAlbum
//
//  Created by xucg on 5/25/16.
//  Copyright © 2016 xucg. All rights reserved.
//  Welcome visiting https://github.com/gukemanbu/XucgAlbum

#import "XucgPicCropController.h"

@interface XucgPicCropController ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, assign) float imageScale;

@end

@implementation XucgPicCropController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"照片";
    self.view.backgroundColor = [UIColor blackColor];
    // 这句很重要哦，在有navigation的情况下，去掉后发现scrollView里元素上边距无端的多出了一个导航栏的高度
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    // 右确定
    UIButton *okButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 20)];
    [okButton setTitle:@"确认" forState:UIControlStateNormal];
    [okButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    okButton.titleLabel.font = [UIFont systemFontOfSize:17];
    [okButton addTarget:self action:@selector(okButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:okButton];
    
    CGFloat top = (kScreenHeight - kScreenWidth) / 2;
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, top, kScreenWidth, kScreenWidth)];
    _scrollView.delegate = (id<UIScrollViewDelegate>)self;
    _scrollView.minimumZoomScale = 1.0;
    _scrollView.maximumZoomScale = 5.0;
    _scrollView.layer.borderColor = [UIColor whiteColor].CGColor;
    _scrollView.layer.borderWidth = 1;
    _scrollView.layer.masksToBounds = NO;
    CGFloat contentWidth = kScreenWidth;
    CGFloat contentHeight = kScreenWidth;
    if (_picture.size.width > _picture.size.height) {
        contentWidth = (_picture.size.width * contentHeight) / _picture.size.height;
        _imageScale = _picture.size.width / contentWidth;
    } else {
        contentHeight = (_picture.size.height * contentWidth) / _picture.size.width;
        _imageScale = _picture.size.height / contentHeight;
    }
    
    _scrollView.contentSize = CGSizeMake(contentWidth, contentHeight);
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.alwaysBounceVertical = YES;
    _scrollView.alwaysBounceHorizontal = YES;
    [self.view addSubview:_scrollView];
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, contentWidth, contentHeight)];
    _imageView.backgroundColor = [UIColor whiteColor];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.image = _picture;
    [_scrollView addSubview:_imageView];
    
    CGPoint offset;
    if (contentWidth > contentHeight) {
        offset = CGPointMake((contentWidth - contentHeight)/2, 0);
    } else {
        offset = CGPointMake(0, (contentHeight - contentWidth)/2);
    }
    [_scrollView setContentOffset:offset];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void) setPicture:(UIImage *)picture {
    _picture = picture;
    _imageView.image = picture;
}

-(UIView*) viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

-(void) scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
}

- (void)okButtonAction:(id)sender {
    float zoomScale = 1.0 / [_scrollView zoomScale];

    CGRect rect;
    rect.origin.x = [_scrollView contentOffset].x * zoomScale * _imageScale;
    rect.origin.y = [_scrollView contentOffset].y * zoomScale * _imageScale;
    rect.size.width = [_scrollView bounds].size.width * zoomScale * _imageScale;
    rect.size.height = [_scrollView bounds].size.height * zoomScale * _imageScale;
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([[_imageView image] CGImage], rect);
    UIImage *newImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    // 发送通知
    NSNotification *notice = [NSNotification notificationWithName:kXucgCropedImage object:newImage userInfo:nil];
    [[NSNotificationCenter defaultCenter]postNotification:notice];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end