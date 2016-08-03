//Edric Chen
//Snippets from applications I developed and uploaded to the app store.

/****** MEMORY BEATS start ******/
//Chooses beats from resources that start with s and some number in wav format
- (NSMutableArray *)beatChooser:(int)difficulty forInstrument:(int)instrument
{
    NSMutableArray *chosenBeats;
    NSString *temp;
    chosenBeats = [[NSMutableArray alloc] init];
    for (int i = 0; i < (difficulty); i++)
    {
        temp = [NSString stringWithFormat:@"s%d", (((arc4random() % 12) + (12 * instrument)) + 1)];
        if ([chosenBeats containsObject:temp])
        {
            NSLog(@"beatChooser: String already exists in array.");
            i = i - 1;
        }
        else
            [chosenBeats addObject:temp];
    }
    
    return chosenBeats;
}

//Randomizes colors based on the level
- (NSMutableArray *)getRandomColorsForDifficulty:(int)difficulty
{
    NSMutableArray *_randomizedColors;
    _randomizedColors = [[NSMutableArray alloc] init];
    for (int i = 0; i < difficulty; i++)
    {
        int _to;
        
        if (i == (difficulty - 1))
            _to = ((256 / 4) * (i + 1)) - 15;
        else
            _to = ((256 / 4) * (i + 1)) - 30;
        
        int _from = (256 / 4) * i;
        CGFloat _hue = (((arc4random() % (_to - _from)) + _from) / 256.0);
        
        if ([_randomizedColors containsObject:[UIColor colorWithHue:_hue saturation:1.0 brightness:1.0 alpha:1]] || _hue == 0.0 || _hue == 1.0)
        {
            NSLog(@"getRandomColorsForDifficulty: Color already exists in array.");
            i = i - 1;
        }
        else
        {
            [_randomizedColors addObject:[UIColor colorWithHue:_hue saturation:1.0 brightness:1.0 alpha:1]];
            NSLog(@"Hue: %f", _hue);
        }
    }
    return _randomizedColors;
}

//Randomizes beats based on the level
- (NSMutableArray *)soundRadomizer:(NSMutableArray *)chosenBeats forLevel:(int)currentLevel
{
    NSMutableArray *randomizedBeats;
    randomizedBeats = [[NSMutableArray alloc] init];
    int selection;
    
    for (int i = 0; i < currentLevel; i++)
    {
        selection = (arc4random() % [chosenBeats count]);
#ifdef DEBUG
    NSLog(@"soundRandomizer: %@", [chosenBeats objectAtIndex:selection]);
#endif
        [randomizedBeats addObject:[chosenBeats objectAtIndex:selection]];
    }
    return randomizedBeats;
}

//Returns a dictionary containing randomized colors and beats
- (NSDictionary *)soundRadomizer:(NSMutableArray *)chosenBeats forLevel:(int)currentLevel withColors:(NSMutableArray *)colors
{
    NSMutableArray *randomizedBeats;
    NSMutableArray *randomizedColors;
    NSDictionary *beatsAndColors;
    NSArray *keys, *objects;
    
    randomizedBeats = [[NSMutableArray alloc] init];
    randomizedColors = [[NSMutableArray alloc] init];
    int selection;
    
    for (int i = 0; i < currentLevel; i++)
    {
        selection = (arc4random() % [chosenBeats count]);
#ifdef DEBUG
        NSLog(@"soundRandomizer: %@", [chosenBeats objectAtIndex:selection]);
#endif
        [randomizedBeats addObject:[chosenBeats objectAtIndex:selection]];
        [randomizedColors addObject:[colors objectAtIndex:selection]];
    }
    keys = [NSArray arrayWithObjects:@"beats", @"colors", nil];
    objects = [NSArray arrayWithObjects:randomizedBeats, randomizedColors, nil];
    beatsAndColors = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    return beatsAndColors;
}

