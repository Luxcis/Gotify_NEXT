@Component
export default struct RefreshComponent {
  @Prop RefreshingTitle: string = '松开刷新'

  build() {
    Row() {
      if (this.RefreshingTitle !== '松开刷新') {
        LoadingProgress().height(30)
      }
      Text(this.RefreshingTitle).fontSize(16).margin({ left: 20 })
    }
  }
}