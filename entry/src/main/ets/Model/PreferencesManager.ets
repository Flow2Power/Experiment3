import { BusinessError } from '@ohos.base';
import dataPreferences from '@ohos.data.preferences';
export class PreferencesManager {
  //定义存储路径
  private static readonly PREFERENCES_PATH: string = 'DataPersistence';
  //定义存储键
  private static readonly KEY_ShownCity: string = 'ShownCity';
  private static readonly KEY_ShownCityLocation: string = 'ShownCityLocation';
  private static readonly KEY_LocationName: string = 'LocationName';
  //定义存储对象
  private static preferences: dataPreferences.Preferences | undefined = undefined;
  //储存ShownCity
  public static async putShownCity(ShownCity: string, context: Context): Promise<void> {
    try {
      PreferencesManager.preferences = await dataPreferences.getPreferences(context, PreferencesManager.PREFERENCES_PATH);
      await PreferencesManager.preferences.put(PreferencesManager.KEY_ShownCity, ShownCity);
      await PreferencesManager.preferences.flush();
      console.info('模拟器putShownCity success');
    } catch (err) {
      let error: BusinessError = err as BusinessError;
      console.error(`模拟器Failed to put ShownCity. Code:${error.code}, message:${error.message}`);
    }
  }
  //获取ShownCity
  public static async getShownCity(context: Context): Promise<string> {
    let ShownCity: string = '';
    try {
      PreferencesManager.preferences = await dataPreferences.getPreferences(context, PreferencesManager.PREFERENCES_PATH);
      ShownCity = await PreferencesManager.preferences.get(PreferencesManager.KEY_ShownCity, '') as string;
      console.info('模拟器getShownCity success'+JSON.stringify(ShownCity));
    } catch (err) {
      let error: BusinessError= err as BusinessError;
      console.error(`模拟器Failed to get ShownCity. Code:${error.code}, message:${error.message}`);
    }
    return ShownCity;
  }
  //储存LocationName
  public static async putLocationName(LocationName: string, context: Context): Promise<void> {
    try {
      PreferencesManager.preferences = await dataPreferences.getPreferences(context, PreferencesManager.PREFERENCES_PATH);
      await PreferencesManager.preferences.put(PreferencesManager.KEY_LocationName, LocationName);
      await PreferencesManager.preferences.flush();
      console.info('模拟器putLocationName success');
    } catch (err) {
      let error: BusinessError = err as BusinessError;
      console.error(`模拟器Failed to put LocationName. Code:${error.code}, message:${error.message}`);
    }
  }
  //获取LocationName
  public static async getLocationName(context: Context): Promise<string> {
    let LocationName: string = '';
    try {
      PreferencesManager.preferences = await dataPreferences.getPreferences(context, PreferencesManager.PREFERENCES_PATH);
      LocationName = await PreferencesManager.preferences.get(PreferencesManager.KEY_LocationName, '') as string;
      console.info('模拟器getLocationName success'+JSON.stringify(LocationName));
    } catch (err) {
      let error: BusinessError= err as BusinessError;
      console.error(`模拟器Failed to get LocationName. Code:${error.code}, message:${error.message}`);
    }
    return LocationName;
  }
  //存储ShownCityLocation
  public static async putShownCityLocation(ShownCityLocation: string, context: Context): Promise<void> {
    try {
      PreferencesManager.preferences = await dataPreferences.getPreferences(context, PreferencesManager.PREFERENCES_PATH);
      await PreferencesManager.preferences.put(PreferencesManager.KEY_ShownCityLocation, ShownCityLocation);
      await PreferencesManager.preferences.flush();
      console.info('模拟器putShownCityLocation success');
    } catch (err) {
      let error: BusinessError = err as BusinessError;
      console.error(`模拟器Failed to put ShownCityLocation. Code:${error.code}, message:${error.message}`);
    }
  }
  //获取ShownCityLocation
  public static async getShownCityLocation(context: Context): Promise<string> {
    let ShownCityLocation: string = '';
    try {
      PreferencesManager.preferences = await dataPreferences.getPreferences(context, PreferencesManager.PREFERENCES_PATH);
      ShownCityLocation = await PreferencesManager.preferences.get(PreferencesManager.KEY_ShownCityLocation, '') as string;
      console.info('模拟器getShownCityLocation success'+JSON.stringify(ShownCityLocation));
    }catch (err){
      let error: BusinessError= err as BusinessError;
      console.error(`模拟器Failed to get ShownCityLocation. Code:${error.code}, message:${error.message}`);
    }
    return ShownCityLocation;
  }
}
export default PreferencesManager;