import webSocket from '@ohos.net.webSocket';
import { APP_ICON, TOKEN_KEY, URL_KEY } from '../../util/model';
import { HashMap, url } from '@kit.ArkTS';
import { deleteMessageById, getAllMessage, getAllMessageByAppId, Message } from '../../api/message';
import { AlertMessage } from '../../util/alert';
import MessageContent from './MessageContent';
import { DateUtil } from '@pura/harmony-utils';

@Component
export default struct MessageView {
  @StorageProp(URL_KEY) url: string = ''
  @StorageProp(TOKEN_KEY) @Watch('onTokenChange') token: string = ''
  @StorageLink(APP_ICON) appIcon: HashMap<number, string> | undefined = undefined
  @Prop @Watch('onCurrentAppChange') currentAppId: number
  @State messages: Message[] = []
  @State isRefreshing: boolean = false
  private webSocketImpl?: webSocket.WebSocket | null = null;

  onTokenChange() {
    //刷新ws监听
    this.isRefreshing = true
    this.connect()
  }

  onCurrentAppChange() {
    this.isRefreshing = true
  }

  aboutToAppear() {
    console.log('加载消息数据。。。')
    this.isRefreshing = true
    this.connect()
  }

  connect() {
    if (this.url) {
      this.close()
      let webSocketImpl = webSocket.createWebSocket(); // 创建WebSocket实例
      webSocketImpl.on('open', (error, data) => { // 监听连接建立
        this.webSocketImpl = webSocketImpl; // 连接建立成功，可以调用send方法向服务器发送数据
        console.log('连接已建立：' + JSON.stringify(data))
      });
      webSocketImpl.on('message', (error, data) => { // 监听服务器端发送的数据
        console.log('接收到消息：' + data)
        const receivedMessage = JSON.parse(data as string) as Message
        if (receivedMessage.appid === this.currentAppId || this.currentAppId === 0) {
          animateTo({ duration: 500 }, () => {
            this.messages = [receivedMessage, ...this.messages]
          })
        }
      });
      webSocketImpl.on('close', (data) => { // 监听连接关闭的回调
        this.webSocketImpl = null;
        console.log('连接已关闭：' + JSON.stringify(data))
      });
      webSocketImpl.on('error', (data) => { // 监听异常事件
        console.log('ws异常：' + JSON.stringify(data))
        this.close();
      })

      const ws = url.URL.parseURL('/stream', this.url).toString().replace('http', 'ws')
      webSocketImpl.connect(`${ws}?token=${this.token}`, (error, data) => {
        if (!error) {
          console.log('ws连接成功: ' + data)
        } else {
          console.log('ws连接失败: ' + JSON.stringify(error))
        }
      })
    }
  }

  close() {
    if (this.webSocketImpl) {
      this.webSocketImpl.close((data) => {
        console.log("关闭连接: " + JSON.stringify(data));
      });
      this.webSocketImpl = null;
    }
  }

  build() {
    Column() {
      Refresh({ refreshing: $$this.isRefreshing }) {
        List({ space: 10 }) {
          ForEach(this.messages, (msg: Message) => {
            ListItem({ style: ListItemStyle.CARD }) {
              MessageContent({
                title: msg.title,
                message: msg.message,
                time: DateUtil.getTipDateStr(new Date(msg.date)),
                image: this.appIcon?.get(msg.appid)
              })
            }
            .height(undefined)
            .borderRadius(30)
            .transition(TransitionEffect.OPACITY)
            .swipeAction({
              end: {
                builder: () => {
                  this.itemEnd()
                },
                onAction: () => {
                  animateTo({ duration: 500 }, () => {
                    console.log('onAction:触发删除操作')
                    deleteMessageById(msg.id)

                    this.messages = this.messages.filter((item) => {
                      return msg.id != item.id
                    })
                  })
                },
                actionAreaDistance: 56,
              }
            })
          }, (item: Message) => {
            return item.id.toString()
          })
        }
        .width('100%')
        .height('100%')
        .divider({
          strokeWidth: 1,
          color: Color.Gray,
          startMargin: 20,
          endMargin: 20
        })
        .scrollBar(BarState.Off)
      }
      .onRefreshing(() => {
        console.log('appId: ' + this.currentAppId)
        animateTo({ duration: 500 }, () => {
          if (this.currentAppId === 0) {
            getAllMessage().then(res => {
              this.messages = []
              this.messages = res.messages
            }).catch((err: Error) => {
              AlertMessage('全量消息刷新失败：' + err.message)
            }).finally(() => {
              this.isRefreshing = false
            })
          } else {
            getAllMessageByAppId(this.currentAppId).then(res => {
              this.messages = []
              this.messages = res.messages
            }).catch((err: Error) => {
              AlertMessage('应用消息刷新失败：' + err.message)
            }).finally(() => {
              this.isRefreshing = false
            })
          }
        })
      })
      .refreshOffset(64)
      .pullToRefresh(true)
    }
    .padding(5)
  }

  @Builder
  itemEnd() {
    Row() {
      Button({ type: ButtonType.Circle, stateEffect: true }) {
        Image($r('app.media.ic_public_delete_filled'))
          .width(25)
          .fillColor(Color.White)
      }
      .width(40)
      .height(40)
      .margin(5)
      .type(ButtonType.Circle)
      .backgroundColor(Color.Red)
    }
    .padding(4)
    .justifyContent(FlexAlign.SpaceEvenly)
  }
}