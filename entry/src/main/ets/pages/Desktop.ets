import { router } from '@kit.ArkUI'
import { DailyWeather, HourlyWeather, RealtimeAirQuality, RealtimeWeather,
  ShownCity,
  WeatherIndex } from '../Model/DataInterface';
@Entry
@Component
struct Desktop {
  @State searchText: string = ""
  @State RecommendedCities: ShownCity[] = [{
    id: null,
    Name: '定位中',
    Location: '0,0',
    LocationId: '101010100'
  }]
  @State CityList: ShownCity[] = [{
    id: null,
    Name: '定位中',
    Location: '0,0',
    LocationId: '101010100'
  }, {
    id: null,
    Name: '定位中',
    Location: '0,0',
    LocationId: '101010100'
  }, {
    id: null,
    Name: '定位中',
    Location: '0,0',
    LocationId: '101010100'
  }]
  @StorageLink('CurrentLocation') CurrentLocation: string = ""
  @StorageLink('CurrentWeathers') CurrentWeathers: RealtimeWeather[] = []
  @StorageLink('AllHourlyWeathers') AllHourlyWeathers: Array<HourlyWeather[]> = []
  @StorageLink('AllDailyWeathers') AllDailyWeathers: Array<DailyWeather[]> = []
  @StorageLink('CurrentAirQualities') CurrentAirQualities: RealtimeAirQuality[] = []
  @StorageLink('AllWeatherIndexes') AllWeatherIndexes: Array<WeatherIndex[]> = []
  @StorageLink('ShownCities') ShownCities: ShownCity[] = [{
    id: null,
    Name: '定位中',
    Location: '0,0',
    LocationId: '101010100'
  }]
  @StorageLink('CurrentLocationName') CurrentLocationName: string = ""

  build() {
    Column() {
      Row({ space: 20 }) {
        SymbolGlyph($r('sys.symbol.arrow_left'))
          .fontSize(40)
          .fontColor([Color.White])
          .onClick(() => {
            router.back()
            console.info('模拟器返回')
          })
        Text("添加城市")
          .fontSize(25)
          .fontColor(Color.White)
      }
      .width('95%')
      .height('10%')
      .margin({ top: '5%' })

      Search({ placeholder: '搜索城市（中文/拼音）', value: this.searchText })
        .width('95%')
        .height('5%')
        .backgroundColor('#99c3bebe')
        .placeholderColor('#99474646')
        .placeholderFont({ size: 15, weight: 400 })
        .textFont({ size: 20, weight: 400 })
        .onSubmit((value: string) => {
          console.log('搜索内容:' + value);
        })
        .onChange((value: string) => {
          this.searchText = value
        })
      Row() {
        Text(`${this.searchText ? "全部城市" : "推荐城市"}`)
          .fontSize(15)
          .fontColor('#99ffffff')
          .opacity(0.8)
          .margin({ left: '5%' })
      }
      .width('95%')
      .height('5%')
      .borderWidth({ bottom: 1 })
      .borderColor(Color.Grey)
      .margin({ bottom: '5%' })

      List() {
        ForEach(this.CityList, (item: ShownCity, index: number) => {
          ListItem() {
            Text(`${item.Name}`)
              .fontSize(20)
              .width('90%')
              .fontColor(Color.White)
              .textAlign(TextAlign.Start)
              .margin({ left: '5%' })
          }
          .height('5%')
        })
      }
      .width('95%')
      .height('85%')
      .divider({ strokeWidth: 1, color: Color.Grey })
      .alignListItem(ListItemAlign.Start)
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