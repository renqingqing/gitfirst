//
//  ViewController.m
//  MyMapTest4
//
//  Created by 杨 国俊 on 15/9/17.
//  Copyright (c) 2015年 sdzy. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=@"地图";
    self.mapView=[[MKMapView alloc] initWithFrame:CGRectMake(0, 64, 400, 600)];
    [self.view addSubview:self.mapView];
}

-(void)viewWillAppear:(BOOL)animated
{
//    通过地点查找位置  经度和纬度
  /*  CLGeocoder *geocoder=[[CLGeocoder alloc] init];
   [geocoder geocodeAddressString:@"南京理工大学泰州科技学院"
     completionHandler:^(NSArray *placemarks, NSError *error) {
         if (error) {
             NSLog(@"%@",error.localizedDescription);
         }
         else
         {
             for (CLPlacemark *placemark in placemarks) {
                 CLLocationCoordinate2D coordinate= placemark.location.coordinate;
                 NSLog(@"%.4f,%.4f",coordinate.latitude,coordinate.longitude);
                 NSDictionary *dic=[placemark addressDictionary];
                 NSLog(@"%@",dic[@"Country"]);
                 NSLog(@"%@",dic[@"State"]);
                 NSLog(@"%@",dic[@"City"]);
                 NSLog(@"%@",dic[@"SubLocality"]);
                 NSLog(@"%@",dic[@"FormattedAddressLines"]);
                 NSArray *addr=dic[@"FormattedAddressLines"];
                 NSLog(@"%@",addr[0]);
                
                 
                 MKPointAnnotation *annotation=[[MKPointAnnotation alloc] init];
                 annotation.coordinate=coordinate;
                 annotation.title=placemark.name;
                 annotation.subtitle=placemark.subLocality;
                 [self.mapView addAnnotation:annotation];
            [self.mapView selectAnnotation:annotation animated:YES];
                 
                 [self.mapView setRegion:MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake( 0.003,0.003)) animated:YES];
             }
         }
         }];
    */
    
    
//    通过经度和纬度查找地点
    /*
    CLGeocoder *geocoder=[[CLGeocoder alloc] init];
    CLLocationCoordinate2D coordinateToBeFound = CLLocationCoordinate2DMake(32.462856, 119.940759);
    CLLocation *location = [[CLLocation alloc] initWithLatitude:32.462856 longitude:119.940759];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error)
        {
            NSLog(@"Error: %@", [error localizedDescription]);
        }
        else
        {
            for (CLPlacemark *placemark in placemarks)
            {
                CLLocationCoordinate2D coordinate = coordinateToBeFound;
                NSLog(@"%.4f, %.4f", coordinate.latitude, coordinate.longitude);
    // 创建标注
                MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
                annotation.coordinate = coordinate;
                annotation.title = placemark.name;
                annotation.subtitle = [placemark.addressDictionary objectForKey:@"Name"];
                [self.mapView addAnnotation:annotation];
                [self.mapView selectAnnotation:annotation animated:NO];
    // 指定显示区域
                [self.mapView setRegion:MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(0.003, 0.003)) animated:NO];
            }
        }
    }];
    */
    // 本地商户查询
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(32.462856, 119.940759);
    MKCoordinateSpan span = MKCoordinateSpanMake(0.005, 0.005);
    
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = @"银行";
    request.region = MKCoordinateRegionMake(coordinate, span);
    
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        if (error)
        {
            NSLog(@"Error: %@", [error localizedDescription]);
        }
        else
        {
            for (MKMapItem *item in response.mapItems)
            {
                CLPlacemark *placemark = item.placemark;
                CLLocationCoordinate2D coordinateP = placemark.location.coordinate;
                NSLog(@"%.4f, %.4f", coordinateP.latitude, coordinateP.longitude);
                
                CLLocationDegrees lat = coordinateP.latitude - coordinate.latitude;
                CLLocationDegrees lon = coordinateP.longitude - coordinate.longitude;
                if (fabs(lat) <= 0.01 && fabs(lon) <= 0.01)
                {
                    // 创建标注
                    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
                    annotation.coordinate = coordinateP;
                    annotation.title = item.name;
                    annotation.subtitle = [placemark.addressDictionary objectForKey:@"Street"];
                    [self.mapView addAnnotation:annotation];
                    
                }
                
                // 3秒后跳转到行车路线
                [self performSelector:@selector(showRoute:) withObject:[NSValue valueWithMKCoordinate:coordinateP] afterDelay:3.0];
                
            }
            // 指定显示区域
            [self.mapView setRegion:MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(0.01, 0.01)) animated:NO];
        }
    }];
    
    
}

-(void)showRoute:(NSValue *)coordinateValue
{
    // 通过map item来实现驾车路线查询
    CLLocationCoordinate2D coordinate = [coordinateValue MKCoordinateValue];
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude) addressDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"工商银行", @"Street", @"取款机", @"Name", nil]];
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    mapItem.name = @"建设银行";
    
    [MKMapItem openMapsWithItems:[NSArray arrayWithObject:mapItem] launchOptions:[NSDictionary dictionaryWithObjectsAndKeys:MKLaunchOptionsDirectionsModeDriving, MKLaunchOptionsDirectionsModeKey, nil]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
