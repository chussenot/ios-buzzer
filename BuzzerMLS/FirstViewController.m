//
//  FirstViewController.m
//  BuzzerMLS
//
//  Created by Clément Hussenot-Desenonges on 20/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FirstViewController.h"
#import "NSStreamAdditions.h"


@implementation FirstViewController

// vars
@synthesize data;
@synthesize iStream;
@synthesize oStream;
// components
@synthesize serverTextinput;
@synthesize serverSwitch;
@synthesize debugSwitch;
@synthesize playerControl;


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload
{
    [self setServerTextinput:nil];
    [self setServerSwitch:nil];
    [self setDebugSwitch:nil];
    [self setPlayerControl:nil];

    [super viewDidUnload];

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc
{
    [serverTextinput release];
    [serverSwitch release];
    [debugSwitch release];
    [playerControl release];
  
	[self disconnect];
	[data release];
	[iStream release];
	[oStream release];
    [super dealloc];
}


- (IBAction)playerChoice:(id)sender {
    NSLog(@"now with player ...");
}

- (IBAction)onConnectChange:(id)sender {
    NSLog(@"Connect ip : %@, player : %@, debug : %@, serverSwitch %@", serverTextinput.text,
          (playerControl.selectedSegmentIndex == 0 ? @"A" : @"B" ),
          (debugSwitch.on ? @"YES" : @"NO"),
          (serverSwitch.on ? @"YES" : @"NO")
          );
    if( serverSwitch.on )
    {
        [self connectToServerUsingStream: serverTextinput.text portNo:1025];
        debugSwitch.enabled = false;
        //pingButton.enabled = false;
        
    } else {
        [self disconnect];
        debugSwitch.enabled = true;
        //pingButton.enabled = true;
        
    }
}


- (void)connectToServerUsingStream:(NSString *)urlStr portNo:(uint)portNo {
	
    if (![urlStr isEqualToString:@""]) {
        NSURL *website = [NSURL URLWithString:urlStr];
        if (!website) {
            NSLog(@"%@ is not a valid URL", website);
            return;
        } else {
            [NSStream getStreamsToHostNamed:urlStr 
                                       port:portNo 
                                inputStream:&iStream
                               outputStream:&oStream];            
            [iStream retain];
            [oStream retain];
            
            [iStream setDelegate:self];
            [oStream setDelegate:self];
            
            [iStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                               forMode:NSDefaultRunLoopMode];
            [oStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                               forMode:NSDefaultRunLoopMode];
            
            [oStream open];
            [iStream open];            
        }
	}    
	
}

/**
 * Envoyer le buzz
 **/ 
- (void)sendBuzz:(const uint8_t *)buf { 
    
    NSUInteger written = [oStream write:buf maxLength:strlen((char*)buf)+1]; 

    if( written == -1 )
    {
        NSError *error = [oStream streamError];
        NSLog(@"Error writing data: %@", [error localizedDescription]);
    }

}


- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode {
        if( debugSwitch.on == false )
        {
        return;
        }    
        switch(eventCode) {
            case NSStreamEventHasBytesAvailable:
            {
                if (data == nil) {
                    data = [[NSMutableData alloc] init];
                }
                uint8_t buf[1024];
                unsigned int len = 0;
                len = [(NSInputStream *)stream read:buf maxLength:1024];
                if(len) {    
                    [data appendBytes:(const void *)buf length:len];
                    int bytesRead;
                    bytesRead += len;
                } else {
                    NSLog(@"No data.");
                }
                
                NSString *str = [[NSString alloc] initWithData:data 
                                                      encoding:NSUTF8StringEncoding];
                NSLog(str,nil);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"From server" 
                                                                message:str 
                                                               delegate:self 
                                                      cancelButtonTitle:@"OK" 
                                                      otherButtonTitles:nil];
                [alert show];
                [alert release];
                
                [str release];
                [data release];        
                data = nil;
            } break;
        }   
    
}

-(void) disconnect {
    [iStream close];
    [oStream close];
}

- (IBAction)onDebugChange:(id)sender {
    NSLog(@"Debug");
}

- (IBAction)onEditEnd:(id)sender {
    [sender resignFirstResponder];
}

- (IBAction)testBuzz:(id)sender {
    NSString *message = [NSString stringWithFormat:@"<ping player='%@' />", 
                         playerControl.selectedSegmentIndex == 0 ? @"A" : @"B" ];
    const uint8_t *str = (uint8_t *) [message cStringUsingEncoding:NSASCIIStringEncoding];
    [self sendBuzz:str];  
}
- (IBAction)disEndOnExit:(id)sender {
}
@end
