//
//  TMTumblrActivity.m
//  TumblrAppClient
//
//  Created by Bryan Irace on 3/19/13.
//  Copyright (c) 2013 Tumblr. All rights reserved.
//

#import "TMTumblrActivity.h"
#import "../AppClient/TMTumblrAppClient.h"

@implementation TMTumblrActivity

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
	
    if ([TMTumblrAppClient isTumblrInstalled]) {
		for (id item in activityItems) {
			if ([item isKindOfClass:[NSURL class]]) {
				return YES;
			}
			if ([item isKindOfClass:[NSString class]]) {
				return YES;
			}
		}
	}
	
	return NO;
}

- (NSString *)activityType {
	return NSStringFromClass([self class]);
}

- (NSString *)activityTitle {
	return @"Tumblr";
}

- (UIImage *)activityImage {
	return [UIImage imageNamed:@"UIActivityTumblr"];
}

#ifdef __IPHONE_7_0
- (UIActivityCategory)activityCategory {
    return UIActivityCategoryShare;
}
#endif

- (void)prepareWithActivityItems:(NSArray *)activityItems {
	self.title = nil;
	self.url = nil;
	self.description = nil;

    for (id item in activityItems) {
        if ([item isKindOfClass:[NSString class]]) {
			if (self.title) {
				self.description = item;
			} else {
				self.title = item;
			}
        } else if ([item isKindOfClass:[NSURL class]]) {
			NSURL* url = item;
			self.url = url;
        }
    }
}

static TMTumblrActivity* currentTMTumblrActivity = nil;

- (void)performActivity {
	currentTMTumblrActivity = self;
	
	NSURL* successURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@://tumblrShareSuccess", [[NSBundle mainBundle] bundleIdentifier]]];
	NSURL* cancelURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@://tumblrShareCancel", [[NSBundle mainBundle] bundleIdentifier]]];
	if (self.url) {
		[TMTumblrAppClient createLinkPost:self.title URLString:[self.url absoluteString] description:self.description tags:nil success:successURL cancel:cancelURL];
	} else if (self.title) {
		[TMTumblrAppClient createTextPost:self.title body:self.description tags:nil success:successURL cancel:cancelURL];
	}
}

- (void)activityDidFinish:(BOOL)completed {
    [super activityDidFinish:completed];
}

+ (BOOL)handleURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
	NSURL* successURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@://tumblrShareSuccess", [[NSBundle mainBundle] bundleIdentifier]]];
	NSURL* cancelURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@://tumblrShareCancel", [[NSBundle mainBundle] bundleIdentifier]]];

	if ([url isEqual:successURL]) {
		if (currentTMTumblrActivity) {
			[currentTMTumblrActivity activityDidFinish:YES];
			currentTMTumblrActivity = nil;
		}
		return YES;
	} else if ([url isEqual:cancelURL]) {
		if (currentTMTumblrActivity) {
			[currentTMTumblrActivity activityDidFinish:NO];
			currentTMTumblrActivity = nil;
		}
		return YES;
	}
	
	return NO;
}

@end
