//
//  ETViewController.m
//  Oset
//
//  Created by Dizzrt on 03/07/2023.
//  Copyright (c) 2023 Dizzrt. All rights reserved.
//

#import "ETViewController.h"

#import <Oset/ETReporter.h>

@interface ETViewController ()

@property (nonatomic, strong)UIButton *btn;

@end

@implementation ETViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.view.backgroundColor = [UIColor whiteColor];
    self.btn = [[UIButton alloc] initWithFrame:CGRectMake(100, 250, 80, 30)];
    self.btn.backgroundColor = [UIColor cyanColor];
    [self.btn setTitle:@"report" forState:UIControlStateNormal];
    [self.btn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btn];
    
    NSString *ak = @"0d411034531db6c120960c3e0f0f6b566fff9e2679cae5c82b07e2cbd6927d5d";
    NSString *sk = @"415313be406547fd86873c2597669eb772694ca9db341d46456d7c11a21bde6e";
    [[ETReporter sharedReporter] initWithAccessKey:ak secretKey:sk content:@"testcontent"];
}

- (void)click:(UIButton *) button{
    NSDictionary *data = @{@"msg":@"test event",@"key_a":@"value_a",@"key_b":@(1111),@"arr":@[@(1),@(2),@(3)],@"dict":@{@"inner_key":@"inner_value"}};
    [[ETReporter sharedReporter] reportEvent:@"test_event" data:data did:12345678];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
