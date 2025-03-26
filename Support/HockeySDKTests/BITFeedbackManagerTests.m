//
//  BITFeedbackManagerTests.m
//  HockeySDK
//
//  Created by Andreas Linde on 24.03.14.
//
//

#import <XCTest/XCTest.h>

#import <OCHamcrestIOS/OCHamcrestIOS.h>
#import <OCMockitoIOS/OCMockitoIOS.h>

#import "HockeySDK.h"

#if HOCKEYSDK_FEATURE_FEEDBACK

#import "HockeySDKPrivate.h"
#import "BITFeedbackManager.h"
#import "BITFeedbackManagerPrivate.h"
#import "BITHockeyBaseManager.h"
#import "BITHockeyBaseManagerPrivate.h"

#import "BITTestHelper.h"

@interface BITFeedbackManagerTests : XCTestCase

@property BITFeedbackManager *sut;

@end

@implementation BITFeedbackManagerTests

- (void)setUp {
  [super setUp];

  BITHockeyManager *hm = [BITHockeyManager sharedHockeyManager];
  hm.delegate = nil;
  self.sut = [[BITFeedbackManager alloc] initWithAppIdentifier:nil appEnvironment:BITEnvironmentOther];
  self.sut.delegate = nil;
}

- (void)tearDown {
  self.sut = nil;
  
  [super tearDown];
}

#pragma mark - Private

- (void)startManager {
  [self.sut startManager];
}

#pragma mark - Setup Tests

- (void)testSetup {
  XCTAssertNotNil(self.sut);
  XCTAssertTrue([self.sut feedbackObservationMode] == BITFeedbackObservationNone);
  XCTAssertNil(self.sut.tapRecognizer);
  XCTAssertFalse([self.sut isFeedbackManagerDisabled]);
  XCTAssertFalse([self.sut observationModeOnScreenshotEnabled]);
  XCTAssertFalse([self.sut observationModeThreeFingerTapEnabled]);
  XCTAssertNil([self.sut userEmail]);
  XCTAssertNil([self.sut userID]);
  XCTAssertNil([self.sut userName]);
  XCTAssertNil([self.sut lastMessageID]);
  XCTAssertNil([self.sut lastCheck]);
  XCTAssertFalse([self.sut didAskUserData]);
}

#pragma mark - User Metadata

- (void)testUpdateUserIDWithNoDataPresent {
  BITHockeyManager *hm = [BITHockeyManager sharedHockeyManager];
  id delegateMock = mockProtocol(@protocol(BITHockeyManagerDelegate));
  hm.delegate = delegateMock;
  self.sut.delegate = delegateMock;
  
  BOOL dataAvailable = [self.sut updateUserIDUsingDelegate];
  
  assertThatBool(dataAvailable, isFalse());
  assertThat(self.sut.userID, nilValue());
  
  [verifyCount(delegateMock, times(1)) userIDForHockeyManager:hm componentManager:self.sut];
}

- (void)testUpdateUserIDWithDelegateReturningData {
  BITHockeyManager *hm = [BITHockeyManager sharedHockeyManager];
  NSObject <BITHockeyManagerDelegate> *classMock = mockObjectAndProtocol([NSObject class], @protocol(BITHockeyManagerDelegate));
  [given([classMock userIDForHockeyManager:hm componentManager:self.sut]) willReturn:@"test"];
  hm.delegate = classMock;
  self.sut.delegate = classMock;
  
  BOOL dataAvailable = [self.sut updateUserIDUsingDelegate];
  
  assertThatBool(dataAvailable, isTrue());
  assertThat(self.sut.userID, equalTo(@"test"));
  
  [verifyCount(classMock, times(1)) userIDForHockeyManager:hm componentManager:self.sut];
}

- (void)testUpdateUserNameWithNoDataPresent {
  BITHockeyManager *hm = [BITHockeyManager sharedHockeyManager];
  id delegateMock = mockProtocol(@protocol(BITHockeyManagerDelegate));
  hm.delegate = delegateMock;
  self.sut.delegate = delegateMock;
  
  BOOL dataAvailable = [self.sut updateUserNameUsingDelegate];
  
  assertThatBool(dataAvailable, isFalse());
  assertThat(self.sut.userName, nilValue());
  
  [verifyCount(delegateMock, times(1)) userNameForHockeyManager:hm componentManager:self.sut];
}

- (void)testUpdateUserNameWithDelegateReturningData {
  BITHockeyManager *hm = [BITHockeyManager sharedHockeyManager];
  NSObject <BITHockeyManagerDelegate> *classMock = mockObjectAndProtocol([NSObject class], @protocol(BITHockeyManagerDelegate));
  [given([classMock userNameForHockeyManager:hm componentManager:self.sut]) willReturn:@"test"];
  hm.delegate = classMock;
  self.sut.delegate = classMock;
  
  BOOL dataAvailable = [self.sut updateUserNameUsingDelegate];
  
  assertThatBool(dataAvailable, isTrue());
  assertThat(self.sut.userName, equalTo(@"test"));
  
  [verifyCount(classMock, times(1)) userNameForHockeyManager:hm componentManager:self.sut];
}

