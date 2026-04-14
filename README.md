# lxc-setup

[『もうセットアップで消耗しないProxmox LXCカスタムテンプレートの作り方』](https://techbookfest.org/product/jbjsfm1ZCzRw9qYJhJDXEC?productVariantID=p1WxSn3WGic9HFDERefBer)で紹介したセットアップ用のスクリプトです。

参考のために、本来はLXCコンテナ内に配置するスクリプトもリポジトリに含めています。

```sh
テンプレート内に含めるもの
lxc-setup/
├── lxc-setup.service
├── start.sh
├── cleanup.sh
├── ssh秘密鍵
└── setup.env
```

## 構成

![概要図](https://github.com/shikasan2127/lxc-setup/blob/main/images/overview.png?raw=true)
