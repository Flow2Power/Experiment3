import { router } from '@kit.ArkUI'
import {
  CityInfo,
  DailyWeather, HourlyWeather, RealtimeAirQuality, RealtimeWeather,
  ShownCity,
  WeatherIndex } from '../Model/DataInterface';
import NetworkDataFetcher from '../Model/NetworkDataFetcher';
import StoreManager from '../Model/StoreManager';
import { webview } from '@kit.ArkWeb';

@Entry
@Component
struct WebInfo {
  @StorageLink('WebName') WebName: string = ""
  @StorageLink('WebTitle') WebTitle: string = ""
  @StorageLink('WebLink') WebLink: string = ""
  WebController: webview.WebviewController = new webview.WebviewController();
  onPageShow(): void {
    console.info('模拟器进入WebInfo')
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
        Text(`${this.WebName}${this.WebTitle}`)
          .fontSize(25)
          .fontColor(Color.White)
      }
      .width('95%')
      .height('10%')
      .margin({top:'5%'})
      Web({ src: this.WebLink, controller: this.WebController })
        .width('100%')
        .height('90%')
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