//
//  AudioPlayerViewController.h
//  demo_music
//
//  Created by Smallkot on 22.06.15.
//  Copyright (c) 2015 smallkot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioControlPanel.h"
#import "TrackCell.h"
#import <AVFoundation/AVAudioPlayer.h>

@interface AudioPlayerViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UISlider *sliderTrack;
@property (weak, nonatomic) IBOutlet UILabel *timeTrack;
@property (weak, nonatomic) IBOutlet UITableView *playlistTable;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

@property NSTimer *timer;

- (IBAction)playSound:(id)sender;
- (IBAction)prevSound:(id)sender;
- (IBAction)nextSound:(id)sender;
- (IBAction)setCurrentTime:(id)sender;

@end
