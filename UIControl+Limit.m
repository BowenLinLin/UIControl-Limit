//
//  UIControl+Limit.m
//  youju
//
//  Created by bowenlin on 2019/5/14.
//  Copyright © 2019年 weiwen. All rights reserved.
//

#import "UIControl+Limit.h"
#import <objc/runtime.h>
static const char *UIControl_limitEventInterval="UIControl_limitEventInterval";
static const char *UIControl_ignoreEvent="UIControl_ignoreEvent";
@implementation UIControl (Limit)
+(void)load {
    //a方法有可能是在父类中实现的,要做容错
    Method a = class_getInstanceMethod(self,@selector(sendAction:to:forEvent:));
    Method b = class_getInstanceMethod(self,@selector(swizzled_sendAction:to:forEvent:));
    BOOL didAddMethod = class_addMethod([self class],@selector(sendAction:to:forEvent:), method_getImplementation(b), method_getTypeEncoding(b));
    
    if (didAddMethod) {
        //a方法在父类中,要使用以下方法交换
        class_replaceMethod([self class], @selector(swizzled_sendAction:to:forEvent:), method_getImplementation(a), method_getTypeEncoding(a));
    }else{
        method_exchangeImplementations(a, b);
    }
}

- (void)setLimitEventInterval:(float)limitEventInterval{
    objc_setAssociatedObject(self,UIControl_limitEventInterval, @(limitEventInterval), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (float)limitEventInterval{
    return [objc_getAssociatedObject(self,UIControl_limitEventInterval) floatValue];
}

-(void)setIgnoreEvent:(BOOL)ignoreEvent{
    objc_setAssociatedObject(self,UIControl_ignoreEvent, @(ignoreEvent), OBJC_ASSOCIATION_ASSIGN);
}

-(BOOL)ignoreEvent{
    return [objc_getAssociatedObject(self,UIControl_ignoreEvent) boolValue];
}

- (void)swizzled_sendAction:(SEL)action to:(id)target forEvent:(UIEvent*)event
{
    if(self.ignoreEvent){
        NSLog(@"重复点击:%@",self);
        return;}
    if(self.limitEventInterval>0){
        self.ignoreEvent=YES;
        [self performSelector:@selector(setIgnoreEventWithNo)  withObject:nil afterDelay:self.limitEventInterval];
    }
    [self swizzled_sendAction:action to:target forEvent:event];
}

-(void)setIgnoreEventWithNo{
    self.ignoreEvent=NO;
}

@end
