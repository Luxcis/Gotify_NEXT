const URL_KEY = 'BASE_URL'
const TOKEN_KEY = 'X-Gotify-Key'
const CLIENT_NAME_KEY = 'CLIENT_NAME'
const USERNAME_KEY = 'USERNAME'
const PASSWORD_KEY = 'PASSWORD'
const APP_ICON = 'APP_ICON'
const PUSH_TOKEN = 'PUSH_TOKEN'
const NEED_LOGIN = 'NEED_LOGIN'
type RequestMethods = 'get' | 'post' | 'put' | 'delete' | 'patch' | 'option' | 'head'
const Ok = 200
const BadRequest = 400
const Unauthorized = 401
const Forbidden = 403
const NotFound = 404
const InternalServerError = 500

export interface ErrorResponse {
  error: string
  errorCode: number
  errorDescription: string
}

export {
  URL_KEY,
  TOKEN_KEY,
  CLIENT_NAME_KEY,
  USERNAME_KEY,
  PASSWORD_KEY,
  APP_ICON,
  PUSH_TOKEN,
  NEED_LOGIN,
  RequestMethods,
  Ok,
  BadRequest,
  Unauthorized,
  Forbidden,
  NotFound,
  InternalServerError
}