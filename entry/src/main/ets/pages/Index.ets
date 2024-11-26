import { user, version } from '../api/ping';
import { AlertMessage } from '../util/alert';
import { NEED_LOGIN, TOKEN_KEY, URL_KEY } from '../util/model';
import MessageView from './components/MessageView';
import ServerSettings from './components/ServerSettings';
import SideNavBar from './components/SideNavBar';
import TopBar from './components/TopBar';

@Entry
@Component
struct Index {
  @StorageLink('topRectHeight') topRectHeight: number = 0
  @StorageLink(URL_KEY) url: string = ''
  @StorageLink(TOKEN_KEY) token: string = ''
  @StorageProp('WindowWidth') windowWidth: number = 0
  @State showSettings: boolean = false
  @State showSideBar: boolean = false
  @State nickname: string = ''
  @State version: string = ''
  @State currentAppTitle: string = 'Gotify'
  @State currentAppId: number = 0
  private scroller: Scroller = new Scroller()

  onPageShow() {
    this.checkServer()
  }

  onBackPress() {
    console.info('IndexComponent onBackPress');
    if (this.showSideBar) {
      animateTo({ duration: 400 }, () => {
        this.showSideBar = false
      })
      return true
    }
    return false
  }

  build() {
    SideBarContainer(SideBarContainerType.Embed) {
      Column() {
        SideNavBar({
          nickname: this.nickname,
          version: this.version,
          currentAppId: this.currentAppId,
          currentAppTitle: this.currentAppTitle,
          showSettings: this.showSettings,
        })
      }
      .width('70%')
      .height('100%')

      Column() {
        Scroll(this.scroller) {
          Column() {
            TopBar({
              showSideBar: this.showSideBar,
              title: this.currentAppTitle
            }).height('12%')

            MessageView({
              currentAppId: this.currentAppId,
            }).height('88%')
          }
        }
        .enabled(!this.showSideBar)
        .width(this.windowWidth ? this.windowWidth : '100%')
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)

        Flex() {
          // 设置界面
        }
        .width(0)
        .height(0)
        .borderRadius({ topRight: 30, bottomRight: 30 })
        .bindSheet(this.showSettings, this.settings(), {
          showClose: this.token ? true : false,
          dragBar: false,
          backgroundColor: 'white',
          blurStyle: BlurStyle.COMPONENT_ULTRA_THIN,
          onDisappear: () => {
            // this.showSettings = false
            this.checkServer()
          },
        })
      }
      .width('170%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .showSideBar($$this.showSideBar)
    .sideBarWidth('70%')
    .maxSideBarWidth(350)
    .divider({ strokeWidth: 0 })
    .controlButton({
      // 设置侧边栏控制按钮的样式
      width: 30, // 设置侧边栏控制按钮宽度为30
      height: 30, // 设置侧边栏控制按钮高度为30
      top: 15 + this.topRectHeight, // 设置侧边栏控制按钮距离容器顶部为15
      icons: {
        // 设置侧边栏控制按钮图片
        hidden: $r('app.media.ic_public_drawer_filled'), // 设置侧边栏隐藏时控制按钮的图标。
        shown: $r('app.media.ic_public_drawer_filled'), // 设置侧边栏显示时控制按钮的图标。
        switching: $r('app.media.ic_public_drawer_filled')        // 设置侧边栏显示和隐藏状态切换时控制按钮的图标。
      }
    })
  }

  @Builder
  settings() {
    Row() {
      ServerSettings({ showSettings: this.showSettings })
    }
  }

  checkServer() {
    if (this.url.length === 0) {
      this.showSettings = true
    } else if (this.token.length === 0) {
      this.showSettings = true
    } else {
      console.log('加载版本信息。。。')
      version().then(res => {
        this.version = res.version
        console.log('加载用户信息。。。')
        user().then(res => {
          this.showSettings = false
          this.nickname = res.name
        }).catch((err: Error) => {
          if (err.message === NEED_LOGIN) {
            AlertMessage('Token失效，请重新登陆')
          } else {
            AlertMessage(`服务异常：${err.message}`)
          }
          this.showSettings = true
        })
      }).catch(() => {
        this.showSettings = true
      })
    }
  }
}
