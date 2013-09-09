//
//  CustomUAPushHandler.h
//  MyCustomPushHandler
//
//  Created by Raj Wilhoit on 9/9/13.
//  Copyright (c) 2013 UF.rajwilhoit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UAirship.h"
#import "UAPush.h"
#import "UAAnalytics.h"

@interface CustomUAPushHandler : NSObject <UIAlertViewDelegate, UAPushNotificationDelegate>


// singleton
+ (SSDPCustomUAPushNotificationHandler *)sharedInstance;

@property (nonatomic, strong) NSString *id;             // The id of the asset or item that the push notification wants to open
@property (nonatomic) BOOL launchedFromColdStart;       // A flag for if we are opening the app from a cold start
@property (nonatomic) BOOL receivedPushNotification;    // A flag for if we have received a push notification. Set to nil after you have finished
                                                        // handling the noitifcation
@property (nonatomic) BOOL delegateLock;                // A lock for the delegate to handle a UA bug where UA's UAAutoDelegate would fire my methods for
                                                        // the custom handler at the same time my custom handler would

/**
 * Called when an alert notification is received in the foreground.
 * @param alertMessage a simple string to be displayed as an alert
 */
- (void)displayNotificationAlert:(NSString *)alertMessage;

/**
 * Called when a push notification is received while the app is running in the foreground.
 *
 * @param notification The notification dictionary.
 */
- (void)receivedForegroundNotification:(NSDictionary *)notification;

/**
 * Called when the app is started or resumed because a user opened a notification.
 *
 * @param notification The notification dictionary.
 */
- (void)launchedFromNotification:(NSDictionary *)notification;

@end
