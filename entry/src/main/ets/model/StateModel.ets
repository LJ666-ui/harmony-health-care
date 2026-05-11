import { PatientInfo, PatientDetail } from './PatientModel';

export enum LoadingState {
  IDLE = 'IDLE',
  LOADING = 'LOADING',
  SUCCESS = 'SUCCESS',
  ERROR = 'ERROR',
  EMPTY = 'EMPTY'
}

export interface PatientListPageState {
  patients: PatientInfo[];
  filteredPatients: PatientInfo[];
  viewedPatientIds: Set<string>;
  loadingState: LoadingState;
  searchText: string;
  pageNumber: number;
  pageSize: number;
  hasMore: boolean;
  total: number;
  errorMessage?: string;
}

export interface PatientDetailPageState {
  rawDetail: PatientDetail | null;
  displayDetail: PatientDetail | null;
  loadingState: LoadingState;
  isFromCache: boolean;
  cacheExpireTime: number;
  errorMessage?: string;
}

export function createInitialListState(): PatientListPageState {
  return {
    patients: [],
    filteredPatients: [],
    viewedPatientIds: new Set<string>(),
    loadingState: LoadingState.IDLE,
    searchText: '',
    pageNumber: 1,
    pageSize: 20,
    hasMore: false,
    total: 0
  };
}

export function createInitialDetailState(): PatientDetailPageState {
  return {
    rawDetail: null,
    displayDetail: null,
    loadingState: LoadingState.IDLE,
    isFromCache: false,
    cacheExpireTime: 0
  };
}
