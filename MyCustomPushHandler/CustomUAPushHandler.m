//
//  CustomUAPushHandler.m
//  MyCustomPushHandler
//
//  Created by Raj Wilhoit on 9/9/13.
//  Copyright (c) 2013 UF.rajwilhoit. All rights reserved.
//

#import "CustomUAPushHandler.h"

@implementation CustomUAPushHandler

@synthesize id = _id;

#pragma mark - sharedInstance

/*
    I used a singleton to tell the delegate that THIS is the custom push handler to use
 */
+ (CustomUAPushHandler *)sharedInstance
{
    static CustomUAPushHandler *sharedInstance;
    
    @synchronized(self)
    {
        if (sharedInstance == nil) {
            sharedInstance = [[CustomUAPushHandler alloc] init];
        }
        
        return sharedInstance;
    }
}

/*
    This will make it so after calling id once, the id value will be set to nil. 
    The point is to make sure there won't be a value for id that is remaining from a previous usage 
    (Since we're using a handler with a singleton instance)
 */
- (NSString *)id
{
    NSString *identifier = _id;
    _id = nil;
    return identifier;
}

/*
    This will display a UIAlert notificication, where the alertMessage 
    variable contains the body of the push notification message
 */
- (void)displayNotificationAlert:(NSString *)alertMessage {
    
    UA_LDEBUG(@"Received an alert in the foreground.");
    
    /*
        Unfortunately due to a bug I encountered with UA I had to create a lock (think semaphores)
        that would only let my own custom handler show a UIAlert. This may not be the case for you.
     */
    if(self.delegateLock) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"My App Name"
                                                        message: alertMessage
                                                       delegate: self
                                              cancelButtonTitle: @"Cancel"
                                              otherButtonTitles: @"Open",nil];
        self.delegateLock = NO;
        [alert show];
    }
}

/* 
    This checks if the user clicked cancel for the foreground push notification.
    You must 'nil' out the value for the id if the user cancels the notification.
 */
- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:DATA_READY_TO_DISPLAY_NOTIFICATION object:nil];
    }
    else {
        self.id = nil;
    }
}

/*
    This is called when receiving a notification in the foreground
 */
- (void)receivedForegroundNotification:(NSDictionary *)notification {
    UA_LDEBUG(@"Received a notification while the app was already in the foreground");
    
    if([notification count] != 0) {
        // I had to use this flag to handle how to display the assets down the line
        [SSDPCustomUAPushNotificationHandler sharedInstance].launchedFromColdStart = NO;
        
        // Set the id given from the push notifcation
        [self handleAssetFromPushNotification:notification];
    }
    
}

/*
    This is called when the user opens the app from a notification
 */
- (void)launchedFromNotification:(NSDictionary *)notification {
    
    if([notification count] != 0) {
        // Set the id given from the push notifcation
        [self handleAssetFromPushNotification:notification];
        [[NSNotificationCenter defaultCenter] postNotificationName:DATA_READY_TO_DISPLAY_NOTIFICATION object:nil];
    }
	
}

/* 
    This reads JSON from the notification to take out the information we need 
    to follow the notification's directions. In this case I want to open an asset
    with an id from the JSON value ID.
 */
- (void)handleAssetFromPushNotification:(NSDictionary *)notification {
    
    if([notification count] != 0)
    {
        // Set flag for receiving a push notification
        [self setReceivedPushNotification:YES];
        
        // Check that the value for id actually exists
        if ([notification valueForKey:@"id"])
        {
                // Find asset id and start dashboard
                [self setId:[[NSString alloc] initWithFormat:@"%@",[notification valueForKey:@"id"]]];
            }
        }
    }
}

@end
