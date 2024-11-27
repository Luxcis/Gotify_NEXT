import webSocket from '@ohos.net.webSocket';
import { APP_ICON, TOKEN_KEY, URL_KEY } from '../../util/model';
import { HashMap, url } from '@kit.ArkTS';
import { deleteMessageById, getMessages, Message } from '../../api/message';
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
  @State since: number = 0
  @State limit: number = 10
  @State isRefreshing: boolean = false
  @State canLoad: boolean = false
  @State isLoading: boolean = false;
  @State isEnd: boolean = false;
  @State isAll: boolean = true;
  private webSocketImpl?: webSocket.WebSocket | null = null;
  private scroll: Scroller = new Scroller()

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
      webSocketImpl.on('open', (_, data) => { // 监听连接建立
        this.webSocketImpl = webSocketImpl; // 连接建立成功，可以调用send方法向服务器发送数据
        console.log('连接已建立：' + JSON.stringify(data))
      });
      webSocketImpl.on('message', (_, data) => { // 监听服务器端发送的数据
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
        List({ space: 10, scroller: this.scroll }) {
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

          ListItem() {
            Row() {
              LoadingProgress().height(32).width(48)
            }.width("100%")
            .height(64)
            .justifyContent(FlexAlign.Center)
            // 当不处于加载中状态时隐藏组件
            .visibility(this.isLoading ? Visibility.Visible : Visibility.Hidden)
          }
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
        .onScrollStart(() => {
          if (this.isEnd) {
            console.log('到底辣！！！')
            this.canLoad = true
            animateTo({ duration: 1000 }, () => {
              this.isLoading = true
            })
          } else {
            this.canLoad = false
          }
        })
        .onReachEnd(() => {
          if (this.isEnd && this.canLoad && !this.isAll) {
            console.log('onReachEnd到底辣！！！')
            animateTo({ duration: 500 }, () => {
              this.loadMessage(this.since)
            })
          }
        })
        .onScrollIndex((start: number, end: number) => {
          console.log(`${start}|${end}`)
          this.isEnd = end === this.messages.length
        })
      }
      .onRefreshing(() => {
        console.log('appId: ' + this.currentAppId)
        this.since = 0
        animateTo({ duration: 500 }, () => {
          this.loadMessage(this.since)
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

  loadMessage(since: number) {
    getMessages(since, this.limit, this.currentAppId).then(res => {
      if (this.isRefreshing) {
        this.messages = res.messages
        this.scroll.scrollToIndex(0, true)
      } else {
        this.messages.push(...res.messages)
      }
      this.since = res.paging.since
      this.isAll = res.messages.length === 0
    }).catch((err: Error) => {
      if (this.currentAppId === 0) {
        AlertMessage('全量消息刷新失败：' + err.message)
      } else {
        AlertMessage('应用消息刷新失败：' + err.message)
      }
    }).finally(() => {
      this.isRefreshing = false
      this.isLoading = false
      this.canLoad = false
      this.isEnd = false
    })
  }
}