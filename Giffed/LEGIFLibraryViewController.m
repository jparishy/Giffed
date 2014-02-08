//
//  LEGIFLibraryViewController.m
//  Giffed
//
//  Created by Julius Parishy on 1/21/14.
//  Copyright (c) 2014 jp. All rights reserved.
//

#import "LEGIFLibraryViewController.h"

#import <MobileCoreServices/MobileCoreServices.h>

#import "LEGIFLibrary.h"
#import "LEGIFLibraryEntryCell.h"

#import "LEImgurClient.h"

#define LEGIFLibraryEntryCellIdentifier (@"entry")

@interface LEGIFLibraryViewController () <LEGIFLibraryEntryCellDelegate>

@property (nonatomic, strong) LEGIFLibrary *library;
@property (nonatomic, strong) NSArray *entries;

@property (nonatomic, strong) UIView *loadingView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation LEGIFLibraryViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Library", nil);
    
    self.library = [LEGIFLibrary sharedLibrary];
    self.entries = [self.library.entries sortedArrayUsingDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"createdDate" ascending:NO] ]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.entries.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LEGIFLibraryEntryCell *cell = [tableView dequeueReusableCellWithIdentifier:LEGIFLibraryEntryCellIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    
    LEGIFLibraryEntry *entry = self.entries[indexPath.row];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MMMM dd, yyyy";
    
    cell.createdLabel.text = [dateFormatter stringFromDate:entry.createdDate];
    
    UIImage *image = [UIImage imageWithContentsOfFile:entry.filePath];
    cell.previewImageView.image = image;
    
    return cell;
}

#pragma mark - LEGIFLibraryEntryCellDelegate

- (LEGIFLibraryEntry *)entryFromCell:(LEGIFLibraryEntryCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    return self.entries[indexPath.row];
}

- (void)libraryEntryCellShouldCopyToClipboard:(LEGIFLibraryEntryCell *)cell
{
    LEGIFLibraryEntry *entry = [self entryFromCell:cell];
    NSData *data = [NSData dataWithContentsOfFile:entry.filePath];
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setData:data forPasteboardType:(NSString *)kUTTypeGIF];
    
    [self showSuccessfullyCopiedToClipboardAlert];
}

- (void)libraryEntryCellShouldUploadToImgur:(LEGIFLibraryEntryCell *)cell
{
    LEGIFLibraryEntry *entry = [self entryFromCell:cell];
    NSData *data = [NSData dataWithContentsOfFile:entry.filePath];
    
    __weak typeof(self) weakSelf = self;
    [[LEImgurClient sharedClient] uploadGIFWithData:data success:^(NSString *url) {
        
        
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setURL:[NSURL URLWithString:url]];
    
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf showSuccessfullyCopiedToClipboardAlert];
        
        [strongSelf hideLoadingView];
        
    } failure:^(NSError *error) {
        
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf handleError:error];
        
        [strongSelf hideLoadingView];
    }];
    
    [self showLoadingView];
}

- (void)showSuccessfullyCopiedToClipboardAlert
{
    NSString *title = NSLocalizedString(@"Done", nil);
    NSString *message = NSLocalizedString(@"The GIF was copied to your clipboard. Send away!", nil);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"Great, thanks!", nil) otherButtonTitles:nil];
    [alertView show];
}

- (void)handleError:(NSError *)error
{
    NSString *title = NSLocalizedString(@"Oh noes", nil);
    
    NSString *staticMessage = NSLocalizedString(@"There was a problem talking to the web server :( Here's there error if it's of any use to you:", nil);
    NSString *message = [NSString stringWithFormat:@"%@\nn\n%@", staticMessage, error.localizedDescription];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"Otay", nil) otherButtonTitles:nil];
    [alertView show];
}

- (UIView *)loadingView
{
    if(!_loadingView)
    {
        _loadingView = [[UIView alloc] initWithFrame:self.view.bounds];
        _loadingView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.75f];
        
        UIActivityIndicatorView *indicator = self.activityIndicator;
        
        CGRect frame = self.activityIndicator.frame;
        frame.origin.x = CGRectGetMidX(_loadingView.bounds) - (CGRectGetWidth(frame) / 2.0f);
        frame.origin.y = CGRectGetMidY(_loadingView.bounds) - (CGRectGetHeight(frame) / 2.0f);
       
         indicator.frame = frame;
        
        [_loadingView addSubview:indicator];    
    }
    
    return _loadingView;
}

- (UIActivityIndicatorView *)activityIndicator
{
    if(!_activityIndicator)
    {
        _activityIndicator = [[UIActivityIndicatorView alloc] init];
    }
    
    return _activityIndicator;
}

- (void)showLoadingView
{
    self.loadingView.alpha = 0.0f;
    [self.view addSubview:self.loadingView];
    
    [self.activityIndicator startAnimating];
    
    [UIView animateWithDuration:0.25f animations:^{
        
        self.loadingView.alpha = 1.0f;
    }];
}

- (void)hideLoadingView
{
    [UIView animateWithDuration:0.25f animations:^{
        
        self.loadingView.alpha = 0.25f;
    } completion:^(BOOL finished) {
        
        [self.loadingView removeFromSuperview];
        [self.activityIndicator stopAnimating];
    }];
}

@end
