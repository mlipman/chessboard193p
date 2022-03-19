//
//  ViewController.m
//  FinalProject
//
//  Created by Michael Lipman on 5/25/14.
//  Copyright (c) 2014 mouthy. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UIScrollViewDelegate>

@property (strong, nonatomic) NSMutableArray *boxesArray; // States, which are UIViews
@property (strong, nonatomic) NSMutableArray *selectedPoints; // NSNumbers indicating array index in pointsArray

@property (weak, nonatomic) IBOutlet UIView *nebraska;
@property (nonatomic) int level;

@property (weak, nonatomic) IBOutlet UISegmentedControl *compControl;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;


@end

@implementation ViewController


# pragma mark - Loading

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpScrollView:self.scrollview];
    self.nebraska.backgroundColor = nil;
    [self newGameAtLevel:0];


}

- (void)newGameAtLevel:(int)level
{
    [[self.nebraska subviews]
        makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.scrollview.zoomScale = 1.0;
    self.boxesArray = nil;
    self.selectedPoints = nil;
    self.level = level;
    [self drawSquaresAddTo:self.boxesArray withView:self.nebraska andLevel:self.level];
    [self updateUI];
}

- (void)updateUI
{
    for (UIButton *any_button in self.boxesArray) {
        any_button.backgroundColor = [UIColor blackColor];
        any_button.layer.borderColor = [UIColor greenColor].CGColor;
        any_button.layer.borderWidth = 0;
    }
    
    
    for (NSNumber *selectedPointIndex in self.selectedPoints) {
        id thing = self.boxesArray[[selectedPointIndex integerValue]];
        if (![thing isKindOfClass:[UIView class]]) [NSException raise:@"23454" format:@""];
        UIView *selectedButton = (UIView *)thing;
        
        selectedButton.layer.borderWidth = 5.0;
        
        for (NSNumber *neighborInd in [self getNeighborIndeciesForPointAtIndex:selectedPointIndex]) {
            id thing = self.boxesArray[[neighborInd integerValue]];
            if (![thing isKindOfClass:[UIView class]]) [NSException raise:@"2674" format:@""];
            UIView *reachableButton = (UIView *)thing;
            
            reachableButton.backgroundColor = [UIColor redColor];
        }
    }
    
}


# pragma mark - Helpers

- (void)drawSquaresAddTo:(NSMutableArray *)boxesArray withView:(UIView *)view andLevel:(int)level
{
    static const float distance = 0.4;
    float remainder = 1-distance;
    CGSize sz = view.frame.size;
    CGRect LL = CGRectMake(0, 0, distance*sz.width, distance*sz.height);
    CGRect LR = CGRectMake(remainder*sz.width, 0, distance*sz.width, distance*sz.height);
    CGRect UL = CGRectMake(0, remainder*sz.height, distance*sz.width, distance*sz.height);
    CGRect UR = CGRectMake(remainder*sz.width, remainder*sz.height, 0.4*sz.width, 0.4*sz.height);
    
    CGRect corners[4] = {LL, LR, UL, UR};
    
    for (int i=0; i<4; i++) {
        if (level==0) {
            UIView *lilSquare = [[UIView alloc] initWithFrame:corners[i]];
            lilSquare.backgroundColor = [UIColor redColor];
            [view addSubview:lilSquare];
            [boxesArray addObject:lilSquare];
            
            UITapGestureRecognizer *singleFingerTap =
            [[UITapGestureRecognizer alloc] initWithTarget:self
                                                    action:@selector(handleSingleTap:)];
            [lilSquare addGestureRecognizer:singleFingerTap];
            
        } else {
            UIView *miniState = [[UIView alloc] initWithFrame:corners[i]];
            [self drawSquaresAddTo:boxesArray withView:miniState andLevel:level-1];
            [view addSubview:miniState];
        }
        
    }
}



-(NSArray *) getNeighborIndeciesForPointAtIndex:(NSNumber *)num
{
    int start = (int)[num integerValue];
    int dim = 2 +2*self.level;
    //NSLog(@"dim: %d, 2^dim:%d", dim ,(int)pow(2,dim));
    if (start>pow(2,dim)-1) [NSException raise:@"Bad index" format:@""];
    NSMutableArray *neighbors = [[NSMutableArray alloc] init];
    for (int i=0; i<dim; i++) {
        int twotothedim = pow(2,i);
        int nay = start ^ twotothedim;
        NSNumber *num = [[NSNumber alloc] initWithInt:nay];
        [neighbors addObject:num];
    }
    return neighbors; // NSArray of NSNumbers
}


# pragma mark - UIHandlers

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    UIView *sender = recognizer.view;
    NSUInteger ind = [self.boxesArray indexOfObject:sender];
    if (ind==NSNotFound) [NSException raise:@"Can't find button" format:@""];
    NSNumber *numIndex = [NSNumber numberWithUnsignedInteger:ind];
    
    BOOL buttonAlreadySelected = [self.selectedPoints containsObject:numIndex];
    
    int dim = 2 +2*self.level;
    int spotspercoins = ((int)pow(2, dim))/dim;

    if (buttonAlreadySelected) {
        [self.selectedPoints removeObject:numIndex];
    } else if([self.selectedPoints count]<spotspercoins) { // only select if they haven't select too many
        [self.selectedPoints addObject:numIndex];
    }
    
    [self updateUI];

}

- (IBAction)changeComp:(UISegmentedControl *)sender {
    int seg = (int)[sender selectedSegmentIndex];
    int dim;
    if (seg==0) {
        dim=0;
    } else if (seg==1) {
        dim=1;
    } else if (seg==2) {
        dim=3;
    } else {
        [NSException raise:@"Unrecognized segment" format:@""];
    }
    [self newGameAtLevel:dim];
    
}



# pragma mark - Lazy Instantiation

- (NSMutableArray *)selectedPoints
{
    if (!_selectedPoints) _selectedPoints = [[NSMutableArray alloc] init];
    return _selectedPoints;
}

- (NSMutableArray *)boxesArray
{
    if (!_boxesArray) _boxesArray = [[NSMutableArray alloc] init];
    return _boxesArray;
}

# pragma mark - ScrollView

-(void)setUpScrollView:(UIScrollView *)scrollView
{
    self.scrollview.delegate = self;
    self.scrollview.minimumZoomScale = 1.0;
    self.scrollview.maximumZoomScale = 10.0;
    self.scrollview.zoomScale = 1.0;
    self.scrollview.contentSize = self.view.frame.size;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.nebraska;
}

@end
