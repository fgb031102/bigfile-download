//
//  skyViewController.m
//  文件下载
//
//  Created by sky on 14-4-29.
//  Copyright (c) 2014年 sky. All rights reserved.
//

#import "skyViewController.h"
#import "skyFielDown.h"

@interface skyViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *iconView;

@end

@implementation skyViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	[[[skyFielDown alloc] init]fileDownWithURL:@"http://localhost//itcast/images/head1.png" completion:^(UIImage *img) {
        self.iconView.image = img;
        NSLog(@"%@",img);
//        NSLog(@"2-----%@----",[NSThread currentThread]);
    }];
     
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
