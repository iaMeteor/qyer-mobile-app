# Changelogs

## v0.6.0

- [FEATURE] qma publish 新增 --json-data 参数接收租装全部参数和额外更多参数

## v0.5.3

- [BUGFIX] 处理在非 osx 环境下获取 ipa 的 mobileprovision 属性会报异常

## v0.5.2

- [STAGE] 处理 ipa 的图标暂不做还原处理

## v0.5.1

- [BUGFIX] 修复无法获取 iPad 图标的问题
- [BUGFIX] 忘记引入 table-terminal gem
- [BUGFIX] 优化判断 ipa mobileprovision 的方法
- [BUGFIX] 修复判断 ipa device_type 有误的问题
- [STYLE] 格式化 Android/iOS/iPad/iPhone/Universal 等专有名词的大小写

## v0.5.0

- [FEATURE] 增加上报本机 IP 的功能

## 0.4.0

- [FEATURE] 抽离解析 app、配置类、上传 app 并重构核心代码
- [CHANGE] 修改 qma config 的存储结构并会自动升级修改配置文件

## 0.3.0

- [FEATURE] qma publish 支持上传 git 信息和上传渠道信息

## 0.2.0

- [FEATURE] qma publish 兼容服务器判断之前是否已经上传的返回话术
- [FEATURE] 解析 ipa 更多的数据信息

## 0.1.2

- [FEATURE] 清理代码，移除暂时不用的 gems

## 0.1.1

- [BUGFIX] 使用 ruby_android 替换 ruby_apk 修复解析问题

## 0.1.0

- [FEATURE] 实现 qma config/publish 的核心功能
