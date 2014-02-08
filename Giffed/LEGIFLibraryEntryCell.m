//
//  LEGIFLibraryEntryCell.m
//  Giffed
//
//  Created by Julius Parishy on 1/21/14.
//  Copyright (c) 2014 jp. All rights reserved.
//

#import "LEGIFLibraryEntryCell.h"

@implementation LEGIFLibraryEntryCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)copyToClipboardPressed:(UIButton *)button
{
    if(self.delegate)
    {
        [self.delegate libraryEntryCellShouldCopyToClipboard:self];
    }
}

- (IBAction)uploadToImgurPressed:(UIButton *)button
{
    if(self.delegate)
    {
        [self.delegate libraryEntryCellShouldUploadToImgur:self];
    }
}


@end