//Plays the beats in the randomly generated array
- (void)playBeats:(NSMutableArray*)beats
{
    //SystemSoundID _beat;
    NSError *_error;
#ifdef DEBUG
    NSLog(@"playBeats: %d", beats.count);
#endif
    for (int i = 0; i < beats.count; i++)
    {
#ifdef DEBUG
    NSLog(@"playBeats: %@", [beats objectAtIndex:i]);
#endif
        /*
        UInt32 sessionCategory = kAudioSessionCategory_AmbientSound;   
        
        AudioSessionSetProperty (
                                 kAudioSessionProperty_AudioCategory,                       
                                 sizeof (sessionCategory),                                   
                                 &sessionCategory                                            
                                 );
        
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:[beats objectAtIndex:i] ofType:@"wav"]], &_beat);
        AudioServicesPlaySystemSound(_beat);
        */
        NSURL *_beat = [[NSURL alloc]initFileURLWithPath:[[NSBundle mainBundle] pathForResource:[beats objectAtIndex:i] ofType:@"wav"]];
        patternPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:_beat error:&_error];
        [patternPlayer setDelegate:self];
        [patternPlayer prepareToPlay];
        [patternPlayer play];
        [NSThread sleepForTimeInterval:0.5];
    }
}

//Changes the color of the button based on the index of the array
- (void)changeColor:(id)sender withColors:(NSMutableArray *)colors
{
    for (int i = 0; i < colors.count; i++)
    {
        [sender setBackgroundColor:[colors objectAtIndex:i]];
        [self.view setNeedsDisplay];
        [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate: [NSDate date]];
        [NSThread sleepForTimeInterval:0.5];
    }
}

//Plays back a single beat file (a single note ie. C#,A, etc.)
- (void)playBeat: (NSString *)beat
{
    /*
    SystemSoundID _beat;
    
    UInt32 sessionCategory = kAudioSessionCategory_AmbientSound;
    
    AudioSessionSetProperty (
                             kAudioSessionProperty_AudioCategory,
                             sizeof (sessionCategory),
                             &sessionCategory
                             );
    
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:beat ofType:@"wav"]], &_beat);
    AudioServicesPlaySystemSound(_beat);
    */
    
    NSError *_error;
    NSURL *_beat = [[NSURL alloc]initFileURLWithPath:[[NSBundle mainBundle] pathForResource:beat ofType:@"wav"]];
    beatPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:_beat error:&_error];
    [beatPlayer setDelegate:self];
    [beatPlayer prepareToPlay];
    [beatPlayer play];
}

//Initializes a button based on a the randomly generated arrays of sounds and beats
- (void)buttonSetter:(NSMutableArray *)sounds withColors:(NSMutableArray *)colors
{
    NSString *temp = [[sounds objectAtIndex:0] stringByReplacingOccurrencesOfString:@"s" withString:@""];
    [_b0 setTag: [temp intValue]];
    [_b0 setBackgroundColor:[colors objectAtIndex:0]];
    temp = [[sounds objectAtIndex:1] stringByReplacingOccurrencesOfString:@"s" withString:@""];
    [_b1 setTag: [temp intValue]];
    [_b1 setBackgroundColor:[colors objectAtIndex:1]];
    temp = [[sounds objectAtIndex:2] stringByReplacingOccurrencesOfString:@"s" withString:@""];
    [_b2 setTag: [temp intValue]];
    [_b2 setBackgroundColor:[colors objectAtIndex:2]];
    temp = [[sounds objectAtIndex:3] stringByReplacingOccurrencesOfString:@"s" withString:@""];
    [_b3 setTag: [temp intValue]];
    [_b3 setBackgroundColor:[colors objectAtIndex:3]];
}

