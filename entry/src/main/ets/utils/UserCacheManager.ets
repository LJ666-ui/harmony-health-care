import relationalStore from '@ohos.data.relationalStore';
import RdbHelper from './RdbHelper';
import {
  TABLE_USER_CACHE,
  COLUMN_ID,
  COLUMN_USER_ID,
  COLUMN_USERNAME,
  COLUMN_AVATAR,
  COLUMN_PHONE,
  COLUMN_EXPIRE_TIME,
  COLUMN_UPDATE_TIME
} from './DatabaseConstants';

export interface UserCache {
  id?: number;
  userId: string;
  username?: string;
  avatar?: string;
  phone?: string;
  expireTime?: number;
  updateTime?: number;
}

class UserCacheManager {
  private static instance: UserCacheManager;

  private constructor() {}

  public static getInstance(): UserCacheManager {
    if (!UserCacheManager.instance) {
      UserCacheManager.instance = new UserCacheManager();
    }
    return UserCacheManager.instance;
  }

  public async cacheUser(user: UserCache): Promise<number> {
    const values: relationalStore.ValuesBucket = {
      [COLUMN_USER_ID]: user.userId,
      [COLUMN_USERNAME]: user.username || null,
      [COLUMN_AVATAR]: user.avatar || null,
      [COLUMN_PHONE]: user.phone || null,
      [COLUMN_EXPIRE_TIME]: user.expireTime || Date.now() + 7 * 24 * 60 * 60 * 1000,
      [COLUMN_UPDATE_TIME]: Date.now()
    };

    const predicates = new relationalStore.RdbPredicates(TABLE_USER_CACHE);
    predicates.equalTo(COLUMN_USER_ID, user.userId);
    
    const resultSet = await RdbHelper.queryByPredicates(predicates, [COLUMN_ID]);
    if (resultSet.goToFirstRow()) {
      const id = resultSet.getLong(0);
      resultSet.close();
      return await RdbHelper.update(TABLE_USER_CACHE, values, predicates);
    }
    resultSet.close();
    
    return await RdbHelper.insert(TABLE_USER_CACHE, values);
  }

  public async getCachedUser(userId: string): Promise<UserCache | null> {
    const predicates = new relationalStore.RdbPredicates(TABLE_USER_CACHE);
    predicates.equalTo(COLUMN_USER_ID, userId);

    const resultSet = await RdbHelper.queryByPredicates(predicates);
    if (resultSet.goToFirstRow()) {
      const user: UserCache = {
        id: resultSet.getLong(resultSet.getColumnIndex(COLUMN_ID)),
        userId: resultSet.getString(resultSet.getColumnIndex(COLUMN_USER_ID)),
        username: resultSet.getString(resultSet.getColumnIndex(COLUMN_USERNAME)),
        avatar: resultSet.getString(resultSet.getColumnIndex(COLUMN_AVATAR)),
        phone: resultSet.getString(resultSet.getColumnIndex(COLUMN_PHONE)),
        expireTime: resultSet.getLong(resultSet.getColumnIndex(COLUMN_EXPIRE_TIME)),
        updateTime: resultSet.getLong(resultSet.getColumnIndex(COLUMN_UPDATE_TIME))
      };
      resultSet.close();

      if (user.expireTime && user.expireTime < Date.now()) {
        await this.clearUserCache(userId);
        return null;
      }

      return user;
    }
    resultSet.close();
    return null;
  }

  public async clearUserCache(userId: string): Promise<number> {
    const predicates = new relationalStore.RdbPredicates(TABLE_USER_CACHE);
    predicates.equalTo(COLUMN_USER_ID, userId);
    return await RdbHelper.delete(predicates);
  }

  public async updateUserAvatar(userId: string, avatar: string): Promise<number> {
    const values: relationalStore.ValuesBucket = {
      [COLUMN_AVATAR]: avatar,
      [COLUMN_UPDATE_TIME]: Date.now()
    };
    const predicates = new relationalStore.RdbPredicates(TABLE_USER_CACHE);
    predicates.equalTo(COLUMN_USER_ID, userId);
    return await RdbHelper.update(TABLE_USER_CACHE, values, predicates);
  }
}

const userCacheManager = UserCacheManager.getInstance();
export default userCacheManager;
