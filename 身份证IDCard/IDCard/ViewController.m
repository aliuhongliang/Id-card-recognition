//
//  ViewController.m
//  IDCard
//
//  Created by lihongwen-pc on 2017/1/5.
//  Copyright © 2017年 Univalsoft. All rights reserved.
//

#import "ViewController.h"
#import "IDCardIdentifyTool.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
    [[IDCardIdentifyTool IDCardIdentify] openCameraWithVC:self completion:^(UIImage *image) {
       
        [[IDCardIdentifyTool IDCardIdentify] startIndentifyUserIDCard:image completion:^(IDCardDetailInfo *model) {
           
            NSLog(@"%@",model.name);
        }];
    }];
}


@end
