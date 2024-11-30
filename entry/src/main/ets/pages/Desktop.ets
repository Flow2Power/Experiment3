import { router } from '@kit.ArkUI'
import { DailyWeather, HourlyWeather, RealtimeAirQuality, RealtimeWeather,
  ShownCity,
  WeatherIndex } from '../Model/DataInterface';
import PreferencesManager from '../Model/PreferencesManager';

@Entry
@Component
struct Desktop {
  @State ShownCityName:string = ""
  @State index:number = 0
  @State isLocalItemChecked: boolean = true // 新增状态变量
  @State CityList:ShownCity[]=[]
  @StorageLink('CurrentLocation') CurrentLocation: string = ""
  @StorageLink('CurrentWeathers') CurrentWeathers: RealtimeWeather[] = []
  @StorageLink('AllHourlyWeathers') AllHourlyWeathers: Array<HourlyWeather[]> = []
  @StorageLink('AllDailyWeathers') AllDailyWeathers: Array<DailyWeather[]> = []
  @StorageLink('CurrentAirQualities') CurrentAirQualities: RealtimeAirQuality[] = []
  @StorageLink('AllWeatherIndexes') AllWeatherIndexes: Array<WeatherIndex[]> = []
  @StorageLink('ShownCities') ShownCities: ShownCity[] =[]
  @StorageLink('CurrentLocationName') CurrentLocationName: string = ""

  async aboutToAppear(): Promise<void> {
    console.info('模拟器Desktop-aboutToAppear')
    this.ShownCityName = await PreferencesManager.getShownCity(getContext(this))
    if(this.ShownCityName==""){
      this.ShownCityName = this.CurrentLocationName;
    }
    this.index = this.ShownCities.findIndex(city => city.Name === this.ShownCityName);
    this.isLocalItemChecked = this.ShownCityName == this.CurrentLocationName;
    this.CityList=this.ShownCities;
    this.CityList.push({
      id:null,
      Name:"添加城市",
      Location:'',
      LocationId:''
    })
    console.info('模拟器Desktop-aboutToAppear-ShownCityName:',this.isLocalItemChecked)
  }
  @Builder CurrentWeatherBuilder() {
    Column({space: 10}){
      Stack(){
        SymbolGlyph($r('sys.symbol.local_fill'))
          .fontSize(20)
          .fontColor([Color.White])
          .fontWeight(FontWeight.Bold)
          .margin({left:'30%'})
          .opacity(this.ShownCities[this.index]?.Name==this.CurrentLocationName?1:0)
        Text(`${this.ShownCities[this.index]?.Name}`)
          .fontSize(20)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
      }
      Row(){
        Text(`${this.CurrentWeathers[this.index]?.temp||'--'}`)
          .fontSize(140)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Center)
        Text("℃")
          .fontSize(40)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .margin({top:'7%'})
      }
      .alignItems(VerticalAlign.Top)
      .justifyContent(FlexAlign.Start)
      Text(`${this.AllDailyWeathers[this.index]?.[0]?.tempMax||0}℃/${this.AllDailyWeathers[this.index]?.[0]?.tempMin||0}℃`)
        .fontSize(20)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center)
      Text(`${this.CurrentWeathers[this.index]?.text||'--'} 空气${this.CurrentAirQualities[this.index]?.category||'--'}`)
        .fontSize(20)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center)
    }
    .width('95%')
    .height('45%')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Start)
  }
  @Builder LocalItem(){
    Row(){
      Text("当前位置")
        .fontSize(18)
        .fontColor(Color.White)
        .margin({left:'7%'})
      Toggle({type: ToggleType.Switch,isOn: this.isLocalItemChecked})
        .margin({right:'5%'})
        .onChange((isOn:boolean)=>{
          this.isLocalItemChecked = isOn;
          if (isOn) {
            this.ShownCityName = this.CurrentLocationName;
            PreferencesManager.putShownCity(this.ShownCityName,getContext(this));
            this.index = this.ShownCities.findIndex(city => city.Name === this.ShownCityName);
          }
        })
    }
    .width('95%')
    .height('5%')
    .borderRadius(10)
    .backgroundColor('#996d6d6d')
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.SpaceBetween)
  }
  @Builder ChooseItem(item:ShownCity){
    Row(){
      Text(`${item.Name}`)
        .fontSize(18)
        .fontColor(Color.White)
        .margin({left:'5%'})
      Radio({value: item.Name,group: 'ChooseItem'})
        .margin({right:'5%'})
        .checked(item.Name === this.ShownCityName)
        .onChange((isChecked:boolean)=>{
          if (isChecked) {
            this.ShownCityName = item.Name;
            PreferencesManager.putShownCity(this.ShownCityName,getContext(this));
            this.index = this.ShownCities.findIndex(city => city.Name === item.Name);
            this.isLocalItemChecked = false; // 确保 LocalItem 不被选中
          }
        })
    }
    .width('95%')
    .height('5%')
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.SpaceBetween)
  }
  @Builder ToAddCity(item:ShownCity){
    Row(){
      Text(`${item.Name}`)
        .fontSize(18)
        .fontColor(Color.White)
        .margin({left:'5%'})
    }
    .width('95%')
    .height('5%')
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.SpaceBetween)
    .onClick(() => {
      router.pushUrl({
        url: 'pages/AddCity',
      })
    })
  }
  build() {
    Column() {
      Row({space: 20}){
        SymbolGlyph($r('sys.symbol.arrow_left'))
          .fontSize(40)
          .fontColor([Color.White])
          .onClick(()=>{
            router.back()
            console.info('模拟器返回')
          })
        Text("桌面天气")
          .fontSize(25)
          .fontColor(Color.White)
      }
      .width('95%')
      .height('10%')
      .margin({top:'5%'})
      this.CurrentWeatherBuilder()
      this.LocalItem()
      Row(){
        Text("常驻城市")
          .fontSize(18)
          .fontColor('#99ffffff')
          .opacity(0.8)
      }
      .width('85%')
      .height('5%')
      .alignItems(VerticalAlign.Center)
      .margin({top:'1%'})
      List(){
        ForEach(this.CityList, (item:ShownCity) => {
          if(item.Name=="添加城市"){
            this.ToAddCity(item)
          }else if(item.Name!=this.CurrentLocationName){
            this.ChooseItem(item)
          }
        },(item:ShownCity)=>item.Name)
      }
      .alignListItem(ListItemAlign.Center)
      .divider({strokeWidth:1,color:Color.Grey})
      .width('95%')
      .borderRadius(10)
      .backgroundColor('#996d6d6d')
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