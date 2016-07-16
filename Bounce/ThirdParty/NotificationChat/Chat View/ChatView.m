//
// Copyright (c) 2015 Related Code - http://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <MediaPlayer/MediaPlayer.h>
#import <Parse/Parse.h>
#import "ProgressHUD.h"
#import "AppConstant.h"
#import "camera.h"
#import "messages.h"
#import "pushnotification.h"
#import "ChatView.h"
#import "ParseManager.h"
#import "UIView+AutoLayout.h"

@interface ChatView()
{
//	NSTimer *timer;
	BOOL isLoading;

//	NSString *groupId;

	NSMutableArray *users;
	NSMutableDictionary *avatars;
//    NSMutableArray *messages;
	JSQMessagesBubbleImage *bubbleImageOutgoing;
	JSQMessagesBubbleImage *bubbleImageIncoming;
	JSQMessagesAvatarImage *avatarImageBlank;
}

@end

@implementation ChatView
@synthesize messages = messages;
@synthesize groupId = groupId;
@synthesize timer = timer;

- (id)initWith:(NSString *)groupId_ {
	self = [super init];
	groupId = groupId_;
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
    
    self.currentRequest1 = [[ParseManager getInstance] retrieveRequestUpdate:self.groupId]; // should be handled in background...
    
	users = [[NSMutableArray alloc] init];
	messages = [[NSMutableArray alloc] init];
	avatars = [[NSMutableDictionary alloc] init];

	PFUser *user = [PFUser currentUser];
	self.senderId = user.objectId;
	self.senderDisplayName = user[PF_USER_USERNAME];

	JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
	bubbleImageOutgoing = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
	bubbleImageIncoming = [bubbleFactory incomingMessagesBubbleImageWithColor:BounceRed];

	avatarImageBlank = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"chat_blank"] diameter:30.0];

	isLoading = NO;
	[self loadMessages];

	ClearMessageCounter(groupId);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
    [self saveLastMessage];
	self.collectionView.collectionViewLayout.springinessEnabled = YES;
	timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(loadMessages) userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[timer invalidate];
}

#pragma mark - Backend methods

- (void)loadMessages {
	if (isLoading == NO) {
		isLoading = YES;
		JSQMessage *message_last = [messages lastObject];
        
        if ([messages lastObject] != nil) {
            if (self.chatPrompt) {
                MAKE_A_WEAKSELF;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.chatPrompt removeFromSuperview];
                });
            }
        }
        
		PFQuery *query = [PFQuery queryWithClassName:PF_CHAT_CLASS_NAME];
		[query whereKey:PF_CHAT_GROUPID equalTo:groupId];
		if (message_last != nil) [query whereKey:PF_CHAT_CREATEDAT greaterThan:message_last.date];
		[query includeKey:PF_CHAT_USER];
		[query orderByDescending:PF_CHAT_CREATEDAT];
		[query setLimit:50];
        
		[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
			if (error == nil) {
				self.automaticallyScrollsToMostRecentMessage = NO;
				for (PFObject *object in [objects reverseObjectEnumerator])
				{
					[self addMessage:object];
				}
				if ([objects count] != 0)
				{
					[self finishReceivingMessage];
					[self scrollToBottomAnimated:NO];
                    if (self.chatPrompt) {
                        MAKE_A_WEAKSELF;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf.chatPrompt removeFromSuperview];
                        });
                    }
				}
				self.automaticallyScrollsToMostRecentMessage = YES;
			}
			else [ProgressHUD showError:@"Network error."];
			isLoading = NO;
            if ([self.messages count] == 0) {
                if (!_chatPrompt) {
                UILabel *chatPrompt = [UILabel new];
                chatPrompt.translatesAutoresizingMaskIntoConstraints = NO;
                chatPrompt.textColor = BounceSeaGreen;
                chatPrompt.numberOfLines = 0;
                chatPrompt.font = [UIFont fontWithName:@"AvenirNext-Bold" size:20];
                [self.view addSubview:chatPrompt];
                [chatPrompt kgn_pinToTopEdgeOfSuperviewWithOffset:40];
                [chatPrompt kgn_centerHorizontallyInSuperview];
                [chatPrompt sizeToFit];
                [chatPrompt kgn_sizeToWidth:self.view.frame.size.width - 50];
                self.chatPrompt = chatPrompt;
                }
                if (self.homepointChat) {
                    self.chatPrompt.text = @"Go out with your neighbors.\nPlan it here!";
                }
                else {
                    self.chatPrompt.text = @"Before you're about to leave, pick a place to meet!\n\nBe sure to remove anyone who isn't responding, before stating your location.";
                }
            }
            
		}];
        [self saveLastMessage];
	}
}

