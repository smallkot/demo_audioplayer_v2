//
//  TrackCell.h
//  demo_music
//
//  Created by Smallkot on 22.06.15.
//  Copyright (c) 2015 smallkot. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrackCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *TrackLabel;
@property (weak, nonatomic) IBOutlet UILabel *LoadingLabel;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *LoadingIndicator;
@end
