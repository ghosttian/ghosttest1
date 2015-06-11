//
//  GinPortraitViewController.m
//  microChannel
//
//  Created by aidenluo on 3/10/14.
//  Copyright (c) 2014 wbdev. All rights reserved.
//

#import "GinPortraitViewController.h"

@interface GinPortraitViewController ()

@end

@implementation GinPortraitViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    _candoTransition = NO;
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    _candoTransition = YES;
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    _candoTransition = NO;
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion
{
    if (!flag || _candoTransition) {
        
        [super presentViewController:viewControllerToPresent animated:flag completion:completion];
    }
}

@end
