import { curves, router } from '@kit.ArkUI'
import { DailyWeather, HourlyWeather, RealtimeAirQuality, RealtimeWeather,
  ShownCity,
  WeatherIndex } from '../Model/DataInterface';
@Entry
@Component
struct Cities {
  //转场效果
  private effect: TransitionEffect =
    TransitionEffect.asymmetric(
      TransitionEffect.IDENTITY,  // 出现时没有效果
      TransitionEffect.SLIDE     // 消失时透明度从1变为0
        .animation({ duration: 400 })  // 动画持续时间为1000毫秒
        .combine(
          TransitionEffect.translate({ x: 150})  // 同时进行水平移动
            .animation({ curve: curves.springMotion(0.6, 1.2) })  // 使用springMotion曲线
        )
    )
  @StorageLink('CurrentLocation') CurrentLocation: string = ""
  @StorageLink('CurrentWeathers') CurrentWeathers: RealtimeWeather[] = []
  @StorageLink('AllHourlyWeathers') AllHourlyWeathers: Array<HourlyWeather[]> = []
  @StorageLink('AllDailyWeathers') AllDailyWeathers: Array<DailyWeather[]> = []
  @StorageLink('CurrentAirQualities') CurrentAirQualities: RealtimeAirQuality[] = []
  @StorageLink('AllWeatherIndexes') AllWeatherIndexes: Array<WeatherIndex[]> = []
  @StorageLink('ShownCities') ShownCities: ShownCity[] = [
    { id: null, Name: '北京', Location: '39.9042,116.4074', LocationId: '101010100' },
    { id: null, Name: '上海', Location: '31.2304,121.4737', LocationId: '101020100' },
    { id: null, Name: '广州', Location: '23.1291,113.2644', LocationId: '101280100' },
    { id: null, Name: '深圳', Location: '22.5431,114.0579', LocationId: '101280600' },
    { id: null, Name: '成都', Location: '30.6595,104.0668', LocationId: '101270100' },
    { id: null, Name: '杭州', Location: '30.2741,120.1551', LocationId: '101210100' },
    { id: null, Name: '南京', Location: '32.0603,118.7951', LocationId: '101190100' },
    { id: null, Name: '武汉', Location: '30.5929,114.3052', LocationId: '101200100' },
    { id: null, Name: '重庆', Location: '29.5630,106.5516', LocationId: '101040100' },
    { id: null, Name: '西安', Location: '34.3416,108.9402', LocationId: '101110100' },
    { id: null, Name: '天津', Location: '39.3434,117.3616', LocationId: '101030100' },
    { id: null, Name: '苏州', Location: '31.3042,120.5844', LocationId: '101190400' },
    { id: null, Name: '长沙', Location: '28.2339,112.9317', LocationId: '101250100' },
    { id: null, Name: '青岛', Location: '36.0668,120.3833', LocationId: '101120200' },
    { id: null, Name: '大连', Location: '38.9148,121.6192', LocationId: '101090100' }
  ]

  @StorageLink('CurrentLocationName') CurrentLocationName: string = ""
  @Builder Card(item:ShownCity){
    Stack(){
      Text(`${item.Name}`)
        .fontSize(25)
        .fontColor(Color.White)
        .margin({left: '5%'})
      SymbolGlyph($r('sys.symbol.local_fill'))
        .fontSize(20)
        .fontColor([Color.White])
        .fontWeight(FontWeight.Bold)
        .margin({left: '20%'})
        .opacity(item.Name==this.CurrentLocationName?1:0)
      Column(){
        Row(){
          // Text(`${this.CurrentWeathers[index].temp}`)
          Text("℃")
            .fontSize(40)
            .fontColor(Color.White)
            .textAlign(TextAlign.Center)
          Text("℃")
            .fontSize(30)
            .fontColor(Color.White)
            .textAlign(TextAlign.Center)
            .margin({top:'1%'})
        }
        .alignItems(VerticalAlign.Top)
        .justifyContent(FlexAlign.Start)
        // Text(`${this.CurrentWeathers[index].text}`)
        Text("℃")
        .fontSize(15)
        .fontColor(Color.White)
        .textAlign(TextAlign.Center)
      }
      .margin({left:'80%'})
    }
    .width('95%')
    .height('15%')
    .borderRadius(10)
    .backgroundColor('#996d6d6d')
    .margin({bottom:'2%'})
    .alignContent(Alignment.Start)
  }
  @Builder ItemEnd(item:ShownCity){
    Image($r('app.media.delete'))
      .width(50)
      .height(50)
      .margin({left:'8%'})
      .onClick(()=>{
        console.info('模拟器删除城市'+JSON.stringify(item))
        let index = this.ShownCities.findIndex(city => city.Location === item.Location);
        if (index !== -1) {
          animateTo({duration:1000},()=>{
            this.ShownCities.splice(index, 1);
          });
        }
      })
  }
  build() {
    Column(){
      Row({space: 20}){
        SymbolGlyph($r('sys.symbol.arrow_left'))
          .fontSize(40)
          .fontColor([Color.White])
          .onClick(()=>{
            router.back()
            console.info('模拟器返回')
          })
        Text("管理城市")
          .fontSize(25)
          .fontColor(Color.White)
      }
      .width('95%')
      .height('10%')
      .margin({top:'5%'})
      List(){
        ForEach(this.ShownCities, (item: ShownCity) => {
          ListItem() {
            this.Card(item)
          }
          .swipeAction({ end: this.ItemEnd.bind(this, item), edgeEffect: SwipeEdgeEffect.None })
          .transition(this.effect)
        }, (item: ShownCity) => item.Location)
      }
      .width('95%')
      .height('80%')
      .margin({bottom:'2%'})
      .alignListItem(ListItemAlign.Center)
      .edgeEffect(EdgeEffect.None)
      Column({space:5}){
        Image($r('app.media.add'))
          .fillColor(Color.White)
          .width(25)
          .height(25)
        Text("添加城市")
          .fontSize(15)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
      }
      .height('10%')
      .onClick(()=>{
        console.info('模拟器添加城市')
        router.pushUrl({
          url: 'pages/AddCity'
        })
      })
    }
    .width('100%')
    .height('100%')
    .backgroundImage($r('app.media.MyBackground'))
    .backgroundImageSize(ImageSize.Cover)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Start)
    .backdropBlur(500)
  }
}