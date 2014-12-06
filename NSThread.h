
#import <Foundation/Foundation.h>

@interface NSThread (Extended)

- (void) callMethod:(SEL)selector target:(NSObject *)target asynchronous:(BOOL)asynchronous;

@end
