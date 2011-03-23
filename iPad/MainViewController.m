    //
//  MainViewController.m
//  PubNubLib
//
//  Created by Chad Etzel on 3/21/11.
//  Copyright 2011 Phrygian Labs, Inc. All rights reserved.
//

#import "MainViewController.h"


@implementation MainViewController


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	NSLog(@"loading view...");
	self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];

	UIButton *btn; // = [[UIButton alloc] initWithFrame:CGRectMake(10.0, 10.0, 50.0, 50.0)];
	btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	btn.frame = CGRectMake(10.0, 50.0, 50.0, 50.0);
	[btn addTarget:self action:@selector(button1click:) forControlEvents:UIControlEventTouchUpInside];
	[btn setTitle:@"ONE" forState:UIControlStateNormal];
	[self.view addSubview:btn];

	
	btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	btn.frame = CGRectMake(80.0, 50.0, 50.0, 50.0);
	[btn addTarget:self action:@selector(button2click:) forControlEvents:UIControlEventTouchUpInside];
	[btn setTitle:@"TWO" forState:UIControlStateNormal];
	[self.view addSubview:btn];
	
	
	btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	btn.frame = CGRectMake(150.0, 50.0, 50.0, 50.0);
	[btn addTarget:self action:@selector(button3click:) forControlEvents:UIControlEventTouchUpInside];
	[btn setTitle:@"THR3" forState:UIControlStateNormal];
	[self.view addSubview:btn];

	
	btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	btn.frame = CGRectMake(10.0, 150.0, 50.0, 50.0);
	[btn addTarget:self action:@selector(button4click:) forControlEvents:UIControlEventTouchUpInside];
	[btn setTitle:@"TIME" forState:UIControlStateNormal];
	[self.view addSubview:btn];
	
	
	btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	btn.frame = CGRectMake(80.0, 150.0, 50.0, 50.0);
	[btn addTarget:self action:@selector(button5click:) forControlEvents:UIControlEventTouchUpInside];
	[btn setTitle:@"HIST" forState:UIControlStateNormal];
	[self.view addSubview:btn];
	


	
	
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	
	/* pubnub test stuff */
	
	CEPubnub *pubnub = [[CEPubnub alloc]
						publishKey:   @"demo" 
						subscribeKey: @"demo" 
						secretKey:    @"demo" 
						sslOn:        NO
						origin:       @"pubsub.pubnub.com"
						];
	
	//subscribe to a few channels
	
	NSLog(@"subscribing...");
	[pubnub subscribe: @"hello_world_objective_c" delegate:self];
	[pubnub subscribe: @"hello_world_objective_d" delegate:self];
	[pubnub subscribe: @"hello_world_objective_e" delegate:self];
	
	
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

- (void)button1click: (id)sender
{
	NSLog(@"button1click");
	
	CEPubnub *pubnub = [[[CEPubnub alloc] autorelease]
						publishKey:   @"demo" 
						subscribeKey: @"demo"
						secretKey:    @"demo" 
						sslOn:        NO
						origin:       @"pubsub.pubnub.com"
						];
	[pubnub publish:@"hello_world_objective_c" message: [NSDictionary dictionaryWithObjectsAndKeys:@"Cheeseburger",@"food",@"Coffee",@"drink", nil] delegate: self];
	
}

- (void)button2click: (id)sender
{
	NSLog(@"button2click");
	
	CEPubnub *pubnub = [[[CEPubnub alloc] autorelease]
						publishKey:   @"demo" 
						subscribeKey: @"demo" 
						secretKey:    @"demo" 
						sslOn:        NO
						origin:       @"pubsub.pubnub.com"
						];
	[pubnub publish:@"hello_world_objective_d" message:@"This is a string" delegate: self];
	
}

- (void)button3click: (id)sender
{
	NSLog(@"button3click");
	
	CEPubnub *pubnub = [[[CEPubnub alloc] autorelease]
						publishKey:   @"demo" 
						subscribeKey: @"demo" 
						secretKey:    @"demo" 
						sslOn:        NO
						origin:       @"pubsub.pubnub.com"
						];
	[pubnub publish:@"hello_world_objective_e" message: [NSArray arrayWithObjects:@"seven", @"eight", @"nine", nil] delegate: self];
	
}

- (void)button4click: (id)sender
{
	NSLog(@"button4click");
	
	CEPubnub *pubnub = [[[CEPubnub alloc] autorelease]
						publishKey:   @"demo" 
						subscribeKey: @"demo" 
						secretKey:    @"demo" 
						sslOn:        NO
						origin:       @"pubsub.pubnub.com"
						];
	
	[pubnub time:self];
	
}

- (void)button5click: (id)sender
{
	NSLog(@"button5click");
	
	CEPubnub *pubnub = [[[CEPubnub alloc] autorelease]
						publishKey:   @"demo" 
						subscribeKey: @"demo" 
						secretKey:    @"demo" 
						sslOn:        NO
						origin:       @"pubsub.pubnub.com"
						];
	
	[pubnub history:@"hello_world_objective_c" limit:10 delegate:self];
	
}

#pragma mark -
#pragma mark CEPubnubDelegate stuff



- (void)pubnub:(CEPubnub *)pubnub subscriptionDidReceiveDictionary:(NSDictionary *)response onChannel:(NSString *)channel
{
	NSLog(@"sub on channel (dict) : %@ - received: %@", channel, response);
}

- (void)pubnub:(CEPubnub *)pubnub subscriptionDidReceiveArray:(NSArray *)response onChannel:(NSString *)channel
{
	NSLog(@"sub on channel (arr) : %@ - received: %@ - pubnub %@", channel, response, pubnub);
}

- (void)pubnub:(CEPubnub *)pubnub subscriptionDidReceiveString:(NSString *)response onChannel:(NSString *)channel
{
	NSLog(@"sub on channel (str) : %@ - received: %@", channel, response);
}


- (void)pubnub:(CEPubnub *)pubnub subscriptionDidFailWithResponse:(NSString *)response onChannel:(NSString *)channel
{
	NSLog(@"FAILURE sub on channel: %@ - received: %@", channel, response);
}

- (void)pubnub:(CEPubnub *)pubnub subscriptionDidReceiveHistoryArray:(NSArray *)response onChannel:(NSString *)channel
{
	NSLog(@"HISTORY on channel (arr) : %@ - received: %@ - pubnub %@", channel, response, pubnub);
}

- (void)pubnub:(CEPubnub *)pubnub publishDidSucceedWithResponse:(NSString *)response onChannel:(NSString *)channel
{
	NSLog(@"publish on channel: %@ - received: %@", channel, response);
}

- (void)pubnub:(CEPubnub *)pubnub publishDidFailWithResponse:(NSString *)response onChannel:(NSString *)channel
{
	NSLog(@"FAILURE publish on channel: %@ - received: %@", channel, response);
}

- (void)pubnub:(CEPubnub *)pubnub didReceiveTime:(NSString *)timestamp
{
	NSLog(@"Timestamp is %@ - pubnub %@", timestamp, pubnub);
}




@end