//Plays back the entirety of the beats and colors arrays
- (IBAction)playPattern:(id)sender
{
    if (_freebies > 0 )
    {
        if (!_gamePaused)
        {
            if (!_soundStarted)
            {
                _soundStarted = YES;
                bQueue = dispatch_queue_create("com.echenapps.memorybeats.changecolor", NULL);
                dispatch_async(bQueue,
                ^{
                    [self playBeats:_randomBeats];
                    _soundStarted = NO;
                });
            }
            
            if (!_colorStarted)
            {
                _colorStarted = YES;
                [_b0 setUserInteractionEnabled:NO];
                [_b1 setUserInteractionEnabled:NO];
                [_b2 setUserInteractionEnabled:NO];
                [_b3 setUserInteractionEnabled:NO];
                [_b12 setUserInteractionEnabled:NO];
                _colorTime = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(changeColor) userInfo:nil repeats:YES];
                [UIView beginAnimations:@"showOverlay" context:nil];
                [UIView setAnimationDuration:0.2];
                [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
                [_overlay setAlpha:1.0];
                [UIView commitAnimations];
                
                [_time invalidate];
                [_colorTime fire];
            }
        }
    }
    else
    {
        NSLog(@"Level: %d | Score: %d | Difficulty: %d | Freebies: %d | Current Score: %d", [[NSUserDefaults standardUserDefaults] integerForKey:@"level"], [[NSUserDefaults standardUserDefaults] integerForKey:@"score"], [[NSUserDefaults standardUserDefaults] integerForKey:@"difficulty"], [[NSUserDefaults standardUserDefaults] integerForKey:@"freebies"], _currentScore);
    }
}

/****** MEMORY BEATS end ******/

/****** ROLLOVER start ******/
//Finds when to reset a budget based on the users settings
- (void)findBudgetResetCount
{
    Budget *tempbudget = [[Budget alloc] init];
    for (int i = 0; i < _budgetList.count; i++)
    {
        tempbudget = [_budgetList objectAtIndex:i];
        
        NSDate *fromDateTime = [NSDate dateWithYear:tempbudget.year Month:tempbudget.month Day:tempbudget.day];
        NSDate *toDateTime = [NSDate dateWithYear:_year Month:_month Day:_day];
        NSDate *fromDate;
        NSDate *toDate;
        NSCalendar *calendar = [NSCalendar currentCalendar];
        [calendar rangeOfUnit:NSMonthCalendarUnit|NSDayCalendarUnit startDate:&fromDate interval:NULL forDate:fromDateTime];
        [calendar rangeOfUnit:NSMonthCalendarUnit|NSDayCalendarUnit startDate:&toDate interval:NULL forDate:toDateTime];
        NSDateComponents *difference = [calendar components:NSMonthCalendarUnit|NSDayCalendarUnit fromDate:fromDate toDate:toDate options:0];
        NSInteger occurance = [difference month];
        NSDateComponents *components =[[NSCalendar currentCalendar] components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear fromDate:fromDate];
        NSInteger fromDay = [components day];
        if (fromDay < tempbudget.customDay)
        {
            occurance = occurance + 1;
        }
        
        components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:toDate];
        NSInteger toDay = [components day];
        if (toDay > tempbudget.customDay)
        {
            occurance = occurance + 1;
        }
        
        tempbudget.count = tempbudget.count + occurance;
        tempbudget.day = _day;
        tempbudget.month = _month;
        tempbudget.year = _year;
        
        [_dbutil saveBudget:tempbudget];
    }
}


//Allows the user to edit the budget
- (IBAction)editBudget:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    
    CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
    
    if (iOSDeviceScreenSize.height == 480)
    {
        storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard35" bundle:nil];
    }
    
    EditBudgetViewController *editView = [storyboard instantiateViewControllerWithIdentifier:@"EditBudgetViewController"];
    _ebvc = editView;
    [_ebvc setBudgetID:_budgetID];
    [self.navigationController pushViewController:_ebvc animated:YES];
}

//A gradient color for visual purposes
- (CAGradientLayer*) blueGradient {
    
    UIColor *colorOne = [UIColor colorWithRed:(10/255.0) green:(10/255.0) blue:(10/255.0) alpha:1.0];
    UIColor *colorTwo = [UIColor colorWithRed:(54/255.0)  green:(161/255.0)  blue:(255/255.0)  alpha:1.0];
    
    NSArray *colors = [NSArray arrayWithObjects:(id)colorOne.CGColor, colorTwo.CGColor, nil];
    NSNumber *stopOne = [NSNumber numberWithFloat:0.0];
    NSNumber *stopTwo = [NSNumber numberWithFloat:1.0];
    
    NSArray *locations = [NSArray arrayWithObjects:stopOne, stopTwo, nil];
    
    CAGradientLayer *headerLayer = [CAGradientLayer layer];
    headerLayer.colors = colors;
    headerLayer.locations = locations;
    
    return headerLayer;
    
}

