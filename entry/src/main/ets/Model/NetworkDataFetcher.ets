import { rcp } from '@kit.RemoteCommunicationKit';
import {
  CityInfo,
  DailyWeather,
  DailyWeatherResponse,
  HourlyWeather,
  HourlyWeatherResponse,
  LocationResponse,
  RealtimeAirQuality,
  RealtimeAirQualityResponse,
  RealtimeWeather, RealtimeWeatherResponse,
  ShownCity,
  topCityResponse,
  WeatherIndex,
  WeatherIndexResponse } from './DataInterface';
import { BusinessError } from '@kit.BasicServicesKit';

export class NetworkDataFetcher {
  private static key: string = '589e95d506024b67b892ac138ef465ec';
  private static session = rcp.createSession();
  public static modifyFxLinkToAdd30d(fxLink: string): string {
    // 找到第一个 "weather" 的位置
    const firstWeatherIndex = fxLink.indexOf("weather");
    if (firstWeatherIndex === -1) {
      console.error("URL 中未找到 'weather'");
      return fxLink;
    }
    // 从第一个 "weather" 的位置之后开始查找第二个 "weather"
    const secondWeatherIndex = fxLink.indexOf("weather", firstWeatherIndex + "weather".length);
    if (secondWeatherIndex === -1) {
      console.error("URL 中未找到第二个 'weather'");
      return fxLink;
    }
    // 在第二个 "weather" 后面插入 "30d"
    const modifiedLink = fxLink.slice(0, secondWeatherIndex + "weather".length) + "30d" + fxLink.slice(secondWeatherIndex + "weather".length);
    return modifiedLink;
  }

