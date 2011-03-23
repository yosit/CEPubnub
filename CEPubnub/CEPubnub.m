//
//  CEPubnub.m
//  PubNubLib
//
//  Created by Chad Etzel on 3/21/11.
//  Copyright 2011 Phrygian Labs, Inc. All rights reserved.
//

#import "CEPubnub.h"

#import <CommonCrypto/CommonDigest.h>

@implementation CEPubnub

@synthesize publish_key, subscribe_key, secret_key, scheme, host, subscriptions, parser, writer;

-(CEPubnub *)
publishKey:   (NSString*) pub_key
subscribeKey: (NSString*) sub_key
secretKey:    (NSString*) sec_key
sslOn:        (BOOL)      ssl_on
origin:       (NSString*) origin
{
    //pool          = [[NSAutoreleasePool alloc] init];
    self          = [super init];
    publish_key   = pub_key;
    subscribe_key = sub_key;
    secret_key    = sec_key;
    scheme        = ssl_on ? @"https" : @"http";
    host          = origin;
    subscriptions = [[NSMutableDictionary alloc] init];
    parser        = [SBJsonParser new];
    writer        = [SBJsonWriter new];
	
    return self;
}

+(NSString*) urlencode: (NSString*) string {
    
	return [string
			stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding
			];
	
	
	//return [(NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)(string), NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8) autorelease];
}
+(NSString*) md5: (NSString*) input {
    const char* str = [input UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, strlen(str), result);
	
    NSMutableString *ret = [NSMutableString stringWithCapacity:
							CC_MD5_DIGEST_LENGTH * 2
							];
    for (int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}

// * /publish/pub-key/sub-key/signature/channel/callback/"msg"
-(void)
publish:  (NSString*) channel
message:  (id)        message
delegate: (id)        delegate
{
	
	
	NSString* message_string;
	if ([message isKindOfClass:[NSString class]]) {
		message_string = [NSString stringWithFormat:@"\"%@\"", message];
	} else {
		message_string = [writer stringWithObject: message];
	}
	
    NSString* signature = [CEPubnub md5: [NSString
										stringWithFormat: @"%@/%@/%@/%@/%@",
										publish_key,
										subscribe_key,
										secret_key,
										channel,
										message_string
										]];
	
    if (1500 < [message_string length]) {
        NSLog(@"Message Too Long (Over: 1500)");
        return;
    }
	
    [[[CEPubnubRequest alloc] autorelease]
	 scheme: scheme
	 host:   host
	 path:   [NSString
			  stringWithFormat: @"/publish/%@/%@/%@/%@/0/%@",
			  publish_key,
			  subscribe_key,
			  signature,
			  [CEPubnub urlencode: channel],
			  [CEPubnub urlencode: message_string]
			  ]
	 callback: [[[CEPubnubPublishDelegate alloc] autorelease]
				finished: delegate
				pubnub:   self
				channel:  channel
				]
	 ];
	
}

-(BOOL) subscribed: (NSString*) channel {
    if ([subscriptions objectForKey: channel]) return YES;
    return NO;
}
// * /subscribe/sub-key/channel/callback/timetoken
-(void) subscribe: (NSDictionary*) args {
    NSString* channel = [args objectForKey:@"channel"];
    
	CEPubnubResponse *callback = [CEPubnubSubscribeDelegate alloc];
	[callback
	 finished: [args objectForKey:@"delegate"]
	 pubnub:   self
	 channel:  channel
	 ];
								  

	CEPubnubRequest *req = [CEPubnubRequest alloc];
	
	[req
	 scheme: scheme
	 host:   host
	 path:   [NSString
			  stringWithFormat: @"/subscribe/%@/%@/0/%@",
			  subscribe_key,
			  [CEPubnub urlencode: channel],
			  [args objectForKey:@"timetoken"]
			  ]
	 callback: callback /*[[CEPubnubSubscribeDelegate alloc]
				finished: [args objectForKey:@"delegate"]
				pubnub:   self
				channel:  channel
				]*/
	 ];
	
	[subscriptions setObject:req forKey:channel];
	[req release];
	[callback release];
	//NSLog(@"req retainCount: %d", [req retainCount]);
	//NSLog(@"callback retainCount: %d", [callback retainCount]);
	
	
}

-(void)
subscribe: (NSString*) channel
delegate:  (id)        delegate
{
		
	
    if ([self subscribed: channel]) {
        NSLog( @"Already Subscribed: %@", channel );
        return;
    }
	
    
	
    [self
	 performSelector: @selector(subscribe:)
	 withObject: [NSDictionary
				  dictionaryWithObjectsAndKeys:
				  channel,   @"channel", 
				  delegate,  @"delegate", 
				  @"0",      @"timetoken", 
				  nil]
	 ];
}


-(void) unsubscribe: (NSString*) channel {
	CEPubnubRequest *req = [subscriptions objectForKey:channel];
	
	if (req.connection) {
		[req.connection cancel];
	}
	
    [subscriptions removeObjectForKey:channel];
	
}

// * /history/sub-key/channel/callback/limit
-(void)
history:  (NSString*) channel
limit:    (int)       limit
delegate: (id)        delegate
{
    if (limit > 100) limit = 100;
	
    [[[CEPubnubRequest alloc] autorelease]
	 scheme: scheme
	 host:   host
	 path:   [NSString
			  stringWithFormat: @"/history/%@/%@/0/%i",
			  subscribe_key,
			  [CEPubnub urlencode: channel],
			  limit
			  ]
	 callback: [[[CEPubnubHistoryDelegate alloc] autorelease]
				finished: delegate
				pubnub:   self
				channel:  channel
				]
	 ];
}

-(void) time: (id) delegate {
    [[[CEPubnubRequest alloc] autorelease]
	 scheme:   scheme
	 host:     host
	 path:     @"/time/0"
	 callback: [[[CEPubnubTimeDelegate alloc] autorelease]
				finished: delegate
				pubnub:   self
				]
	 ];
}

-(void) dealloc {
	//SLog(@"DEALLOCING PUBNUB!!!!");
	
	[subscriptions release];
	[parser release];
	[writer release];
	
	[super dealloc];
}

@end

@implementation CEPubnubSubscribeDelegate
-(void) callback: (id) response {
	
	
	
    NSArray* response_data = [parser objectWithString: response];
    if (![pubnub subscribed: channel]) return;
	
	
	
    [pubnub
	 performSelector: @selector(subscribe:)
	 withObject: [NSDictionary
				  dictionaryWithObjectsAndKeys:
				  channel,                         @"channel", 
				  delegate,                        @"delegate", 
				  [response_data objectAtIndex:1], @"timetoken", 
				  nil]
	 ];
	
    id message;
    NSEnumerator* messages = [[response_data objectAtIndex:0]
							  objectEnumerator
							  ];
	
		
    while ((message = [messages nextObject])) {
		
		
        //[delegate callback: message];
		if (delegate) {
			
			
			if ([message isKindOfClass:[NSDictionary class]]) {
				if ([delegate respondsToSelector:@selector(pubnub:subscriptionDidReceiveDictionary:onChannel:)]) {
					[delegate pubnub:pubnub subscriptionDidReceiveDictionary:message onChannel:channel];
				}
			} else if ([message isKindOfClass:[NSArray class]]) {
				if ([delegate respondsToSelector:@selector(pubnub:subscriptionDidReceiveArray:onChannel:)]) {
					[delegate pubnub:pubnub subscriptionDidReceiveArray:message onChannel:channel];
				}
			} else if ([message isKindOfClass:[NSString class]]) {
				if ([delegate respondsToSelector:@selector(pubnub:subscriptionDidReceiveString:onChannel:)]) {
					[delegate pubnub:pubnub subscriptionDidReceiveString:message onChannel:channel];
				}
			}
			
			
		} else {
			
		}
    }
	
}

-(void) fail: (id) response {
    if (![pubnub subscribed: channel]) return;
	
    [pubnub
	 performSelector: @selector(subscribe:)
	 withObject: [NSDictionary
				  dictionaryWithObjectsAndKeys:
				  channel,  @"channel", 
				  delegate, @"delegate", 
				  @"1",     @"timetoken", 
				  nil]
	 afterDelay: 1.0
	 ];
	
	if (delegate) {
		if ([delegate respondsToSelector:@selector(pubnub:subscriptionDidFailWithResponse:onChannel:)]) {
			[delegate pubnub:pubnub subscriptionDidFailWithResponse:response onChannel:channel];
		}
	}
}
@end


@implementation CEPubnubHistoryDelegate
-(void) callback: (id) response {
	
	
	
    NSArray* response_data = [parser objectWithString: response];
	
	if (delegate) {
		if ([delegate respondsToSelector:@selector(pubnub:subscriptionDidReceiveHistoryArray:onChannel:)]) {
			[delegate pubnub:pubnub subscriptionDidReceiveHistoryArray:response_data onChannel:channel];
		}
	}
		
}

-(void) fail: (id) response {
    if (![pubnub subscribed: channel]) return;
	
    [pubnub
	 performSelector: @selector(subscribe:)
	 withObject: [NSDictionary
				  dictionaryWithObjectsAndKeys:
				  channel,  @"channel", 
				  delegate, @"delegate", 
				  @"1",     @"timetoken", 
				  nil]
	 afterDelay: 1.0
	 ];
	
	if (delegate) {
		if ([delegate respondsToSelector:@selector(pubnub:subscriptionDidFailWithResponse:onChannel:)]) {
			[delegate pubnub:pubnub subscriptionDidFailWithResponse:response onChannel:channel];
		}
	}
}
@end

@implementation CEPubnubPublishDelegate

-(void) callback: (id) response {
	
	if (delegate) {
		
		if ([delegate respondsToSelector:@selector(pubnub:publishDidSucceedWithResponse:onChannel:)]) {
			[delegate pubnub:pubnub publishDidSucceedWithResponse:response onChannel:channel];
		}
	}
}

-(void) fail: (id) response {
	
	if (delegate) {
		
		if ([delegate respondsToSelector:@selector(pubnub:publishDidFailWithResponse:onChannel:)]) {
			[delegate pubnub:pubnub publishDidFailWithResponse:response onChannel:channel];
		}
	}
}

@end


@implementation CEPubnubTimeDelegate
-(void) callback: (id) response {
    //[delegate callback: [[parser objectWithString: response] objectAtIndex:0]];
	
	if (delegate) {
		if ([delegate respondsToSelector:@selector(pubnub:didReceiveTime:)]) {
			[delegate pubnub:pubnub didReceiveTime:(NSString *)[[parser objectWithString: response] objectAtIndex:0]];
		}
	}
}
@end