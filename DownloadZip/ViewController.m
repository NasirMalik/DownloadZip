//
//  ViewController.m
//  DownloadZip
//
//  Created by Nasir Mahmood on 11/04/2013.
//  Copyright (c) 2013 Shinnx. All rights reserved.
//   nasir.malik44@gmail.com
//

#import "ViewController.h"
#define DOWNLOAD_LINK @"https://dl.dropbox.com/key/Images.zip?dl=1"
#import "ZipArchive.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [activity startAnimating];
    NSURL *serverURL = [NSURL URLWithString:DOWNLOAD_LINK];
    NSURLRequest *request = [NSURLRequest requestWithURL:serverURL];
    NSURLConnection *cn = [NSURLConnection connectionWithRequest:request delegate:self];
    [cn start];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - NSURLConnection Delegate Methods
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"%s",__FUNCTION__);
    responseData = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"%s",__FUNCTION__);
    responseData = [[NSMutableData alloc] initWithCapacity:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"%s",__FUNCTION__);
    [responseData appendData:data];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"%s",__FUNCTION__);
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDirPath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSString *filePath = [docDirPath stringByAppendingPathComponent:@"DownloadedZip.zip"];
    
    // Save file to Document Directory
    [responseData writeToFile:filePath atomically:YES];
    responseData = nil;
    
    ZipArchive *zip = [[ZipArchive alloc] init];
    [zip UnzipOpenFile:filePath];
    [zip UnzipFileTo:docDirPath overWrite:YES];
    [zip UnzipCloseFile];
    [zip release];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:[docDirPath stringByAppendingPathComponent:@"DownloadedZip.zip"] error:NULL];
    [activity stopAnimating];

    
    
    
   NSMutableArray* arrayOfImages = [[NSMutableArray alloc]init];
    NSError *error = nil;
    
    
    NSString *stringPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    stringPath=[stringPath stringByAppendingPathComponent:@"Images"];
    NSArray *filePathsArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:stringPath  error:&error];
    
    for(int i=0;i<[filePathsArray count];i++)
    {
        NSString *strFilePath = [filePathsArray objectAtIndex:i];
        if ([[strFilePath pathExtension] isEqualToString:@"jpg"] || [[strFilePath pathExtension] isEqualToString:@"png"] || [[strFilePath pathExtension] isEqualToString:@"PNG"])
        {
            NSString* imagePath=[NSString stringWithFormat:@"%@/%@",stringPath,strFilePath];
            NSData *data = [NSData dataWithContentsOfFile:imagePath];
            if(data)
            {
                UIImage *image = [UIImage imageWithData:data];
                [arrayOfImages addObject:image];
            }
        }
        
    }

    
    imageView.animationImages=arrayOfImages;
    imageView.animationDuration=1.2f;
    imageView.animationRepeatCount = 0;
    [imageView startAnimating];

}


- (void)dealloc {
    [imageView release];
    [activity release];
    [super dealloc];
}
@end
