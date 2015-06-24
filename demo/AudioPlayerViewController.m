//
//  AudioPlayerViewController.m
//  demo_music
//
//  Created by Smallkot on 22.06.15.
//  Copyright (c) 2015 smallkot. All rights reserved.
//

#import "AudioPlayerViewController.h"

@interface AudioPlayerViewController ()
    @property long count_tracks;
    @property (strong, nonatomic) NSArray *trackLinks;
    @property (nonatomic, strong) AVAudioPlayer *audioPlayer;
    @property long current_track;
@end

@implementation AudioPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *pathToFile = [[NSBundle mainBundle] pathForResource:@"playlist" ofType:@"txt"];
    NSString *sourceOfInput = [NSString stringWithContentsOfFile:pathToFile encoding:NSUTF8StringEncoding error:nil];
    _trackLinks = [sourceOfInput componentsSeparatedByString: @"\n" ];
    _count_tracks = _trackLinks.count;
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *createMusic = [NSHomeDirectory() stringByAppendingString:@"/Music"];
    [fm createDirectoryAtPath:createMusic withIntermediateDirectories:YES attributes:nil error:nil];
    _current_track = 0;
    self.timeTrack.text = @"0:00";
    _isPlay = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _count_tracks;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TrackCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TrackCell"];
    [cell.LoadingIndicator startAnimating];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSURL*url = [NSURL URLWithString:_trackLinks[indexPath.row]];
    NSString *fileName = url.pathComponents[url.pathComponents.count-1];
    NSString *path = [NSHomeDirectory() stringByAppendingString:@"/Music"];
    NSString *music_path = [path stringByAppendingPathComponent:fileName];
    
    if([fm fileExistsAtPath:music_path] == NO)
    {
        cell.LoadingLabel.hidden = NO;
        cell.LoadingIndicator.hidden = NO;
        cell.LoadingLabel.text = _trackLinks[indexPath.row];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData* data = [[NSData alloc] initWithContentsOfURL:url];
            [data writeToFile:music_path atomically:YES];
            dispatch_async(dispatch_get_main_queue(), ^
                           {
                               [cell.LoadingIndicator stopAnimating];
                               NSString* trackTitle = [self getTrackTitle:[NSURL fileURLWithPath:music_path]];
                               if([trackTitle isEqualToString:@""])
                                   cell.TrackLabel.text = fileName;
                               else
                                   cell.TrackLabel.text = trackTitle;
                               cell.LoadingIndicator.hidden = YES;
                               cell.LoadingLabel.hidden = YES;
                           });
        });
    }
    else
    {
        [cell.LoadingIndicator stopAnimating];
        cell.LoadingIndicator.hidden = YES;
        cell.LoadingLabel.hidden = YES;
        
        NSString* trackTitle = [self getTrackTitle:[NSURL fileURLWithPath:music_path]];
        if([trackTitle isEqualToString:@""])
            cell.TrackLabel.text = fileName;
        else
            cell.TrackLabel.text = trackTitle;
    }
    
    return cell;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    [self playSoundToIndex:indexPath.row];
    _current_track = indexPath.row;
}

- (NSURL*) urlSoundFromDirectory:(NSString*)directory fileSound:(NSString*) fileSound
{
    NSString *path = [NSHomeDirectory() stringByAppendingString:directory];
    NSString *music_path = [path stringByAppendingPathComponent:fileSound];
    NSURL *url = [NSURL fileURLWithPath:music_path];
    return url;
}

- (IBAction)playSound:(id)sender {
    if(_audioPlayer)
    {
        if ([_audioPlayer isPlaying] == YES)
        {
            [_audioPlayer pause];
            [self.playButton setBackgroundImage:[UIImage imageNamed:@"play.png"]
                                       forState:UIControlStateNormal];
            _isPlay = NO;
        }
        else
        {
            [_audioPlayer play];
            [self.playButton setBackgroundImage:[UIImage imageNamed:@"pause.png"]
                                       forState:UIControlStateNormal];
            _isPlay = YES;
        }
    }
}

- (IBAction)prevSound:(id)sender {
    if(_audioPlayer && _audioPlayer.isPlaying)
    {
        int track_number = _current_track-1;
        do
        {
            if (track_number < 0)
            {
                track_number = _trackLinks.count - 1;
            }
            
            if([self playSoundToIndex:track_number] == YES)
            {
                _current_track = track_number;
                break;
            }
            _current_track--;
        }while(track_number!=_current_track);
    }
}

