import { formBindingData, FormExtensionAbility, formInfo, formProvider } from '@kit.FormKit';
import { Want } from '@kit.AbilityKit';
import { CardData, DailyWeather, RealtimeAirQuality, WeatherIndex } from '../Model/DataInterface';
import { BusinessError } from '@kit.BasicServicesKit';
import PreferencesManager from '../Model/PreferencesManager';
import StoreManager from '../Model/StoreManager';

export default class EntryFormAbility extends FormExtensionAbility {
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
  onAddForm(want: Want) {
    // Called to return a FormBindingData object.
    let formData : CardData = {
      ShownCityName: '',
      CurrentLocationName: '',
      tempMax: 0,
      tempMin: 0,
      weather: '',
      airLevel: '',
      date: '',
      week: '',
      weatherIcon: '',
      category1: '',
      category2: '',
      category3: '',
      category4: ''
    }
    try {
      PreferencesManager.getShownCity(this.context).then((ShownCityName:string) => {
        PreferencesManager.getLocationName(this.context).then((CurrentLocationName:string) => {
          PreferencesManager.getShownCityLocation(this.context).then((ShownCityLocation:string) => {
            formData.ShownCityName = ShownCityName;
            formData.CurrentLocationName = CurrentLocationName;
            StoreManager.getDailyWeathers(this.context).then((dailyWeathers:DailyWeather[])=>{
              const DailyWeathers = dailyWeathers.filter(weather => weather.Location === ShownCityLocation);
              console.info('模拟器获取卡片数据DailyWeathers成功'+JSON.stringify(DailyWeathers))
              formData.tempMax = DailyWeathers[1]?.tempMax;
              formData.tempMin = DailyWeathers[1]?.tempMin;
              formData.weather = DailyWeathers[1]?.textDay;
              formData.weatherIcon = DailyWeathers[1]?.iconDay;
              formData.date = this.extractDateFromFxDate(DailyWeathers[1]?.fxDate);
              formData.week = this.extractWeekFromDate(DailyWeathers[1]?.fxDate);
              StoreManager.getRealtimeAirQualities(this.context).then((airQualities:RealtimeAirQuality[])=>{
                const AirQualities = airQualities.filter(airQuality => airQuality.Location === ShownCityLocation);
                console.info('模拟器获取卡片数据AirQualities成功'+JSON.stringify(AirQualities))
                formData.airLevel = AirQualities[0]?.category
                StoreManager.getWeatherIndices(this.context).then((weatherIndices:WeatherIndex[])=>{
                  const WeatherIndices = weatherIndices.filter(weatherIndex => weatherIndex.Location === ShownCityLocation);
                  console.info('模拟器获取卡片数据WeatherIndices成功'+JSON.stringify(WeatherIndices))
                  formData.category1 = WeatherIndices[5]?.category
                  formData.category2 = WeatherIndices[0]?.category
                  formData.category3 = WeatherIndices[8]?.category
                  formData.category4 = WeatherIndices[1]?.category
                  console.info('模拟器获取卡片数据成功'+JSON.stringify(formData))
                  //定义需要传递给卡片的数据
                  let bindData = formBindingData.createFormBindingData(formData);
                  let formId = want.parameters && want.parameters['ohos.extra.param.key.form_identity'].toString()
                  console.info('模拟器卡片Get formId successfully.'+formId)
                  //更新卡片数据
                  formProvider.updateForm(formId, bindData).then(() => {
                    console.log('模拟器卡片Card updated successfully.');
                  }).catch((error: BusinessError) => {
                    console.error(`模拟器卡片Failed to update card: code is ${error.code},message is ${error.message}`);
                  });
                })
              })
            })
          })
        })
      })
    }catch (err){
      let error: BusinessError = err as BusinessError;
      console.error(`模拟器获取卡片数据失败. Code:${error.code}, message:${error.message}`);
    }
    return formBindingData.createFormBindingData(formData);
  }

