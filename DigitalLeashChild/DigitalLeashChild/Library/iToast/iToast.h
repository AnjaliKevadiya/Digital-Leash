/*

iToast.h

MIT LICENSE

Copyright (c) 2012 Guru Software

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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger , iToastGravity) {
  iToastGravityTop = 1000001,
  iToastGravityBottom,
  iToastGravityCenter
};

typedef NS_ENUM(NSInteger, iToastDuration) {
  iToastDurationLong = 10000,
  iToastDurationShort = 1000,
  iToastDurationNormal = 3000
};

typedef NS_ENUM(NSInteger , iToastType) {
  iToastTypeInfo = -100000,
  iToastTypeNotice,
  iToastTypeWarning,
  iToastTypeError,
  iToastTypeNone // For internal use only (to force no image)
};

typedef NS_ENUM(NSInteger , iToastImageLocation) {
  iToastImageLocationTop,
  iToastImageLocationLeft
};


@class iToastSettings;

@interface iToast : NSObject
@property (nonatomic, strong, readonly) iToastSettings *settings;

- (void) show;
- (void) show:(iToastType) type;
- (iToast *) setDuration:(NSInteger ) duration;
- (iToast *) setGravity:(iToastGravity) gravity
             offsetLeft:(NSInteger) left
              offsetTop:(NSInteger) top;
- (iToast *) setGravity:(iToastGravity) gravity;
- (iToast *) setPosition:(CGPoint) position;
- (iToast *) setFontSize:(CGFloat) fontSize;
- (iToast *) setUseShadow:(BOOL) useShadow;
- (iToast *) setCornerRadius:(CGFloat) cornerRadius;
- (iToast *) setBgRed:(CGFloat) bgRed;
- (iToast *) setBgGreen:(CGFloat) bgGreen;
- (iToast *) setBgBlue:(CGFloat) bgBlue;
- (iToast *) setBgAlpha:(CGFloat) bgAlpha;

+ (iToast *) makeText:(NSString *) text;

@end



@interface iToastSettings : NSObject<NSCopying>
@property(assign) NSInteger duration;
@property(assign) iToastGravity gravity;
@property(assign) CGPoint postition;
@property(assign) CGFloat fontSize;
@property(assign) BOOL useShadow;
@property(assign) CGFloat cornerRadius;
@property(assign) CGFloat bgRed;
@property(assign) CGFloat bgGreen;
@property(assign) CGFloat bgBlue;
@property(assign) CGFloat bgAlpha;
@property(assign) NSInteger offsetLeft;
@property(assign) NSInteger offsetTop;
@property(readonly) NSDictionary *images;
@property(assign) iToastImageLocation imageLocation;


- (void) setImage:(UIImage *)img forType:(iToastType) type;
- (void) setImage:(UIImage *)img withLocation:(iToastImageLocation)location forType:(iToastType)type;
+ (iToastSettings *) getSharedSettings;
						  
@end