
#import "NSThread.h"

@implementation NSThread (Extended)

- (void) callMethod:(SEL)selector target:(NSObject *)target asynchronous:(BOOL)asynchronous
{
  [target performSelector:selector onThread:self withObject:nil waitUntilDone:!asynchronous];
}

@end
