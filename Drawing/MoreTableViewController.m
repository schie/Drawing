//
//  MoreTableViewController.m
//  Drawing
//
//  Created by Dustin Schie on 10/26/14.
//  Copyright (c) 2014 Dustin Schie. All rights reserved.
//

#import "MoreTableViewController.h"

#import "SharedSettings.h"

#import <Social/Social.h>


@interface MoreTableViewController ()
@property (strong, nonatomic) SharedSettings *sharedSettings;
@end

@implementation MoreTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self setSharedSettings:[SharedSettings sharedSettings]];
    if (![[self delegate] conformsToProtocol: @protocol(MoreTableViewControllerDelegate)]
        || ![[self delegate] respondsToSelector:@selector(moreTableViewControllerIsDone:)])
    {
        // set buttons to unselectable
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ([indexPath section]) {
        case 0:
            [cell setBackgroundColor:[UIColor colorWithRed:255 green:255 blue:255 alpha:0.7f]];
            [[cell contentView] setBackgroundColor:[UIColor clearColor]];
            break;
        default:
            [cell setBackgroundColor:[UIColor clearColor]];
            [[cell contentView] setBackgroundColor:[UIColor clearColor]];
            break;
    }
}

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}

//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    return 0;
//}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)savePhoto:(UIButton *)sender
{
    if ([[self delegate] conformsToProtocol: @protocol(MoreTableViewControllerDelegate)]
        && [[self delegate] respondsToSelector:@selector(moreTableViewControllerIsDone:)])
    {
        [[self delegate] moreTableViewControllerSavePhoto:self];
    }
}

- (IBAction)snapShot:(UIButton *)sender
{
    
}

- (IBAction)shareImage:(id)sender
{
    /**
     * 0 - facebook
     * 1 - twitter
     * 2 - email
     * 3 - sms
     */
    switch ([sender tag])
    {
        case 0:
            [self sendToSocial:SLServiceTypeFacebook];
            break;
        case 1:
            [self sendToSocial:SLServiceTypeTwitter];
            break;
        case 2:
            
            break;
        case 3:
            
            break;
        default:
            break;
    }
}

- (IBAction)done:(id)sender
{
    if ([[self delegate] conformsToProtocol: @protocol(MoreTableViewControllerDelegate)]
        && [[self delegate] respondsToSelector:@selector(moreTableViewControllerIsDone:)])
    {
        [[self delegate] moreTableViewControllerIsDone:self];
    }
}

- (IBAction)hostSession:(id)sender
{
    if ([[self delegate] conformsToProtocol: @protocol(MoreTableViewControllerDelegate)]
        && [[self delegate] respondsToSelector:@selector(moreTableViewController:hostSessionButtonPressed:)])
    {
        [[self delegate] moreTableViewController:self hostSessionButtonPressed:(UIButton *)sender];
    }
}

- (void) sendToSocial:(NSString *) sLServiceType
{
    if ([SLComposeViewController isAvailableForServiceType:sLServiceType])
    {
        SLComposeViewController *compose = [SLComposeViewController composeViewControllerForServiceType:sLServiceType];
        [compose setInitialText:@"Check out what I made with the app, Drawing!"];
        [compose addImage:[[self sharedSettings] boardImage]];
        [self presentViewController:compose animated:YES completion:nil];
        
    }
}

@end
