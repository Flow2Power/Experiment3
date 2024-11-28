import { BusinessError } from '@kit.BasicServicesKit';
import { geoLocationManager } from '@kit.LocationKit';
import { abilityAccessCtrl, common, Permissions } from '@kit.AbilityKit';
const permissions: Array<Permissions> = ['ohos.permission.LOCATION', 'ohos.permission.APPROXIMATELY_LOCATION'];

export async function reqPermissionsFromUser( Context: Context): Promise<string> {
  let location: string="";
  let context: common.UIAbilityContext = Context as common.UIAbilityContext;
  let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
  // requestPermissionsFromUser会判断权限的授权状态来决定是否唤起弹窗
  try {
    let data = await atManager.requestPermissionsFromUser(context, permissions);
    let grantStatus: Array<number> = data.authResults;
    if (grantStatus.some(status => status !== 0)) {
      // 用户拒绝授权，提示用户必须授权才能访问当前页面的功能，并引导用户到系统设置中打开相应的权限
      console.error('模拟器未获取授权');
      return location;
    }
    // 授权成功
    try {
      let UserLocation =  geoLocationManager.getLastLocation();
      location = UserLocation.longitude + ',' + UserLocation.latitude;
    } catch (err) {
      let error: BusinessError = err as BusinessError;
      console.error(`模拟器获取位置信息失败: Code is ${error.code}, message is ${error.message}`);
    }
  }catch (err){
    let error: BusinessError = err as BusinessError;
    console.error(`模拟器获取位置信息权限失败: Code is ${error.code}, message is ${error.message}`);
  }
  return location;
}