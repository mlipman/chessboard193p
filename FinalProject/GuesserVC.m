//
//  GuesserVC.m
//  FinalProject
//
//  Created by Michael Lipman on 6/6/14.
//  Copyright (c) 2014 mouthy. All rights reserved.
//

#import "GuesserVC.h"

@interface GuesserVC ()
@property (weak, nonatomic) IBOutlet UITextView *gameStatus;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (strong, nonatomic) NSString *magicLabelText;
@property (strong, nonatomic) NSArray *coins;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *coinButtons;

@property (nonatomic) int magicSquare;
// Modes:
// 0 - flip coins
// 1 - select magic square
// coin flips over
// 2 - make guess
// 3 - see result
@property (nonatomic) int mode;


@end

@implementation GuesserVC


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mode = 0;
    [self pressNewGame];
    // Do any additional setup after loading the view.
}
- (IBAction)pressNextButton {
    NSLog(@"pressed next, while mode is %d", self.mode);
    //self.magicLabel.text = self.magicLabelText; // show magic label text
    if (self.mode==0) {
        self.mode = 1;
    } else if (self.mode==1) {
        if (self.magicSquare==-1) {
            // don't advance, say need to pick a square
            self.gameStatus.text = @"You have to pick a coin to be the magic coin";
            return;
        } else {
            [self changeOneCoinInCoins];
            self.mode = 2;
        }
    }
    [self updateUI];
}

- (IBAction)pressNewGame {
    self.coins = [self getRandomCoinArray];
    self.magicSquare = -1;
    self.mode = 0;
    [self updateUI]; // draws all coins (needed) and sets button labels (needed)

}


# pragma mark - UI
- (IBAction)touchCoinButton:(UIButton *)sender {
    NSUInteger index = [self.coinButtons indexOfObject:sender];
    if (index==NSNotFound) [NSException raise:@"Can't find button" format:@""];
    int i = (int)index;
    
    
    if (self.mode==0) {
        [self manualChangeCoinsIndex:i];
        [self updateUI];
        // ANIMATE THISSSS
        
    } else if (self.mode==1) {
        // update ui to highlight magic coin
        self.magicSquare = (int)index;
        [self updateUI];
        
    } else if (self.mode==2) {
        [self checkGuess:index];
        self.mode=3;
        [self updateUI];
    }
    
}

- (void)updateUI {
    NSLog(@"updating ui");
    NSLog(@"magic square is: %d", self.magicSquare);
    self.nextButton.alpha = 1;
    // Draw all coins
    for (int i=0; i<[self.coins count]; i++) {
        UIButton *button = self.coinButtons[i];
        [button setTitle:@"" forState:UIControlStateNormal];
        button.backgroundColor = nil;
        UIImage *image;
        [self doHighlight:NO forButton:button]; // given a button, whether to highlight it
        if ([self.coins[i] intValue]) {
            image = [UIImage imageNamed:@"john"];
        } else {
            image = [UIImage imageNamed:@"tree_logo"];
            
        }
        [button setBackgroundImage:image forState:UIControlStateNormal];
    }
    
    
    if (self.mode==0) {
        self.gameStatus.text = @"Touch coins to flip them";
        [self.nextButton setTitle:@"Done" forState:UIControlStateNormal];
    } else if (self.mode==1) {
        self.gameStatus.text = @"Pick a coin to be the magic coin, hit done when you are finished";
        [self.nextButton setTitle:@"Done" forState:UIControlStateNormal];
        if (self.magicSquare >=0 && self.magicSquare < (int)[self.coins count]) {
            NSUInteger nsuindex = (unsigned long)self.magicSquare;
            UIView *magicButton = [self.coinButtons objectAtIndex:nsuindex];
            [self doHighlight:YES forButton:magicButton];
        }
        
    } else if (self.mode==2) {
        self.gameStatus.text = @"The other player must now guess which coin is the magic coin that you chose. As a small hint, one coin was flipped, but they shouldn't know which one that was.";
    } else if (self.mode==3) {
        // game status text already set
        self.nextButton.alpha = 0;
    }
    
    
}


- (void)checkGuess:(NSUInteger)index {
    // updates ui in response to a guess of index
    if (self.magicSquare==-1) return; // could die here
    [self doHighlight:YES forButton:(UIView *)[self.coinButtons objectAtIndex:index]];
    if ((int)index==self.magicSquare) {
        self.gameStatus.text = @"Correct!";
    } else {
        self.gameStatus.text = @"Incorrect";
    }
}



- (void) doHighlight:(BOOL)doit forButton:(UIView *)button {
    if (doit) {
        button.layer.borderColor = [UIColor blackColor].CGColor;
        button.layer.borderWidth = 3.0;
    } else {
        button.layer.borderWidth = 0;
    }
}


