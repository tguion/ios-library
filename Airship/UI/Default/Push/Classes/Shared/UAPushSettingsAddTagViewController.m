/*
 Copyright 2009-2011 Urban Airship Inc. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 1. Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2. Redistributions in binaryform must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided withthe distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE URBAN AIRSHIP INC``AS IS'' AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 EVENT SHALL URBAN AIRSHIP INC OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "UAPushSettingsAddTagViewController.h"
#import "UAPush.h"
#import "UATagUtils.h"

enum TagSections {
    TagSectionDesc = 0,
    TagSectionCustom = 1,
    TagSectionPreset = 2,
    TagSectionRowCount = 3
};


@implementation UAPushSettingsAddTagViewController

@synthesize tagDelegate;
@synthesize tableView;
@synthesize tagCell;
@synthesize textCell;
@synthesize textLabel;
@synthesize tagField;
@synthesize presetTags;


- (void)dealloc {
    RELEASE_SAFELY(cancelButton);
    RELEASE_SAFELY(saveButton);
    
    [tableView release];
    [tagCell release];
    [textCell release];
    [textLabel release];
    [tagField release];
    
    self.presetTags = nil;
    
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"New Tag";
    
    text = @"Assign a tags to a device to simplify "
    @"the process of sending notifications. Define custom tags, or use UATagUtils to "
    @"generate commonly used tags.";
    
    tagField.text = @"";
    textLabel.text = text;
    
    if (!self.presetTags) {
        self.presetTags = [UATagUtils createTags:
                           UATagTypeCountry|UATagTypeDeviceType|UATagTypeLanguage|UATagTypeTimeZone|UATagTypeTimeZoneAbbreviation];
    }
    
    //Create an add button in the nav bar
    if (cancelButton == nil) {
        cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    }
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    if (saveButton == nil) {
        saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(save:)];
    }
    self.navigationItem.rightBarButtonItem = saveButton;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

#pragma mark -
#pragma mark UITableViewDelegate

#define kCellPaddingHeight 10

// TODO: text?
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    switch (indexPath.section) {
        case TagSectionPreset:
        case TagSectionCustom:
            return 44;
        case TagSectionDesc:
        {
            CGFloat height = [text sizeWithFont:textLabel.font
                              constrainedToSize:CGSizeMake(300, 1500)
                                  lineBreakMode:UILineBreakModeWordWrap].height;
            return height + kCellPaddingHeight * 4;
            break;
        }
        default:
            break;
    }
    return 0;
}

- (void)tableView:(UITableView *)view didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == TagSectionPreset) {
        [tagDelegate addTag:[self.presetTags objectAtIndex:indexPath.row]];
        [view deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    switch (section) {
        case TagSectionCustom:
            return @"Custom Tag";
        case TagSectionPreset:
            return @"Common Tags";
        default:
            break;
    }
    return nil;
}


#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
        case TagSectionDesc:
            return 1;
        case TagSectionCustom:
            return 1;
        case TagSectionPreset:
            return [self.presetTags count];
        default:
            break;
    }
    
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return TagSectionRowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case TagSectionDesc:
            textLabel.text = text;//TODO: necessary???
            return textCell;
        case TagSectionCustom:
            return tagCell;
        case TagSectionPreset:
        {
            UITableViewCell *cell;
            
            /////////////
            
            static NSString *CellIdentifier = @"PresetCell";
            
            cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
            
            // Configure the cell...
            
            cell.textLabel.text = [presetTags objectAtIndex:indexPath.row];
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            return cell;
        }
        default:
            break;
    }
    
    return nil;
}

#pragma mark -
#pragma mark UITextFieldDelegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}

#pragma mark -
#pragma mark Save/Cancel

- (void)save:(id)sender {
    [tagDelegate addTag:tagField.text];
    tagField.text = nil;
}

- (void)cancel:(id)sender {
    [tagDelegate cancelAddTag];
    tagField.text = nil;
}
    

@end