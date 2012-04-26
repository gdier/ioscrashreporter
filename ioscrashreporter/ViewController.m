//
//  ViewController.m
//  ioscrashreporter
//
//  Created by Gdier Zhang on 12-4-26.
//  Copyright (c) 2012年 Gdier.zh. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)realBadAccess
{
    void (*nullFunction)() = NULL;
    
    nullFunction();
}

- (void)badAccess
{
    [self realBadAccess];
}

- (void)makeException
{
    [self string];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)onClickExceptionButton:(id)sender
{
    [self string];
}

- (void)onClickErrorBadAccessButton:(id)sender
{
    [self badAccess];
}

- (void)onClickNewThreadExceptionButton:(id)sender
{
	[self performSelector:@selector(string) withObject:nil afterDelay:.5];
}

- (void)onClickNewThreadErrorBadAccessButton:(id)sender
{
    [self performSelector:@selector(realBadAccess) withObject:nil afterDelay:.5];
}

@end
