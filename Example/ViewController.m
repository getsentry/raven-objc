//
//  ViewController.m
//  Raven
//
//  Created by Kevin Renskers on 25-05-12.
//  Copyright (c) 2012 Gangverk. All rights reserved.
//

#import "ViewController.h"
#import "RavenClient.h"


@interface ViewController ()
@property (strong, nonatomic) NSMutableArray *status;
@end


@implementation ViewController

@synthesize tableView = _tableView;
@synthesize status = _status;

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.status = [NSMutableArray array];
    NSLog(@"RavenClient: %@", [RavenClient sharedClient]);
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}

#pragma mark - Public methods

- (void)addStatus:(NSString *)status {
    [self.status addObject:status];
    [self.tableView reloadData];
}

- (IBAction)sendMessage {
    [self addStatus:@"Sending message..."];
    RavenCaptureMessage(@"TEST %i %@ %f", 1, @"2", 3.0);
}

- (IBAction)generateException {
    [self addStatus:@"Generating exception..."];
    [self performSelector:@selector(nonExistingSelector)];
}

- (IBAction)sendError {
    NSError *error;
    RavenCaptureError(error);
}

- (IBAction)sendException {
    NSException *exception;
    RavenCaptureException(exception);
}

#pragma mark - UITableViewDelegate
// Nothing...

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.status count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StatusCell"];
    cell.textLabel.text = [self.status objectAtIndex:indexPath.row];
    return cell;
}

@end
