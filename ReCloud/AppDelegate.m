//
//  AppDelegate.m
//  ReCloud
//
//  Created by hanl on 12-4-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "Constants.h"

@implementation AppDelegate

@synthesize window = _window;


- (void)dealloc
{
    [_window release];

    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{       
    
    [self customizeNavigationBar];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *samplePath = [[self documentPath] stringByAppendingPathComponent:SAMPLE_DIR];
    NSString *audioPath = [[self documentPath] stringByAppendingPathComponent:AUDIO_DIR];
    NSString *indexPath = [[self documentPath] stringByAppendingPathComponent:INDEX_DIR];
    if(![fileManager fileExistsAtPath:samplePath]){
        [fileManager createDirectoryAtPath:samplePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if(![fileManager fileExistsAtPath:audioPath]){
        [fileManager createDirectoryAtPath:audioPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if(![fileManager fileExistsAtPath:indexPath]){
        [fileManager createDirectoryAtPath:indexPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    //屏幕常亮
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    MainViewController *mainVC = [[MainViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:mainVC];    
    self.window.rootViewController = nav;
    [mainVC release];    
    
    self.window.backgroundColor = [UIColor blackColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

#pragma mark - Instance Methods

-(NSString *) documentPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES);
    NSString *docPath= [paths objectAtIndex:0];
    
    NSLog(@"%@", docPath);
    
    return docPath;
}

-(void) customizeNavigationBar{
    if([[[UIDevice currentDevice] systemVersion] floatValue] > 4.9){
        UIImage *gradientImage44 = [[UIImage imageNamed:@"top_port.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        UIImage *gradientImage32 = [[UIImage imageNamed:@"top_land.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];        
        [[UINavigationBar appearance] setBackgroundImage:gradientImage44 forBarMetrics:UIBarMetricsDefault];
        [[UINavigationBar appearance] setBackgroundImage:gradientImage32 forBarMetrics:UIBarMetricsLandscapePhone];
    }
}

@end
