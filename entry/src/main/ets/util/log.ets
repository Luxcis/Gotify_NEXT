export const ErrorLog = (err: Error) => {
  console.error(`服务异常：name[${err.name}] message[${err.message}] stack[${err.stack}]`)
}