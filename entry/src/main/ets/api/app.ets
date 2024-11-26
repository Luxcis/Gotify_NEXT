import { HttpUtil } from '../util/http';

export interface Application {
  defaultPriority?: number;
  description?: string;
  id: number;
  image: ResourceStr;
  internal?: boolean;
  lastUsed?: Date;
  name: string;
  token?: string;
}

export const applications = (): Promise<Application[]> => {
  return HttpUtil.get('/application');
}