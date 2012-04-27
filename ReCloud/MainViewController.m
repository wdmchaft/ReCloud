//
//  MainViewController.m
//  ReCloud
//
//  Created by hanl on 12-4-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MainViewController.h"
#import "RecordingViewController.h"
#import "PlaybackViewController.h"
#import "MAlertView.h"
#import "Constants.h"
#import "AppDelegate.h"

@implementation MainViewController

@synthesize myTableView;
@synthesize editLabel;
@synthesize audioList;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void) dealloc{
    self.audioList = nil;
    self.editLabel = nil;
    
    [super dealloc];
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"%s", __FUNCTION__);    
    
    viewingLocal = YES;   
    
    [self initLayout];    
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@"%s", __FUNCTION__);
    
    [self refreshAudioList];
    [myTableView reloadData];
}

- (void)viewDidUnload
{
    self.myTableView = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewDidUnload];    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UITableView DataSource Methods

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(audioList != nil && audioList.count > 0){
        return audioList.count;
    }
    return 0;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"%s", __FUNCTION__);
    
    static NSString *cellIdentifier = @"mainViewCell";    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"MainViewCell" owner:self options:nil] lastObject];
    } 
    
    if(audioList != nil && audioList.count > 0){
        NSDictionary *dict = [audioList objectAtIndex:indexPath.row];
        
        UILabel *timeLabel = (UILabel *)[cell.contentView viewWithTag:TAG_TIME_LABEL];
        UILabel *dateLabel = (UILabel *)[cell.contentView viewWithTag:TAG_DATE_LABEL];
        UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:TAG_TITLE_LABEL];
        UILabel *durationLabel = (UILabel *)[cell.contentView viewWithTag:TAG_DURATION_LABEL];
        UILabel *sizeLabel = (UILabel *)[cell.contentView viewWithTag:TAG_SIZE_LABEL];
        
        UIButton *editButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [editButton setTitle:@"E" forState:UIControlStateNormal];
        editButton.tag = BASE_TAG_EDIT_BUTTON + indexPath.row;
        editButton.frame = CGRectMake(240, 11, 30, 25);
        [cell.contentView addSubview:editButton];
        
        UIButton *uploadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [uploadButton setTitle:@"U" forState:UIControlStateNormal];
        uploadButton.tag = BASE_TAG_UPLOAD_BUTTON + indexPath.row;
        uploadButton.frame = CGRectMake(285, 11, 30, 25);
        [cell.contentView addSubview:uploadButton];
        
        timeLabel.text = [dict objectForKey:kTime];
        dateLabel.text = [dict objectForKey:kDate];
        titleLabel.text = [dict objectForKey:kTitle];
        durationLabel.text = [dict objectForKey:kDuration];
        sizeLabel.text = [NSString stringWithFormat:@"%@MB", [dict objectForKey:kSize]];
        [editButton addTarget:self action:@selector(editTitle:) forControlEvents:UIControlEventTouchUpInside];
        [uploadButton addTarget:self action:@selector(uploadToCloud:) forControlEvents:UIControlEventTouchUpInside];
    }

    
    return cell;
}

-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        NSLog(@"%s", __FUNCTION__);
        
        NSString *filename = [[audioList objectAtIndex:indexPath.row] objectForKey:kFilename];
        NSString *filePrefix = [[NSString alloc] initWithFormat:@"%@", [[filename componentsSeparatedByString:@"."] objectAtIndex:0]];
        [audioList removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade]; 
        
        NSFileManager *filemanager = [NSFileManager defaultManager];
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        NSString *audioFile = [[[appDelegate documentPath] stringByAppendingPathComponent:AUDIO_DIR] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.pcm", filePrefix]];
        NSString *plistFile = [[[appDelegate documentPath] stringByAppendingPathComponent:INDEX_DIR] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", filePrefix]];
        [filemanager removeItemAtPath:audioFile error:nil];
        [filemanager removeItemAtPath:plistFile error:nil];

    }    
}

#pragma mark - UITableView Delegate Methods

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];    
    
    PlaybackViewController *playbackVC = [[PlaybackViewController alloc] initWithAudioInfo:[audioList objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:playbackVC animated:YES];
    //[playbackVC release]; //这里release时，进入playbackVC-> 退出 -> 进入recordingVC，会导致崩溃。why？
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

#pragma mark - UIView Animation Callback Methods

-(void) removeEditingView{
    [editingView removeFromSuperview];
    editingView = nil;
}

#pragma mark - Instance Methods

-(IBAction) showRecordingView:(id)sender{    
    [self doneEditingAction:nil];
    
    RecordingViewController *recordingVC = [[RecordingViewController alloc] init];
    [self.navigationController pushViewController:recordingVC animated:YES];
    //[recordingVC release];    
}

-(void) editAction:(id)sender{    
    [myTableView setEditing:YES animated:YES];    
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"done" style:UIBarButtonItemStyleBordered target:self action:@selector(doneEditingAction:)];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    [leftButtonItem release];
}

-(void) doneEditingAction:(id)sender{
    [myTableView setEditing:NO animated:YES];
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"edit" style:UIBarButtonItemStyleBordered target:self action:@selector(editAction:)];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    [leftButtonItem release];
}

