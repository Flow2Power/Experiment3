import { BusinessError } from '@ohos.base';
import dataPreferences from '@ohos.data.preferences';
export class PreferencesManager {
  //定义存储路径
  private static readonly PREFERENCES_PATH: string = 'DataPersistence';
  //定义存储键
  private static readonly KEY_ShownCity: string = 'ShownCity';
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
      console.info('模拟器getShownCity success');
    } catch (err) {
      let error: BusinessError= err as BusinessError;
      console.error(`模拟器Failed to get ShownCity. Code:${error.code}, message:${error.message}`);
    }
    return ShownCity;
  }
}
export default PreferencesManager;