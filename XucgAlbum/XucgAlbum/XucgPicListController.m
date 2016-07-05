//
//  XucgPicListController.m
//  XucgAlbum
//
//  Created by xucg on 5/25/16.
//  Copyright © 2016 xucg. All rights reserved.
//  Welcome visiting https://github.com/gukemanbu/XucgAlbum

#import "XucgPicListController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "XucgPicCropController.h"

#define kPicCell @"XucgPicCell"

@interface XucgPicListController ()

@property (nonatomic, assign) CGFloat itemWidth;
@property (nonatomic, strong) NSMutableArray *picArray;
@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation XucgPicListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = [_assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    
    // 集合视图
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat spacing = 3;
    layout.sectionInset = UIEdgeInsetsMake(spacing, 0, 0, 0);
    _itemWidth = (kScreenWidth - spacing * 2) / 3;
    layout.itemSize = CGSizeMake(_itemWidth, _itemWidth);
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = spacing;
    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor whiteColor];
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kPicCell];
    [self.view addSubview:self.collectionView];
    
    _picArray = [[NSMutableArray alloc] init];
    [_assetsGroup enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result) {
            [_picArray addObject:result];
        } else {
            _collectionView.delegate = (id<UICollectionViewDelegate>)self;
            _collectionView.dataSource = (id<UICollectionViewDataSource>)self;
            [self.collectionView reloadData];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return [_picArray count];
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"XucgPicCell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    ALAsset *asset = _picArray[indexPath.row];
    CGImageRef thumbnailRef = [asset thumbnail];
    UIImage *thumbnail = [UIImage imageWithCGImage:thumbnailRef];
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
    if (!imageView) {
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _itemWidth, _itemWidth)];
        imageView.tag = 1;
        [cell addSubview:imageView];
    }
    imageView.image = thumbnail;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ALAsset *asset = _picArray[indexPath.row];
    ALAssetRepresentation *assetRepresentation = [asset defaultRepresentation];
    
    UIImage *fullScreenImage = [UIImage imageWithCGImage:[assetRepresentation fullScreenImage]
                                                   scale:[assetRepresentation scale]
                                             orientation:UIImageOrientationUp];
    XucgPicCropController *cropController = [[XucgPicCropController alloc] init];
    cropController.picture = fullScreenImage;
    [self.navigationController pushViewController:cropController animated:YES];
//    [self presentViewController:cropController animated:YES completion:nil];
}

@end