-(void) loginAction:(id)sender{
    editLabel.text = @"edit";
    [self doneEditingAction:nil];
    
    /*
    [audioList addObject:@""];
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
    [myTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationMiddle];
     */
    
    MAlertView *alertView = [[MAlertView alloc] initWithTitle:@"" message:nil delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [alertView addTextField:[[[UITextField alloc] init] autorelease] placeHolder:@"Account"];
    [alertView addTextField:[[[UITextField alloc] init] autorelease] placeHolder:@"Password"];
    [alertView show];
    [alertView release];
    
}

-(IBAction) viewCloud:(id)sender{
    [self doneEditingAction:nil];
    
    if(viewingLocal){
        //从云端下载数据
        self.audioList = nil;
        [myTableView reloadData];
        viewingLocal = NO;
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil 
                                                            message:@"请先登陆" 
                                                           delegate:nil 
                                                  cancelButtonTitle:@"知道了" 
                                                  otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
    }
}

-(IBAction) viewLocal:(id)sender{
    [self doneEditingAction:nil];
    
    if(!viewingLocal){        
        //浏览本地文件
        [self refreshAudioList];        
        [myTableView reloadData];        
        viewingLocal = YES;
    }
}

-(void) refreshAudioList{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    NSString *indexPath = [[appDelegate documentPath] stringByAppendingPathComponent:INDEX_DIR];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *fileList = [fileManager contentsOfDirectoryAtPath:indexPath error:nil];
    
    NSMutableArray *newArr = [[NSMutableArray alloc] init];
    for(NSString *file in fileList){
        NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:[indexPath stringByAppendingPathComponent:file]];
        [newArr insertObject:dict atIndex:0];
        [dict release];
    }    
    self.audioList = newArr;
    [newArr release];
    //NSLog(@"newArr count: %@", newArr);
    NSLog(@"audioList count: %d", audioList.count);
    
}

-(void) editTitle:(id)sender{
    UIButton *clicked = (UIButton *)sender;
    NSLog(@"editButton: %d", clicked.tag);
    editingIndex = clicked.tag - BASE_TAG_EDIT_BUTTON;
    UITableViewCell *editingCell = [myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:editingIndex inSection:0]];
    UILabel *titleLabel = (UILabel *)[editingCell.contentView viewWithTag:TAG_TITLE_LABEL];
    
    editingView = [[[NSBundle mainBundle] loadNibNamed:@"EditingView" owner:self options:nil] lastObject];
    editingView.alpha = 0;
    editingView.frame = CGRectMake(0.0, 20.0, editingView.frame.size.width, editingView.frame.size.height);
    
    UITextView *textView = (UITextView *)[editingView viewWithTag:TAG_EDITVIEW_TEXTVIEW];
    textView.text = titleLabel.text;
    [textView becomeFirstResponder];
    
    UIButton *okButton = (UIButton *)[editingView viewWithTag:TAG_EDITVIEW_OK_BUTTON];
    [okButton addTarget:self action:@selector(confirmEditing:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *cancelButton = (UIButton *)[editingView viewWithTag:TAG_EDITVIEW_CANCEL_BUTTON];
    [cancelButton addTarget:self action:@selector(cancelEditing:) forControlEvents:UIControlEventTouchUpInside];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.window addSubview:editingView];
    [UIView animateWithDuration:0.5 animations:^{
        editingView.alpha = 1.0;
    }];
    
}

-(void) cancelEditing:(id)sender{
    [UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(removeEditingView)];
    editingView.alpha = 0.0;
    [UIView commitAnimations];
}

-(void) confirmEditing:(id)sender{    
    UITableViewCell *editingCell = [myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:editingIndex inSection:0]];
    UILabel *titleLabel = (UILabel *)[editingCell.contentView viewWithTag:TAG_TITLE_LABEL];
    UITextView *textView = (UITextView *)[editingView viewWithTag:TAG_EDITVIEW_TEXTVIEW];
    titleLabel.text = textView.text;
    [textView resignFirstResponder];
    
    NSMutableDictionary *dict = [[audioList objectAtIndex:editingIndex] mutableCopy];
    [dict setObject:textView.text forKey:kTitle];    
    [audioList replaceObjectAtIndex:editingIndex withObject:dict];
    [dict release];
    
    NSString *temp = [[[dict objectForKey:kFilename] componentsSeparatedByString:@"."] objectAtIndex:0];
    NSString *filename = [NSString stringWithFormat:@"%@.plist", temp];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSString *filePath = [[[appDelegate documentPath] stringByAppendingPathComponent:INDEX_DIR] stringByAppendingPathComponent:filename];
    [dict writeToFile:filePath atomically:YES];    
    
    [self cancelEditing:nil];
}



-(void) uploadToCloud:(id)sender{
    
}

-(void) initLayout{
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"edit" style:UIBarButtonItemStyleBordered target:self action:@selector(editAction:)];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    [leftButtonItem release];
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"login" style:UIBarButtonItemStyleBordered target:self action:@selector(loginAction:)];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    [rightButtonItem release];
}

@end