- (void)testUpdateUserEmailWithNoDataPresent {
  BITHockeyManager *hm = [BITHockeyManager sharedHockeyManager];
  id delegateMock = mockProtocol(@protocol(BITHockeyManagerDelegate));
  hm.delegate = delegateMock;
  self.sut.delegate = delegateMock;
  
  BOOL dataAvailable = [self.sut updateUserEmailUsingDelegate];
  
  assertThatBool(dataAvailable, isFalse());
  assertThat(self.sut.userEmail, nilValue());
  
  [verifyCount(delegateMock, times(1)) userEmailForHockeyManager:hm componentManager:self.sut];
}

- (void)testUpdateUserEmailWithDelegateReturningData {
  BITHockeyManager *hm = [BITHockeyManager sharedHockeyManager];
  NSObject <BITHockeyManagerDelegate> *classMock = mockObjectAndProtocol([NSObject class], @protocol(BITHockeyManagerDelegate));
  [given([classMock userEmailForHockeyManager:hm componentManager:self.sut]) willReturn:@"test"];
  hm.delegate = classMock;
  self.sut.delegate = classMock;
  
  BOOL dataAvailable = [self.sut updateUserEmailUsingDelegate];
  
  assertThatBool(dataAvailable, isTrue());
  assertThat(self.sut.userEmail, equalTo(@"test"));
  
  [verifyCount(classMock, times(1)) userEmailForHockeyManager:hm componentManager:self.sut];
}

- (void)testAllowFetchingNewMessages {
    BOOL fetchMessages = NO;

    // check the default
    fetchMessages = [self.sut allowFetchingNewMessages];
    
    assertThatBool(fetchMessages, isTrue());
    
    // check the delegate is implemented and returns NO
    BITHockeyManager *hm = [BITHockeyManager sharedHockeyManager];
    NSObject <BITHockeyManagerDelegate> *classMock = mockObjectAndProtocol([NSObject class], @protocol(BITHockeyManagerDelegate));
    [given([classMock allowAutomaticFetchingForNewFeedbackForManager:self.sut]) willReturn:@NO];
    hm.delegate = classMock;
    self.sut.delegate = classMock;
    
    fetchMessages = [self.sut allowFetchingNewMessages];
    
    assertThatBool(fetchMessages, isFalse());
    
    [verifyCount(classMock, times(1)) allowAutomaticFetchingForNewFeedbackForManager:self.sut];
}

- (void)testFeedbackObservationModeDefault {
  XCTAssertTrue(self.sut.feedbackObservationMode == BITFeedbackObservationNone);
  XCTAssertFalse(self.sut.observationModeOnScreenshotEnabled);
  XCTAssertFalse(self.sut.observationModeThreeFingerTapEnabled);
  XCTAssertNil(self.sut.tapRecognizer);
}

