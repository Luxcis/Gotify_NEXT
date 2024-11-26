import { login } from '../../api/auth';
import { version } from '../../api/ping';
import { AlertMessage } from '../../util/alert';
import { CLIENT_NAME_KEY, NEED_LOGIN, PASSWORD_KEY, TOKEN_KEY, URL_KEY, USERNAME_KEY } from '../../util/model';
import { ErrorLog } from '../../util/log';
import url from '@ohos.url';
import { HttpUtil } from '../../util/http';
import { DialogUtil } from '@pura/harmony-utils';

@Component
export default struct ServerSettings {
  @StorageLink(URL_KEY) url: string = ''
  @StorageLink(TOKEN_KEY) token: string = ''
  @StorageLink(USERNAME_KEY) username: string = ''
  @StorageLink(PASSWORD_KEY) password: string = ''
  @StorageLink(CLIENT_NAME_KEY) clientName: string = ''
  @Link showSettings: boolean
  @State checkButtonText: string = '检查服务'
  @State inChecking: boolean = false
  @State inLogin: boolean = false
  @State loginInputBorderColor: Color = Color.White

  build() {
    Scroll() {
      Column() {
        Row() {
          Image($r('app.media.startIcon'))
            .objectFit(ImageFit.Contain)
            .width('80%')
        }.height('50%')
        .focusOnTouch(true)

        Column() {
          TextInput({
            placeholder: 'Gotify服务URL',
            text: this.url
          })
            .enterKeyType(EnterKeyType.Done)
            .width('90%')
            .margin({ bottom: 10 })
            .onChange(val => {
              if (this.checkUrl(val)) {
                console.log('url正确，保存至本地。。。')
                this.url = url.URL.parseURL('', val).toString()
              }
            })

          Button(this.checkButtonText)
            .onClick(() => {
              console.log(`检查服务：${this.url}`);
              if (this.checkUrl()) {
                this.inChecking = true
                version().then(res => {
                  this.checkButtonText = `服务正常 ${res.version}`
                }).catch((err: Error) => {
                  ErrorLog(err)
                  AlertMessage(`服务异常：${err.message}`)
                }).finally(() => {
                  this.inChecking = false
                })
              }
            }).margin({ bottom: 10 })
            .width('90%')
            .visibility(this.inChecking ? Visibility.None : Visibility.Visible)

          Button() {
            Row() {
              LoadingProgress().width(35).height(35).color(0xFFFFFF)
              Text(this.checkButtonText).fontColor(0xffffff).margin({ left: 5, right: 12 })
            }
          }
          .margin({ bottom: 10 })
          .width('90%')
          .visibility(this.inChecking ? Visibility.Visible : Visibility.None)

          TextInput({
            placeholder: '设备名称',
            text: this.clientName
          })
            .width('90%')
            .margin({ bottom: 10 })
            .enterKeyType(EnterKeyType.Next)
            .onChange(val => {
              this.clientName = val
            })
            .onSubmit(() => {
              this.getUIContext().getFocusController().requestFocus('username')
            })

          TextInput({
            placeholder: '用户名',
            text: this.username
          })
            .id('username')
            .type(InputType.USER_NAME)
            .width('90%')
            .margin({ bottom: 10 })
            .enterKeyType(EnterKeyType.Next)
            .borderWidth(1)
            .borderColor(this.loginInputBorderColor)
            .onChange(val => {
              this.username = val
            })
            .onSubmit(() => {
              this.getUIContext().getFocusController().requestFocus('password')
            })

          TextInput({
            placeholder: '密码',
            text: this.password
          })
            .id('password')
            .type(InputType.NEW_PASSWORD)
            .width('90%')
            .margin({ bottom: 10 })
            .enterKeyType(EnterKeyType.Done)
            .borderWidth(1)
            .borderColor(this.loginInputBorderColor)
            .onChange(val => {
              this.password = val
            })
            .onSubmit(() => {
              this.doLogin()
            })

          Button('登陆')
            .onClick(() => {
              this.doLogin()
            })
            .margin({ bottom: 10 })
            .width('90%')
            .visibility(this.inLogin ? Visibility.None : Visibility.Visible)

          Button() {
            Row() {
              LoadingProgress().width(35).height(35).color(0xFFFFFF)
              Text('登陆').fontColor(0xffffff).margin({ left: 5, right: 12 })
            }
          }
          .margin({ bottom: 10 })
          .width('90%')
          .visibility(this.inLogin ? Visibility.Visible : Visibility.None)

        }.height('50%')
      }
    }
    .height('100%')
    .width('100%')
    .transition(TransitionEffect.OPACITY
      .combine(TransitionEffect.translate({ x: '100%' }))
      .combine(TransitionEffect.scale({ x: 0.95, y: 0.95 })))
  }

  checkUrl(baseUrl: string = this.url): boolean {
    try {
      url.URL.parseURL(baseUrl)
      HttpUtil.init(baseUrl)
      return true
    } catch (err) {
      ErrorLog(err)
      return false
    }
  }

  doLogin() {
    if (this.checkUrl()) {
      version().then(res => {
        this.checkButtonText = `服务正常 ${res.version}`
        this.inLogin = true
        this.loginInputBorderColor = Color.White
        login({
          username: this.username,
          password: this.password,
          name: this.clientName
        }).then(res => {
          this.token = res.token
          this.showSettings = false
          AlertMessage('登陆成功')
        }).catch((err: Error) => {
          ErrorLog(err)
          if (err.message === NEED_LOGIN) {
            AlertMessage('用户名密码错误')
            DialogUtil.showConfirmDialog({
              title: '登陆失败',
              message: '用户名密码错误！',
              confirm: '确定',
            })
          } else {
            AlertMessage(err.message)
          }
          this.loginInputBorderColor = Color.Red
        }).finally(() => {
          this.inLogin = false
        })
      }).catch((err: Error) => {
        ErrorLog(err)
        AlertMessage(`服务异常：${err.message}`)
      }).finally(() => {
        this.inChecking = false
      })
    }
  }
}