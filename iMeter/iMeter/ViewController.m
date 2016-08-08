//
//  ViewController.m
//  iMeter
//
//  Created by yinzhihao on 16/8/3.
//  Copyright © 2016年 zcsmart. All rights reserved.
//

#import "ViewController.h"
#import "SVProgressHUD.h"
#import "UIColor+Util.h"

#define SCREEN_WIDTH  [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGTH [[UIScreen mainScreen] bounds].size.height
#define MAX_CHARACTERISTIC_VALUE_SIZE 20
#define WriteCharacteristicUUID @"BEF8D6C9-9C21-4C9E-B632-BD58C1009F9F"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    BabyBluetooth *baby;
    
    NSMutableArray *_peripherals;
    
    NSMutableArray *_peripheralsAD;
    
    //保存连接的设备和特征
    CBPeripheral *_connectedPeripheral;
    CBCharacteristic *_characteristic;
}

@property (nonatomic) UITableView *tableView;

//电量
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    [SVProgressHUD showInfoWithStatus:@"准备打开设备"];
    
    [self customTableView];
    
    [self initData];
    
    [self initButtons];
    
    // 初始化BabyBluetooth 蓝牙库
    baby = [BabyBluetooth shareBabyBluetooth];
    //设置蓝牙委托
    [self babyDelegate];
    //设置委托后直接可以使用，无需等待CBCentralManagerStatePoweredOn状态
    baby.scanForPeripherals().begin();
    
    //扫描设备 然后读取服务,然后读取characteristics名称和值和属性，获取characteristics对应的description的名称和值
    //    baby.scanForPeripherals().connectToPeripherals().discoverServices()
    //    .discoverCharacteristics().readValueForCharacteristic().discoverDescriptorsForCharacteristic()
    //    .readValueForDescriptors().begin();

    
    
}

#pragma mark - 蓝牙部分
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [baby cancelAllPeripheralsConnection];
    
    baby.scanForPeripherals().begin();
}

