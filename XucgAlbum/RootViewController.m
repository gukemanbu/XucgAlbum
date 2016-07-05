//
//  RootViewController.m
//  XucgAlbum
//
//  Created by xucg on 7/5/16.
//  Copyright © 2016 xucg. All rights reserved.
//

#import "RootViewController.h"
#import "XucgAlbumListController.h"

@interface RootViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *picture;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(didSeletedPicture:) name:kXucgCropedImage object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)albumListButtonAction:(id)sender {
    XucgAlbumListController *albumList = [[XucgAlbumListController alloc] init];
    [self.navigationController pushViewController:albumList animated:YES];
}

- (void)didSeletedPicture:(NSNotification*)notification {
    UIImage *newImage = [notification object];
    [_picture setImage:newImage];
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
