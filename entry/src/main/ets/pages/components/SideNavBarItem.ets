import { Application } from '../../api/app'


@Component
export default struct SideNavBarItem {
  @Prop currentAppId: number
  @Prop app: Application

  build() {
    Row() {
      Image(this.app.image)
        .width(28)

      Text(this.app.name)
        .fontWeight(this.currentAppId === this.app.id ? FontWeight.Bold : FontWeight.Normal)
        .margin({ left: 10 })
    }
    .width('100%')
    .padding({
      top: 8,
      bottom: 8,
      left: 20,
      right: 20
    })
  }
}