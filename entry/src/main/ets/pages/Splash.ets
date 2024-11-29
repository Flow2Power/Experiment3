import router from '@ohos.router'
import { CityInfo, DailyWeather, HourlyWeather, RealtimeAirQuality, RealtimeWeather,
  ShownCity,
  WeatherData,
  WeatherIndex } from '../Model/DataInterface';
import NetworkDataFetcher from '../Model/NetworkDataFetcher';
import StoreManager from '../Model/StoreManager';
import { reqPermissionsFromUser } from '../ViewModel/PermissionsDialog';

@Entry
@Component
struct Splash {
  @StorageLink('yOffset') yOffset: number[] = []
  @StorageLink('CurrentLocation') CurrentLocation: string = ""
  @StorageLink('CurrentLocationName') CurrentLocationName: string = ""
  @StorageLink('ShownCities') ShownCities: ShownCity[] = [{
    id: null,
    Name: '定位中',
    Location: '0,0',
    LocationId: '101010100'
  }]
  @StorageLink('CurrentWeathers') CurrentWeathers: RealtimeWeather[] = []
  @StorageLink('AllHourlyWeathers') AllHourlyWeathers: Array<HourlyWeather[]> = []
  @StorageLink('AllDailyWeathers') AllDailyWeathers: Array<DailyWeather[]> = []
  @StorageLink('CurrentAirQualities') CurrentAirQualities: RealtimeAirQuality[] = []
  @StorageLink('AllWeatherIndexes') AllWeatherIndexes: Array<WeatherIndex[]> = []

  async aboutToAppear() {
    this.CurrentLocation = await reqPermissionsFromUser(getContext(this));
    let CurrentCityInfo = await NetworkDataFetcher.getCityInfo(this.CurrentLocation)
    this.CurrentLocationName = CurrentCityInfo[0].name
    this.ShownCities = await StoreManager.getShownCities(getContext(this))
    if (this.ShownCities.length == 0) {
      let CityInfo: CityInfo[] = await NetworkDataFetcher.getCityInfo(this.CurrentLocation)
      this.ShownCities.push({
        id: null,
        Name: CityInfo[0].name,
        Location: CityInfo[0].lon + ',' + CityInfo[0].lat,
        LocationId: CityInfo[0].id
      })
      this.CurrentLocationName = CityInfo[0].name
      await StoreManager.addShownCity(getContext(this), this.ShownCities[0])
    }
    this.yOffset=new Array(this.ShownCities.length).fill(0)
    // 对每个城市执行相同的操作
    let weatherDataArray = await Promise.all(this.ShownCities.map(async (city) => {
      let locationId = city.LocationId;
      let location = city.Location;
      // 获取实时天气信息
      let currentWeather = await NetworkDataFetcher.getRealtimeWeather(locationId);
      // 获取逐小时天气预报
      let hourlyWeather = await NetworkDataFetcher.getHourlyWeather(locationId);
      // 获取每日天气预报
      let dailyWeather = await NetworkDataFetcher.getDailyWeather(locationId);
      // 获取实时空气质量信息
      let airQuality = await NetworkDataFetcher.getAirQuality(location);
      // 获取天气指数
      let weatherIndex = await NetworkDataFetcher.getWeatherIndex(locationId);
      return {
        currentWeather,
        hourlyWeather,
        dailyWeather,
        airQuality,
        weatherIndex
      } as WeatherData;
    }));
    console.info('模拟器weatherDataArray'+JSON.stringify(weatherDataArray.length))
    weatherDataArray.forEach((weatherData, index) => {
      this.CurrentWeathers.push(weatherData.currentWeather);
      this.AllHourlyWeathers.push(weatherData.hourlyWeather);
      this.AllDailyWeathers.push(weatherData.dailyWeather);
      this.CurrentAirQualities.push(weatherData.airQuality);
      this.AllWeatherIndexes.push(weatherData.weatherIndex);
    })
    router.replaceUrl({ url: 'pages/Index'});
  }
  build() {
    Column(){

    }
    .width('100%')
    .height('100%')
    .backgroundImage($r('app.media.MyBackground'))
    .backgroundImageSize(ImageSize.Cover)
  }
}