-(void) manualChangeCoinsIndex:(int)i {
    NSMutableArray *temp = [NSMutableArray arrayWithArray:self.coins];
    temp[i] = [NSNumber numberWithInt:(![self.coins[i] intValue])];
    self.coins = temp;
}











# pragma mark - big one

- (void)changeOneCoinInCoins {

    int sq = self.magicSquare;
    int startFirst = [self getPair:1 fromCoins:self.coins];
    int startSecond = [self getPair:2 fromCoins:self.coins];
    int startThird = [self getPair:3 fromCoins:self.coins];
    
    int baseFirst = [self getBaseWithMagicSquare:sq Oridnal:1];
    int baseSecond = [self getBaseWithMagicSquare:sq Oridnal:2];
    int baseThird = [self getBaseWithMagicSquare:sq Oridnal:3];
    
    int matchFirst = [self getMatchWithStart:startFirst Base:baseFirst];
    int matchSecond = [self getMatchWithStart:startSecond Base:baseSecond];
    int matchThird = [self getMatchWithStart:startThird Base:baseThird];
    
    int altFirst = [self isAlt:matchFirst];
    int altSecond = [self isAlt:matchSecond];
    int altThird = [self isAlt:matchThird];
    
    int smallFirst = [self size:matchFirst]; // 1 for big, 0 for small
    int smallSecond = [self size:matchSecond];
    int smallThird = [self size:matchThird];
    
    int numAlt = altFirst + altSecond + altThird;
    
    int pairToFlip;
    int alt;
    int coin;

    
    
    if (numAlt==0 || numAlt==3) {
        
        if (numAlt==0) {
            alt = 0;
        } else if (numAlt==3) {
            alt = 1;
        } else {
            alt=-1;
            [NSException raise:@"die num alt 0 1" format:@""];
        }
        if ([self flipAlt:sq]) alt = !alt;
        coin = [self findSixOrSevenWithAlt:alt size1:smallFirst size2:smallSecond size3:smallThird coins:self.coins];

        
        
    } else if (numAlt==1 || numAlt==2) {
        if (numAlt==1) {
            alt = 0;
            if (altFirst) pairToFlip = 0;
            else if (altSecond) pairToFlip = 1;
            else if (altThird) pairToFlip = 2;
            else [NSException raise:@"die pair to flip 1" format:@""];
        } else if (numAlt==2) {
            alt = 1;
            if (!altFirst) pairToFlip = 0;
            else if (!altSecond) pairToFlip = 1;
            else if (!altThird) pairToFlip = 2;
            else [NSException raise:@"die pair to flip 2" format:@""];
        } else {
            alt=-1;
            [NSException raise:@"die num alt 2 3" format:@""];
        }
        if ([self flipAlt:sq]) alt = !alt;

        // 0 means need small, 1 means need big
        int sizeNeeded = [self sizeNeededForPair:pairToFlip withAlt:alt size1:smallFirst size2:smallSecond size3:smallThird sixVal:[self.coins[6] intValue]];
        
        // get start to change
        int startToChange;
        if (pairToFlip==0) startToChange = startFirst;
        else if (pairToFlip==1) startToChange = startSecond;
        else if (pairToFlip==2) startToChange = startThird;
        else [NSException raise:@"die start to change" format:@""];
        
        // get base of interest
        int baseForCompare;
        if (pairToFlip==0) baseForCompare = baseFirst;
        else if (pairToFlip==1) baseForCompare = baseSecond;
        else if (pairToFlip==2) baseForCompare = baseThird;
        else [NSException raise:@"die base For Compare" format:@""];
        
        
        int changeLeft = startToChange^2;
        int changeRight = startToChange^1;
        // size of changeLeft given base
        int matchChangeLeft = [self getMatchWithStart:changeLeft Base:baseForCompare];
        int matchChangeRight = [self getMatchWithStart:changeRight Base:baseForCompare];
        int sizeLeft = [self size:matchChangeLeft];
        int sizeRight = [self size:matchChangeRight];
        if (sizeLeft==sizeRight) [NSException raise:@"die size match" format:@""];
        
        if (sizeLeft==sizeNeeded) coin = pairToFlip*2;
        else coin = pairToFlip*2+1;
        
    } else {
        [NSException raise:@"die pair to flip 3" format:@""];
    }
    
    
    
    
    
    

    
    NSMutableArray *newCoins = [[NSMutableArray alloc] initWithArray:self.coins];
    newCoins[coin] = @([newCoins[coin] intValue]==0);
    //self.coinsLabel.text = [self stringFromCoinsArray:newCoins]; // show new coins
    self.coins = newCoins;
    [self updateUI];
    
    /*(NSLog(@"magic square is: %d", sq);
     NSLog(@"bases are: %d, %d, %d", baseFirst, baseSecond, baseThird);
     NSLog(@"starts are: %d, %d, %d", startFirst, startSecond, startThird);
     NSLog(@"match one: %d", [self getMatchWithStart:startFirst Base:baseFirst]);
     NSLog(@"match two: %d", [self getMatchWithStart:startSecond Base:baseSecond]);
     NSLog(@"match three: %d", [self getMatchWithStart:startThird Base:baseThird]);*/
    
    
    
    
    
    
    
    //int ord = arc4random()%3+1; // 1 to 3
    //NSLog(@"coins: %@", coins);
    //NSLog(@"sq: %d, six is: %d", sq, [self getSixWithMagicSquare:sq]);
    
}




