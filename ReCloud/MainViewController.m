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
#import "Constants.h"
#import "AppDelegate.h"
#import "UINavigationBar+Customized.h"

@implementation MainViewController

@synthesize myTableView;
@synthesize editLabel;
@synthesize audioList;
@synthesize guideView;

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
    lastSelectedIndex = -1;
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
    self.guideView = nil;
    
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
    NSLog(@"%s, row: %d", __FUNCTION__, indexPath.row);
    
    static NSString *cellIdentifier = @"mainViewCell";    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil){        
        cell = [[[NSBundle mainBundle] loadNibNamed:@"MainViewCell" owner:self options:nil] lastObject];
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; 
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } 
    
    if(audioList != nil && audioList.count > 0){
        NSDictionary *dict = [audioList objectAtIndex:indexPath.row];
        
        UILabel *timeLabel = (UILabel *)[cell.contentView viewWithTag:TAG_TIME_LABEL];
        UILabel *dateLabel = (UILabel *)[cell.contentView viewWithTag:TAG_DATE_LABEL];
        UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:TAG_TITLE_LABEL];
        UILabel *durationLabel = (UILabel *)[cell.contentView viewWithTag:TAG_DURATION_LABEL];
        UILabel *sizeLabel = (UILabel *)[cell.contentView viewWithTag:TAG_SIZE_LABEL];
        
        NSString *timeStr = [dict objectForKey:kTime];
        NSArray *arr = [timeStr componentsSeparatedByString:@":"];
        timeLabel.text = [NSString stringWithFormat:@"%@:%@", [arr objectAtIndex:0], [arr objectAtIndex:1]];        
        
        dateLabel.text = [dict objectForKey:kDate];
        titleLabel.text = [dict objectForKey:kTitle];
        durationLabel.text = [dict objectForKey:kDuration];
        sizeLabel.text = [NSString stringWithFormat:@"%@M", [dict objectForKey:kSize]];        
        
        UIButton *editBtn = (UIButton *)[cell.contentView viewWithTag:TAG_EDITING_BUTTON1];
        [editBtn addTarget:self action:@selector(editTitle:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *uploadBtn = (UIButton *)[cell.contentView viewWithTag:TAG_UPLOAD_BUTTON1];
        [uploadBtn addTarget:self action:@selector(uploadToCloud:) forControlEvents:UIControlEventTouchUpInside];
        
        UIImageView *hoverView = (UIImageView *)[cell.contentView viewWithTag:TAG_CELL1_HOVERVIEW];
        if(lastSelectedIndex == indexPath.row){
            hoverView.alpha = 1.0;
        }else{
            hoverView.alpha = 0.0;
        }
    }
    
    return cell;
}

-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        NSLog(@"%s", __FUNCTION__);
        
        NSString *filename = [[audioList objectAtIndex:indexPath.row] objectForKey:kFilename];
        NSString *filePrefix = [[NSString alloc] initWithFormat:@"%@", [[filename componentsSeparatedByString:@"."] objectAtIndex:0]];
        [audioList removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight]; 
        
        NSFileManager *filemanager = [NSFileManager defaultManager];
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        NSString *audioFile = [[[appDelegate documentPath] stringByAppendingPathComponent:AUDIO_DIR] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.pcm", filePrefix]];
        NSString *plistFile = [[[appDelegate documentPath] stringByAppendingPathComponent:INDEX_DIR] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", filePrefix]];
        [filemanager removeItemAtPath:audioFile error:nil];
        [filemanager removeItemAtPath:plistFile error:nil];
        
        if(audioList.count == 0){
            [UIView animateWithDuration:0.3 animations:^{
                guideView.alpha = 1.0;
            }]; 
        }
    }    
}

#pragma mark - UITableView Delegate Methods

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIImageView *hoverView = (UIImageView *)[cell.contentView viewWithTag:TAG_CELL1_HOVERVIEW];
    hoverView.alpha = 1.0;
    
    if(lastSelectedIndex >= 0 && lastSelectedIndex != indexPath.row){
        NSIndexPath *lastPath = [NSIndexPath indexPathForRow:lastSelectedIndex inSection:0];
        UITableViewCell *lastSelectedCell = [tableView cellForRowAtIndexPath:lastPath];
        UIImageView *hoverView = (UIImageView *)[lastSelectedCell.contentView viewWithTag:TAG_CELL1_HOVERVIEW];
        hoverView.alpha = 0.0;        
    }
    lastSelectedIndex = indexPath.row;
    
    PlaybackViewController *playbackVC = [[PlaybackViewController alloc] initWithAudioInfo:[audioList objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:playbackVC animated:YES];
    //[playbackVC release]; //这里release时，进入playbackVC-> 退出 -> 进入recordingVC，会导致崩溃。why？
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 49;
}

