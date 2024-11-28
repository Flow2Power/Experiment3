import { relationalStore, ValuesBucket } from "@kit.ArkData";
import { BusinessError } from "@kit.BasicServicesKit";
import { ShownCity } from "./DataInterface";

export class StoreManager{
  // 数据库对象
  private static store: relationalStore.RdbStore | null = null
  // 建表语句
  private static createShownCities:string=`
    CREATE TABLE IF NOT EXISTS ShownCity (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      Name TEXT NOT NULL,
      Location TEXT NOT NULL,
      LocationId TEXT NOT NULL
    )
  `;// ShownCities
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
      await StoreManager.store.executeSql(StoreManager.createShownCities);
      console.log('模拟器数据库创建成功');
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
      console.info('模拟器获取数据库数据成功'+JSON.stringify(shownCities))
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
      }catch (err){
        let error: BusinessError = err as BusinessError;
        console.error(`模拟器添加数据失败: Code is ${error.code}, message is ${error.message}`);
      }
      return true;
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
      }catch (err){
        let error: BusinessError = err as BusinessError;
        console.error(`模拟器更新数据失败: Code is ${error.code}, message is ${error.message}`);
        return false;
      }
      console.info('模拟器更新数据库数据成功'+JSON.stringify(ShownCity))
      return true;
    }catch (err){
      let error: BusinessError = err as BusinessError;
      console.error(`模拟器获取数据库对象失败: Code is ${error.code}, message is ${error.message}`);
      return false;
    }
  }
}
export default StoreManager;