  // 城市搜索
  public static async getCityInfo(location: string): Promise<CityInfo[]> {
    let CityInfos: CityInfo[] = [];
    try{
      let response =await NetworkDataFetcher.session.get(`https://geoapi.qweather.com/v2/city/lookup?key=${NetworkDataFetcher.key}&location=${location}`)
      let data: LocationResponse = response.toJSON() as LocationResponse
      CityInfos = data.location
    }catch (err){
      let error: BusinessError = err as BusinessError;
      console.error(`模拟器获取城市信息失败: Code is ${error.code}, message is ${error.message}`)
    }
    return CityInfos
  }
  // 实时天气信息
  public static async getRealtimeWeather(location: string): Promise<RealtimeWeather> {
    let realtimeWeather:RealtimeWeather= {
      id: null,
      Location: '',
      obsTime: '',
      temp: '',
      feelsLike: '',
      icon: '',
      text: '',
      wind360: '',
      windDir: '',
      windScale: 0,
      windSpeed: '',
      humidity: 0,
      precip: '',
      pressure: '',
      vis: '',
      cloud: '',
      dew: '',
      fxLink: '',
    }
    try {
      let response =await NetworkDataFetcher.session.get(`https://devapi.qweather.com/v7/weather/now?key=${NetworkDataFetcher.key}&location=${location}`)
      let data: RealtimeWeatherResponse = response.toJSON() as RealtimeWeatherResponse
      realtimeWeather = data.now
      realtimeWeather.fxLink = data.fxLink
      realtimeWeather.Location = location
      console.info('模拟器获取实时天气成功'+JSON.stringify(realtimeWeather))
    }catch (err){
      let error: BusinessError = err as BusinessError;
      console.error(`模拟器获取实时天气失败: Code is ${error.code}, message is ${error.message}`)
    }
    return realtimeWeather
  }
  // 逐小时天气预报
  public static async getHourlyWeather(location: string): Promise<HourlyWeather[]> {
    let hourlyWeathers: HourlyWeather[] = [];
    try {
      let response =await NetworkDataFetcher.session.get(`https://devapi.qweather.com/v7/weather/24h?key=${NetworkDataFetcher.key}&location=${location}&lang=zh-hans`)
      let data: HourlyWeatherResponse = response.toJSON() as HourlyWeatherResponse
      hourlyWeathers = data.hourly
      hourlyWeathers[0].fxLink = data.fxLink
      hourlyWeathers.forEach(item => {
        item.Location = location
      })
      console.info('模拟器获取逐小时天气预报成功'+JSON.stringify(hourlyWeathers))
    }catch (err){
      let error: BusinessError = err as BusinessError;
      console.error(`模拟器获取逐小时天气预报失败: Code is ${error.code}, message is ${error.message}`)
    }
    return hourlyWeathers;
  }
  // 每日天气预报
  public static async getDailyWeather(location: string): Promise<DailyWeather[]> {
    let dailyWeather: DailyWeather[] = []
    try {
      let response =await NetworkDataFetcher.session.get(`https://devapi.qweather.com/v7/weather/7d?key=${NetworkDataFetcher.key}&location=${location}&lang=zh-hans`)
      let data: DailyWeatherResponse = response.toJSON() as DailyWeatherResponse
      dailyWeather = data.daily
      dailyWeather[0].fxLink = NetworkDataFetcher.modifyFxLinkToAdd30d(data.fxLink)
      dailyWeather.forEach(item => {
        item.Location = location
      })
      console.info('模拟器获取每日天气预报成功'+JSON.stringify(dailyWeather))
    }catch (err){
     let error: BusinessError = err as BusinessError;
     console.error(`模拟器获取每日天气预报失败: Code is ${error.code}, message is ${error.message}`)
    }
    return dailyWeather
  }
  // 实时空气质量
  public static async getAirQuality(location: string): Promise<RealtimeAirQuality> {
    let realtimeAirQuality:RealtimeAirQuality= {
      id: null,
      Location: '',
      pubTime: '',
      aqi: 0,
      level: '',
      category: '',
      pm10: '',
      pm2p5: '',
      no2: '',
      so2: '',
      co: '',
      o3: '',
      fxLink: ''
    }
    try {
      let response =await NetworkDataFetcher.session.get(`https://devapi.qweather.com/v7/air/now?key=${NetworkDataFetcher.key}&location=${location}&lang=zh-hans`)
      let data: RealtimeAirQualityResponse = response.toJSON() as RealtimeAirQualityResponse
      // 由于有不需要的primary,故进行单个赋值
      realtimeAirQuality.aqi = data.now.aqi
      realtimeAirQuality.level = data.now.level
      realtimeAirQuality.category = data.now.category
      realtimeAirQuality.pm10 = data.now.pm10
      realtimeAirQuality.pm2p5 = data.now.pm2p5
      realtimeAirQuality.no2 = data.now.no2
      realtimeAirQuality.so2 = data.now.so2
      realtimeAirQuality.co = data.now.co
      realtimeAirQuality.o3 = data.now.o3
      realtimeAirQuality.fxLink = data.fxLink
      realtimeAirQuality.Location = location
      realtimeAirQuality.pubTime = data.now.pubTime
      console.info('模拟器获取实时空气质量成功'+JSON.stringify(realtimeAirQuality))
    }catch (err){
      let error: BusinessError =err as BusinessError;
      console.error(`模拟器获取空气质量失败: Code is ${error.code}, message is ${error.message}`)
    }
    return realtimeAirQuality
  }
  // 天气指数
  public static async getWeatherIndex(location: string): Promise<WeatherIndex[]> {
    let weatherIndex: WeatherIndex[]=[]
    try {
      let response =await NetworkDataFetcher.session.get(`https://devapi.qweather.com/v7/indices/1d?key=${NetworkDataFetcher.key}&location=${location}&type=0&lang=zh-hans`)
      let data:WeatherIndexResponse= response.toJSON() as WeatherIndexResponse
      weatherIndex = data.daily
      weatherIndex[0].fxLink = data.fxLink
      weatherIndex.forEach(item => {
        item.Location = location
      })
      console.info('模拟器获取天气指数成功'+JSON.stringify(weatherIndex))
    }catch (err){
      let error:BusinessError = err as BusinessError;
      console.error(`模拟器获取天气指数失败: Code is ${error.code}, message is ${error.message}`)
    }
    return weatherIndex
  }
  // 热门城市列表
  public static async getRecommendedCities(): Promise<ShownCity[]> {
    let recommendedCities: ShownCity[] = []
    try {
      let response = await NetworkDataFetcher.session.get(`https://geoapi.qweather.com/v2/city/top?key=${NetworkDataFetcher.key}&range=cn`)
      let data: topCityResponse = response.toJSON() as topCityResponse
      data.topCityList.forEach(item => {
        recommendedCities.push({
          id: null,
          Name: item.name,
          Location: item.lon+','+item.lat,
          LocationId: item.id,
        })
      })
      console.info('模拟器获取热门城市列表成功'+JSON.stringify(recommendedCities))
    }catch (err){
      let error: BusinessError = err as BusinessError;
      console.error(`模拟器获取热门城市列表失败: Code is ${error.code}, message is ${error.message}`)
    }
    return recommendedCities;
  }
}
export default NetworkDataFetcher;