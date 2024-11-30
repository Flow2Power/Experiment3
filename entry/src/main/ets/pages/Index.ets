import { DailyWeather, HourlyWeather, RealtimeAirQuality, RealtimeWeather,
  ShownCity,
  WeatherIndex } from '../Model/DataInterface';
import NetworkDataFetcher from '../Model/NetworkDataFetcher';
import StoreManager from '../Model/StoreManager';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  // Scroll组件相关变量与用于控制显示与隐藏的状态变量
  @StorageLink('yOffset') yOffset: number[] = []
  private scroller: Scroller = new Scroller()
  // refresh容器组件相关状态变量
  @State isRefreshing: boolean = false
  @State ratio: number = 1
  // tabs容器组件相关状态变量
  @State index: number = 0
  // 页面信息显示相关的变量
  private CurrentTime:string= ''
  private windLevelTerms: string[] = [
  '无风',
  '软风',
  '轻风',
  '微风',
  '和风',
  '清风',
  '强风',
  '疾风',
  '大风',
  '烈风',
  '狂风',
  '暴风',
  '飓风'
];
  @StorageLink('CurrentLocation') CurrentLocation: string = ""
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(new RenderingContextSettings(true));
  private offContext: OffscreenCanvasRenderingContext2D = new OffscreenCanvasRenderingContext2D(600, 600, new RenderingContextSettings(true))
  private ItemWith: number = 80
  private ItemStart: number = 40
  //页面信息显示相关的状态变量
  @StorageLink('CurrentWeathers') CurrentWeathers: RealtimeWeather[] = []
  @StorageLink('AllHourlyWeathers') AllHourlyWeathers: Array<HourlyWeather[]> = []
  @StorageLink('AllDailyWeathers') AllDailyWeathers: Array<DailyWeather[]> = []
  @StorageLink('CurrentAirQualities') CurrentAirQualities: RealtimeAirQuality[] = []
  @StorageLink('AllWeatherIndexes') AllWeatherIndexes: Array<WeatherIndex[]> = []
  @StorageLink('ShownCities') ShownCities: ShownCity[] = []
  @StorageLink('CurrentLocationName') CurrentLocationName: string = ""
  aboutToAppear(): void {
    let CurrentDate = new Date()
    let hours=CurrentDate.getHours()
    let minutes=CurrentDate.getMinutes()
    let formattedHours=String(hours).padStart(2, '0');
    let formattedMinutes=String(minutes).padStart(2, '0');
    this.CurrentTime = formattedHours + ':' + formattedMinutes
  }
  // 提取obsTime中的时间部分
  extractTimeFromObsTime(obsTime: string): string {
    let date = new Date(obsTime)
    let time: string = date.getHours() + ':' + date.getMinutes()+'0'
    return time
  }
  // 提取fxDate中的日期部分
  extractDateFromFxDate(fxDate: string): string {
    let date = new Date(fxDate)
    let month: string = (date.getMonth() + 1)+''
    let day: string = date.getDate() + ''
    return month + '月' + day + '日'
  }
  // 输入日期时，返回对应的星期几
  extractWeekFromDate(fxDate: string): string {
    let date = new Date(fxDate);
    let dayOfWeek = date.getDay();
		switch (dayOfWeek) {
			case 0:
				return '星期日';
      case 1:
        return '星期一';
      case 2:
        return '星期二';
      case 3:
        return '星期三';
      case 4:
        return '星期四';
      case 5:
        return '星期五';
      case 6:
        return '星期六';
      default:
        return '未知';
		}
	}
  // 输入时间，计算时间差
  calculateMinutesDifference(time1: string, time2:string) {
    let differenceInMinutes: number=0
    // 解析时间字符串为 Date 对象
    try {
      let parts1:string[] = time1?.split(':');
      let hours1 = parseInt(parts1[0], 10);
      let minutes1 = parseInt(parts1[1], 10);
      let parts2: string[] = time2?.split(':');
      let hours2 = parseInt(parts2[0], 10);
      let minutes2 = parseInt(parts2[1], 10);

      let date1 = new Date(0, 0, 0, hours1, minutes1, 0);
      let date2 = new Date(0, 0, 0, hours2, minutes2, 0);
      // 计算时间差（以毫秒为单位）
      let differenceInMilliseconds = Math.abs(date2?.getTime() - date1?.getTime());
      // 将时间差转换为分钟数
      differenceInMinutes = differenceInMilliseconds / (1000 * 60);
      console.info('模拟器时间差：' + differenceInMinutes + '分钟');
    }catch (err){
    }
    return differenceInMinutes;
}
  // 渲染函数
  render(context: CanvasRenderingContext2D,index: number){
    // 确定绘制比例
    let height: number = 250;
    let maxTemperature: number = -Infinity;
    let minTemperature: number = Infinity;
    // 计算最大和最小温度
    this.AllDailyWeathers[index].forEach((item) => {
      maxTemperature = Math.max(maxTemperature, item.tempMax);
      minTemperature = Math.min(minTemperature, item.tempMin);
    });
    let step: number = (height * 0.2) / (maxTemperature - minTemperature);
    // 设置曲线的样式
    context.lineWidth = 1;
    context.fillStyle = '#fff6f4f4';
    context.strokeStyle = '#fff6f3f3';
    context.globalAlpha = 1;
    // 存放坐标的数组
    let xPos: number[] = [];
    let highYPos: number[] = [];
    let lowYPos: number[] = [];
    this.AllDailyWeathers[index].forEach((item, index) => {
      // 计算坐标
      let x: number = index==0?this.ItemStart:index * this.ItemWith + 40
      let yHeight: number = height - (item.tempMax - minTemperature) * step;
      let yLow: number = height - (item.tempMin - minTemperature) * step;
      xPos.push(x);
      highYPos.push(yHeight);
      lowYPos.push(yLow);
      // 描点
      let region: Path2D = new Path2D();
      region.ellipse(x, yHeight, 3, 3, 0, 0, Math.PI * 2);
      region.ellipse(x, yLow, 3, 3, 0, 0, Math.PI * 2);
      context.fill(region);
      context.font = 'normal bold 50px';
      // 绘制星期
      let weekStr: string = index==0?'今天':index==1?'明天':this.extractWeekFromDate(item.fxDate);
      context.fillText(weekStr, x - context.measureText(weekStr).width / 2, 20);
      // 绘制日期
      let dateStr: string = this.extractDateFromFxDate(item.fxDate);
      context.fillText(dateStr, x - context.measureText(dateStr).width / 2, 50);
      // 绘制天气图标
      let img:ImageBitmap = new ImageBitmap(`/common/images/${item.iconDay}.svg`)
      this.offContext.drawImage(img, x-15, 70, 30, 30);
      this.offContext.globalCompositeOperation = 'source-atop';
      this.offContext.fillStyle = 'rgba(255, 255, 255, 1)';
      this.offContext.fillRect(x-15, 70, 30, 30)
      let image = this.offContext.transferToImageBitmap();
      context.transferFromImageBitmap(image);
      // 绘制天气文字描述
      context.fillText(item.textDay, x - context.measureText(item.textDay).width / 2, 120);
      context.font = 'normal 70px';
      // 准备气温文字
      let highTemperatureStr: string = `${item.tempMax}℃`;
      let lowTemperatureStr: string = `${item.tempMin}℃`;
      // 绘制高温点文字
      context.fillText(highTemperatureStr, x - context.measureText(highTemperatureStr).width / 2, yHeight - 30);
      // 绘制低温点文字
      context.fillText(lowTemperatureStr, x - context.measureText(lowTemperatureStr).width / 2, yLow + 30);
    });
    this.offContext.clearRect(0,0,600,600)
    // 绘制高温曲线
    context.beginPath();
    context.moveTo(xPos[0], highYPos[0]);
    this.AllDailyWeathers[index].forEach((item, index) => {
      if (index === 0) return;
      let x0: number = index * this.ItemWith;
      let y0: number = height - (item.tempMax - minTemperature) * step;
      context.bezierCurveTo(x0, y0, xPos[index] - (xPos[index] - xPos[index - 1]) * 0.3, highYPos[index - 1], xPos[index], highYPos[index]);
    });
    context.stroke();
    // 绘制低温曲线
    context.beginPath();
    context.moveTo(xPos[0], lowYPos[0]);
    this.AllDailyWeathers[index].forEach((item, index) => {
      if (index === 0) return;
      let x0: number = index * this.ItemWith;
      let y0: number = height - (item.tempMin - minTemperature) * step;
      context.bezierCurveTo(x0, y0, xPos[index] - (xPos[index] - xPos[index - 1]) * 0.3, lowYPos[index - 1], xPos[index], lowYPos[index]);
    });
    context.stroke();
  }
  // 更新信息
  async updateInfo(index: number) {
    // 通过网络请求数据
    let currentWeather = await NetworkDataFetcher.getRealtimeWeather(this.ShownCities[index].Location);
    let hourlyWeather = await NetworkDataFetcher.getHourlyWeather(this.ShownCities[index].Location);
    let dailyWeather = await NetworkDataFetcher.getDailyWeather(this.ShownCities[index].Location);
    let airQuality = await NetworkDataFetcher.getAirQuality(this.ShownCities[index].Location);
    let weatherIndex = await NetworkDataFetcher.getWeatherIndex(this.ShownCities[index].Location);
    // 删除数据库中的数据
    await StoreManager.deleteCurrentWeather(getContext(this),this.CurrentWeathers[index])
    await StoreManager.deleteHourlyWeathers(getContext(this),this.AllHourlyWeathers[index])
    await StoreManager.deleteDailyWeathers(getContext(this),this.AllDailyWeathers[index])
    await StoreManager.deleteRealtimeAirQuality(getContext(this),this.CurrentAirQualities[index])
    await StoreManager.deleteWeatherIndex(getContext(this),this.AllWeatherIndexes[index])
    // 添加数据
    await StoreManager.addCurrentWeather(getContext(this),currentWeather)
    await StoreManager.addHourlyWeathers(getContext(this),hourlyWeather)
    await StoreManager.addDailyWeathers(getContext(this),dailyWeather)
    await StoreManager.addRealtimeAirQuality(getContext(this),airQuality)
    await StoreManager.addWeatherIndex(getContext(this),weatherIndex)
    // 刷新数据
    this.CurrentWeathers[index] = currentWeather;
    this.AllHourlyWeathers[index] = hourlyWeather;
    this.AllDailyWeathers[index] = dailyWeather;
    this.CurrentAirQualities[index] = airQuality;
    this.AllWeatherIndexes[index] = weatherIndex;
    console.info('模拟器-更新数据')
  }
  //构建菜单按钮
  @Builder menu() {
    SymbolGlyph($r('sys.symbol.dot_grid_2x2'))
      .fontSize(30)
      .fontColor([Color.White])
      .fontWeight(FontWeight.Bold)
      .bindMenu([
        {
          value: '管理城市',
          action: () => {
            router.pushUrl({
              url: 'pages/Cities'
            })
            console.info('模拟器-管理城市')
          }
        },// 管理城市
        {
          value: '桌面天气',
          action: async () => {
            router.pushUrl({
              url: 'pages/Desktop'
            })
            console.info('模拟器-桌面天气')
          }
        },
      ])
  }
  //构建TabContent
  @Builder WeatherBuilder(index: number){
    Refresh({ refreshing: $$this.isRefreshing}) {
      Scroll(this.scroller){
        Column(){
          this.CurrentWeatherBuilder(index)
          this.HourlyWeatherBuilder(index)
          this.TitleBuilder("近日天气",5,0)
          this.DailyWeatherBuilder(index)
          this.TitleBuilder("",2,0)
          this.MoreDailyWeatherBuilder(index)
          this.TitleBuilder("空气质量",5,0.8)
          this.CurrentAirQualityBuilder(index)
          this.TitleBuilder("舒适度",5,0.8)
          this.ComfortBuilder(index)
          this.TitleBuilder("风向风力",5,0.8)
          this.WindBuilder(index)
          this.TitleBuilder("日出日落",5,0.8)
          this.SunriseSunsetBuilder(index)
          this.TitleBuilder("",4,0)
          this.FooterBuilder()
        }
      }
      .width('100%')
      .onWillScroll((xOffset: number, yOffset: number, scrollState: ScrollState) => {
        this.yOffset[this.index] += yOffset
      })
    }
    .onStateChange((refreshStatus: RefreshStatus) => {
      console.info('Refresh onStatueChange state is ' + refreshStatus)
    })
    .onOffsetChange((offset: number) => {
      this.ratio = 1 - Math.pow((offset / 100.0), 3)
      console.info('Refresh onOffsetChange offset is ' + offset)
    })
    .onRefreshing(async () => {
      await this.updateInfo(index)
      this.isRefreshing=false
      console.log('模拟器更新信息')
    })
    .refreshOffset(64)
    .pullToRefresh(true)
    .pullDownRatio(this.ratio)
  }
  //构建tabBar
  @Builder tabBuilder(index: number) {
    SymbolGlyph($r(this.index===index?'sys.symbol.smallcircle_filled_circle':'sys.symbol.circle'))
      .fontSize(10)
      .fontColor([Color.White])
      .fontWeight(FontWeight.Bold)
      .width(20)
  }
  //构建标题空格行
  @Builder TitleBuilder(title:string,height:number,opacity:number) {
    Row(){
      Text(title)
        .fontSize(20)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Bold)
        .width('85%')
      Text("更多  >")
        .fontSize(18)
        .fontColor(Color.White)
        .opacity(opacity)
    }
    .width('85%')
    .height(`${height}%`)
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.SpaceBetween)
  }
  //空气质量半扇型进度条构建
  @Builder CurrentAirQualityGaugeBuilder(index:number){
    Stack(){
      Gauge({value:this.CurrentAirQualities[index]?.aqi,max:500}){
        Column(){
          Text(this.CurrentAirQualities[index]?.category)
            .fontSize(20)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
          Text(`${this.CurrentAirQualities[index]?.aqi}`)
            .fontSize(40)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
        }
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')
      .height(150)
      .startAngle(210)
      .endAngle(150)
      .strokeWidth(10)
      .colors([[Color.Green, this.CurrentAirQualities[index]?.aqi/500], ['#99fdfdfd', 1 - this.CurrentAirQualities[index]?.aqi/500]])
      .indicator(null)
      .trackShadow(null)
      .description(null)
      Row({space: 60}){
        Text('0')
          .fontSize(15)
          .fontColor(Color.White)
          .opacity(0.9)
        Text('500')
          .fontSize(15)
          .fontColor(Color.White)
          .opacity(0.9)
      }
      .height('5%')
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)
    }
    .alignContent(Alignment.Bottom)
  }
  //舒适度半扇型进度条构建
  @Builder ComfortGaugeBuilder(index:number){
    Stack(){
      Gauge({value:this.CurrentWeathers[index]?.humidity,max:100}){
        Column(){
          Text(`${this.CurrentWeathers[index]?.humidity}%`)
            .fontSize(45)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
        }
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')
      .height(150)
      .startAngle(210)
      .endAngle(150)
      .strokeWidth(10)
      .colors([[Color.White, this.CurrentWeathers[index]?.humidity/100], ['#99fdfdfd', 1 - this.CurrentWeathers[index]?.humidity/100]])
      .indicator(null)
      .trackShadow(null)
      .description(null)
      Row({space: 60}){
        Text('0')
          .fontSize(15)
          .fontColor(Color.White)
          .opacity(0.9)
        Text('100')
          .fontSize(15)
          .fontColor(Color.White)
          .opacity(0.9)
      }
      .height('5%')
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)
    }
    .alignContent(Alignment.Bottom)
  }
  //构建实时天气信息
  @Builder CurrentWeatherBuilder(index: number) {
    Column({space: 10}){
      Stack(){
        SymbolGlyph($r('sys.symbol.local_fill'))
          .fontSize(20)
          .fontColor([Color.White])
          .fontWeight(FontWeight.Bold)
          .margin({left:'30%'})
          .opacity(this.ShownCities[index]?.Name==this.CurrentLocationName?1:0)
        Text(`${this.ShownCities[index]?.Name}`)
          .fontSize(20)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
      }
      Row(){
        Text(`${this.CurrentWeathers[index]?.temp||'--'}`)
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
      Text(`${this.AllDailyWeathers[index]?.[0]?.tempMax||0}℃/${this.AllDailyWeathers[index]?.[0]?.tempMin||0}℃`)
        .fontSize(20)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center)
      Text(`${this.CurrentWeathers[index]?.text||'--'} 空气${this.CurrentAirQualities[index]?.category||'--'}`)
        .fontSize(20)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center)
    }
    .width('95%')
    .height('45%')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .opacity((60-this.yOffset[index])/60)
  }
  //构建逐小时天气预报
  @Builder HourlyWeatherBuilder(index: number) {
    List(){
      ForEach(this.AllHourlyWeathers[index],(item: HourlyWeather, index:number)=>{
        ListItem(){
          Column({space: 20}){
            Text(`${this.extractTimeFromObsTime(item.fxTime)}`)
              .fontSize(20)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
            Image($r(`app.media.${item.icon}`))
              .fillColor(Color.White)
              .width(30)
              .height(30)
            Text(item.temp+"℃")
              .fontSize(20)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
          }
          .width(80)
          .height('20%')
          .margin({top:'5%'})
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.Start)
        }
      })
    }
    .width('95%')
    .height('20%')
    .borderRadius(10)
    .backgroundColor('#996d6d6d')
    .listDirection(Axis.Horizontal)
    .alignListItem(ListItemAlign.Start)
  }
  //构建每日天气预报
  @Builder DailyWeatherBuilder(index:number) {
    Scroll(){
      Canvas(this.context)
        .width(this.ItemStart*2+this.ItemWith*6)
        .height(300)
        .onReady(()=>{
          this.render(this.context,index)
        })
    }
    .width('95%')
    .height('45%')
    .borderRadius(10)
    .backgroundColor('#996d6d6d')
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
  }
  //构建查看多天天气预报
  @Builder MoreDailyWeatherBuilder(index: number) {
    Row(){
      Text("查看多天预报 >")
        .fontSize(15)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center)
    }
    .width('95%')
    .height('6%')
    .borderRadius(10)
    .backgroundColor('#996d6d6d')
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }
  //构建实时空气质量信息
  @Builder CurrentAirQualityBuilder(index: number) {
    Row(){
      Column({space: 10}){
        Text('污染指数')
          .fontSize(15)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
        this.CurrentAirQualityGaugeBuilder(index)
      }
      .width('40%')
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.End)
      .margin({left:'10%'})
      Column({space: 10}){
        Text("PM10")
          .fontSize(15)
          .fontColor(Color.White)
          .opacity(0.8)
        Text("PM2.5")
          .fontSize(15)
          .fontColor(Color.White)
          .opacity(0.8)
        Text("NO₂")
          .fontSize(15)
          .fontColor(Color.White)
          .opacity(0.8)
        Text("SO₂")
          .fontSize(15)
          .fontColor(Color.White)
          .opacity(0.8)
        Text("O₃")
          .fontSize(15)
          .fontColor(Color.White)
          .opacity(0.8)
        Text("CO")
          .fontSize(15)
          .fontColor(Color.White)
          .opacity(0.8)
      }
      .width('20%')
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
      .margin({left:'10%'})
      Column({space: 10}){
        Text(`${this.CurrentAirQualities[index]?.pm10}`)
          .fontSize(15)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
        Text(`${this.CurrentAirQualities[index]?.pm2p5}`)
          .fontSize(15)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
        Text(`${this.CurrentAirQualities[index]?.no2}`)
          .fontSize(15)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
        Text(`${this.CurrentAirQualities[index]?.so2}`)
          .fontSize(15)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
        Text(`${this.CurrentAirQualities[index]?.o3}`)
          .fontSize(15)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
        Text(`${this.CurrentAirQualities[index]?.co}`)
          .fontSize(15)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
      }
      .width('20%')
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
      .margin({right:'10%'})
    }
    .width('95%')
    .height('30%')
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .borderRadius(10)
    .backgroundColor('#996d6d6d')
  }
  //构建舒适度信息
  @Builder ComfortBuilder(index: number) {
    Column({space: 20}){
      Row(){
        Column({space: 10}){
          Text('空气湿度')
            .fontSize(15)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
          this.ComfortGaugeBuilder(index)
        }
        .width('40%')
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.End)
        .margin({left:'10%'})
        Column({space: 10}){
          Text("体感温度")
            .fontSize(15)
            .fontColor(Color.White)
            .opacity(0.8)
          Text("紫外线指数")
            .fontSize(15)
            .fontColor(Color.White)
            .opacity(0.8)
        }
        .width('21%')
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Start)
        .margin({left:'10%'})
        Column({space: 10}){
          Text(`${this.CurrentWeathers[index]?.feelsLike}℃`)
            .fontSize(15)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
          Text(`${this.AllWeatherIndexes[index]?.[4]?.level}   ${this.AllWeatherIndexes[index]?.[4]?.category}`)
            .fontSize(15)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
        }
        .width('20%')
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Start)
      }
      Row(){
        Column({space: 5}){
          Image($r('app.media.tourism'))
            .fillColor(Color.White)
            .width(30)
            .height(30)
          Text('旅游')
            .fontSize(15)
            .fontColor(Color.White)
            .opacity(0.8)
          Text(`${this.AllWeatherIndexes[index]?.[5]?.category}`)
            .fontSize(16)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
        }
        Column({space: 5}){
          Image($r('app.media.sports'))
            .fillColor(Color.White)
            .width(30)
            .height(30)
          Text('运动')
            .fontSize(15)
            .fontColor(Color.White)
            .opacity(0.8)
          Text(`${this.AllWeatherIndexes[index]?.[0]?.category}`)
            .fontSize(16)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
        }
        Column({space: 5}){
          Image($r('app.media.cold'))
            .fillColor(Color.White)
            .width(30)
            .height(30)
          Text('感冒')
            .fontSize(15)
            .fontColor(Color.White)
            .opacity(0.8)
          Text(`${this.AllWeatherIndexes[index]?.[8]?.category}`)
            .fontSize(16)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
        }
        Column({space: 5}){
          Image($r('app.media.wash'))
            .fillColor(Color.White)
            .width(30)
            .height(30)
          Text('洗车')
            .fontSize(15)
            .fontColor(Color.White)
            .opacity(0.8)
          Text(`${this.AllWeatherIndexes[index]?.[1]?.category}`)
            .fontSize(16)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
        }
      }
      .width('80%')
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceAround)
    }
    .width('95%')
    .height('45%')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .borderRadius(10)
    .backgroundColor('#996d6d6d')
  }
  //构建风向风力
  @Builder WindBuilder(index: number) {
    Row(){
      Stack(){
        Image($r('app.media.windmill'))
          .width(150)
          .height(150)
        Image($r('app.media.windmill'))
          .width(120)
          .height(120)
          .margin({ left: '40%' ,top: '12%'})
      }
      .alignContent(Alignment.Start)
      .width('40%')
      .margin({left:'5%',right:'5%'})
      Column({space: 10}){
        Text("风向")
          .fontSize(15)
          .fontColor(Color.White)
          .opacity(0.8)
        Text("风力")
          .fontSize(15)
          .fontColor(Color.White)
          .opacity(0.8)
      }
      .width('21%')
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
      .margin({left:'10%'})
      Column({space: 10}){
        Text(`${this.CurrentWeathers[index]?.windDir}`)
          .fontSize(15)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
        Text(`${this.windLevelTerms[this.CurrentWeathers[index]?.windScale]}`)
          .fontSize(15)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
      }
      .width('20%')
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
    }
    .width('95%')
    .height('25%')
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .borderRadius(10)
    .backgroundColor('#996d6d6d')
  }
  //构建日出日落
  @Builder SunriseSunsetBuilder(index: number) {
    Stack(){
      Gauge({value:Math.min(this.calculateMinutesDifference(this.AllDailyWeathers[index]?.[0]?.sunrise,this.CurrentTime),this.calculateMinutesDifference(this.AllDailyWeathers[index]?.[0]?.sunrise,this.AllDailyWeathers[index]?.[0]?.sunset)),max:this.calculateMinutesDifference(this.AllDailyWeathers[index]?.[0]?.sunrise,this.AllDailyWeathers[index]?.[0]?.sunset)}){
      }
      .width('100%')
      .height(300)
      .startAngle(270)
      .endAngle(90)
      .strokeWidth(2)
      .colors(Color.White)
      .indicator({ icon: $r('app.media.sun'),space: 10})
      .trackShadow(null)
      .description(null)
      .alignSelf(ItemAlign.Center)
      .margin({left:'20%',top:'30%'})
      Text("———————————————————————")
        .fontColor(Color.White)
        .margin({top:'33%'})
      Row({space: 250}){
        Text(`${this.AllDailyWeathers[index]?.[0]?.sunrise}`)
          .fontSize(15)
          .fontColor(Color.White)
          .opacity(0.9)
        Text(`${this.AllDailyWeathers[index]?.[0]?.sunset}`)
          .fontSize(15)
          .fontColor(Color.White)
          .opacity(0.9)
      }
      .height('5%')
      .margin({top:'40%'})
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)
      Row({space: 15}){
        Image($r(`app.media.${this.AllDailyWeathers[index]?.[0]?.moonPhaseIcon}`))
          .fillColor(Color.White)
          .width(20)
          .height(20)
        Text(`${this.AllDailyWeathers[index]?.[0]?.moonPhase}`)
          .fontSize(15)
          .fontColor(Color.White)
          .opacity(0.9)
      }
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .margin({top:'45%'})
    }
    .width('95%')
    .height('30%')
    .borderRadius(10)
    .backgroundColor('#996d6d6d')
    .alignContent(Alignment.Center)
  }
  //构建底部说明
  @Builder FooterBuilder() {
    Column(){
      Row(){
        Text("Powered by ")
          .fontSize(15)
          .fontColor(Color.White)
          .opacity(0.8)
          .textAlign(TextAlign.Center)
        Text("和风天气")
          .fontSize(15)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
          .opacity(0.8)
          .textAlign(TextAlign.Center)
      }
      Row(){
        Text("Copyright © 2024 ")
          .fontSize(15)
          .fontColor(Color.White)
          .opacity(0.8)
          .textAlign(TextAlign.Center)
        Text("Flow2Power")
          .fontSize(15)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
          .opacity(0.8)
          .textAlign(TextAlign.Center)
        Text(". All rights reserved.")
          .fontSize(15)
          .fontColor(Color.White)
          .opacity(0.8)
          .textAlign(TextAlign.Center)
      }
      Text("Version 1.0.0")
        .fontSize(15)
        .fontColor(Color.White)
        .opacity(0.8)
        .textAlign(TextAlign.Center)
    }
  }
  build() {
    Column(){
      Stack(){
        Text(`${this.ShownCities[this.index]?.Name}`)
          .fontSize(20)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .opacity(this.yOffset[this.index]>60?1:0)
        SymbolGlyph($r('sys.symbol.local_fill'))
          .fontSize(20)
          .fontColor([Color.White])
          .fontWeight(FontWeight.Bold)
          .margin({left:'30%'})
          .opacity(this.ShownCities[this.index]?.Name==this.CurrentLocationName?this.yOffset[this.index]>60?1:0:0)
        Row(){
          this.menu()
        }
        .width('100%')
        .alignItems(VerticalAlign.Bottom)
        .justifyContent(FlexAlign.End)
      }
      .width('95%')
      .height('10%')
      .alignContent(Alignment.Bottom)
      Tabs(){
        ForEach(this.ShownCities,(item: ShownCity, index:number)=>{
          TabContent(){
            this.WeatherBuilder(index)
          }
          .tabBar(this.tabBuilder(index))
        },(item: ShownCity)=>item.Location)
      }
      .onChange((index: number)=>{
        this.index = index
        console.info(`模拟器切换到第${index}个Tab`)
      })
      .barWidth('30%')
      .barHeight('5%')
      .fadingEdge(false)
      .barMode(BarMode.Scrollable)
      .barPosition(BarPosition.End)
      .width('100%')
      .height('90%')
    }
    .width('100%')
    .backgroundImage($r('app.media.MyBackground'))
    .backgroundImageSize(ImageSize.Cover)
  }
}