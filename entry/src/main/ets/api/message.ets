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

export const getMessages = (since: number, limit: number, appId?: number): Promise<MessageResponse> => {
  if (appId && appId > 0) {
    return getAllMessageByAppId(since, limit, appId)
  } else {
    return getAllMessage(since, limit)
  }
}

export const getAllMessage = (since: number, limit: number): Promise<MessageResponse> => {
  return HttpUtil.get('/message', { since, limit })
}

export const getAllMessageByAppId = (since: number, limit: number, appId: number): Promise<MessageResponse> => {
  return HttpUtil.get(`/application/${appId}/message`, { since, limit })
}

export const deleteMessageById = (id: number): Promise<ESObject> => {
  return HttpUtil.request('delete', `/message/${id}`)
}