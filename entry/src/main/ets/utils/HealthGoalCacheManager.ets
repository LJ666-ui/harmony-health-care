import relationalStore from '@ohos.data.relationalStore';
import RdbHelper from './RdbHelper';
import {
  TABLE_HEALTH_GOAL_CACHE,
  COLUMN_ID,
  COLUMN_GOAL_ID,
  COLUMN_USER_ID,
  COLUMN_TYPE,
  COLUMN_TARGET_VALUE,
  COLUMN_CURRENT_VALUE,
  COLUMN_START_TIME,
  COLUMN_END_TIME,
  COLUMN_SYNCED
} from './DatabaseConstants';

export interface HealthGoalCache {
  id?: number;
  goalId: string;
  userId?: string;
  type?: string;
  targetValue?: string;
  currentValue?: string;
  startTime?: number;
  endTime?: number;
  synced?: number;
}

class HealthGoalCacheManager {
  private static instance: HealthGoalCacheManager;

  private constructor() {}

  public static getInstance(): HealthGoalCacheManager {
    if (!HealthGoalCacheManager.instance) {
      HealthGoalCacheManager.instance = new HealthGoalCacheManager();
    }
    return HealthGoalCacheManager.instance;
  }

  public async cacheHealthGoal(goal: HealthGoalCache): Promise<number> {
    const values: relationalStore.ValuesBucket = {
      [COLUMN_GOAL_ID]: goal.goalId,
      [COLUMN_USER_ID]: goal.userId || null,
      [COLUMN_TYPE]: goal.type || null,
      [COLUMN_TARGET_VALUE]: goal.targetValue || null,
      [COLUMN_CURRENT_VALUE]: goal.currentValue || null,
      [COLUMN_START_TIME]: goal.startTime || Date.now(),
      [COLUMN_END_TIME]: goal.endTime || null,
      [COLUMN_SYNCED]: goal.synced || 0
    };

    const predicates = new relationalStore.RdbPredicates(TABLE_HEALTH_GOAL_CACHE);
    predicates.equalTo(COLUMN_GOAL_ID, goal.goalId);
    
    const resultSet = await RdbHelper.queryByPredicates(predicates, [COLUMN_ID]);
    if (resultSet.goToFirstRow()) {
      resultSet.close();
      return await RdbHelper.update(TABLE_HEALTH_GOAL_CACHE, values, predicates);
    }
    resultSet.close();
    
    return await RdbHelper.insert(TABLE_HEALTH_GOAL_CACHE, values);
  }

  public async getCachedHealthGoal(goalId: string): Promise<HealthGoalCache | null> {
    const predicates = new relationalStore.RdbPredicates(TABLE_HEALTH_GOAL_CACHE);
    predicates.equalTo(COLUMN_GOAL_ID, goalId);

    const resultSet = await RdbHelper.queryByPredicates(predicates);
    if (resultSet.goToFirstRow()) {
      const goal: HealthGoalCache = {
        id: resultSet.getLong(resultSet.getColumnIndex(COLUMN_ID)),
        goalId: resultSet.getString(resultSet.getColumnIndex(COLUMN_GOAL_ID)),
        userId: resultSet.getString(resultSet.getColumnIndex(COLUMN_USER_ID)),
        type: resultSet.getString(resultSet.getColumnIndex(COLUMN_TYPE)),
        targetValue: resultSet.getString(resultSet.getColumnIndex(COLUMN_TARGET_VALUE)),
        currentValue: resultSet.getString(resultSet.getColumnIndex(COLUMN_CURRENT_VALUE)),
        startTime: resultSet.getLong(resultSet.getColumnIndex(COLUMN_START_TIME)),
        endTime: resultSet.getLong(resultSet.getColumnIndex(COLUMN_END_TIME)),
        synced: resultSet.getLong(resultSet.getColumnIndex(COLUMN_SYNCED))
      };
      resultSet.close();
      return goal;
    }
    resultSet.close();
    return null;
  }

  public async getHealthGoalsByUser(userId: string): Promise<HealthGoalCache[]> {
    const predicates = new relationalStore.RdbPredicates(TABLE_HEALTH_GOAL_CACHE);
    predicates.equalTo(COLUMN_USER_ID, userId);
    predicates.orderByDesc(COLUMN_START_TIME);

    const goals: HealthGoalCache[] = [];
    const resultSet = await RdbHelper.queryByPredicates(predicates);
    
    while (resultSet.goToNextRow()) {
      goals.push({
        id: resultSet.getLong(resultSet.getColumnIndex(COLUMN_ID)),
        goalId: resultSet.getString(resultSet.getColumnIndex(COLUMN_GOAL_ID)),
        userId: resultSet.getString(resultSet.getColumnIndex(COLUMN_USER_ID)),
        type: resultSet.getString(resultSet.getColumnIndex(COLUMN_TYPE)),
        targetValue: resultSet.getString(resultSet.getColumnIndex(COLUMN_TARGET_VALUE)),
        currentValue: resultSet.getString(resultSet.getColumnIndex(COLUMN_CURRENT_VALUE)),
        startTime: resultSet.getLong(resultSet.getColumnIndex(COLUMN_START_TIME)),
        endTime: resultSet.getLong(resultSet.getColumnIndex(COLUMN_END_TIME)),
        synced: resultSet.getLong(resultSet.getColumnIndex(COLUMN_SYNCED))
      });
    }
    resultSet.close();
    return goals;
  }

  public async updateCurrentValue(goalId: string, currentValue: string): Promise<number> {
    const values: relationalStore.ValuesBucket = {
      [COLUMN_CURRENT_VALUE]: currentValue
    };
    const predicates = new relationalStore.RdbPredicates(TABLE_HEALTH_GOAL_CACHE);
    predicates.equalTo(COLUMN_GOAL_ID, goalId);
    return await RdbHelper.update(TABLE_HEALTH_GOAL_CACHE, values, predicates);
  }

  public async markAsSynced(goalId: string): Promise<number> {
    const values: relationalStore.ValuesBucket = {
      [COLUMN_SYNCED]: 1
    };
    const predicates = new relationalStore.RdbPredicates(TABLE_HEALTH_GOAL_CACHE);
    predicates.equalTo(COLUMN_GOAL_ID, goalId);
    return await RdbHelper.update(TABLE_HEALTH_GOAL_CACHE, values, predicates);
  }

  public async removeCachedHealthGoal(goalId: string): Promise<number> {
    const predicates = new relationalStore.RdbPredicates(TABLE_HEALTH_GOAL_CACHE);
    predicates.equalTo(COLUMN_GOAL_ID, goalId);
    return await RdbHelper.delete(predicates);
  }
}

const healthGoalCacheManager = HealthGoalCacheManager.getInstance();
export default healthGoalCacheManager;
