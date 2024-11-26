import { HttpUtil } from '../util/http';
import { UserResponse } from './auth';

export interface VersionResponse {
  buildDate: string;
  commit: string;
  version: string;
}

export interface HealthResponse {
  health: string;
  database: string;
}

export const version = (): Promise<VersionResponse> => {
  return HttpUtil.get('/version')
}

export const health = (): Promise<HealthResponse> => {
  return HttpUtil.get('/health')
}

export const user = (): Promise<UserResponse> => {
  return HttpUtil.get('/current/user');
}