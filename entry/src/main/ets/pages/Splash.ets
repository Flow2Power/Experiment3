import router from '@ohos.router'
import { CityInfo, DailyWeather, HourlyWeather, RealtimeAirQuality, RealtimeWeather,
  ShownCity,
  WeatherData,
  WeatherIndex } from '../Model/DataInterface';
import NetworkDataFetcher from '../Model/NetworkDataFetcher';
import PreferencesManager from '../Model/PreferencesManager';
import StoreManager from '../Model/StoreManager';
import { reqPermissionsFromUser } from '../ViewModel/PermissionsDialog';

@Entry
@Component
struct Splash {
  @StorageLink('RecommendedCities') RecommendedCities: ShownCity[] = []
  @StorageLink('yOffset') yOffset: number[] = []
  @StorageLink('CurrentLocation') CurrentLocation: string = ""
  @StorageLink('CurrentLocationName') CurrentLocationName: string = ""
  @StorageLink('ShownCities') ShownCities: ShownCity[] = []
  @StorageLink('CurrentWeathers') CurrentWeathers: RealtimeWeather[] = []
  @StorageLink('AllHourlyWeathers') AllHourlyWeathers: Array<HourlyWeather[]> = []
  @StorageLink('AllDailyWeathers') AllDailyWeathers: Array<DailyWeather[]> = []
  @StorageLink('CurrentAirQualities') CurrentAirQualities: RealtimeAirQuality[] = []
  @StorageLink('AllWeatherIndexes') AllWeatherIndexes: Array<WeatherIndex[]> = []
  @StorageLink('ShownCityName') ShownCityName: string = ""
  @StorageLink('ShownTexts') ShownTexts: string[] = []
  async aboutToAppear() {
    console.info('模拟器Splash-aboutToAppear')
    this.RecommendedCities = await NetworkDataFetcher.getRecommendedCities()
    this.CurrentLocation = await reqPermissionsFromUser(getContext(this));
    let CurrentCityInfo: CityInfo[] = await NetworkDataFetcher.getCityInfo(this.CurrentLocation)
    this.CurrentLocationName = CurrentCityInfo[0].name
    this.ShownCities = await StoreManager.getShownCities(getContext(this))
    if (this.ShownCities.length == 0) {
      await StoreManager.addShownCity(getContext(this), {
        id: null,
        Name: CurrentCityInfo[0].name,
        Location: CurrentCityInfo[0].lon + ',' + CurrentCityInfo[0].lat,
        LocationId: CurrentCityInfo[0].id
      }as ShownCity)
      this.ShownCities = await StoreManager.getShownCities(getContext(this))
    }
    this.CurrentLocation = this.ShownCities[0].Location
    this.ShownCityName = await PreferencesManager.getShownCity(getContext(this))
    if(this.ShownCityName==""){
      this.ShownCityName = this.CurrentLocationName;
      await PreferencesManager.putShownCity(this.ShownCityName,getContext(this));
      await PreferencesManager.putShownCityLocation(this.CurrentLocation, getContext(this));
      await PreferencesManager.putLocationName(this.CurrentLocationName, getContext(this))
    }
    this.yOffset=new Array(this.ShownCities.length).fill(0)
    // 先从数据库全部尝试一次获取，没有再从网络获取
    let currentWeathers = await StoreManager.getCurrentWeathers(getContext(this))
    let allHourlyWeathers = await StoreManager.getHourlyWeathers(getContext(this))
    let allDailyWeathers = await StoreManager.getDailyWeathers(getContext(this))
    let currentAirQualities = await StoreManager.getRealtimeAirQualities(getContext(this))
    let allWeatherIndexes = await StoreManager.getWeatherIndices(getContext(this))
    if(currentWeathers.length==0){
      console.info('模拟器从网络获取天气数据')
      // 对每个城市执行相同的操作
      let weatherDataArray = await Promise.all(this.ShownCities.map(async (city) => {
        let location = city.Location;
        // 获取实时天气信息
        let currentWeather = await NetworkDataFetcher.getRealtimeWeather(location);
        // 获取逐小时天气预报
        let hourlyWeather = await NetworkDataFetcher.getHourlyWeather(location);
        // 获取每日天气预报
        let dailyWeather = await NetworkDataFetcher.getDailyWeather(location);
        // 获取实时空气质量信息
        let airQuality = await NetworkDataFetcher.getAirQuality(location);
        // 获取天气指数
        let weatherIndex = await NetworkDataFetcher.getWeatherIndex(location);
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
      // 保存数据,对每个城市执行相同的操作
      for(let i=0;i<this.ShownCities.length;i++){
        await StoreManager.addCurrentWeather(getContext(this), this.CurrentWeathers[i])
        for(let j=0;j<this.AllHourlyWeathers[i].length;j++){
          await StoreManager.addHourlyWeathers(getContext(this), [this.AllHourlyWeathers[i][j]])
        }
        for(let j=0;j<this.AllDailyWeathers[i].length;j++){
          await StoreManager.addDailyWeathers(getContext(this), [this.AllDailyWeathers[i][j]])
        }
        await StoreManager.addRealtimeAirQuality(getContext(this), this.CurrentAirQualities[i])
        for(let j=0;j<this.AllWeatherIndexes[i].length;j++){
          await StoreManager.addWeatherIndex(getContext(this), [this.AllWeatherIndexes[i][j]])
        }
      }
    }else{
      console.info('模拟器从数据库获取天气数据')
      //对每个城市执行相同的操作
      this.ShownCities.forEach((city: ShownCity) => {
        // 查找当前天气
        const currentWeather = currentWeathers.find(weather => weather.Location === city.Location);
        if (currentWeather) {
          this.CurrentWeathers.push(currentWeather)
        }
        // 查找当前空气质量
        const currentAirQuality = currentAirQualities.find(airQuality => airQuality.Location === city.Location);
        if (currentAirQuality) {
          this.CurrentAirQualities.push(currentAirQuality)
        }
        // 查找所有小时天气并合并
        const hourlyWeathers = allHourlyWeathers.filter(weather => weather.Location === city.Location);
        this.AllHourlyWeathers.push(hourlyWeathers)
        // 查找所有每日天气并合并
        const dailyWeathers = allDailyWeathers.filter(weather => weather.Location === city.Location);
        this.AllDailyWeathers.push(dailyWeathers)
        // 查找所有天气指数并合并
        const weatherIndexes = allWeatherIndexes.filter(index => index.Location === city.Location);
        this.AllWeatherIndexes.push(weatherIndexes)
      });
    }
    this.AllWeatherIndexes.forEach((weatherIndexes: WeatherIndex[], index: number) => {
      let shownText: string = '';
      weatherIndexes.forEach((weatherIndex: WeatherIndex) => {
        shownText = shownText + weatherIndex.text + '   ';
      })
      this.ShownTexts.push(shownText);
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