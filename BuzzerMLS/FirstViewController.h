//
//  FirstViewController.h
//  BuzzerMLS
//
//  Created by Clément Hussenot-Desenonges on 20/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FirstViewController : UIViewController
<NSStreamDelegate>
{
    
	NSMutableData *data;
	
	NSInputStream *iStream;
	NSOutputStream *oStream;
    UITextField *serverTextinput;
    UISwitch *serverSwitch;
    UISwitch *debugSwitch;
    UISegmentedControl *playerControl;
    UIButton *pindButton;
	
	UITextField *txtMessage;
}
- (IBAction)onEditEnd:(id)sender;

- (IBAction)testBuzz:(id)sender;

@property (nonatomic, retain) NSMutableData *data;
- (IBAction)disEndOnExit:(id)sender;
@property (nonatomic, retain) NSInputStream *iStream;
@property (nonatomic, retain) NSOutputStream *oStream;
@property (nonatomic, retain) IBOutlet UITextField *serverTextinput;
@property (nonatomic, retain) IBOutlet UISwitch *serverSwitch;
@property (nonatomic, retain) IBOutlet UISwitch *debugSwitch;
@property (nonatomic, retain) IBOutlet UISegmentedControl *playerControl;


- (void)sendBuzz:(const uint8_t *)buf;
- (void)connectToServerUsingStream:(NSString *)urlStr portNo:(uint)portNo;
- (void) disconnect;

- (IBAction)playerChoice:(id)sender;
- (IBAction)onConnectChange:(id)sender;
- (IBAction)onDebugChange:(id)sender;

@end
