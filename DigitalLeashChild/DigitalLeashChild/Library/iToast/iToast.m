/*

iToast.m

MIT LICENSE

Copyright (c) 2011 Guru Software

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/


#import "iToast.h"
#import <QuartzCore/QuartzCore.h>

#define CURRENT_TOAST_TAG 6984678

static const CGFloat kComponentPadding = 5;

static iToastSettings *sharedSettings = nil;

@interface iToast ()

@property(nonatomic, copy) NSString *text;
@property(nonatomic, strong) UIButton *view;
@property (nonatomic, strong, readwrite) iToastSettings *settings;

@end


@implementation iToast


- (id) initWithText:(NSString *) tex{
	if (self = [super init]) {
		self.text = [tex copy];
	}
	
	return self;
}

- (void) show{
	[self show:iToastTypeNone];
}

- (void) show:(iToastType) type {
	
	iToastSettings *theSettings = _settings;
	
	if (!theSettings) {
		theSettings = [iToastSettings getSharedSettings];
	}
	
	UIImage *image = [theSettings.images valueForKey:[NSString stringWithFormat:@"%ld", type]];
	
	UIFont *font = [UIFont systemFontOfSize:theSettings.fontSize];

    NSAttributedString *attributedText =[[NSAttributedString alloc] initWithString:self.text attributes:@{ NSFontAttributeName: font}];
    CGRect rect = [attributedText boundingRectWithSize:CGSizeMake(280, 60)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    CGSize textSize = rect.size;
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, textSize.width + kComponentPadding, textSize.height + kComponentPadding)];
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor whiteColor];
	label.font = font;
	label.text = self.text;
	label.numberOfLines = 0;
	if (theSettings.useShadow) {
		label.shadowColor = [UIColor darkGrayColor];
		label.shadowOffset = CGSizeMake(1, 1);
	}
	
	UIButton *v = [UIButton buttonWithType:UIButtonTypeCustom];
	if (image) {
		v.frame = [self _toastFrameForImageSize:image.size withLocation:[theSettings imageLocation] andTextSize:textSize];
        
        switch ([theSettings imageLocation]) {
            case iToastImageLocationLeft:
                [label setTextAlignment:NSTextAlignmentLeft];
                label.center = CGPointMake(image.size.width + kComponentPadding * 2 
                                           + (v.frame.size.width - image.size.width - kComponentPadding * 2) / 2, 
                                           v.frame.size.height / 2);
                break;
            case iToastImageLocationTop:
                [label setTextAlignment:NSTextAlignmentCenter];
                label.center = CGPointMake(v.frame.size.width / 2, 
                                           (image.size.height + kComponentPadding * 2 
                                            + (v.frame.size.height - image.size.height - kComponentPadding * 2) / 2));
                break;
            default:
                break;
        }
		
	} else {
		v.frame = CGRectMake(0, 0, textSize.width + kComponentPadding * 2, textSize.height + kComponentPadding * 2);
		label.center = CGPointMake(v.frame.size.width / 2, v.frame.size.height / 2);
	}
	CGRect lbfrm = label.frame;
	lbfrm.origin.x = ceil(lbfrm.origin.x);
	lbfrm.origin.y = ceil(lbfrm.origin.y);
	label.frame = lbfrm;
	[v addSubview:label];
#if !__has_feature(objc_arc)
	[label release];
#endif
	
	if (image) {
		UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
		imageView.frame = [self _frameForImage:type inToastFrame:v.frame];
    [v addSubview:imageView];
#if !__has_feature(objc_arc)
    [imageView release];
#endif
	}
	
  v.backgroundColor = [UIColor colorWithRed:theSettings.bgRed green:theSettings.bgGreen blue:theSettings.bgBlue alpha:theSettings.bgAlpha];
	v.layer.cornerRadius = theSettings.cornerRadius;
	
	UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
	
	CGPoint point = CGPointZero;
	
  if (theSettings.gravity == iToastGravityTop) {
    point = CGPointMake(window.frame.size.width / 2, 45);
  } else if (theSettings.gravity == iToastGravityBottom) {
    point = CGPointMake(window.frame.size.width / 2, window.frame.size.height - 45);
  } else if (theSettings.gravity == iToastGravityCenter) {
    point = CGPointMake(window.frame.size.width/2, window.frame.size.height/2);
  } else {
    point = theSettings.postition;
  }

	v.center = CGPointMake(point.x + theSettings.offsetLeft, point.y + theSettings.offsetTop);
	v.frame = CGRectIntegral(v.frame);
	
	NSTimer *timer1 = [NSTimer timerWithTimeInterval:((float)theSettings.duration)/1000 
											 target:self selector:@selector(hideToast:) 
										   userInfo:nil repeats:NO];
	[[NSRunLoop mainRunLoop] addTimer:timer1 forMode:NSDefaultRunLoopMode];
	
	v.tag = CURRENT_TOAST_TAG;

	UIView *currentToast = [window viewWithTag:CURRENT_TOAST_TAG];
	if (currentToast != nil) {
    	[currentToast removeFromSuperview];
	}

	v.alpha = 0;
	[window addSubview:v];
	[UIView beginAnimations:nil context:nil];
	v.alpha = 1;
	[UIView commitAnimations];

#if !__has_feature(objc_arc)
	self.view = [v retain];
#else
  self.view = v;
#endif
	
	[v addTarget:self action:@selector(hideToast:) forControlEvents:UIControlEventTouchDown];
}

- (CGRect)_toastFrameForImageSize:(CGSize)imageSize withLocation:(iToastImageLocation)location andTextSize:(CGSize)textSize {
    CGRect theRect = CGRectZero;
    switch (location) {
        case iToastImageLocationLeft:
            theRect = CGRectMake(0, 0, 
                                 imageSize.width + textSize.width + kComponentPadding * 3, 
                                 MAX(textSize.height, imageSize.height) + kComponentPadding * 2);
            break;
        case iToastImageLocationTop:
            theRect = CGRectMake(0, 0, 
                                 MAX(textSize.width, imageSize.width) + kComponentPadding * 2, 
                                 imageSize.height + textSize.height + kComponentPadding * 3);
            
        default:
            break;
    }    
    return theRect;
}

- (CGRect)_frameForImage:(iToastType)type inToastFrame:(CGRect)toastFrame {
    iToastSettings *theSettings = _settings;
    if (!theSettings) {
      theSettings = [iToastSettings getSharedSettings];
    }
    UIImage *image = [theSettings.images valueForKey:[NSString stringWithFormat:@"%ld", type]];
    
    if (!image) return CGRectZero;
    
    CGRect imageFrame = CGRectZero;

    switch ([theSettings imageLocation]) {
        case iToastImageLocationLeft:
            imageFrame = CGRectMake(kComponentPadding, (toastFrame.size.height - image.size.height) / 2, image.size.width, image.size.height);
            break;
        case iToastImageLocationTop:
            imageFrame = CGRectMake((toastFrame.size.width - image.size.width) / 2, kComponentPadding, image.size.width, image.size.height);
            break;
            
        default:
            break;
    }
    
    return imageFrame;
    
}

- (void) hideToast:(NSTimer*)theTimer{
	[UIView beginAnimations:nil context:NULL];
	self.view.alpha = 0;
	[UIView commitAnimations];
	
	NSTimer *timer2 = [NSTimer timerWithTimeInterval:500 
											 target:self selector:@selector(hideToast:) 
										   userInfo:nil repeats:NO];
	[[NSRunLoop mainRunLoop] addTimer:timer2 forMode:NSDefaultRunLoopMode];
}

- (void) removeToast:(NSTimer*)theTimer{
	[self.view removeFromSuperview];
}


+ (iToast *) makeText:(NSString *) _text{
  iToast *toast;
  
#if !__has_feature(objc_arc)
    toast = [[[iToast alloc] initWithText:_text] autorelease];
#else
    toast = [[iToast alloc] initWithText:_text];
#endif
	
	return toast;
}


- (iToast *) setDuration:(NSInteger ) duration{
	self.settings.duration = duration;
	return self;
}

- (iToast *) setGravity:(iToastGravity) gravity 
			 offsetLeft:(NSInteger) left
			  offsetTop:(NSInteger) top{
	self.settings.gravity = gravity;
	self.settings.offsetLeft = left;
	self.settings.offsetTop = top;
	return self;
}

- (iToast *) setGravity:(iToastGravity) gravity{
	self.settings.gravity = gravity;
	return self;
}

- (iToast *) setPosition:(CGPoint) _position{
	self.settings.postition = CGPointMake(_position.x, _position.y);
	
	return self;
}

- (iToast *) setFontSize:(CGFloat) fontSize{
	self.settings.fontSize = fontSize;
	return self;
}

- (iToast *) setUseShadow:(BOOL) useShadow{
	self.settings.useShadow = useShadow;
	return self;
}

- (iToast *) setCornerRadius:(CGFloat) cornerRadius{
	self.settings.cornerRadius = cornerRadius;
	return self;
}

- (iToast *) setBgRed:(CGFloat) bgRed{
	self.settings.bgRed = bgRed;
	return self;
}

- (iToast *) setBgGreen:(CGFloat) bgGreen{
	self.settings.bgGreen = bgGreen;
	return self;
}

- (iToast *) setBgBlue:(CGFloat) bgBlue{
	self.settings.bgBlue = bgBlue;
	return self;
}

- (iToast *) setBgAlpha:(CGFloat) bgAlpha{
	self.settings.bgAlpha = bgAlpha;
	return self;
}


-(iToastSettings *) settings{
	if (!_settings) {
		_settings = [[iToastSettings getSharedSettings] copy];
	}
	
	return _settings;
}

@end


@implementation iToastSettings
@synthesize offsetLeft;
@synthesize offsetTop;
@synthesize duration;
@synthesize gravity;
@synthesize postition;
@synthesize fontSize;
@synthesize useShadow;
@synthesize cornerRadius;
@synthesize bgRed;
@synthesize bgGreen;
@synthesize bgBlue;
@synthesize bgAlpha;
@synthesize images;
@synthesize imageLocation;

- (void) setImage:(UIImage *) img withLocation:(iToastImageLocation)location forType:(iToastType) type {
	if (type == iToastTypeNone) {
		// This should not be used, internal use only (to force no image)
		return;
	}
	
	if (!images) {
		images = [[NSMutableDictionary alloc] initWithCapacity:4];
	}
	
	if (img) {
		NSString *key = [NSString stringWithFormat:@"%ld", type];
		[images setValue:img forKey:key];
	}
    
    [self setImageLocation:location];
}

- (void)setImage:(UIImage *)img forType:(iToastType)type {
    [self setImage:img withLocation:iToastImageLocationLeft forType:type];
}


+ (iToastSettings *) getSharedSettings{
	if (!sharedSettings) {
		sharedSettings = [iToastSettings new];
		sharedSettings.gravity = iToastGravityCenter;
		sharedSettings.duration = iToastDurationShort;
		sharedSettings.fontSize = 16.0;
		sharedSettings.useShadow = YES;
		sharedSettings.cornerRadius = 5.0;
		sharedSettings.bgRed = 0;
		sharedSettings.bgGreen = 0;
		sharedSettings.bgBlue = 0;
		sharedSettings.bgAlpha = 0.7;
		sharedSettings.offsetLeft = 0;
    sharedSettings.offsetTop = 0;
    [sharedSettings setImage:[UIImage imageNamed:@"info"] forType:iToastTypeInfo];
    [sharedSettings setImage:[UIImage imageNamed:@"warning"] forType:iToastTypeWarning];
    [sharedSettings setImage:[UIImage imageNamed:@"error"] forType:iToastTypeError];
    [sharedSettings setImage:[UIImage imageNamed:@"notice"] forType:iToastTypeNotice];
	}
	
	return sharedSettings;
	
}

- (id) copyWithZone:(NSZone *)zone{
	iToastSettings *copy = [iToastSettings new];
	copy.gravity = self.gravity;
	copy.duration = self.duration;
	copy.postition = self.postition;
	copy.fontSize = self.fontSize;
	copy.useShadow = self.useShadow;
	copy.cornerRadius = self.cornerRadius;
	copy.bgRed = self.bgRed;
	copy.bgGreen = self.bgGreen;
	copy.bgBlue = self.bgBlue;
	copy.bgAlpha = self.bgAlpha;
	copy.offsetLeft = self.offsetLeft;
	copy.offsetTop = self.offsetTop;
	
	NSArray *keys = [self.images allKeys];
	
	for (NSString *key in keys){
		[copy setImage:[images valueForKey:key] forType:[key intValue]];
	}
    
    [copy setImageLocation:imageLocation];
	
	return copy;
}

@end
