import { promptAction } from '@kit.ArkUI'

/**
 * 自定义提示
 * @param message
 */
export function AlertMessage(message: string, showDuration: number = 2000) {
  promptAction.showToast({
    message: message,
    duration: showDuration,
  })
}