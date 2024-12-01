import { ValuesBucket } from "@kit.ArkData";

//城市搜索数据接口
interface ReferInfo {
  sources: string[];  // 数据来源
  license: string[];  // 许可证
}
export interface CityInfo {
  name: string;       // 城市名称
  id: string;         // 城市ID
  lat: string;        // 纬度
  lon: string;        // 经度
  adm2: string;       // 区县
  adm1: string;       // 城市
  country: string;    // 国家
  tz: string;         // 时区
  utcOffset: string;  // UTC偏移量
  isDst: string;      // 是否夏令时
  type: string;       // 类型
  rank: string;       // 排名
  fxLink: string;     // 天气预报链接
}
export interface LocationResponse {
  code: string;       // 响应码
  location: CityInfo[]; // 城市信息数组
  refer: ReferInfo;   // 引用信息
}
//实时天气数据接口
interface Source {
  sources: string[];
  license: string[];
}
export interface RealtimeWeather extends ValuesBucket {
  id:number|null;
  Location: string;
  obsTime: string;
  temp: string;
  feelsLike: string;
  icon: string;
  text: string;
  wind360: string;
  windDir: string;
  windScale: number;
  windSpeed: string;
  humidity: number;
  precip: string;
  pressure: string;
  vis: string;
  cloud: string;
  dew: string;
  fxLink: string;
}
export interface RealtimeWeatherResponse {
  code: string;
  updateTime: string;
  fxLink: string;
  now: RealtimeWeather;
  refer: Source;
}
//逐小时天气预报数据接口
interface Refer {
  sources: string[];
  license: string[];
}
export interface HourlyWeather extends ValuesBucket {
  id:number|null;
  Location: string;
  fxTime: string;
  temp: string;
  icon: string;
  text: string;
  wind360: number;
  windDir: string;
  windScale: string;
  windSpeed: number;
  humidity: number;
  pop: number;
  precip: number;
  pressure: number;
  cloud: number;
  dew: number;
  fxLink: string;
}
export interface HourlyWeatherResponse {
  code: string;
  updateTime: string;
  fxLink: string;
  hourly: HourlyWeather[];
  refer: Refer;
}
//每日天气预报数据接口
export interface DailyWeather extends ValuesBucket {
  id:number|null;
  Location: string;
  fxDate: string;
  sunrise: string;
  sunset: string;
  moonrise: string;
  moonset: string;
  moonPhase: string;
  moonPhaseIcon: string;
  tempMax: number;
  tempMin: number;
  iconDay: string;
  textDay: string;
  iconNight: string;
  textNight: string;
  wind360Day: string;
  windDirDay: string;
  windScaleDay: string;
  windSpeedDay: string;
  wind360Night: string;
  windDirNight: string;
  windScaleNight: string;
  windSpeedNight: string;
  humidity: string;
  precip: string;
  pressure: string;
  vis: string;
  cloud: string;
  uvIndex: string;
  fxLink: string;
}
export interface DailyWeatherResponse {
  code: string;
  updateTime: string;
  fxLink: string;
  daily: DailyWeather[];
  refer: Refer;
}
//实时空气质量数据接口
interface AirQualityStation {
  pubTime: string;
  name: string;
  id: string;
  aqi: string;
  level: string;
  category: string;
  primary: string;
  pm10: string;
  pm2p5: string;
  no2: string;
  so2: string;
  co: string;
  o3: string;
}
export interface RealtimeAirQuality extends ValuesBucket {
  id:number|null;
  Location: string;
  pubTime: string;
  aqi: number;
  level: string;
  category: string;
  pm10: string;
  pm2p5: string;
  no2: string;
  so2: string;
  co: string;
  o3: string;
  fxLink: string;
}
export interface RealtimeAirQualityResponse {
  code: string;
  updateTime: string;
  fxLink: string;
  now: RealtimeAirQuality
  station: AirQualityStation[];
  refer: Refer
}
//天气指数数据接口
export interface WeatherIndex extends ValuesBucket {
  id:number|null;
  Location: string;
  date: string;       // 日期
  type: string;       // 指数类型
  name: string;       // 指数名称
  level: string;      // 指数级别
  category: string;   // 指数类别
  text: string;       // 指数描述
  fxLink: string;     // 预报链接
}
export interface WeatherIndexResponse {
  code: string;       // 响应码
  updateTime: string; // 更新时间
  fxLink: string;     // 预报链接
  daily: WeatherIndex[]; // 生活指数数组
  refer: Refer;       // 引用信息
}
//ShownCity数据接口
export interface ShownCity extends ValuesBucket {
  id:number|null;
  Name: string;
  Location: string;
  LocationId: string;
}
//获取的天气数据
export interface WeatherData {
  currentWeather: RealtimeWeather;
  hourlyWeather: HourlyWeather[];
  dailyWeather: DailyWeather[];
  airQuality: RealtimeAirQuality;
  weatherIndex: WeatherIndex[];
}
//热门城市
export interface TopCity {
  name: string;
  id: string;
  lat: string;
  lon: string;
  adm2: string;
  adm1: string;
  country: string;
  tz: string;
  utcOffset: string;
  isDst: string;
  type: string;
  rank: string;
  fxLink: string;
}
export interface ReferSources {
  sources: string[];
  license: string[];
}
export interface topCityResponse {
  code: string;
  topCityList: TopCity[];
  refer: ReferSources;
}
//桌面卡片
export interface CardData {
  ShownCityName: string;
  CurrentLocationName: string;
  tempMax: number;
  tempMin: number;
  weather: string;
  airLevel: string;
  date: string;
  week: string;
  weatherIcon: string;
  category1: string;
  category2: string;
  category3: string;
  category4: string;
}

