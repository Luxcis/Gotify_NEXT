import { Base64Util, StrUtil } from '@pura/harmony-utils';
import { HttpUtil } from '../util/http';

export interface LoginResponse {
  id: number;
  lastUsed?: Date;
  name: string;
  token: string;
}

export interface LoginRequest {
  username: string;
  password: string;
  name: string;
}

export interface UserResponse {
  id: number;
  name: string;
  admin: boolean
}

export const login = (param: LoginRequest): Promise<LoginResponse> => {
  const key = Base64Util.encodeToStrSync(StrUtil.strToUint8Array(`${param.username}:${param.password}`))
  console.log('登陆中。。。' + key);
  return HttpUtil.request('post', '/client', {
    data: { name: param.name },
    headers: {
      'Authorization': `Basic ${key}`
      //   登陆中。。。YWRtaW46TEJONDdVVGlqWUpacnk0Km51ZGQ=
      //   登陆中。。。YWRtaW46TEJONDdVVGlqWUpacnk0Km51ZGQ=
    }
  })
}