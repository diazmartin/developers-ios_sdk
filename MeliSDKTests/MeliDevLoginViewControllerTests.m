//
//  MeliDevLoginViewControllerTests.m
//  MeliDevSDK
//
//  Created by Ignacio Giagante on 27/9/16.
//  Copyright © 2016 Mercado Libre. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MeliDevLoginViewController.h"
#import <OCMock/OCMock.h>

static NSString * const CLIENT_ID = @"app_id";
static NSString * const ACCESS_TOKEN = @"access_token";
static NSString * const EXPIRES_IN = @"expires_in";
static NSString * const USER_ID = @"user_id";

@interface MeliDevLoginViewController(Tests) <UIWebViewDelegate>

@property(nonatomic, weak) IBOutlet UIWebView *webView;

@end

@interface MeliDevLoginViewControllerTests : XCTestCase

@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic, strong) NSDictionary *wrongData;

- (void) success: (NSString *) message;
- (void) error: (NSError *) error;

@end

@implementation MeliDevLoginViewControllerTests

- (void)setUp {
    [super setUp];
    
    _data = @{ @"user_id" : @"221910727", @"access_token" : @"token", @"expires_in" : @"26100" };
    _wrongData = @{ @"user_id" : @"221910727", @"access_token" : @"token" };
}
    
- (BOOL) checkIfUserPropertiesExist: (NSDictionary *) data {
    return [data objectForKey:USER_ID] != nil && [data objectForKey:ACCESS_TOKEN] != nil && [data objectForKey:EXPIRES_IN] != nil;
}

- (void)testCheckIfPropertiesExist_withCorrectKeys_shouldReturnYes {
    
    XCTAssertTrue([self checkIfUserPropertiesExist: _data] == YES, @"The dictionary does not contain the correct keys");
}

- (void)testCheckIfPropertiesExist_withIncorrectKeys_shouldReturnNo {
    
    XCTAssertTrue([self checkIfUserPropertiesExist: _wrongData] == NO, @"The dictionary contain the correct keys");
}

- (void) success: (NSString *) message {
    NSLog(@"%@", message);
}

- (void) error: (NSError *) error {
    NSLog(@"%@", error);
}

- (void)testGetIdentityData_withCorrectUrlParams_shouldCallOnLoginCompleted {
    
    //Set stubs & mocks
    MeliDevLoginViewController *loginController = [[MeliDevLoginViewController alloc] init];
    NSString * params = @"access_token=APP_USR-5197208004815569-092710-c5a973091106231723d0e9491b1fa6d9__M_B__-221910727&expires_in=21600&user_id=221910727&domains=www.example.com";
    
    OCMStub([self checkIfUserPropertiesExist: _data]).andReturn(YES);
    
    __weak MeliDevLoginViewControllerTests * weakSelf = self;
    
    loginController.onLoginCompleted = ^(NSDictionary *data){
        [weakSelf success:@"OK"];
    };
    
    loginController.onErrorDetected = ^(NSError *error){
        [weakSelf error:error];
    };
    
    // when
    [loginController generateIdentityWithData:params];
    
    // verify
    OCMVerify([weakSelf success:OCMOCK_ANY]);
}

- (void) testGetIdentityData_withInCorrectUrlParams_shouldCallOnErrorDetected {
    
    //Set stubs & mocks
    MeliDevLoginViewController *loginController = [[MeliDevLoginViewController alloc] init];
    NSString * params = @"access_token=APP_USR-5197208004815569-092710-c5a973091106231723d0e9491b1fa6d9__M_B__-221910727&user_id=221910727&domains=www.example.com";

    OCMStub([self checkIfUserPropertiesExist: _wrongData]).andReturn(NO);
    
    __weak MeliDevLoginViewControllerTests * weakSelf = self;
    
    loginController.onLoginCompleted = ^(NSDictionary *data){
        [weakSelf success:@"OK"];
    };
    
    loginController.onErrorDetected = ^(NSError *error){
        [weakSelf error:error];
    };
    
    // when
    [loginController generateIdentityWithData:params];
    
    //verify
    OCMVerify([weakSelf error:OCMOCK_ANY]);
}

- (void) testShouldStartLoadWithRequest_withCorrectCallback_shouldReturnData {
    
    //Set stubs & mocks
    UIViewController *rootVC = [[UIViewController alloc] init];
    UINavigationController *mockNavigationController = OCMPartialMock([[UINavigationController alloc] initWithRootViewController:rootVC]);
    [OCMStub([mockNavigationController popViewControllerAnimated:YES]) andDo:^(NSInvocation *invocation) {
        [mockNavigationController popViewControllerAnimated:NO];
    }];
    
    NSString *appId = @"5197208004815569";
    NSString *redirectUrl = @"https://www.example.com";
    MeliDevLoginViewController *mockedLoginVC = OCMPartialMock([[MeliDevLoginViewController alloc] initWithAppId: appId andRedirectUrl: redirectUrl]);
    [mockNavigationController pushViewController:mockedLoginVC animated:NO];
    
    NSString * params = @"access_token=APP_USR-5197208004815569-092710-c5a973091106231723d0e9491b1fa6d9__M_B__-221910727&user_id=221910727&domains=www.example.com";
    OCMStub([mockedLoginVC generateIdentityWithData:params]).andReturn(_data);
    
    __weak MeliDevLoginViewControllerTests * weakSelf = self;
    
    mockedLoginVC.onLoginCompleted = ^(NSDictionary *data){
        [weakSelf success:@"OK"];
    };
    
    mockedLoginVC.onErrorDetected = ^(NSError *error){
        [weakSelf error:error];
    };
    
    NSURL *url = [NSURL URLWithString:@"https://www.example.com#params"];
    
    // when
    [mockedLoginVC webView: mockedLoginVC.webView shouldStartLoadWithRequest:[[NSURLRequest alloc]initWithURL:url] navigationType:UIWebViewNavigationTypeLinkClicked];
    
    // verify
    XCTAssertEqual(mockNavigationController.topViewController, rootVC);
}

@end