-(void) saveLastMessage {
    JSQMessage *msg = [messages lastObject];
    if ([messages lastObject] != nil) {
        self.currentRequest1[PF_REQUEST_LAST_MESSAGE] = msg.text;
        [self.currentRequest1 saveInBackground];
    }
}

- (void)addMessage:(PFObject *)object {
	JSQMessage *message;

	PFUser *user = object[PF_CHAT_USER];
	NSString *name = user[PF_USER_FULLNAME];

	PFFile *fileVideo = object[PF_CHAT_VIDEO];
	PFFile *filePicture = object[PF_CHAT_PICTURE];

	if ((filePicture == nil) && (fileVideo == nil))
	{
		message = [[JSQMessage alloc] initWithSenderId:user.objectId senderDisplayName:name date:object.createdAt text:object[PF_CHAT_TEXT]];
	}

	if (fileVideo != nil)
	{
		JSQVideoMediaItem *mediaItem = [[JSQVideoMediaItem alloc] initWithFileURL:[NSURL URLWithString:fileVideo.url] isReadyToPlay:YES];
		mediaItem.appliesMediaViewMaskAsOutgoing = [user.objectId isEqualToString:self.senderId];
		message = [[JSQMessage alloc] initWithSenderId:user.objectId senderDisplayName:name date:object.createdAt media:mediaItem];
	}

	if (filePicture != nil)
	{
		JSQPhotoMediaItem *mediaItem = [[JSQPhotoMediaItem alloc] initWithImage:nil];
		mediaItem.appliesMediaViewMaskAsOutgoing = [user.objectId isEqualToString:self.senderId];
		message = [[JSQMessage alloc] initWithSenderId:user.objectId senderDisplayName:name date:object.createdAt media:mediaItem];

		[filePicture getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
			if (error == nil) {
				mediaItem.image = [UIImage imageWithData:imageData];
				[self.collectionView reloadData];
			}
		}];
	}
	[users addObject:user];
	[messages addObject:message];
}

- (void)sendMessage:(NSString *)text Video:(NSURL *)video Picture:(UIImage *)picture
{
	PFFile *fileVideo = nil;
	PFFile *filePicture = nil;
	if (video != nil)
	{
		text = @"[Video message]";
		fileVideo = [PFFile fileWithName:@"video.mp4" data:[[NSFileManager defaultManager] contentsAtPath:video.path]];
        
		[fileVideo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
		{
			if (error != nil) [ProgressHUD showError:@"Network error."];
		}];
	}
	if (picture != nil)
	{
		text = @"[Picture message]";
		filePicture = [PFFile fileWithName:@"picture.jpg" data:UIImageJPEGRepresentation(picture, 0.6)];
        
		[filePicture saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
		{
			if (error != nil) [ProgressHUD showError:@"Picture save error."];
		}];
	}
	PFObject *object = [PFObject objectWithClassName:PF_CHAT_CLASS_NAME];
	object[PF_CHAT_USER] = [PFUser currentUser];
	object[PF_CHAT_GROUPID] = groupId;
	object[PF_CHAT_TEXT] = text;
	if (fileVideo != nil) object[PF_CHAT_VIDEO] = fileVideo;
	if (filePicture != nil) object[PF_CHAT_PICTURE] = filePicture;
    
	[object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
		if (error == nil) {
			[JSQSystemSoundPlayer jsq_playMessageSentSound];
			[self loadMessages];
		}
		else [ProgressHUD showError:@"Network error."];;
	}];
    if (!self.homepointChat) {
        if (self.currentRequest) {
            SendPushNotification(groupId, text, self.currentRequest);
        }
    }
    else {
        if (self.homepoint) {
            SendHomepointPush(self.homepoint, text, groupId); /////////// WTF???
        }
    }
	UpdateMessageCounter(groupId, text);
	[self finishSendingMessage];
    [self saveLastMessage];
}

#pragma mark - JSQMessagesViewController method overrides

- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date {
	[self sendMessage:text Video:nil Picture:nil];
    MAKE_A_WEAKSELF;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.chatPrompt removeFromSuperview];
    });
}

- (void)didPressAccessoryButton:(UIButton *)sender {
        
        UIAlertController *imageActionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        [imageActionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
            // Cancel button tappped do nothing.
            
        }]];
        
        [imageActionSheet addAction:[UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            ShouldStartCamera(self, YES);
        }]];
    
    [imageActionSheet addAction:[UIAlertAction actionWithTitle:@"Upload Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        ShouldStartPhotoLibrary(self, YES);
    }]];
    
        [imageActionSheet addAction:[UIAlertAction actionWithTitle:@"Upload Video" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            ShouldStartVideoLibrary(self, YES);
        }]];
    
    // Present action sheet.
    [self presentViewController:imageActionSheet animated:YES completion:nil];
}

#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (messages) {
        if (self.chatPrompt) {
            MAKE_A_WEAKSELF;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.chatPrompt removeFromSuperview];
            });
        }
    }
	return messages[indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
			 messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
	JSQMessage *message = messages[indexPath.item];
    [self saveLastMessage];
	if ([message.senderId isEqualToString:self.senderId]) {
		return bubbleImageOutgoing;
	}
	return bubbleImageIncoming;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
					avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
	PFUser *user = users[indexPath.item];
	if (avatars[user.objectId] == nil)
	{
		PFFile *fileThumbnail = user[PF_USER_THUMBNAIL];
        
		[fileThumbnail getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
			if (error == nil) {
				avatars[user.objectId] = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageWithData:imageData] diameter:30.0];
				[self.collectionView reloadData];
			}
		}];
		return avatarImageBlank;
	}
	else return avatars[user.objectId];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.item % 3 == 0)
	{
		JSQMessage *message = messages[indexPath.item];
		return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
	}
	return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath {
	JSQMessage *message = messages[indexPath.item];
	if ([message.senderId isEqualToString:self.senderId])
	{
		return nil;
	}

	if (indexPath.item - 1 > 0)
	{
		JSQMessage *previousMessage = messages[indexPath.item-1];
		if ([previousMessage.senderId isEqualToString:message.senderId])
		{
			return nil;
		}
	}
	return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath {
	return nil;
}

#pragma mark - UICollectionView DataSource


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return [messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
	
	JSQMessage *message = messages[indexPath.item];
	if ([message.senderId isEqualToString:self.senderId])
	{
		cell.textView.textColor = [UIColor blackColor];
	}
	else
	{
		cell.textView.textColor = [UIColor whiteColor];
	}
	return cell;
}

#pragma mark - JSQMessages collection view flow layout delegate

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
				   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.item % 3 == 0)
	{
		return kJSQMessagesCollectionViewCellLabelHeightDefault;
	}
	return 0;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
				   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath {
	JSQMessage *message = messages[indexPath.item];
	if ([message.senderId isEqualToString:self.senderId])
	{
		return 0;
	}
	
	if (indexPath.item - 1 > 0)
	{
		JSQMessage *previousMessage = messages[indexPath.item-1];
		if ([previousMessage.senderId isEqualToString:message.senderId])
		{
			return 0;
		}
	}
	return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
				   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath {
	return 0;
}

#pragma mark - Responding to collection view tap events


- (void)collectionView:(JSQMessagesCollectionView *)collectionView
				header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender {
	NSLog(@"didTapLoadEarlierMessagesButton");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView
		   atIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"didTapAvatarImageView");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath {
	JSQMessage *message = messages[indexPath.item];
	if (message.isMediaMessage)
	{
		if ([message.media isKindOfClass:[JSQVideoMediaItem class]])
		{
			JSQVideoMediaItem *mediaItem = (JSQVideoMediaItem *)message.media;
			MPMoviePlayerViewController *moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:mediaItem.fileURL];
			[self presentMoviePlayerViewControllerAnimated:moviePlayer];
			[moviePlayer.moviePlayer play];
		}
	}
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation {
	NSLog(@"didTapCellAtIndexPath %@", NSStringFromCGPoint(touchLocation));
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	NSURL *video = info[UIImagePickerControllerMediaURL];
	UIImage *picture = info[UIImagePickerControllerEditedImage];
	[self sendMessage:nil Video:video Picture:picture];
	[picker dismissViewControllerAnimated:YES completion:nil];
}

@end