- (void)babyDelegate
{
    __weak typeof(self) weakSelf = self;
    
    BabyRhythm *rhythm = [[BabyRhythm alloc]init];
    
    [baby setBlockOnCentralManagerDidUpdateState:^(CBCentralManager *central) {
        if (central.state == CBCentralManagerStatePoweredOn) {
            [SVProgressHUD showInfoWithStatus:@"设备打开成功，开始扫描设备"];
        }
    }];
    
    //设置扫描到设备的委托
    [baby setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
//        NSLog(@"搜索到了设备：%@",peripheral.name);
        [weakSelf insertTableView:peripheral advertisementData:advertisementData];
    }];
    
    //设置设备连接成功的委托
    [baby setBlockOnConnected:^(CBCentralManager *central, CBPeripheral *peripheral) {
        NSLog(@"设备：%@--连接成功",peripheral.name);
        [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"设备：%@--连接成功",peripheral.name]];
    }];
    
    //设置设备连接失败的委托
    [baby setBlockOnFailToConnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"设备：%@--连接失败",peripheral.name);
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"设备：%@--连接失败",peripheral.name]];
    }];
    
    //设置设备断开连接的委托
    [baby setBlockOnDisconnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"%@断开连接",peripheral.name);
        [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"%@断开连接",peripheral.name]];
    }];
    
    //设置发现设备的Services的委托
    [baby setBlockOnDiscoverServices:^(CBPeripheral *peripheral, NSError *error) {
        NSLog(@"-----Discover设备 %@ 的所有服务：%@",peripheral.name,peripheral.services);
        for (CBService *s in peripheral.services) {
            NSLog(@"服务之一：%@",s.UUID.UUIDString);
        }
        
        for (int i=0; i<_peripherals.count; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            UITableViewCell *cell = [weakSelf.tableView cellForRowAtIndexPath:indexPath];
            
            if ([cell.textLabel.text isEqualToString:peripheral.name]) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu个service",(unsigned long)peripheral.services.count];
            }
        }
        
        [rhythm beats];
    }];
    
    //设置发现设service的Characteristics的委托
    [baby setBlockOnDiscoverCharacteristics:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        NSLog(@"-----Discover设备 %@ 的服务 %@ 的所有特征：%@",peripheral.name,service.UUID,service.characteristics);
        
        for (CBCharacteristic *c in service.characteristics) {
            NSLog(@"特征之一：%@",c.UUID.UUIDString);
            
            if ([c.UUID.UUIDString isEqualToString:WriteCharacteristicUUID]) {
                _characteristic = c;
            }
        }
    }];
    
    [baby setBlockOnReadValueForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        NSLog(@"特征 %@ 的 值：%@",characteristic.UUID.UUIDString,characteristic.value);
    }];
    
    [baby setBlockOnDiscoverDescriptorsForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        NSLog(@"-----Discover设备 %@ 的服务 %@ 的特征 %@ 的 所有Descriptors：%@",peripheral.name,characteristic.service.UUID,characteristic.UUID.UUIDString,characteristic.descriptors);
        
        for (CBDescriptor *d in characteristic.descriptors) {
            NSLog(@"Descriptor之一：%@",d.UUID);
        }
    }];
    
    [baby setBlockOnReadValueForDescriptors:^(CBPeripheral *peripheral, CBDescriptor *descriptor, NSError *error) {
        NSLog(@"descriptor %@ 的值：%@",descriptor.UUID,descriptor.value);
    }];
    
    //读取rssi的委托
    [baby setBlockOnDidReadRSSI:^(NSNumber *RSSI, NSError *error) {
        NSLog(@"set Block On Did Read RSSI,RSSI:%@",RSSI);
    }];
    
    //设置beats break委托
    [rhythm setBlockOnBeatsBreak:^(BabyRhythm *bry) {
        NSLog(@"set Block On Beats Break call");
        //如果完成任务，即可停止beat,返回bry可以省去使用weak rhythm的麻烦
        //        if (<#condition#>) {
        //            [bry beatsOver];
        //        }
    }];
    
    //设置beats over委托
    [rhythm setBlockOnBeatsOver:^(BabyRhythm *bry) {
        NSLog(@"set Block On Beats Over call");
    }];
    
    //过滤器
    //设置查找设备的过滤器
    [baby setFilterOnDiscoverPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
        
        //最常用的场景是查找某一个前缀开头的设备
        //        if ([peripheralName hasPrefix:@"Pxxxx"] ) {
        //            return YES;
        //        }
        //        return NO;
        
        //设置查找规则是名称大于0 ， the search rule is peripheral.name length > 0
        if (peripheralName.length > 0) {
            return YES;
        }
        return NO;
    }];
    
    [baby setBlockOnCancelAllPeripheralsConnectionBlock:^(CBCentralManager *centralManager) {
        NSLog(@"setBlockOnCancelAllPeripheralsConnectionBlock");
    }];
    
    [baby setBlockOnCancelScanBlock:^(CBCentralManager *centralManager) {
        NSLog(@"setBlockOnCancelScanBlock");
    }];
    
    //扫描选项->CBCentralManagerScanOptionAllowDuplicatesKey:忽略同一个Peripheral端的多个发现事件被聚合成一个发现事件
    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    /*连接选项->
     CBConnectPeripheralOptionNotifyOnConnectionKey :当应用挂起时，如果有一个连接成功时，如果我们想要系统为指定的peripheral显示一个提示时，就使用这个key值。
     CBConnectPeripheralOptionNotifyOnDisconnectionKey :当应用挂起时，如果连接断开时，如果我们想要系统为指定的peripheral显示一个断开连接的提示时，就使用这个key值。
     CBConnectPeripheralOptionNotifyOnNotificationKey:
     当应用挂起时，使用该key值表示只要接收到给定peripheral端的通知就显示一个提
     */
    NSDictionary *connectOptions = @{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES,
                                     CBConnectPeripheralOptionNotifyOnDisconnectionKey:@YES,
                                     CBConnectPeripheralOptionNotifyOnNotificationKey:@YES};
    //连接设备->
    [baby setBabyOptionsWithScanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:connectOptions scanForPeripheralsWithServices:nil discoverWithServices:nil discoverWithCharacteristics:nil];
    
}

#pragma mark -事件

