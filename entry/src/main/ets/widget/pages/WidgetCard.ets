@Entry
@Component
struct WidgetCard {
  @LocalStorageProp('ShownCityName') ShownCityName:string = "沙坪坝"
  @LocalStorageProp('CurrentLocationName') CurrentLocationName: string = "沙坪坝"
  @LocalStorageProp('tempMax') tempMax: number= 10
  @LocalStorageProp('tempMin') tempMin: number= 10
  @LocalStorageProp('weather') weather: string = "小雨"
  @LocalStorageProp('airLevel') airLevel: string = "优"
  @LocalStorageProp('date') date: string = "11月25日"
  @LocalStorageProp('week') week: string = "星期一"
  @LocalStorageProp('weatherIcon') weatherIcon: string = "100"
  @LocalStorageProp('category1') category1: string = "适合"
  @LocalStorageProp('category2') category2: string = "适合"
  @LocalStorageProp('category3') category3: string = "适合"
  @LocalStorageProp('category4') category4: string = "适合"
  build() {
    Row() {
      Column(){
        Stack(){
          SymbolGlyph($r('sys.symbol.local_fill'))
            .fontSize(15)
            .fontColor([Color.White])
            .fontWeight(FontWeight.Bold)
            .margin({left:'40%'})
            .opacity(this.ShownCityName==this.CurrentLocationName?1:0)
          Text(`${this.ShownCityName}`)
            .fontSize(15)
            .fontColor(Color.White)
            .textAlign(TextAlign.Center)
            .opacity(0.8)
          Row(){
            Text("明日")
              .fontSize(12)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
              .textAlign(TextAlign.Center)
          }
          .width('20%')
          .height('200%')
          .borderRadius(2)
          .backgroundColor('#99949292')
          .margin({left:'60%',top:'4%'})
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Center)
        }
        .alignContent(Alignment.Start)
        .width('80%')
        .height('5%')
        .margin({top:'7%'})
        Row(){
          Text(`${this.tempMax}°/${this.tempMin}°`)
            .fontSize(40)
            .fontColor(Color.White)
            .textAlign(TextAlign.Center)
        }
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .width('100%')
        .height('60%')
        Row(){
          Column(){
            Row(){
              Text(`${this.weather}   空气${this.airLevel}`)
                .fontSize(12)
                .fontColor(Color.White)
                .fontWeight(FontWeight.Bold)
                .textAlign(TextAlign.Center)
            }
            .width('100%')
            .height('45%')
            Row(){
              Text(`${this.date} ${this.week}`)
                .fontSize(12)
                .fontColor(Color.White)
                .fontWeight(FontWeight.Bold)
                .textAlign(TextAlign.Center)
            }
            .width('100%')
            .height('45%')
          }
          .width('60%')
          .height('90%')
          Column(){
            Image($r(`app.media.${this.weatherIcon}`))
              .fillColor(Color.White)
              .width(50)
              .height(50)
          }
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.Center)
          .margin({bottom:'10%'})
          .width('35%')
          .height('100%')
        }
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .width('100%')
        .height('30%')
      }
      .width('50%')
      .height('95%')
      .border({
        width: { right: 0.5 },
        color: { right: Color.Grey },
      })
      Row(){
        Column({space: 10}){
          Image($r('app.media.tourism'))
            .fillColor(Color.White)
            .width(25)
            .height(25)
          Image($r('app.media.sports'))
            .fillColor(Color.White)
            .width(25)
            .height(25)
          Image($r('app.media.cold'))
            .fillColor(Color.White)
            .width(25)
            .height(25)
          Image($r('app.media.wash'))
            .fillColor(Color.White)
            .width(25)
            .height(25)
        }
        .width('10%')
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Start)
        .margin({left:'5%'})
        Column({space: 10}){
          Text('旅游')
            .fontSize(15)
            .fontColor(Color.White)
            .opacity(0.8)
            .height(25)
          Text('运动')
            .fontSize(15)
            .fontColor(Color.White)
            .opacity(0.8)
            .height(25)
          Text('感冒')
            .fontSize(15)
            .fontColor(Color.White)
            .opacity(0.8)
            .height(25)
          Text('洗车')
            .fontSize(15)
            .fontColor(Color.White)
            .opacity(0.8)
            .height(25)
        }
        .width('20%')
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Start)
        .margin({left:'10%'})
        Column({space: 10}){
          Text(`${this.category1}`)
            .fontSize(15)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
            .height(25)
          Text(`${this.category2}`)
            .fontSize(15)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
            .height(25)
          Text(`${this.category3}`)
            .fontSize(15)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
            .height(25)
          Text(`${this.category4}`)
            .fontSize(15)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
            .height(25)
        }
        .width('30%')
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Start)
        .margin({left:'20%'})
      }
      .width('50%')
      .height('95%')
      .border({
        width: { left: 0.5 },
        color: { left: Color.Grey },
      })
    }
    .width('100%')
    .height('100%')
    .backgroundImage($r('app.media.MyBackground'))
    .backgroundImageSize(ImageSize.Cover)
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .backdropBlur(500)
    .onClick(() => {
      postCardAction(this, {
        action: 'router',
        abilityName: 'EntryAbility',
        params: {
          message: '模拟器进入应用首页'
        }
      });
    })
  }
}