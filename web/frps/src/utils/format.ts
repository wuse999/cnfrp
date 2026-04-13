export function formatDistanceToNow(date: Date): string {
  const seconds = Math.floor((new Date().getTime() - date.getTime()) / 1000)

  let interval = seconds / 31536000
  if (interval > 1) return Math.floor(interval) + ' 年前'

  interval = seconds / 2592000
  if (interval > 1) return Math.floor(interval) + ' 个月前'

  interval = seconds / 86400
  if (interval > 1) return Math.floor(interval) + ' 天前'

  interval = seconds / 3600
  if (interval > 1) return Math.floor(interval) + ' 小时前'

  interval = seconds / 60
  if (interval > 1) return Math.floor(interval) + ' 分钟前'

  return Math.max(1, Math.floor(seconds)) + ' 秒前'
}

export function formatFileSize(bytes: number): string {
  if (!Number.isFinite(bytes) || bytes < 0) return '0 B'
  if (bytes === 0) return '0 B'
  const k = 1024
  const sizes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  const unit = sizes[i] || sizes[sizes.length - 1]
  const val = bytes / Math.pow(k, i)

  return parseFloat(val.toFixed(2)) + ' ' + unit
}