//What happens before the view appears. Sets up view.
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    _dbutil = [[DBUtil alloc] init];
    [_dbutil initDatabase];
    
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd"];
    NSString *dateString = [dateFormat stringFromDate:date];
    _day = [dateString integerValue];
    [dateFormat setDateFormat:@"MM"];
    dateString = [dateFormat stringFromDate:date];
    _month = [dateString integerValue];
    [dateFormat setDateFormat:@"YYYY"];
    dateString = [dateFormat stringFromDate:date];
    _year = [dateString integerValue];
    
    _thisBudget = [[Budget alloc] init];
    _thisBudget = [_dbutil getBudget:_budgetID];
    
    [self.navigationItem setTitle:_thisBudget.name];
    
    _thesePurchases = [[NSMutableArray alloc] init];
    _thesePurchases = [_dbutil getPurchasesWithBudgetID:_budgetID];
    _thesePurchases = [[[_thesePurchases reverseObjectEnumerator] allObjects] mutableCopy];

    [self initProgressBar];
    double tempBalance = [_thisBudget.budget doubleValue];
    Purchase *tempPurchase = [[Purchase alloc] init];
    NSMutableArray *monthPurchases = [[NSMutableArray alloc] init];
    monthPurchases = [_dbutil getPurchasesWithcDay:_thisBudget.customDay Day:_day Month:_month Year:_year WithBudgetID:_thisBudget.budgetID];
    double monthsBalance = 0.0;
    for (int i = 0; i < monthPurchases.count; i++)
    {
        tempPurchase = [monthPurchases objectAtIndex:i];
        if (tempPurchase.deposit == 1)
        {
            monthsBalance = monthsBalance + [tempPurchase.amount doubleValue];
            NSLog(@"monthsbalance = %f",monthsBalance);
        }
        else
        {
            monthsBalance = monthsBalance - [tempPurchase.amount doubleValue];
            NSLog(@"monthsbalance = %f",monthsBalance);
        }
    }
    
    NSMutableArray *allPurchases = [[NSMutableArray alloc] init];
    double rolloverAmount = 0.0;
    if (_thisBudget.rolloverN == 1 || _thisBudget.rolloverP == 1)
    {
        allPurchases = [_dbutil getPurchasesWithBudgetID:_thisBudget.budgetID];
        for (int i = 0; i < allPurchases.count; i++)
        {
            tempPurchase = [allPurchases objectAtIndex:i];
            rolloverAmount = rolloverAmount - [tempPurchase.amount doubleValue];
        }
        rolloverAmount = rolloverAmount + ([_thisBudget.budget doubleValue] * _thisBudget.count);
        rolloverAmount = rolloverAmount - monthsBalance;
        //NSLog([NSString stringWithFormat:@"%d %f",_thisBudget.budgetID,rolloverAmount]);
    }
    //NSLog(@"NRollover: %d, PRollover: %ld",(long)_thisBudget.rolloverN, (long)_thisBudget.rolloverP);
    if (_thisBudget.rolloverN == 1 && _thisBudget.rolloverP == 1)
    {
        tempBalance = tempBalance + rolloverAmount + monthsBalance;
        NSLog(@"11");
    }
    else if (_thisBudget.rolloverN == 1 && _thisBudget.rolloverP == 0)
    {
        if (rolloverAmount < 0)
        {
            tempBalance = tempBalance + rolloverAmount;
        }
        tempBalance = tempBalance + monthsBalance;
        NSLog(@"10");
    }
    else if (_thisBudget.rolloverN == 0 && _thisBudget.rolloverP == 1)
    {
        if (rolloverAmount > 0)
        {
            tempBalance = tempBalance + rolloverAmount;
        }
        tempBalance = tempBalance + monthsBalance;
        NSLog(@"01");
    }
    else
    {
        tempBalance = tempBalance + monthsBalance;
        NSLog(@"00");
    }
    [_progress setProgress:(tempBalance/[_thisBudget.budget doubleValue]) animated:animated];
    
    [_purchases reloadData];
    
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
    [_budget setText:[nf stringFromNumber:[NSNumber numberWithDouble:tempBalance]]];
}
/****** ROLLOVER end ******/