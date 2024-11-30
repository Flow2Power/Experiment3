import { curves, router } from '@kit.ArkUI'
import { DailyWeather, HourlyWeather, RealtimeAirQuality, RealtimeWeather,
  ShownCity,
  WeatherIndex } from '../Model/DataInterface';
import StoreManager from '../Model/StoreManager';

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
  @StorageLink('yOffset') yOffset: number[] = []
  @StorageLink('CurrentLocation') CurrentLocation: string = ""
  @StorageLink('CurrentWeathers') CurrentWeathers: RealtimeWeather[] = []
  @StorageLink('AllHourlyWeathers') AllHourlyWeathers: Array<HourlyWeather[]> = []
  @StorageLink('AllDailyWeathers') AllDailyWeathers: Array<DailyWeather[]> = []
  @StorageLink('CurrentAirQualities') CurrentAirQualities: RealtimeAirQuality[] = []
  @StorageLink('AllWeatherIndexes') AllWeatherIndexes: Array<WeatherIndex[]> = []
  @StorageLink('ShownCities') ShownCities: ShownCity[] = []


  @StorageLink('CurrentLocationName') CurrentLocationName: string = "北京"
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
          Text(`${this.CurrentWeathers[this.ShownCities.findIndex(city => city.Location === item.Location)]?.temp}`)
          // Text("℃")
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
        Text(`${this.CurrentWeathers[this.ShownCities.findIndex(city => city.Location === item.Location)]?.text}`)
        // Text("℃")
        .fontSize(15)
        .fontColor(Color.White)
        .textAlign(TextAlign.Center)
      }
      .margin({left:'75%'})
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
          animateTo({duration:1000,curve: Curve.EaseIn}, async ()=>{
            // // 删除数据库中数据
            await StoreManager.deleteShownCity(getContext(this),item)
            await StoreManager.deleteCurrentWeather(getContext(this),this.CurrentWeathers[index])
            await StoreManager.deleteHourlyWeathers(getContext(this),this.AllHourlyWeathers[index])
            await StoreManager.deleteDailyWeathers(getContext(this),this.AllDailyWeathers[index])
            await StoreManager.deleteRealtimeAirQuality(getContext(this),this.CurrentAirQualities[index])
            await StoreManager.deleteWeatherIndex(getContext(this),this.AllWeatherIndexes[index])
            // 使用 filter 方法创建新数组
            this.yOffset = this.yOffset.filter((_, idx) => idx !== index);
            this.ShownCities = this.ShownCities.filter((city, idx) => idx !== index);
            this.CurrentWeathers = this.CurrentWeathers.filter((weather, idx) => idx !== index);
            this.AllHourlyWeathers = this.AllHourlyWeathers.filter((hourlyWeathers, idx) => idx !== index);
            this.AllDailyWeathers = this.AllDailyWeathers.filter((dailyWeathers, idx) => idx !== index);
            this.CurrentAirQualities = this.CurrentAirQualities.filter((airQuality, idx) => idx !== index);
            this.AllWeatherIndexes = this.AllWeatherIndexes.filter((weatherIndex, idx) => idx !== index);
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
      .scrollBar(BarState.Off)
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