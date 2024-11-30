import { relationalStore, ValuesBucket } from "@kit.ArkData";
import { BusinessError } from "@kit.BasicServicesKit";
import { DailyWeather, HourlyWeather, RealtimeAirQuality, RealtimeWeather, ShownCity,
  WeatherIndex } from "./DataInterface";

export class StoreManager{
  // 数据库对象
  private static store: relationalStore.RdbStore | null = null
  // 建表语句
  private static createShownCities:string=`
    CREATE TABLE IF NOT EXISTS ShownCity (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      Name TEXT ,
      Location TEXT ,
      LocationId TEXT
    )
  `;// ShownCities
  private static createCurrentWeathers: string = `
  CREATE TABLE IF NOT EXISTS RealtimeWeather (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    Location TEXT,
    obsTime TEXT,
    temp TEXT,
    feelsLike TEXT,
    icon TEXT,
    text TEXT,
    wind360 TEXT,
    windDir TEXT,
    windScale INTEGER,
    windSpeed TEXT,
    humidity INTEGER,
    precip TEXT,
    pressure TEXT,
    vis TEXT,
    cloud TEXT,
    dew TEXT,
    fxLink TEXT
  )
`;// CurrentWeathers
  private static createHourlyWeathers:string=`
  CREATE TABLE IF NOT EXISTS HourlyWeather (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  Location TEXT,
  fxTime TEXT,
  temp TEXT,
  icon TEXT,
  text TEXT,
  wind360 INTEGER,
  windDir TEXT,
  windScale TEXT,
  windSpeed INTEGER,
  humidity INTEGER,
  pop INTEGER,
  precip REAL,
  pressure REAL,
  cloud INTEGER,
  dew REAL,
  fxLink TEXT
);
`;// HourlyWeathers
  private static createDailyWeathers: string = `
CREATE TABLE IF NOT EXISTS DailyWeather (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  Location TEXT,
  fxDate TEXT,
  sunrise TEXT,
  sunset TEXT,
  moonrise TEXT,
  moonset TEXT,
  moonPhase TEXT,
  moonPhaseIcon TEXT,
  tempMax REAL,
  tempMin REAL,
  iconDay TEXT,
  textDay TEXT,
  iconNight TEXT,
  textNight TEXT,
  wind360Day TEXT,
  windDirDay TEXT,
  windScaleDay TEXT,
  windSpeedDay TEXT,
  wind360Night TEXT,
  windDirNight TEXT,
  windScaleNight TEXT,
  windSpeedNight TEXT,
  humidity TEXT,
  precip TEXT,
  pressure TEXT,
  vis TEXT,
  cloud TEXT,
  uvIndex TEXT,
  fxLink TEXT
);
`;// DailyWeathers
  private static createRealtimeAirQuality: string = `
CREATE TABLE IF NOT EXISTS RealtimeAirQuality (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  Location TEXT,
  pubTime TEXT,
  aqi INTEGER,
  level TEXT,
  category TEXT,
  pm10 TEXT,
  pm2p5 TEXT,
  no2 TEXT,
  so2 TEXT,
  co TEXT,
  o3 TEXT,
  fxLink TEXT
);
`;// RealtimeAirQuality
  private static createWeatherIndex: string = `
CREATE TABLE IF NOT EXISTS WeatherIndex (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  Location TEXT,
  date TEXT,
  type TEXT,
  name TEXT,
  level TEXT,
  category TEXT,
  text TEXT,
  fxLink TEXT
);
`;
  // 获取数据库对象
  public static async getStore(context:Context) {
    try {
      if (StoreManager.store) {
        return StoreManager.store;
      }
      // 创建数据库对象
      StoreManager.store = await relationalStore.getRdbStore(context,{
        name:'RDB.db',//数据库名称
        securityLevel:relationalStore.SecurityLevel.S1,//数据库安全级别
      });
      // 创建表
      // ShownCities
      try {
        await StoreManager.store.executeSql(StoreManager.createShownCities);
      }catch (err){
        let error: BusinessError = err as BusinessError;
        console.error(`模拟器创建表ShownCities失败: Code is ${error.code}, message is ${error.message}`);
      }
      // CurrentWeathers
      try {
        await StoreManager.store.executeSql(StoreManager.createCurrentWeathers);
      }catch (err){
        let error: BusinessError = err as BusinessError;
        console.error(`模拟器创建表CurrentWeathers失败: Code is ${error.code}, message is ${error.message}`);
      }
      // HourlyWeathers
      try{
        await StoreManager.store.executeSql(StoreManager.createHourlyWeathers);
      }catch (err){
        let error: BusinessError = err as BusinessError;
        console.error(`模拟器创建表HourlyWeathers失败: Code is ${error.code}, message is ${error.message}`);
      }
      // DailyWeathers
      try {
        await StoreManager.store.executeSql(StoreManager.createDailyWeathers);
      }catch (err){
        let error: BusinessError = err as BusinessError;
        console.error(`模拟器创建表DailyWeathers失败: Code is ${error.code}, message is ${error.message}`);
      }
      // RealtimeAirQuality
      try {
        await StoreManager.store.executeSql(StoreManager.createRealtimeAirQuality);
      }catch (err){
        let error: BusinessError = err as BusinessError;
        console.error(`模拟器创建表RealtimeAirQuality失败: Code is ${error.code}, message is ${error.message}`);
      }
      // WeatherIndex
      try {
        await StoreManager.store.executeSql(StoreManager.createWeatherIndex);
      }catch (err){
        let error: BusinessError = err as BusinessError;
        console.error(`模拟器创建表WeatherIndex失败: Code is ${error.code}, message is ${error.message}`);
      }
      console.log('模拟器数据库对象创建成功');
      return StoreManager.store;
    }catch (err){
      let error: BusinessError = err as BusinessError;
      console.error(`模拟器获取数据库对象失败: Code is ${error.code}, message is ${error.message}`);
      return StoreManager.store;
    }
  }
  // 获取ShownCities
  public static async getShownCities(context:Context):Promise<ShownCity[]>{
    let shownCities:ShownCity[]=[];
    try {
      await StoreManager.getStore(context);
      let predicates=new relationalStore.RdbPredicates('ShownCity');
      let resultSet=await StoreManager.store?.query(predicates);
      while (resultSet?.goToNextRow()){
        shownCities.push({
          id:resultSet.getLong(resultSet.getColumnIndex('id')),
          Name:resultSet.getString(resultSet.getColumnIndex('Name')),
          Location:resultSet.getString(resultSet.getColumnIndex('Location')),
          LocationId:resultSet.getString(resultSet.getColumnIndex('LocationId')),
        })
      }
      resultSet?.close();
      console.info('模拟器获取数据库数据shownCities'+JSON.stringify(shownCities))
      return shownCities;
    }catch (err){
      let error: BusinessError = err as BusinessError;
      console.error(`模拟器获取数据库对象失败: Code is ${error.code}, message is ${error.message}`);
      return shownCities;
    }
  }
  // 添加ShownCities
  public static async addShownCity(context:Context,ShownCity:ShownCity):Promise<boolean>{
    try {
      await StoreManager.getStore(context);
      try {
        await StoreManager.store?.insert('ShownCity',ShownCity as ValuesBucket);
        console.info('模拟器添加数据库数据ShownCity'+JSON.stringify(ShownCity))
        return true;
      }catch (err){
        let error: BusinessError = err as BusinessError;
        console.error(`模拟器添加数据ShownCity失败: Code is ${error.code}, message is ${error.message}`);
        return false;
      }
    }catch (err){
      let error: BusinessError = err as BusinessError;
      console.error(`模拟器获取数据库对象失败: Code is ${error.code}, message is ${error.message}`);
      return false;
    }
  }
  // 更新ShownCities
  public static async updateShownCity(context:Context,ShownCity:ShownCity):Promise<boolean>{
    try {
      await StoreManager.getStore(context);
      let predicates=new relationalStore.RdbPredicates('ShownCity');
      predicates.equalTo('id',ShownCity.id);
      try {
        await StoreManager.store?.update(ShownCity as ValuesBucket, predicates);
        console.info('模拟器更新数据库数据ShownCity'+JSON.stringify(ShownCity))
        return true;
      }catch (err){
        let error: BusinessError = err as BusinessError;
        console.error(`模拟器更新数据ShownCity失败: Code is ${error.code}, message is ${error.message}`);
        return false;
      }
    }catch (err){
      let error: BusinessError = err as BusinessError;
      console.error(`模拟器获取数据库对象失败: Code is ${error.code}, message is ${error.message}`);
      return false;
    }
  }
  // 删除ShownCities
  public static async deleteShownCity(context:Context,ShownCity:ShownCity):Promise<boolean>{
    try {
      await StoreManager.getStore(context);
      let predicates=new relationalStore.RdbPredicates('ShownCity');
      predicates.equalTo('Location',ShownCity.Location);
      try {
        await StoreManager.store?.delete(predicates);
        console.info('模拟器删除ShownCities'+ShownCity.Name);
        return true;
      }catch (err){
        let error: BusinessError = err as BusinessError;
        console.error(`模拟器删除数据ShownCities失败: Code is ${error.code}, message is ${error.message}`);
        return false;
      }
    }catch (err){
      let error: BusinessError = err as BusinessError;
      console.error(`模拟器获取数据库对象失败: Code is ${error.code}, message is ${error.message}`);
      return false;
    }
  }
  // 获取CurrentWeathers
  public static async getCurrentWeathers(context: Context): Promise<RealtimeWeather[]> {
    let currentWeathers: RealtimeWeather[] = [];
    try {
      await StoreManager.getStore(context);
      let predicates = new relationalStore.RdbPredicates('RealtimeWeather');
      let resultSet = await StoreManager.store?.query(predicates);
      while (resultSet?.goToNextRow()) {
        currentWeathers.push({
          id: resultSet.getLong(resultSet.getColumnIndex('id')),
          Location: resultSet.getString(resultSet.getColumnIndex('Location')),
          obsTime: resultSet.getString(resultSet.getColumnIndex('obsTime')),
          temp: resultSet.getString(resultSet.getColumnIndex('temp')),
          feelsLike: resultSet.getString(resultSet.getColumnIndex('feelsLike')),
          icon: resultSet.getString(resultSet.getColumnIndex('icon')),
          text: resultSet.getString(resultSet.getColumnIndex('text')),
          wind360: resultSet.getString(resultSet.getColumnIndex('wind360')),
          windDir: resultSet.getString(resultSet.getColumnIndex('windDir')),
          windScale: resultSet.getLong(resultSet.getColumnIndex('windScale')),
          windSpeed: resultSet.getString(resultSet.getColumnIndex('windSpeed')),
          humidity: resultSet.getLong(resultSet.getColumnIndex('humidity')),
          precip: resultSet.getString(resultSet.getColumnIndex('precip')),
          pressure: resultSet.getString(resultSet.getColumnIndex('pressure')),
          vis: resultSet.getString(resultSet.getColumnIndex('vis')),
          cloud: resultSet.getString(resultSet.getColumnIndex('cloud')),
          dew: resultSet.getString(resultSet.getColumnIndex('dew')),
          fxLink: resultSet.getString(resultSet.getColumnIndex('fxLink'))
        });
      }
      resultSet?.close();
      console.info('模拟器获取数据库数据currentWeathers' + JSON.stringify(currentWeathers));
      return currentWeathers;
    } catch (err) {
      let error: BusinessError = err as BusinessError;
      console.error(`模拟器获取数据库对象失败: Code is ${error.code}, message is ${error.message}`);
      return currentWeathers;
    }
  }
  // 添加CurrentWeathers
  public static async addCurrentWeather(context:Context,currentWeather:RealtimeWeather):Promise<boolean>{
    try {
      await StoreManager.getStore(context);
      try {
        await StoreManager.store?.insert('RealtimeWeather',currentWeather as ValuesBucket);
        console.info('模拟器添加数据库数据currentWeather'+JSON.stringify(currentWeather))
        return true;
      }catch (err){
        let error: BusinessError = err as BusinessError;
        console.error(`模拟器添加数据currentWeather失败: Code is ${error.code}, message is ${error.message}`);
        return false;
      }
    }catch (err){
      let error: BusinessError = err as BusinessError;
      console.error(`模拟器获取数据库对象失败: Code is ${error.code}, message is ${error.message}`);
      return false;
    }
  }
  // 更新CurrentWeathers
  public static async updateCurrentWeather(context:Context,currentWeather:RealtimeWeather):Promise<boolean>{
    try {
      await StoreManager.getStore(context);
      let predicates=new relationalStore.RdbPredicates('RealtimeWeather');
      predicates.equalTo('id',currentWeather.id);
      try {
        await StoreManager.store?.update(currentWeather as ValuesBucket, predicates);
        console.info('模拟器更新数据库数据currentWeather'+JSON.stringify(currentWeather))
        return true;
      }catch (err){
        let error: BusinessError = err as BusinessError;
        console.error(`模拟器更新数据currentWeather失败: Code is ${error.code}, message is ${error.message}`);
        return false;
      }
    }catch (err){
      let error: BusinessError = err as BusinessError;
      console.error(`模拟器获取数据库对象失败: Code is ${error.code}, message is ${error.message}`);
      return false;
    }
  }
  // 删除CurrentWeathers
  public static async deleteCurrentWeather(context:Context,currentWeather:RealtimeWeather):Promise<boolean>{
    try {
      await StoreManager.getStore(context);
      let predicates=new relationalStore.RdbPredicates('RealtimeWeather');
      predicates.equalTo('Location',currentWeather.Location);
      try {
        await StoreManager.store?.delete(predicates);
        console.info('模拟器删除CurrentWeathers'+currentWeather.Location);
        return true;
      }catch (err){
        let error: BusinessError = err as BusinessError;
        console.error(`模拟器删除数据CurrentWeathers失败: Code is ${error.code}, message is ${error.message}`);
        return false;
      }
    }catch (err){
      let error: BusinessError = err as BusinessError;
      console.error(`模拟器获取数据库对象失败: Code is ${error.code}, message is ${error.message}`);
      return false;
    }
  }
  // 获取HourlyWeathers
  public static async getHourlyWeathers(context: Context): Promise<HourlyWeather[]> {
    let hourlyWeathers: HourlyWeather[] = [];
    try {
      await StoreManager.getStore(context);
      let predicates = new relationalStore.RdbPredicates('HourlyWeather');
      let resultSet = await StoreManager.store?.query(predicates);
      while (resultSet?.goToNextRow()) {
        hourlyWeathers.push({
          id: resultSet.getLong(resultSet.getColumnIndex('id')),
          Location: resultSet.getString(resultSet.getColumnIndex('Location')),
          fxTime: resultSet.getString(resultSet.getColumnIndex('fxTime')),
          temp: resultSet.getString(resultSet.getColumnIndex('temp')),
          icon: resultSet.getString(resultSet.getColumnIndex('icon')),
          text: resultSet.getString(resultSet.getColumnIndex('text')),
          wind360: resultSet.getLong(resultSet.getColumnIndex('wind360')),
          windDir: resultSet.getString(resultSet.getColumnIndex('windDir')),
          windScale: resultSet.getString(resultSet.getColumnIndex('windScale')),
          windSpeed: resultSet.getLong(resultSet.getColumnIndex('windSpeed')),
          humidity: resultSet.getLong(resultSet.getColumnIndex('humidity')),
          pop: resultSet.getLong(resultSet.getColumnIndex('pop')),
          precip: resultSet.getDouble(resultSet.getColumnIndex('precip')),
          pressure: resultSet.getDouble(resultSet.getColumnIndex('pressure')),
          cloud: resultSet.getLong(resultSet.getColumnIndex('cloud')),
          dew: resultSet.getDouble(resultSet.getColumnIndex('dew')),
          fxLink: resultSet.getString(resultSet.getColumnIndex('fxLink'))
        });
      }
      resultSet?.close();
      console.info('模拟器获取数据库数据hourlyWeathers' + JSON.stringify(hourlyWeathers));
      return hourlyWeathers;
    } catch (err) {
      let error: BusinessError = err as BusinessError;
      console.error(`模拟器获取数据库对象失败: Code is ${error.code}, message is ${error.message}`);
      return hourlyWeathers;
    }
  }
  // 添加HourlyWeathers
  public static async addHourlyWeathers(context:Context,hourlyWeathers:HourlyWeather[]):Promise<boolean>{
    try {
      await StoreManager.getStore(context);
      try {
        for (let i = 0; i < hourlyWeathers.length; i++) {
          await StoreManager.store?.insert('HourlyWeather',hourlyWeathers[i] as ValuesBucket);
        }
        console.info('模拟器添加数据库数据hourlyWeathers'+JSON.stringify(hourlyWeathers))
        return true;
      }catch (err){
        let error: BusinessError = err as BusinessError;
        console.error(`模拟器添加数据hourlyWeathers失败: Code is ${error.code}, message is ${error.message}`);
        return false;
      }
    }catch (err){
      let error: BusinessError = err as BusinessError;
      console.error(`模拟器获取数据库对象失败: Code is ${error.code}, message is ${error.message}`);
      return false;
    }
  }
  // 更新HourlyWeathers
  public static async updateHourlyWeathers(context:Context,hourlyWeathers:HourlyWeather[]):Promise<boolean>{
    try {
      await StoreManager.getStore(context);
      try {
        for (let i = 0; i < hourlyWeathers.length; i++) {
          let predicates=new relationalStore.RdbPredicates('HourlyWeather');
          predicates.equalTo('id',hourlyWeathers[i].id);
          await StoreManager.store?.update(hourlyWeathers[i] as ValuesBucket, predicates);
        }
        console.info('模拟器更新数据库数据hourlyWeathers'+JSON.stringify(hourlyWeathers))
        return true;
      }catch (err){
        let error: BusinessError = err as BusinessError;
        console.error(`模拟器更新数据hourlyWeathers失败: Code is ${error.code}, message is ${error.message}`);
        return false;
      }
    }catch (err){
      let error: BusinessError = err as BusinessError;
      console.error(`模拟器获取数据对象失败: Code is ${error.code}, message is ${error.message}`);
      return false;
    }
  }
  // 删除HourlyWeathers
  public static async deleteHourlyWeathers(context:Context,hourlyWeathers:HourlyWeather[]):Promise<boolean>{
    try {
      await StoreManager.getStore(context);
      try {
        let predicates=new relationalStore.RdbPredicates('HourlyWeather');
        predicates.equalTo('Location',hourlyWeathers[0].Location);
        await StoreManager.store?.delete(predicates);
        console.info('模拟器删除数据库数据hourlyWeathers'+JSON.stringify(hourlyWeathers))
        return true;
      }catch (err){
        let error: BusinessError = err as BusinessError;
        console.error(`模拟器删除数据hourlyWeathers失败: Code is ${error.code}, message is ${error.message}`);
        return false;
      }
    }catch (err){
      let error: BusinessError = err as BusinessError;
      console.error(`模拟器获取数据库对象失败: Code is ${error.code}, message is ${error.message}`);
      return false;
    }
  }
  // 获取DailyWeathers
  public static async getDailyWeathers(context: Context): Promise<DailyWeather[]> {
    let dailyWeathers: DailyWeather[] = [];
    try {
      await StoreManager.getStore(context);
      let predicates = new relationalStore.RdbPredicates('DailyWeather');
      let resultSet = await StoreManager.store?.query(predicates);
      while (resultSet?.goToNextRow()) {
        dailyWeathers.push({
          id: resultSet.getLong(resultSet.getColumnIndex('id')),
          Location: resultSet.getString(resultSet.getColumnIndex('Location')),
          fxDate: resultSet.getString(resultSet.getColumnIndex('fxDate')),
          sunrise: resultSet.getString(resultSet.getColumnIndex('sunrise')),
          sunset: resultSet.getString(resultSet.getColumnIndex('sunset')),
          moonrise: resultSet.getString(resultSet.getColumnIndex('moonrise')),
          moonset: resultSet.getString(resultSet.getColumnIndex('moonset')),
          moonPhase: resultSet.getString(resultSet.getColumnIndex('moonPhase')),
          moonPhaseIcon: resultSet.getString(resultSet.getColumnIndex('moonPhaseIcon')),
          tempMax: resultSet.getDouble(resultSet.getColumnIndex('tempMax')),
          tempMin: resultSet.getDouble(resultSet.getColumnIndex('tempMin')),
          iconDay: resultSet.getString(resultSet.getColumnIndex('iconDay')),
          textDay: resultSet.getString(resultSet.getColumnIndex('textDay')),
          iconNight: resultSet.getString(resultSet.getColumnIndex('iconNight')),
          textNight: resultSet.getString(resultSet.getColumnIndex('textNight')),
          wind360Day: resultSet.getString(resultSet.getColumnIndex('wind360Day')),
          windDirDay: resultSet.getString(resultSet.getColumnIndex('windDirDay')),
          windScaleDay: resultSet.getString(resultSet.getColumnIndex('windScaleDay')),
          windSpeedDay: resultSet.getString(resultSet.getColumnIndex('windSpeedDay')),
          wind360Night: resultSet.getString(resultSet.getColumnIndex('wind360Night')),
          windDirNight: resultSet.getString(resultSet.getColumnIndex('windDirNight')),
          windScaleNight: resultSet.getString(resultSet.getColumnIndex('windScaleNight')),
          windSpeedNight: resultSet.getString(resultSet.getColumnIndex('windSpeedNight')),
          humidity: resultSet.getString(resultSet.getColumnIndex('humidity')),
          precip: resultSet.getString(resultSet.getColumnIndex('precip')),
          pressure: resultSet.getString(resultSet.getColumnIndex('pressure')),
          vis: resultSet.getString(resultSet.getColumnIndex('vis')),
          cloud: resultSet.getString(resultSet.getColumnIndex('cloud')),
          uvIndex: resultSet.getString(resultSet.getColumnIndex('uvIndex')),
          fxLink: resultSet.getString(resultSet.getColumnIndex('fxLink'))
        });
      }
      resultSet?.close();
      console.info('模拟器获取数据库数据dailyWeathers' + JSON.stringify(dailyWeathers));
      return dailyWeathers;
    } catch (err) {
      let error: BusinessError = err as BusinessError;
      console.error(`模拟器获取数据库对象失败: Code is ${error.code}, message is ${error.message}`);
      return dailyWeathers;
    }
  }
  // 添加DailyWeathers
  public static async addDailyWeathers(context: Context, dailyWeathers: DailyWeather[]): Promise<boolean> {
    try {
      await StoreManager.getStore(context);
      try {
        for (let i = 0; i < dailyWeathers.length; i++) {
          await StoreManager.store?.insert('DailyWeather',dailyWeathers[i] as ValuesBucket);
        }
        console.info('模拟器添加数据库数据dailyWeathers'+JSON.stringify(dailyWeathers))
        return true;
      }catch (err){
        let error: BusinessError = err as BusinessError;
        console.error(`模拟器添加数据dailyWeathers失败: Codeis ${error.code}, message is ${error.message}`);
        return false;
      }
    }catch (err){
      let error: BusinessError = err as BusinessError;
      console.error(`模拟器获取数据库对象失败: Code is ${error.code}, message is ${error.message}`);
      return false;
    }
  }
  // 删除DailyWeathers
  public static async deleteDailyWeathers(context: Context, dailyWeathers: DailyWeather[]): Promise<boolean> {
    try {
      await StoreManager.getStore(context);
      try {
        let predicates=new relationalStore.RdbPredicates('DailyWeather');
        predicates.equalTo('Location',dailyWeathers[0].Location);
        await StoreManager.store?.delete(predicates);
        console.info('模拟器删除数据库数据dailyWeathers'+JSON.stringify(dailyWeathers))
        return true;
      }catch (err){
        let error: BusinessError = err as BusinessError;
        console.error(`模拟器删除数据dailyWeathers失败: Code is ${error.code}, message is ${error.message}`);
        return false;
      }
    }catch (err){
      let error: BusinessError = err as BusinessError;
      console.error(`模拟器获取数据库对象失败: Code is ${error.code}, message is ${error.message}`);
      return false;
    }
  }
  // 更新DailyWeathers
  public static async updateDailyWeathers(context: Context, dailyWeathers: DailyWeather[]): Promise<boolean> {
    try {
      await StoreManager.getStore(context);
      try {
        for (let i = 0; i < dailyWeathers.length; i++) {
          let predicates=new relationalStore.RdbPredicates('DailyWeather');
          predicates.equalTo('id',dailyWeathers[i].id);
          await StoreManager.store?.update(dailyWeathers[i] as ValuesBucket,predicates);
        }
        console.info('模拟器更新数据库数据dailyWeathers'+JSON.stringify(dailyWeathers))
        return true;
      }catch (err){
        let error: BusinessError = err as BusinessError;
        console.error(`模拟器更新数据dailyWeathers失败: Code is ${error.code}, message is ${error.message}`);
        return false;
      }
    }catch (err){
      let error: BusinessError = err as BusinessError;
      console.error(`模拟器获取数据库对象失败: Code is ${error.code}, message is ${error.message}`);
      return false;
    }
  }
  // 获取RealtimeAirQuality
  public static async getRealtimeAirQualities(context: Context): Promise<RealtimeAirQuality[]> {
    let realtimeAirQualities: RealtimeAirQuality[] = [];
    try {
      await StoreManager.getStore(context);
      let predicates = new relationalStore.RdbPredicates('RealtimeAirQuality');
      let resultSet = await StoreManager.store?.query(predicates);
      while (resultSet?.goToNextRow()) {
        realtimeAirQualities.push({
          id: resultSet.getLong(resultSet.getColumnIndex('id')),
          Location: resultSet.getString(resultSet.getColumnIndex('Location')),
          pubTime: resultSet.getString(resultSet.getColumnIndex('pubTime')),
          aqi: resultSet.getLong(resultSet.getColumnIndex('aqi')),
          level: resultSet.getString(resultSet.getColumnIndex('level')),
          category: resultSet.getString(resultSet.getColumnIndex('category')),
          pm10: resultSet.getString(resultSet.getColumnIndex('pm10')),
          pm2p5: resultSet.getString(resultSet.getColumnIndex('pm2p5')),
          no2: resultSet.getString(resultSet.getColumnIndex('no2')),
          so2: resultSet.getString(resultSet.getColumnIndex('so2')),
          co: resultSet.getString(resultSet.getColumnIndex('co')),
          o3: resultSet.getString(resultSet.getColumnIndex('o3')),
          fxLink: resultSet.getString(resultSet.getColumnIndex('fxLink'))
        });
      }
      resultSet?.close();
      console.info('模拟器获取数据库数据realtimeAirQualities' + JSON.stringify(realtimeAirQualities));
      return realtimeAirQualities;
    } catch (err) {
      let error: BusinessError = err as BusinessError;
      console.error(`模拟器获取数据库对象失败: Code is ${error.code}, message is ${error.message}`);
      return realtimeAirQualities;
    }
  }
  // 添加RealtimeAirQuality
  public static async addRealtimeAirQuality(context: Context, realtimeAirQuality: RealtimeAirQuality): Promise<boolean> {
    try {
      await StoreManager.getStore(context);
      try {
        await StoreManager.store?.insert('RealtimeAirQuality',realtimeAirQuality as ValuesBucket);
        console.info('模拟器添加数据库数据realtimeAirQuality'+JSON.stringify(realtimeAirQuality))
        return true;
      }catch (err){
        let error: BusinessError = err as BusinessError;
        console.error(`模拟器添加数据realtimeAirQuality失败: Codeis ${error.code},message is ${error.message}`);
        return false;
      }
    }catch (err){
      let error: BusinessError = err as BusinessError;
      console.error(`模拟器获取数据库对象失败: Code is ${error.code}, message is ${error.message}`);
      return false;
    }
  }
  // 删除RealtimeAirQuality
  public static async deleteRealtimeAirQuality(context: Context, realtimeAirQuality: RealtimeAirQuality): Promise<boolean> {
    try {
      await StoreManager.getStore(context);
      try {
        let predicates=new relationalStore.RdbPredicates('RealtimeAirQuality');
        predicates.equalTo('Location',realtimeAirQuality.Location);
        await StoreManager.store?.delete(predicates);
        console.info('模拟器删除数据库数据realtimeAirQuality'+JSON.stringify(realtimeAirQuality))
        return true;
      }catch (err){
        let error: BusinessError = err as BusinessError;
        console.error(`模拟器删除数据realtimeAirQuality失败: Code is ${error.code}, message is ${error.message}`);
        return false;
      }
    }catch (err){
      let error: BusinessError = err as BusinessError;
      console.error(`模拟器获取数据库对象失败: Code is ${error.code}, message is ${error.message}`);
      return false;
    }
  }
  // 更新RealtimeAirQuality
  public static async updateRealtimeAirQuality(context: Context, realtimeAirQuality: RealtimeAirQuality): Promise<boolean> {
    try {
      await StoreManager.getStore(context);
      try {
        let predicates=new relationalStore.RdbPredicates('RealtimeAirQuality');
        predicates.equalTo('id',realtimeAirQuality.id);
        await StoreManager.store?.update(realtimeAirQuality as ValuesBucket,predicates);
        console.info('模拟器更新数据库数据realtimeAirQuality'+JSON.stringify(realtimeAirQuality))
        return true;
      }catch (err){
        let error: BusinessError = err as BusinessError;
        console.error(`模拟器更新数据realtimeAirQuality失败: Code is ${error.code}, message is ${error.message}`);
        return false;
      }
    }catch (err){
      let error: BusinessError = err as BusinessError;
      console.error(`模拟器获取数据库对象失败: Code is ${error.code}, message is ${error.message}`);
      return false;
    }
  }
  // 获取WeatherIndex
  public static async getWeatherIndices(context: Context): Promise<WeatherIndex[]> {
    let weatherIndices: WeatherIndex[] = [];
    try {
      await StoreManager.getStore(context);
      let predicates = new relationalStore.RdbPredicates('WeatherIndex');
      let resultSet = await StoreManager.store?.query(predicates);
      while (resultSet?.goToNextRow()) {
        weatherIndices.push({
          id: resultSet.getLong(resultSet.getColumnIndex('id')),
          Location: resultSet.getString(resultSet.getColumnIndex('Location')),
          date: resultSet.getString(resultSet.getColumnIndex('date')),
          type: resultSet.getString(resultSet.getColumnIndex('type')),
          name: resultSet.getString(resultSet.getColumnIndex('name')),
          level: resultSet.getString(resultSet.getColumnIndex('level')),
          category: resultSet.getString(resultSet.getColumnIndex('category')),
          text: resultSet.getString(resultSet.getColumnIndex('text')),
          fxLink: resultSet.getString(resultSet.getColumnIndex('fxLink'))
        });
      }
      resultSet?.close();
      console.info('模拟器获取数据库数据weatherIndices' + JSON.stringify(weatherIndices));
      return weatherIndices;
    } catch (err) {
      let error: BusinessError = err as BusinessError;
      console.error(`模拟器获取数据库对象失败: Code is ${error.code}, message is ${error.message}`);
      return weatherIndices;
    }
  }
  // 添加WeatherIndex
  public static async addWeatherIndex(context: Context, weatherIndex: WeatherIndex[]): Promise<boolean> {
    try {
      await StoreManager.getStore(context);
      try {
        for (let i = 0; i < weatherIndex.length; i++) {
          await StoreManager.store?.insert('WeatherIndex', weatherIndex[i] as ValuesBucket);
        }
        console.info('模拟器添加数据库数据weatherIndex' + JSON.stringify(weatherIndex))
        return true;
      } catch (err) {
        let error: BusinessError = err as BusinessError;
        console.error(`模拟器添加数据weatherIndex失败: Codeis ${error.code},message is ${error.message}`);
        return false;
      }
    }catch (err){
      let error: BusinessError = err as BusinessError;
      console.error(`模拟器获取数据库对象失败: Code is ${error.code}, message is ${error.message}`);
      return false;
    }
  }
  // 删除WeatherIndex
  public static async deleteWeatherIndex(context: Context, weatherIndex: WeatherIndex[]): Promise<boolean> {
    try {
      await StoreManager.getStore(context);
      try {
        let predicates=new relationalStore.RdbPredicates('WeatherIndex');
        predicates.equalTo('Location',weatherIndex[0].Location);
        await StoreManager.store?.delete(predicates);
        console.info('模拟器删除数据库数据weatherIndex' + JSON.stringify(weatherIndex))
        return true;
      } catch (err) {
        let error: BusinessError = err as BusinessError;
        console.error(`模拟器删除数据weatherIndex失败: Codeis ${error.code},message is ${error.message}`);
        return false;
      }
    }catch (err){
      let error: BusinessError = err as BusinessError;
      console.error(`模拟器获取数据库对象失败: Code is ${error.code}, message is ${error.message}`);
      return false;
    }
  }
  // 更新WeatherIndex
  public static async updateWeatherIndex(context: Context, weatherIndex: WeatherIndex[]): Promise<boolean> {
    try {
      await StoreManager.getStore(context);
      try {
        for (let i = 0; i < weatherIndex.length; i++) {
          let predicates=new relationalStore.RdbPredicates('WeatherIndex');
          predicates.equalTo('id',weatherIndex[i].id);
          await StoreManager.store?.update(weatherIndex[i] as ValuesBucket,predicates);
        }
        console.info('模拟器更新数据库数据weatherIndex'+JSON.stringify(weatherIndex))
        return true;
     }catch (err){
        let error: BusinessError = err as BusinessError;
        console.error(`模拟器更新数据weatherIndex失败: Code is ${error.code}, message is ${error.message}`);
        return false;
      }
    }catch (err){
      let error: BusinessError = err as BusinessError;
      console.error(`模拟器获取数据库对象失败: Code is ${error.code}, message is ${error.message}`);
      return false;
    }
  }
}
export default StoreManager;