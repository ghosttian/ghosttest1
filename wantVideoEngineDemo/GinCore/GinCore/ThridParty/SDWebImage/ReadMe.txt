替换sdwebimage库的时候，需要修改以下文件：
1 SDWebImageDownloaderOperation.m
line 201-227 图片平台出错的时候，http code还是200，header会有X-ErrNo 和X-Info字段，需要按下载失败的流程处理.
2 SDImageCache.m
line 16 - 18,75 - 77 设置图片最大缓存
3UIImageView+WebCache.m UIButton+WebCache.m
所有options 参数默认值由0 改为SDWebImageRetryFailed，不会缓存下载失败的url。