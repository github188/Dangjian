//
//  EGORefreshTableHeaderView.m
//  Demo
//
//  Created by Devin Doty on 10/14/09October14.
//  Copyright 2009 enormego. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "BaseHeaderView.h"


#define TEXT_COLOR	 RGB(171,109,17)
#define FLIP_ANIMATION_DURATION 0.18f
#define REFRESH_HEIGHT 60.0f

@interface BaseHeaderView (Private)
- (void)setState:(EGOPullRefreshState_DO)aState;
@end

@implementation BaseHeaderView

@synthesize delegate=_delegate;


- (id)initWithFrame:(CGRect)frame isHeader:(BOOL)header{
    if (self = [super initWithFrame:frame]) {
		_isHeader = header;
        
        
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		//self.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
        self.backgroundColor = RGB(229, 216, 192);
        
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 30.0f, self.frame.size.width, 20.0f)];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.font = [UIFont systemFontOfSize:12.0f];
		label.textColor = TEXT_COLOR;
		//label.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
		//label.shadowOffset = CGSizeMake(0.0f, 1.0f);
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = UITextAlignmentCenter;
		[self addSubview:label];
		_lastUpdatedLabel=label;
		[label release];
		
		label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 48.0f, self.frame.size.width, 20.0f)];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.font = [UIFont boldSystemFontOfSize:13.0f];
		label.textColor = TEXT_COLOR;
		label.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
		label.shadowOffset = CGSizeMake(0.0f, 1.0f);
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = UITextAlignmentCenter;
		[self addSubview:label];
		_statusLabel=label;
		[label release];
		
		CALayer *layer = [CALayer layer];
		layer.frame = CGRectMake(25.0f, frame.size.height - REFRESH_HEIGHT, 30.0f, 55.0f);
		layer.contentsGravity = kCAGravityResizeAspect;
		layer.contents = (id)[UIImage imageNamed:@""].CGImage;
		
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
		if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
			layer.contentsScale = [[UIScreen mainScreen] scale];
		}
#endif
		
		[[self layer] addSublayer:layer];
		_arrowImage=layer;
        if (header==NO) {
            _arrowImage.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
        }
		UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		view.frame = CGRectMake(25.0f, frame.size.height - 38.0f, 20.0f, 20.0f);
		[self addSubview:view];
		_activityView = view;
		[view release];
        
		
		[self setState:EGOOPullRefreshNormal_DO];
        
    }
	
    return self;
	
}


#pragma mark -
#pragma mark Setters

- (void)refreshLastUpdatedDate {
	
	if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceLastUpdated:)]) {
		
		NSDate *date = [_delegate egoRefreshTableHeaderDataSourceLastUpdated:self];
		
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setAMSymbol:@"上午"];
		[formatter setPMSymbol:@"下午"];
		[formatter setDateFormat:@"MM/dd/yyyy hh:mm:ss"];
		_lastUpdatedLabel.text = [NSString stringWithFormat:@"最后更新: %@", [formatter stringFromDate:date]];
		[[NSUserDefaults standardUserDefaults] setObject:_lastUpdatedLabel.text forKey:@"EGORefreshTableView_LastRefresh"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		[formatter release];
		
	} else {
		
		_lastUpdatedLabel.text = nil;
		
	}
    
}

