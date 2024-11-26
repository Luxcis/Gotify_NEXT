import { HttpUtil } from '../util/http';

export interface Message {
  appid: number;
  date: string;
  extras?: ESObject;
  id: number;
  message: string;
  priority?: number;
  title?: string;
}

export interface MessageResponse {
  messages: Message[];
  paging: MessagePaging;
}

export interface MessagePaging {
  limit: number;
  next?: string;
  since: number;
  size: number;
}

export const getAllMessage = (): Promise<MessageResponse> => {
  return HttpUtil.get('/message')
}

export const getAllMessageByAppId = (appId: number): Promise<MessageResponse> => {
  return HttpUtil.get(`/application/${appId}/message`)
}

export const deleteMessageById = (id: number): Promise<ESObject> => {
  return HttpUtil.request('delete', `/message/${id}`)
}