# pragma mark - Algorithm
- (NSArray *)getRandomCoinArray {
    NSMutableArray *coins = [[NSMutableArray alloc] initWithCapacity:8];
    for (int i=0; i<8; i++) {
        coins[i]=[NSNumber numberWithUnsignedInt:arc4random()%2];
    }
    return coins;
    
}


// Returns 0 or 1 because those are the only bases
// They can be thought of as 2 digit binary numbers
// The first digit is just always 0
- (int) getBaseWithMagicSquare:(int)sq Oridnal:(int)ord {
    if (ord==1) return 0;
    if (ord==2) return (sq%4)/2;
    if (ord==3) return (sq%2);
    [NSException raise:@"die get base" format:@""];
    return 0;
}


// Returns 1 or 0
- (int) flipAlt:(int)sq {
    // This is the bix for small, small, small (0)
    // Same as 3, 5, and 6
    return sq/4;
}

// All these return 0, 1, 2, or 3
- (int)small:(int)base {
    return base ^ 0; // base xor 11
}

- (int)big:(int)base {
    return base ^ 3; // base xor 00
}

- (int)altsmall:(int)base {
    return base ^ 1; // base xor 01
}

- (int)altbig:(int)base {
    return base ^ 2; // base xor 10
}

// Returns 0, 1, 2, or 3
- (int)getPair:(int)ord fromCoins:(NSArray *)coins {
    int l, r;
    if (ord==1)  {
        l=[coins[0] intValue];
        r=[coins[1] intValue];
    } else if (ord==2) {
        
        l=[coins[2] intValue];
        r=[coins[3] intValue];
    } else if (ord==3) {
        l=[coins[4] intValue];
        r=[coins[5] intValue];
    } else {
        l = r = 0;
        [NSException raise:@"die get pair" format:@""];
    }
    return 2*l+r;
}


// 0 is small, 1 is big, 2 is altsmall, 3 is altbig
- (int)getMatchWithStart:(int)start Base:(int)base {
    
    if (start==[self small:base]) return 0;
    if (start==[self big:base]) return 1;
    if (start==[self altsmall:base]) return 2;
    if (start==[self altbig:base]) return 3;
    [NSException raise:@"die get match" format:@""];
    return 0;
    
}

// 1 if the match is alt, else 0
- (int)isAlt:(int)match {
    return match/2;
}

// takes in a match, returns 1 for big, 0 for small
- (int)size:(int)match {
    return match%2;
}



// Returns 6 or 7
- (int)findSixOrSevenWithAlt:(int)alt size1:(int)one size2:(int)two size3:(int)three coins:(NSArray *)coins {
    if ([self sixValueWithAlt:alt size1:one size2:two size3:three]==[coins[6] intValue]) return 7;
    else return 6;
    
}

// Alt and sizes are 0 or 1
- (int)sixValueWithAlt:(int)alt size1:(int)one size2:(int)two size3:(int)three {
    return alt!=(one==(two==three));
    
}

// return 0 if pair should be small, 1 if pair should be big
- (int) sizeNeededForPair:(int)pair withAlt:(int)alt size1:(int)one size2:(int)two size3:(int)three sixVal:(int)six{
    int needSmall, needBig;
    if (pair==0) {
        needSmall = [self sixValueWithAlt:alt size1:0 size2:two size3:three]==six;
        needBig = [self sixValueWithAlt:alt size1:1 size2:two size3:three]==six;
    } else if (pair==1) {
        needSmall = [self sixValueWithAlt:alt size1:one size2:0 size3:three]==six;
        needBig = [self sixValueWithAlt:alt size1:one size2:1 size3:three]==six;
    } else if (pair==2) {
        needSmall = [self sixValueWithAlt:alt size1:one size2:two size3:0]==six;
        needBig = [self sixValueWithAlt:alt size1:one size2:two size3:1]==six;
    } else {
        [NSException raise:@"die size needed" format:@""];
        needSmall = needBig = 0;
    }
    if (needSmall==needBig) [NSException raise:@"die size needed 2" format:@""];
    return needBig;
}

- (NSString *)stringFromCoinsArray:(NSArray *)coins {
    NSString *ans = @"Coins: ";
    for (int i=0; i<8; i++) {
        ans = [ans stringByAppendingString:[NSString stringWithFormat:@" %@", coins[i]]];
    }
    return ans;
}



@end