//写数据
-(void)writeCharacteristic:(CBPeripheral *)peripheral
            characteristic:(CBCharacteristic *)characteristic
                     value:(NSData *)value{
    
    //打印出 characteristic 的权限，可以看到有很多种，这是一个NS_OPTIONS，就是可以同时用于好几个值，常见的有read，write，notify，indicate，知知道这几个基本就够用了，前连个是读写权限，后两个都是通知，两种不同的通知方式。
    /*
     typedef NS_OPTIONS(NSUInteger, CBCharacteristicProperties) {
     CBCharacteristicPropertyBroadcast												= 0x01,
     CBCharacteristicPropertyRead													= 0x02,
     CBCharacteristicPropertyWriteWithoutResponse									= 0x04,
     CBCharacteristicPropertyWrite													= 0x08,
     CBCharacteristicPropertyNotify													= 0x10,
     CBCharacteristicPropertyIndicate												= 0x20,
     CBCharacteristicPropertyAuthenticatedSignedWrites								= 0x40,
     CBCharacteristicPropertyExtendedProperties										= 0x80,
     CBCharacteristicPropertyNotifyEncryptionRequired NS_ENUM_AVAILABLE(NA, 6_0)		= 0x100,
     CBCharacteristicPropertyIndicateEncryptionRequired NS_ENUM_AVAILABLE(NA, 6_0)	= 0x200
     };
     
     */
    NSLog(@"%lu", (unsigned long)characteristic.properties);
    
    
    //只有 characteristic.properties 有write的权限才可以写
    if(characteristic.properties & CBCharacteristicPropertyWrite){
        /*
         最好一个type参数可以为CBCharacteristicWriteWithResponse或type:CBCharacteristicWriteWithResponse,区别是是否会有反馈
         */
        [peripheral writeValue:value forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
    }else{
        NSLog(@"该字段不可写！");
        [SVProgressHUD showErrorWithStatus:@"该字段不可写！"];
    }
    
    
}



#pragma mark -UIViewController 方法
//插入table数据
- (void)insertTableView:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData
{
    if ([_peripherals containsObject:peripheral]) {
        return;
    }
    NSLog(@"搜索到了设备：%@",peripheral.name);
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    [_peripherals insertObject:peripheral atIndex:0];
    [_peripheralsAD insertObject:advertisementData atIndex:0];
    
    [_tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark -table委托 table delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _peripherals.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"cell"];
    CBPeripheral *peripheral = [_peripherals objectAtIndex:indexPath.row];
    NSDictionary *ad = [_peripheralsAD objectAtIndex:indexPath.row];
    
    NSLog(@"-----advertisement:%@",ad);
    
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //peripheral的显示名称,优先用kCBAdvDataLocalName的定义，若没有再使用peripheral name
    NSString *localName;
    if ([ad objectForKey:@"kCBAdvDataLocalName"]) {
        localName = [NSString stringWithFormat:@"%@",[ad objectForKey:@"kCBAdvDataLocalName"]];
    }else{
        localName = peripheral.name;
    }
    
    cell.textLabel.text = localName;
    //信号和服务
    cell.detailTextLabel.text = @"读取中...";
    //找到cell并修改detaisText
    NSArray *serviceUUIDs = [ad objectForKey:@"kCBAdvDataServiceUUIDs"];
    if (serviceUUIDs) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu个service",(unsigned long)serviceUUIDs.count];
    }else{
        cell.detailTextLabel.text = [NSString stringWithFormat:@"0个service"];
    }
    
    //次线程读取RSSI和服务数量
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //停止扫描
    [baby cancelScan];
    
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    _connectedPeripheral = _peripherals[indexPath.row];
    
    baby.having(_connectedPeripheral).then.connectToPeripherals().discoverServices().discoverCharacteristics().readValueForCharacteristic().discoverDescriptorsForCharacteristic().readValueForDescriptors().begin();
    
    //    PeripheralViewContriller *vc = [[PeripheralViewContriller alloc]init];
    //    vc.currPeripheral = [peripherals objectAtIndex:indexPath.row];
    //    vc->baby = self->baby;
    //    [self.navigationController pushViewController:vc animated:YES];
    
}


#pragma mark - 界面
- (void)customTableView
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 180, SCREEN_WIDTH, 100) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.view addSubview:_tableView];
    
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}

- (void)initData
{
    _peripherals = [NSMutableArray array];
    _peripheralsAD = [NSMutableArray array];
}

- (void)initButtons {
    NSArray *titles = @[@"查询",@"充值"];
    
    int colum = 2;
    CGFloat width = SCREEN_WIDTH/colum;
    CGFloat height = 100;
    
    for (int index = 0; index < titles.count; index++) {
        int x = index%colum;
        CGFloat y = index/colum;
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.titleLabel.font = [UIFont systemFontOfSize:20];
        [btn setTitle:titles[index] forState:UIControlStateNormal];
//        [btn setTitleColor:[UIColor colorWithHex:0x666666 alpha:1.0] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.frame = CGRectMake(width * x, 300 + height * y, width, height);
        btn.layer.borderColor = [UIColor colorWithHex:0xd7d7d7 alpha:1.0].CGColor;
        btn.layer.borderWidth = 1;
//        [btn setBackgroundImage:[UIColor imageFromColor:[UIColor colorWithHex:0xf2f2f2 alpha:1.0] size:btn.frame.size] forState:UIControlStateHighlighted];
        btn.backgroundColor = [UIColor themeColor];
        [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = index + 100;
        [self.view addSubview:btn];
    }
}

- (void)buttonClick:(UIButton *)btn
{
    switch (btn.tag) {
        case 100://查询
            //发什么指令？
            //要做什么转换？
            //
            break;
        case 101://充值
            
            break;
            
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