  onCastToNormalForm(formId: string) {
    // Called when the form provider is notified that a temporary form is successfully
    // converted to a normal form.
  }

  onUpdateForm(formId: string) {
    // Called to notify the form provider to update a specified form.
    let formData : CardData = {
      ShownCityName: '',
      CurrentLocationName: '',
      tempMax: 0,
      tempMin: 0,
      weather: '',
      airLevel: '',
      date: '',
      week: '',
      weatherIcon: '',
      category1: '',
      category2: '',
      category3: '',
      category4: ''
    }
    try {
      PreferencesManager.getShownCity(this.context).then((ShownCityName:string) => {
        PreferencesManager.getLocationName(this.context).then((CurrentLocationName:string) => {
          PreferencesManager.getShownCityLocation(this.context).then((ShownCityLocation:string) => {
            formData.ShownCityName = ShownCityName;
            formData.CurrentLocationName = CurrentLocationName;
            StoreManager.getDailyWeathers(this.context).then((dailyWeathers:DailyWeather[])=>{
              const DailyWeathers = dailyWeathers.filter(weather => weather.Location === ShownCityLocation);
              console.info('模拟器获取卡片数据DailyWeathers成功'+JSON.stringify(DailyWeathers))
              formData.tempMax = DailyWeathers[1]?.tempMax;
              formData.tempMin = DailyWeathers[1]?.tempMin;
              formData.weather = DailyWeathers[1]?.textDay;
              formData.weatherIcon = DailyWeathers[1]?.iconDay;
              formData.date = this.extractDateFromFxDate(DailyWeathers[1]?.fxDate);
              formData.week = this.extractWeekFromDate(DailyWeathers[1]?.fxDate);
              StoreManager.getRealtimeAirQualities(this.context).then((airQualities:RealtimeAirQuality[])=>{
                const AirQualities = airQualities.filter(airQuality => airQuality.Location === ShownCityLocation);
                console.info('模拟器获取卡片数据AirQualities成功'+JSON.stringify(AirQualities))
                formData.airLevel = AirQualities[0]?.category
                StoreManager.getWeatherIndices(this.context).then((weatherIndices:WeatherIndex[])=>{
                  const WeatherIndices = weatherIndices.filter(weatherIndex => weatherIndex.Location === ShownCityLocation);
                  console.info('模拟器获取卡片数据WeatherIndices成功'+JSON.stringify(WeatherIndices))
                  formData.category1 = WeatherIndices[5]?.category
                  formData.category2 = WeatherIndices[0]?.category
                  formData.category3 = WeatherIndices[8]?.category
                  formData.category4 = WeatherIndices[1]?.category
                  console.info('模拟器获取卡片数据成功'+JSON.stringify(formData))
                  //定义需要传递给卡片的数据
                  let bindData = formBindingData.createFormBindingData(formData);
                  console.info('模拟器卡片Get formId successfully.'+formId)
                  //更新卡片数据
                  formProvider.updateForm(formId, bindData).then(() => {
                    console.log('模拟器卡片Card updated successfully.');
                  }).catch((error: BusinessError) => {
                    console.error(`模拟器卡片Failed to update card: code is ${error.code},message is ${error.message}`);
                  });
                })
              })
            })
          })
        })
      })
    }catch (err){
      let error: BusinessError = err as BusinessError;
      console.error(`模拟器获取卡片数据失败. Code:${error.code}, message:${error.message}`);
    }
    return formBindingData.createFormBindingData(formData);
  }

  onFormEvent(formId: string, message: string) {
    // Called when a specified message event defined by the form provider is triggered.
  }

  onRemoveForm(formId: string) {
    // Called to notify the form provider that a specified form has been destroyed.
  }

  onAcquireFormState(want: Want) {
    // Called to return a {@link FormState} object.
    return formInfo.FormState.READY;
  }
};