- (void)setState:(EGOPullRefreshState_DO)aState{
	
	switch (aState) {
		case EGOOPullRefreshPulling_DO:
			
			_statusLabel.text = NSLocalizedString(@"释放以更新", @"Release to refresh status");
			[CATransaction begin];
			[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
            if (_isHeader) {
                _arrowImage.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
            }else{
                _arrowImage.transform = CATransform3DIdentity;
            }
			
			[CATransaction commit];
			
			break;
		case EGOOPullRefreshNormal_DO:
			
            [_activityView stopAnimating];
            [CATransaction begin];
            [CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
            if (_isHeader) {
                _arrowImage.transform = CATransform3DIdentity;
                _statusLabel.text = NSLocalizedString(@"下拉刷新", @"Pull down to refresh status");
            }
            else{
                _arrowImage.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
                _statusLabel.text = NSLocalizedString(@"上拉加载更多", @"Pull up to load more ");
            }
			_arrowImage.hidden = NO;
			[CATransaction commit];
			[self refreshLastUpdatedDate];
			
			break;
		case EGOOPullRefreshLoading_DO:
			
			_statusLabel.text = NSLocalizedString(@"加载中...", @"Loading Status");
			[_activityView startAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
			_arrowImage.hidden = YES;
			[CATransaction commit];
			
			break;
		default:
			break;
	}
	
	_state = aState;
}


#pragma mark -
#pragma mark ScrollView Methods

- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView {
    if (_isHeader) {
        if (_state == EGOOPullRefreshLoading_DO) {
            
            CGFloat offset = MAX(scrollView.contentOffset.y * -1, 0);
            offset = MIN(offset, REFRESH_HEIGHT);
            scrollView.contentInset = UIEdgeInsetsMake(offset, 0.0f, 0.0f, 0.0f);
            
        } else if (scrollView.isDragging) {
            
            BOOL _loading = NO;
            if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceIsLoading:)]) {
                _loading = [_delegate egoRefreshTableHeaderDataSourceIsLoading:self];
            }
            
            if (_state == EGOOPullRefreshPulling_DO && scrollView.contentOffset.y > -(REFRESH_HEIGHT+5.0f) && scrollView.contentOffset.y < 0.0f && !_loading) {
                [self setState:EGOOPullRefreshNormal_DO];
            } else if (_state == EGOOPullRefreshNormal_DO && scrollView.contentOffset.y < -(REFRESH_HEIGHT+5.0f) && !_loading) {
                [self setState:EGOOPullRefreshPulling_DO];
            }
            
            if (scrollView.contentInset.top != 0) {
                scrollView.contentInset = UIEdgeInsetsZero;
            }
            
        }
        
    }else{
        if (_state == EGOOPullRefreshLoading_DO) {
            
            CGFloat offset = MAX(scrollView.contentOffset.y * -1, 0);
            offset = MIN(offset, REFRESH_HEIGHT);
            scrollView.contentInset = UIEdgeInsetsMake(offset, 0.0f, 0.0f, 0.0f);
            
        } else if (scrollView.isDragging) {
            
            BOOL _loading = NO;
            if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceIsLoading:)]) {
                _loading = [_delegate egoRefreshTableHeaderDataSourceIsLoading:self];
            }
            if (_state == EGOOPullRefreshPulling_DO && scrollView.contentOffset.y+self.frame.size.height > self.frame.origin.y && scrollView.contentOffset.y < REFRESH_HEIGHT+5.0f && !_loading) {
                [self setState:EGOOPullRefreshNormal_DO];
            } else if (_state == EGOOPullRefreshNormal_DO && scrollView.contentOffset.y+self.frame.size.height < self.frame.origin.y && !_loading) {
                [self setState:EGOOPullRefreshPulling_DO];
            }
            
            if (scrollView.contentInset.top != 0) {
                scrollView.contentInset = UIEdgeInsetsZero;
            }
            
        }
        
    }
    
}

- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView {
	
	BOOL _loading = NO;
	if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceIsLoading:)]) {
		_loading = [_delegate egoRefreshTableHeaderDataSourceIsLoading:self];
	}
	
	if (scrollView.contentOffset.y <= -(REFRESH_HEIGHT+5.0f) && !_loading) {
		
		if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDidTriggerRefresh:)]) {
			[_delegate egoRefreshTableHeaderDidTriggerRefresh:self];
		}
		
		[self setState:EGOOPullRefreshLoading_DO];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
		scrollView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
		[UIView commitAnimations];
		
	}
    if (scrollView.contentOffset.y+self.frame.size.height <= self.frame.origin.y && !_loading) {
        if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDidTriggerRefresh:)]) {
			[_delegate egoRefreshTableHeaderDidTriggerRefresh:self];
		}
		
		[self setState:EGOOPullRefreshLoading_DO];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
		scrollView.contentInset = UIEdgeInsetsMake(REFRESH_HEIGHT, 0.0f, 0.0f, 0.0f);
		[UIView commitAnimations];
    }
	
}

- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView {
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
    if (_isHeader) {
        [scrollView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
    }
    
	[UIView commitAnimations];
	[self setState:EGOOPullRefreshNormal_DO];
    
    
}


#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
	
	_delegate=nil;
	_activityView = nil;
	_statusLabel = nil;
	_arrowImage = nil;
	_lastUpdatedLabel = nil;
    [super dealloc];
}


@end
