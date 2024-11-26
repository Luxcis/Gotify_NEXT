@Component
export default struct MessageContent {
  @Prop title: string
  @Prop message: string
  @Prop time: string
  @Prop image: string

  build() {
    Flex({ direction: FlexDirection.Column }) {
      Row() {
        Text(this.title)
          .fontWeight(FontWeight.Bold)
          .width('75%')

        Text(this.time)
          .width('25%')
          .textAlign(TextAlign.End)
      }

      Row() {
        Image(this.image)
          .alt($r('app.media.ic_public_close'))
          .width(65)
          .height(65)
          .margin({ right: 10 })

        Text(this.message)
          .padding(10)
          .width('80%')
      }
      .width('100%')
      .constraintSize({ minHeight: 80 })

      // Divider().strokeWidth(1).color(Color.Gray)
    }.padding(10)
  }
}