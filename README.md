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
* コマンドラインの例は、ISOマウントが F: ドライブ。
* .json ファイルのパスは適宜変更する。
* JSON は VCSA65 でも利用できる形式で記載。

```
PS> F:/vcsa-cli-installer/win32/vcsa-deploy.exe install `
--no-esx-ssl-verify --accept-eula --precheck-only `
～/lab-vcsa-67u3.json

PS> F:\vcsa-cli-installer\win32\vcsa-deploy.exe install `
--no-esx-ssl-verify --accept-eula `
～/lab-vcsa-67u3.json
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
PowerCLI> cd ./setup/
PowerCLI> ./step_1_create-base-inventory.ps1 ./config_Base-ESXi.ps1
```

ポートグループの作成

```
PowerCLI> ./step_2_create-nested-pg.ps1 ./config_Base-ESXi.ps1
```

ESXi VM の作成

```
PowerCLI> ./step_3_create-esxi-vm.ps1 ./config_Base-ESXi.ps1
PowerCLI> ../
```

## vSAN Cluster セットアップ

ラボ環境にあわせて、設定情報を config_vSAN-Cluster-01.ps1 のようなファイルを作成。
* $args[0]: デプロイ先ラボ環境のパラメータ ファイル
* $args[1]: デプロイする vSAN クラスタのパラメータ ファイル

```
PowerCLI> ./setup_vSAN-Cluster.ps1 ./config-basic/env_home-lab-01.ps1 ./config-basic/conf_vSAN-Cluster-01_Hybrid.ps1
```

or

```
PowerCLI> ./setup_vSAN-Cluster.ps1 ./config-basic/env_home-lab-01.ps1 ./config-basic/conf_vSAN-Cluster-02_AllFlash.ps1
```

## ラボの初期化

ラボ環境の vSAN クラスタ初期化。（vSAN クラスタ ～ ESXi VM まで削除）

```
PowerCLI> ./destroy_vSAN-Cluster.ps1 ./config-basic/env_home-lab-01.ps1 ./config-basic/conf_vSAN-Cluster-01_Hybrid.ps1
```

## Witness VA のデプロイ / セットアップ

* 事前に Witness VA の .ova ファイルをデプロイしておく。
* 下記で、Witness VA のクローン / ネットワーク設定 / VC 登録が実行される。
* ストレッチクラスタ作成時に、監視ホストとしてこの Witness VA を指定する。

```
PowerCLI> cd ./deploy-1box-vsan/
PowerCLI> ./Witness/setup_vSAN-Witness-Host.ps1 ./config-basic/env_home-lab-01.ps1 ./Witness/config/conf_Witness-VA_192.168.1.99.ps1
```

## Witness VA の削除

* 事前に、監視ホストを利用していた vSAN クラスタは削除しておく。
* 下記で、VC から Witness Host がインベントリ削除、Witness VA もディスクから削除される。

```
PowerCLI> cd ./deploy-1box-vsan/
PowerCLI> ./Witness/destroy_vSAN-Witness-Host.ps1 ./config-basic/env_home-lab-01.ps1 ./Witness/config/conf_Witness-VA_192.168.1.99.ps1
```
