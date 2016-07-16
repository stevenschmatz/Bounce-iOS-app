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

#import <UIKit/UIKit.h>

#import "JSQMessages.h"
#import <Parse/Parse.h>

@interface ChatView : JSQMessagesViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate>

@property NSMutableArray *messages;
@property NSString *groupId;
@property NSTimer *timer;
@property (nonatomic, strong) PFObject *currentRequest1;
@property (nonatomic, strong) UILabel *chatPrompt;

@property (nonatomic) BOOL homepointChat;
@property (nonatomic, strong) PFObject *homepoint;
@property (nonatomic, strong) PFObject *currentRequest;

- (id)initWith:(NSString *)groupId_;
- (void)loadMessages;

@end
