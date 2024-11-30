import { router } from '@kit.ArkUI'
import {
  CityInfo,
  DailyWeather, HourlyWeather, RealtimeAirQuality, RealtimeWeather,
  ShownCity,
  WeatherIndex } from '../Model/DataInterface';
import NetworkDataFetcher from '../Model/NetworkDataFetcher';
import StoreManager from '../Model/StoreManager';

@Entry
@Component
struct AddCity {
  @State searchText:string=""
  @State CityList: ShownCity[] = []
  @StorageLink('RecommendedCities') RecommendedCities: ShownCity[] = []
  @StorageLink('yOffset') yOffset: number[] = []
  @StorageLink('CurrentLocation') CurrentLocation: string = ""
  @StorageLink('CurrentWeathers') CurrentWeathers: RealtimeWeather[] = []
  @StorageLink('AllHourlyWeathers') AllHourlyWeathers: Array<HourlyWeather[]> = []
  @StorageLink('AllDailyWeathers') AllDailyWeathers: Array<DailyWeather[]> = []
  @StorageLink('CurrentAirQualities') CurrentAirQualities: RealtimeAirQuality[] = []
  @StorageLink('AllWeatherIndexes') AllWeatherIndexes: Array<WeatherIndex[]> = []
  @StorageLink('ShownCities') ShownCities: ShownCity[] = []
  @StorageLink('CurrentLocationName') CurrentLocationName: string = ""

  async aboutToAppear(): Promise<void> {
    console.info('模拟器添加城市-aboutToAppear')
    this.CityList= this.RecommendedCities
  }
  // 搜索城市
  async SearchCity() {
    let cityInfo:CityInfo[]= await NetworkDataFetcher.getCityInfo(this.searchText)
    this.CityList=[]
    cityInfo.forEach(item => {
      this.CityList.push({
        id: null,
        Name: item.name,
        Location: item.lon+','+item.lat,
        LocationId: item.id
      })
    })
  }
  // 添加城市
  async AddCity(city:ShownCity) {
    // 通过网络请求数据
    let currentWeather = await NetworkDataFetcher.getRealtimeWeather(city.Location);
    let hourlyWeather = await NetworkDataFetcher.getHourlyWeather(city.Location);
    let dailyWeather = await NetworkDataFetcher.getDailyWeather(city.Location);
    let airQuality = await NetworkDataFetcher.getAirQuality(city.Location);
    let weatherIndex = await NetworkDataFetcher.getWeatherIndex(city.Location);
    // 存储数据
    await StoreManager.addShownCity(getContext(this),city)
    await StoreManager.addCurrentWeather(getContext(this),currentWeather)
    await StoreManager.addHourlyWeathers(getContext(this),hourlyWeather)
    await StoreManager.addDailyWeathers(getContext(this),dailyWeather)
    await StoreManager.addRealtimeAirQuality(getContext(this),airQuality)
    await StoreManager.addWeatherIndex(getContext(this),weatherIndex)
    // 更新数据
    this.ShownCities.push(city)
    this.yOffset.push(0)
    this.CurrentWeathers.push(currentWeather)
    this.AllHourlyWeathers.push(hourlyWeather)
    this.AllDailyWeathers.push(dailyWeather)
    this.CurrentAirQualities.push(airQuality)
    this.AllWeatherIndexes.push(weatherIndex)
    console.info('模拟器添加城市'+city.Name)
    console.info('模拟器ShownCities'+JSON.stringify(this.ShownCities))
    router.back({ url: 'pages/Index'})
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
        Text("添加城市")
          .fontSize(25)
          .fontColor(Color.White)
      }
      .width('95%')
      .height('10%')
      .margin({top:'5%'})
      Search({ placeholder:'搜索城市（中文/拼音）', value: this.searchText })
        .width('95%')
        .height('5%')
        .backgroundColor('#99c3bebe')
        .placeholderColor('#99474646')
        .placeholderFont({ size: 15, weight: 400 })
        .textFont({ size: 20, weight: 400 })
        .onSubmit((value: string) => {
          console.log('搜索内容:'+ value);
        })
        .onChange(async (value: string) => {
          this.searchText = value
          if(this.searchText.length==0){
            this.ShownCities = this.RecommendedCities
          }else{
            this.SearchCity()
          }
        })
      Row(){
        Text(`${this.searchText?"全部城市":"推荐城市"}`)
          .fontSize(15)
          .fontColor('#99ffffff')
          .opacity(0.8)
          .margin({left:'5%'})
      }
      .width('95%')
      .height('5%')
      .borderWidth({bottom:1})
      .borderColor(Color.Grey)
      .margin({bottom:'5%'})
      List(){
        ForEach(this.CityList, (item: ShownCity, index:number)=>{
          ListItem(){
            Text(`${item.Name}`)
              .fontSize(20)
              .width('90%')
              .fontColor(Color.White)
              .opacity(0.8)
              .textAlign(TextAlign.Start)
              .margin({left:'5%'})
          }
          .height('5%')
          .onClick(async ()=>{
            this.AddCity(item)
          })
        },(item:ShownCity)=>item.Name)
      }
      .width('95%')
      .height('85%')
      .divider({strokeWidth:1,color:Color.Grey})
      .alignListItem(ListItemAlign.Start)
      .scrollBar(BarState.Off)
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