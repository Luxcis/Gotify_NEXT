import axios, {
  AxiosError,
  AxiosInstance,
  AxiosRequestConfig,
  AxiosResponse,
  InternalAxiosRequestConfig
} from '@ohos/axios';
import { ErrorResponse, NEED_LOGIN, Ok, RequestMethods, TOKEN_KEY, Unauthorized } from './model';
import { JSON } from '@kit.ArkTS';

export class HttpUtil {
  private static instance: AxiosInstance

  public static init(baseURL?: string) {
    HttpUtil.instance = axios.create({
      baseURL,
      // 超时时间30秒
      timeout: 30 * 1000,
      headers: {
        'Accept': 'application/json, text/plain, */*',
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest'
      },
    });
    // 初始化拦截器
    HttpUtil.httpInterceptorsRequest();
    HttpUtil.httpInterceptorsResponse();
  }

  public static request<T>(
    method: RequestMethods,
    url: string,
    config?: AxiosRequestConfig<ESObject>
  ): Promise<T> {
    if (config) {
      config.method = method
      config.url = url
    } else {
      config = { method, url }
    }
    return new Promise((resolve, reject) => {
      HttpUtil.instance
        .request(config)
        .then((response: ESObject) => {
          resolve(response);
        })
        .catch((error: AxiosError) => {
          reject(error);
        });
    });
  }

  public static get<T>(url: string, params?: ESObject): Promise<T> {
    return HttpUtil.request<T>('get', url, { params });
  }

  public static post<T>(url: string, data?: ESObject): Promise<T> {
    return HttpUtil.request<T>('post', url, { data });
  }

  /**请求拦截器*/
  private static httpInterceptorsRequest() {
    HttpUtil.instance.interceptors.request.use((config: InternalAxiosRequestConfig) => {
      // 对请求数据做点什么
      config.headers[TOKEN_KEY] = AppStorage.get(TOKEN_KEY)
      console.debug(`接口[${config.url}]发送请求，请求参数：${JSON.stringify(config.params)}，请求体：${JSON.stringify(config.data)}`)
      return config;
    }, (error: AxiosError) => {
      // 对请求错误做些什么
      console.error(error.message)
      return Promise.reject(error);
    });
  }

  /**响应拦截器*/
  private static httpInterceptorsResponse() {
    HttpUtil.instance.interceptors.response.use((response: AxiosResponse<ESObject>) => {
      // 对响应数据做点什么
      if (response.status === Ok) {
        console.debug(`接口[${response.config.url}]请求成功，返回结果：${JSON.stringify(response.data)}`)
        return response.data
      } else if (response.status === Unauthorized) {
        return Promise.reject(new Error(NEED_LOGIN));
      } else {
        return Promise.reject(response.data.errorDescription);
      }
    }, (error: AxiosError) => {
      // 对响应错误做点什么
      if (error.message.includes('timeout')) {
        return Promise.reject('连接超时');
      } else {
        console.error(error.message)
        const res = error.response?.data as ErrorResponse
        console.log(JSON.stringify(res))
        if (res.errorCode === Unauthorized) {
          return Promise.reject(new Error(NEED_LOGIN));
        }
        return Promise.reject(new Error(res.errorDescription));
      }
    });
  }
}