//
//  LEGIFLibraryEntryCell.h
//  Giffed
//
//  Created by Julius Parishy on 1/21/14.
//  Copyright (c) 2014 jp. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LEGIFLibraryEntryCell;

@protocol LEGIFLibraryEntryCellDelegate <NSObject>

@required

- (void)libraryEntryCellShouldCopyToClipboard:(LEGIFLibraryEntryCell *)cell;
- (void)libraryEntryCellShouldUploadToImgur:(LEGIFLibraryEntryCell *)cell;

@end

@interface LEGIFLibraryEntryCell : UITableViewCell

@property (nonatomic, assign) id<LEGIFLibraryEntryCellDelegate> delegate;

@property (nonatomic, strong) IBOutlet UIImageView *previewImageView;
@property (nonatomic, strong) IBOutlet UILabel *createdLabel;

@end
