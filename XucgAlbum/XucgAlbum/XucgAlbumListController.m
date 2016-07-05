//
//  XucgAlbumListController.m
//  XucgAlbum
//
//  Created by xucg on 5/25/16.
//  Copyright © 2016 xucg. All rights reserved.
//  Welcome visiting https://github.com/gukemanbu/XucgAlbum

#import "XucgAlbumListController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "XucgPicListController.h"

@interface XucgAlbumListController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *albumsArray;
@property (nonatomic, strong) UITableView *tableView;
// ALAssetsLibrary需要强引用，这是相册的坑
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;

@end

@implementation XucgAlbumListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"相册列表";
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_tableView];
    
    // 提示语
    NSString *tipTextWhenNoPhotosAuthorization;
    
    // 授权结果
    ALAuthorizationStatus authorizationStatus = [ALAssetsLibrary authorizationStatus];
    // 如果没有获得授权
    if (authorizationStatus == ALAuthorizationStatusRestricted || authorizationStatus == ALAuthorizationStatusDenied) {
        NSDictionary *mainInfoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *appName = [mainInfoDictionary objectForKey:@"CFBundleDisplayName"];
        tipTextWhenNoPhotosAuthorization = [NSString stringWithFormat:@"请在设备的\"设置-隐私-照片\"选项中，允许%@访问你的手机相册", appName];
        // 展示提示语
        NSLog(@"%@", tipTextWhenNoPhotosAuthorization);
        
        return;
    }
    
    _albumsArray = [NSMutableArray array];
    
    _assetsLibrary = [[ALAssetsLibrary alloc] init];
    [_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            if (group.numberOfAssets > 0) {
                [_albumsArray addObject:group];
            }
        } else {
            if ([_albumsArray count] > 0) {
                // 把所有的相册储存完毕，可以展示相册列表
                _tableView.dataSource = self;
                _tableView.delegate = self;
                [_tableView reloadData];
            } else {
                // 没有任何有资源的相册，输出提示
                NSLog(@"%@", @"没有找到相册");
            }
        }
    } failureBlock:^(NSError *error) {
        NSLog(@"错误，没有找到相册");
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_albumsArray count];
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.f;
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"AlbumListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    ALAssetsGroup *group = _albumsArray[indexPath.row];
    CGImageRef coverImageRef = [group posterImage];
    UIImage *coverImage = [UIImage imageWithCGImage:coverImageRef];
    cell.imageView.image = coverImage;
    cell.textLabel.text = [group valueForProperty:ALAssetsGroupPropertyName];
    cell.detailTextLabel.text = [@(group.numberOfAssets) stringValue];
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ALAssetsGroup *group = _albumsArray[indexPath.row];
    
    XucgPicListController *picListController = [[XucgPicListController alloc] init];
    picListController.assetsGroup = group;
    [self.navigationController pushViewController:picListController animated:YES];
}

@end