-(NSString *) tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}

#pragma mark - UIView Animation Callback Methods

-(void) removeEditingView{
    [editingView removeFromSuperview];
    editingView = nil;
}


#pragma mark - Instance Methods

-(IBAction) showRecordingView:(id)sender{    
    //[self doneEditingAction:nil];
    
    RecordingViewController *recordingVC = [[RecordingViewController alloc] init];
    recordingVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:recordingVC animated:YES];
    [recordingVC release];
}

-(void) editAction:(id)sender{    
    /*
    [myTableView setEditing:YES animated:YES];    
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"done" style:UIBarButtonItemStyleBordered target:self action:@selector(doneEditingAction:)];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    [leftButtonItem release];
     */
}

-(void) doneEditingAction:(id)sender{
    /*
    [myTableView setEditing:NO animated:YES];
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"edit" style:UIBarButtonItemStyleBordered target:self action:@selector(editAction:)];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    [leftButtonItem release];
     */
}


-(void) loginAction:(id)sender{
    /*
    editLabel.text = @"edit";
    [self doneEditingAction:nil];
    
    MAlertView *alertView = [[MAlertView alloc] initWithTitle:@"" message:nil delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [alertView addTextField:[[[UITextField alloc] init] autorelease] placeHolder:@"Account"];
    [alertView addTextField:[[[UITextField alloc] init] autorelease] placeHolder:@"Password"];
    [alertView show];
    [alertView release];
     */
    
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
    
    if(audioList.count == 0){
        [UIView animateWithDuration:0.3 animations:^{
            guideView.alpha = 1.0;
        }];        
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            guideView.alpha = 0.0;
        }]; 
    }

    NSLog(@"audioList count: %d", audioList.count);
    
}

-(void) editTitle:(id)sender{
    UIButton *clicked = (UIButton *)sender;    
    UITableViewCell *cell = (UITableViewCell *)[[clicked superview] superview];
    NSIndexPath *path = [myTableView indexPathForCell:cell];
    editingIndex = path.row;
    
    NSLog(@"editingIndex: %d", editingIndex); 
    
    UITableViewCell *editingCell = [myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:editingIndex inSection:0]];
    UILabel *titleLabel = (UILabel *)[editingCell.contentView viewWithTag:TAG_TITLE_LABEL];
    
    editingView = [[[NSBundle mainBundle] loadNibNamed:@"EditingView" owner:self options:nil] lastObject];
    editingView.alpha = 0;
    editingView.frame = CGRectMake(0.0, 0.0, editingView.frame.size.width, editingView.frame.size.height);
    
    UITextView *textView = (UITextView *)[editingView viewWithTag:TAG_EDITVIEW_TEXTVIEW];
    textView.text = titleLabel.text;
    [textView becomeFirstResponder];
    
    UIButton *okButton = (UIButton *)[editingView viewWithTag:TAG_EDITVIEW_OK_BUTTON];
    [okButton addTarget:self action:@selector(confirmEditing:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *cancelButton = (UIButton *)[editingView viewWithTag:TAG_EDITVIEW_CANCEL_BUTTON];
    [cancelButton addTarget:self action:@selector(cancelEditing:) forControlEvents:UIControlEventTouchUpInside];
    
    //AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [self.view addSubview:editingView];
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
    UIButton *clicked = (UIButton *)sender;
    UITableViewCell *cell = (UITableViewCell *)[[clicked superview] superview];
    NSIndexPath *path = [myTableView indexPathForCell:cell];
    NSLog(@"row %d click!", path.row);
}

-(void) initLayout{    
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    /*
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"edit" style:UIBarButtonItemStyleBordered target:self action:@selector(editAction:)];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    [leftButtonItem release];
     */
    
    /*
    UIButton *settingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [settingBtn setImage:[UIImage imageNamed:@"button_setting.png"] forState:UIControlStateNormal];
    [settingBtn setImage:[UIImage imageNamed:@"button_setting_hover.png"] forState:UIControlStateHighlighted];
    [settingBtn addTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
    settingBtn.frame = CGRectMake(0, 0, 36, 28);
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:settingBtn];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    [rightButtonItem release];    
     */;
    
    UIImageView *logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]];
    logoView.frame = CGRectMake(0, 0, 61, 18);
    self.navigationItem.titleView = logoView;
    [logoView release];
    
}


@end