- (void)testSetFeedbackObservationMode {
  [self.sut setFeedbackObservationMode:BITFeedbackObservationModeOnScreenshot];
  XCTAssertTrue(self.sut.observationModeOnScreenshotEnabled);
  XCTAssertFalse(self.sut.observationModeThreeFingerTapEnabled);
  XCTAssertNil(self.sut.tapRecognizer);
  XCTAssertTrue(self.sut.feedbackObservationMode == BITFeedbackObservationModeOnScreenshot);

  [self.sut setFeedbackObservationMode:BITFeedbackObservationNone];
  XCTAssertFalse(self.sut.observationModeOnScreenshotEnabled);
  XCTAssertFalse(self.sut.observationModeThreeFingerTapEnabled);
  XCTAssertNil(self.sut.tapRecognizer);
  XCTAssertTrue(self.sut.feedbackObservationMode == BITFeedbackObservationNone);
  
  [self.sut setFeedbackObservationMode:BITFeedbackObservationModeThreeFingerTap];
  XCTAssertFalse(self.sut.observationModeOnScreenshotEnabled);
  XCTAssertTrue(self.sut.observationModeThreeFingerTapEnabled);
  XCTAssertNotNil(self.sut.tapRecognizer);
  XCTAssertTrue(self.sut.feedbackObservationMode == BITFeedbackObservationModeThreeFingerTap);
  
  [self.sut setFeedbackObservationMode:BITFeedbackObservationNone];
  XCTAssertFalse(self.sut.observationModeOnScreenshotEnabled);
  XCTAssertFalse(self.sut.observationModeThreeFingerTapEnabled);
  XCTAssertNil(self.sut.tapRecognizer);
  XCTAssertTrue(self.sut.feedbackObservationMode == BITFeedbackObservationNone);
  
  [self.sut setFeedbackObservationMode:BITFeedbackObservationModeThreeFingerTap];
  XCTAssertFalse(self.sut.observationModeOnScreenshotEnabled);
  XCTAssertTrue(self.sut.observationModeThreeFingerTapEnabled);
  XCTAssertNotNil(self.sut.tapRecognizer);
  XCTAssertTrue(self.sut.feedbackObservationMode == BITFeedbackObservationModeThreeFingerTap);

  [self.sut setFeedbackObservationMode:BITFeedbackObservationModeOnScreenshot];
  XCTAssertTrue(self.sut.observationModeOnScreenshotEnabled);
  XCTAssertFalse(self.sut.observationModeThreeFingerTapEnabled);
  XCTAssertNil(self.sut.tapRecognizer);
  XCTAssertTrue(self.sut.feedbackObservationMode == BITFeedbackObservationModeOnScreenshot);

  [self.sut setFeedbackObservationMode:BITFeedbackObservationModeThreeFingerTap];
  XCTAssertFalse(self.sut.observationModeOnScreenshotEnabled);
  XCTAssertTrue(self.sut.observationModeThreeFingerTapEnabled);
  XCTAssertNotNil(self.sut.tapRecognizer);
  XCTAssertTrue(self.sut.feedbackObservationMode == BITFeedbackObservationModeThreeFingerTap);

  [self.sut setFeedbackObservationMode:BITFeedbackObservationNone];
  XCTAssertFalse(self.sut.observationModeOnScreenshotEnabled);
  XCTAssertFalse(self.sut.observationModeThreeFingerTapEnabled);
  XCTAssertNil(self.sut.tapRecognizer);
  XCTAssertTrue(self.sut.feedbackObservationMode == BITFeedbackObservationNone);

  [self.sut setFeedbackObservationMode:BITFeedbackObservationModeAll];
  XCTAssertTrue(self.sut.observationModeOnScreenshotEnabled);
  XCTAssertTrue(self.sut.observationModeThreeFingerTapEnabled);
  XCTAssertNotNil(self.sut.tapRecognizer);
  XCTAssertTrue(self.sut.feedbackObservationMode == BITFeedbackObservationModeAll);

  [self.sut setFeedbackObservationMode:BITFeedbackObservationModeThreeFingerTap];
  XCTAssertFalse(self.sut.observationModeOnScreenshotEnabled);
  XCTAssertTrue(self.sut.observationModeThreeFingerTapEnabled);
  XCTAssertNotNil(self.sut.tapRecognizer);
  XCTAssertTrue(self.sut.feedbackObservationMode == BITFeedbackObservationModeThreeFingerTap);

  [self.sut setFeedbackObservationMode:BITFeedbackObservationModeAll];
  XCTAssertTrue(self.sut.observationModeOnScreenshotEnabled);
  XCTAssertTrue(self.sut.observationModeThreeFingerTapEnabled);
  XCTAssertNotNil(self.sut.tapRecognizer);
  XCTAssertTrue(self.sut.feedbackObservationMode == BITFeedbackObservationModeAll);

  [self.sut setFeedbackObservationMode:BITFeedbackObservationModeOnScreenshot];
  XCTAssertTrue(self.sut.observationModeOnScreenshotEnabled);
  XCTAssertFalse(self.sut.observationModeThreeFingerTapEnabled);
  XCTAssertNil(self.sut.tapRecognizer);
  XCTAssertTrue(self.sut.feedbackObservationMode == BITFeedbackObservationModeOnScreenshot);

  [self.sut setFeedbackObservationMode:BITFeedbackObservationModeThreeFingerTap];
  XCTAssertFalse(self.sut.observationModeOnScreenshotEnabled);
  XCTAssertTrue(self.sut.observationModeThreeFingerTapEnabled);
  XCTAssertNotNil(self.sut.tapRecognizer);
  XCTAssertTrue(self.sut.feedbackObservationMode == BITFeedbackObservationModeThreeFingerTap);


}

#pragma mark - FeedbackManagerDelegate Tests

- (void)testFeedbackComposeViewController {
  UIImage *sampleImage1 = [UIImage new];
  NSData *sampleData1 = [NSData data];
  
  self.sut.feedbackComposeHideImageAttachmentButton = YES;
  XCTAssertTrue(self.sut.feedbackComposeHideImageAttachmentButton);

  id<BITFeedbackManagerDelegate> mockDelegate = mockProtocol(@protocol(BITFeedbackManagerDelegate));
  [given([mockDelegate preparedItemsForFeedbackManager:self.sut]) willReturn:@[sampleImage1, sampleData1]];
  self.sut.delegate = mockDelegate;
  
  BITFeedbackComposeViewController *composeViewController = [self.sut feedbackComposeViewController];
  NSArray *attachments = [composeViewController performSelector:@selector(attachments)];
  XCTAssertEqual(attachments.count, (NSUInteger)2);
  
  XCTAssertTrue(composeViewController.hideImageAttachmentButton);
  id stronDelegate = composeViewController.delegate;
  XCTAssertEqual(stronDelegate, mockDelegate);
}

@end

#endif /* HOCKEYSDK_FEATURE_FEEDBACK */

