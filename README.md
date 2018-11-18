# ネステッド vSAN ラボを構築するための工夫

想定環境は、vSphere 6.7、PowerCLI 11、Windows 10（の PowerShell）。

* <https://communities.vmware.com/people/gowatana/blog/2018/10/21/vsan-1box-1>
* <https://communities.vmware.com/people/gowatana/blog/2018/10/22/vsan-1box-2>
* <https://communities.vmware.com/people/gowatana/blog/2018/10/23/vsan-1box-3>
* <https://communities.vmware.com/people/gowatana/blog/2018/10/24/vsan-1box-4>
* <https://communities.vmware.com/people/gowatana/blog/2018/11/01/vsan-1box-5>

## vcsa-deploy での VCSA デプロイ

CLI で VCSA をデプロイする。
* PowerShell で実行。（cmd でも可）
* コマンドラインの例は、ISOマウントがドライブ。
* .json ファイルのパスは適宜変更する。
* JSON は VCSA65 でも利用できる形式で記載。

```
PS> D:/vcsa-cli-installer/win32/vcsa-deploy.exe install `
--no-esx-ssl-verify --accept-eula --precheck-only `
～/simple-vsan-vc.json

PS> D:\vcsa-cli-installer\win32\vcsa-deploy.exe install `
--no-esx-ssl-verify --accept-eula `
～/simple-vsan-vc.json
```

## PowerCLIでのVCへの接続

例での 192.168.1.30 は VCSA。

```
PowerCLI> cd ./deploy-1box-vsan
PowerCLI> Connect-VIServer 192.168.1.30 -User administrator@vsphere.local -Password VMware1! -Force
```

## VCインベントリの準備

設定情報は config_Base-ESXi.ps1 ファイルに記載する。

```
PowerCLI> ./setup-01-04_create-base-inventory.ps1 ./config_Base-ESXi.ps1
```

ポートグループの作成

```
PowerCLI> ./setup-02-01_create-nested-pg.ps1 ./config_Base-ESXi.ps1
```

ESXi VM の作成

```
PowerCLI> ./setup-02-02_create-esxi-vm.ps1 ./config_Base-ESXi.ps1
```

## vSAN Cluster セットアップ

ラボ環境にあわせて、設定情報を config_vSAN-Cluster-01.ps1 のようなファイルを作成。

```
PowerCLI> ./setup_vSAN-Cluster_AllFlash.ps1 ./config_vSAN-Cluster-01.ps1
```

or

```
PowerCLI> ./setup_vSAN-Cluster_Hybrid.ps1 ./config_vSAN-Cluster-01.ps1
```

## ラボの初期化

ラボ環境の vSAN クラスタ初期化。（vSAN クラスタ ～ ESXi VM まで削除）

```
PowerCLI> ./destroy_vSAN-Cluster.ps1 ./config_vSAN-Cluster-01.ps1
```