- (IBAction)nextSound:(id)sender {
    if(_audioPlayer && _audioPlayer.isPlaying)
    {
        [self nextPlaySound];
    }
}

- (void) nextPlaySound
{
    if(_audioPlayer)
    {
        int track_number = _current_track+1;
        do
        {
            if (track_number >= _trackLinks.count)
            {
                track_number = 0;
            }
            
            if([self playSoundToIndex:track_number] == YES)
            {
                _current_track = track_number;
                break;
            }
            _current_track++;
        }while(track_number!=_current_track);
    }
}

- (IBAction)setCurrentTime:(id)sender
{
    [NSTimer scheduledTimerWithTimeInterval:0.01
                                     target:self
                                   selector:@selector(updateTime:)
                                   userInfo:nil
                                    repeats:NO];
    
    [self.audioPlayer setCurrentTime:self.sliderTrack.value];
}

- (BOOL) playSoundToIndex:(int) trackNumber
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSURL*urlTrackLink = [NSURL URLWithString:_trackLinks[trackNumber]];
    NSString *fileName = urlTrackLink.pathComponents[urlTrackLink.pathComponents.count-1];
    NSString *path = [NSHomeDirectory() stringByAppendingString:@"/Music"];
    NSString *music_path = [path stringByAppendingPathComponent:fileName];
    
    if([fm fileExistsAtPath:music_path] == YES)
    {
        urlTrackLink = [NSURL fileURLWithPath:music_path];
        [self play:urlTrackLink];

        return YES;
    }
    return NO;
}

- (void)updateTime:(NSTimer *)timer {
    if (_isPlay == YES) {
        self.sliderTrack.value = [self.audioPlayer currentTime];
        self.timeTrack.text = [NSString stringWithFormat:@"%@",
                                 [self timeFormat:[self.audioPlayer currentTime]]];
        
        if (![self.audioPlayer isPlaying]) {
            //[self.playButton setBackgroundImage:[UIImage imageNamed:@"play.png"]                                   forState:UIControlStateNormal];
            //[self.audioPlayer pause];
            [self nextPlaySound];
        }
    }
}

-(NSString*)timeFormat:(float)value{
    
    float minutes = floor(lroundf(value)/60);
    float seconds = lroundf(value) - (minutes * 60);
    
    int roundedSeconds = lroundf(seconds);
    int roundedMinutes = lroundf(minutes);
    
    NSString *time = [[NSString alloc]
                      initWithFormat:@"%d:%02d",
                      roundedMinutes, roundedSeconds];
    return time;
}

- (void)play:(NSURL*)urlFile
{
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:urlFile error:nil];
    [self.audioPlayer play];
    self.sliderTrack.maximumValue = [self.audioPlayer duration];
    self.timeTrack.text = @"0:00";
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                  target:self
                                                selector:@selector(updateTime:)
                                                userInfo:nil
                                                 repeats:YES];
    [self.playButton setBackgroundImage:[UIImage imageNamed:@"pause.png"]
                               forState:UIControlStateNormal];
    _isPlay = YES;
}

-(NSString*)getTrackTitle:(NSURL*)fileUrl
{
    NSString* trackTitle = @"";
    NSString* artist = @"";
    NSString* title = @"";
    AVURLAsset *mp3Asset=[AVURLAsset URLAssetWithURL:fileUrl options:nil];
    for (NSString *format in [mp3Asset availableMetadataFormats])
    {
        for (AVMetadataItem *metadataItem in [mp3Asset metadataForFormat:format])
        {
            if ([metadataItem.commonKey isEqualToString:@"title"])
            {
                title = [NSString stringWithString:(NSString *)metadataItem.value];
            }

            if ([metadataItem.commonKey isEqualToString:@"artist"])
            {
                artist = [NSString stringWithString:(NSString *)metadataItem.value];
            }
        }
    }
    
    if(![artist  isEqualToString: @""] || ![title  isEqualToString: @""])
    {
        trackTitle = [trackTitle stringByAppendingString:artist];
        trackTitle = [trackTitle stringByAppendingString:@" - "];
        trackTitle = [trackTitle stringByAppendingString:title];
    }
    
    return trackTitle;
}

@end
