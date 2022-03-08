//
//  RPViewController.m
//  iBlob
//
//  Created by Richard Pickup on 17/05/2014.
//  Copyright (c) 2014 Richard Pickup. All rights reserved.
//

#import "RPViewController.h"
#import "RPMyScene.h"

@implementation RPViewController


- (void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    SKView * skView = (SKView *)self.view;
    if (!skView.scene) {
        skView.showsFPS = YES;
        skView.showsNodeCount = YES;
        
        // Create and configure the scene.
        SKScene * scene = [RPMyScene sceneWithSize:skView.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        
        // Present the scene.
        [skView presentScene:scene];
    }
    else {
        skView.scene.size = skView.bounds.size;
    }
}




- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return  UIInterfaceOrientationMaskPortrait;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
