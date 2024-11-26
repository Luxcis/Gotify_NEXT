import { Application, applications } from '../../api/app'
import { APP_ICON, TOKEN_KEY, URL_KEY } from '../../util/model'
import SideNavBarItem from './SideNavBarItem'
import { HashMap, url } from '@kit.ArkTS'
import { DialogUtil } from '@pura/harmony-utils'
import { pushService } from '@kit.PushKit'
import { ErrorLog } from '../../util/log'
import { pasteboard } from '@kit.BasicServicesKit';
import { AlertMessage } from '../../util/alert'

@Component
export default struct SideNavBar {
  @StorageProp('topRectHeight') topRectHeight: number = 0
  @StorageProp(URL_KEY) url: string = ''
  @StorageProp(TOKEN_KEY) @Watch('onTokenChange') token: string = ''
  @StorageLink(APP_ICON) appIcon: HashMap<number, string> | undefined = undefined
  @Prop nickname: string
  @Prop version: string
  @Link currentAppId: number
  @Link currentAppTitle: string
  @Link showSettings: boolean
  @State apps: Application[] = []

  onTokenChange() {
    if (this.token) {
      this.apps = []
      this.loadApplication()
    }
  }

  aboutToAppear() {
    console.log('加载应用。。。')
    this.loadApplication()
  }

  loadApplication() {
    let map: HashMap<number, string> = new HashMap()
    applications().then(res => {
      this.apps = res
      for (let app of res) {
        map.set(app.id, url.URL.parseURL(app.image as string, this.url).toString())
      }
      this.appIcon = map
    })
  }

  @Builder
  itemDivider() {
    Divider().strokeWidth(1).color(Color.Gray).margin({ left: 25, right: 25 })
  }

  build() {
    Column() {
      Flex({ direction: FlexDirection.Column }) {
        Image($r('app.media.startIcon'))
          .width('40%')
          .margin({ bottom: 10 })

        Text(this.nickname)
          .fontColor(Color.White)

        Text(this.url)
          .fontColor(Color.White)

        Text(`v${this.version}`)
          .fontColor(Color.White)
      }
      .height('30%')
      .width('100%')
      .padding({ top: 55 + this.topRectHeight, left: 20 })
      .linearGradient({
        angle: 105,
        colors: [[$r('app.color.side_bar_gradient_start'), 0.0], [$r('app.color.side_bar_gradient_end'), 1.0]]
      })

      List() {
        ListItemGroup() {
          ListItem({ style: ListItemStyle.CARD }) {
            SideNavBarItem({
              currentAppId: this.currentAppId,
              app: {
                id: 0,
                name: '所有消息',
                image: $r('app.media.ic_public_app_filled')
              }
            }).onClick(() => {
              animateTo({ duration: 500 }, () => {
                this.currentAppId = 0
                this.currentAppTitle = 'Gotify'
              })
            })
          }
          .backgroundColor('#f6f8fc')
          .selected(this.currentAppId === 0)
          .borderRadius(50)
        }

        ListItemGroup({
          header: this.itemDivider(),
          footer: this.itemDivider()
        }) {
          ForEach(this.apps, (app: Application) => {
            ListItem({ style: ListItemStyle.CARD }) {
              SideNavBarItem({
                currentAppId: this.currentAppId,
                app: {
                  id: app.id,
                  name: app.name,
                  image: this.appIcon?.get(app.id) as string
                }
              }).onClick(() => {
                this.currentAppId = app.id
                this.currentAppTitle = app.name
              })
            }
            .backgroundColor('#f6f8fc')
            .selected(this.currentAppId === app.id)
            .borderRadius(50)
          })
        }

        ListItemGroup() {
          ListItem({ style: ListItemStyle.CARD }) {
            SideNavBarItem({
              currentAppId: this.currentAppId,
              app: {
                id: 999,
                name: '设置',
                image: $r('app.media.ic_public_settings_filled')
              }
            }).onClick(() => {
              this.showSettings = true
            })
          }
          .backgroundColor('#f6f8fc')
          .borderRadius(50)

          ListItem({ style: ListItemStyle.CARD }) {
            SideNavBarItem({
              currentAppId: this.currentAppId,
              app: {
                id: 999,
                name: '获取Token',
                image: $r('app.media.ic_contacts_encryption_calls')
              }
            }).onClick(() => {
              pushService.getToken().then(token => {
                DialogUtil.showConfirmDialog({
                  message: '请妥善保存你的token，不要泄漏',
                  confirm: "复制并关闭",
                  onAction: () => {
                    // 创建一条纯文本类型的剪贴板内容对象
                    let pasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, token);
                    // 将数据写入系统剪贴板
                    let systemPasteboard = pasteboard.getSystemPasteboard();
                    systemPasteboard.setDataSync(pasteData)
                    AlertMessage('成功复制到剪贴板')
                  }
                })
              }).catch((err: Error) => {
                ErrorLog(err)
              })
            })
          }
          .backgroundColor('#f6f8fc')
          .borderRadius(50)
        }
      }
      .height('70%')
      .width('100%')
      .scrollBar(BarState.Off)
      .padding(5)
      .backgroundColor('#f6f8fc')
    }
    .height('100%')
    .width('100%')
  }
}