@Component
export default struct TopBar {
  @StorageLink('topRectHeight') topRectHeight: number = 0
  @Prop showSideBar: boolean
  @Prop title: string

  build() {
    Row() {
      Text(this.title)
        .fontColor(Color.White)
        .fontSize(27)
        .margin({ left: 20 + (this.showSideBar ? 0 : 40) })
        .textAlign(TextAlign.Center)
        .animation({
          duration: 500, // 设置动画指定时长
          curve: Curve.Friction, // 设置动画曲线样式
          playMode: PlayMode.Normal // 设置播放模式
        })
    }
    .height('100%')
    .width('100%')
    .backgroundColor($r('app.color.main_bar_color'))
    .padding({ top: this.topRectHeight })
  }
}