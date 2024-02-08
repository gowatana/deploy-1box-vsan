# WIP: ネステッド vSAN ラボを構築するための工夫

## Wiki

* [Wiki](https://github.com/gowatana/deploy-1box-vsan/wiki)


## 使用例

Linux ディストリビューションの確認。
```
root@lab-pwsh-01 [ ~ ]# cat /etc/photon-release
VMware Photon OS 5.0
PHOTON_BUILD_NUMBER=dde71ec57
```


カレント ディレクトリの確認。
```
root@lab-pwsh-01 [ ~ ]# pwd
/root
```


Docker の起動。
```
systemctl enable docker
systemctl start docker
```


Git のインストール。
```
tdnf install git -y
```


ツールのダウンロード。
```
git clone https://github.com/gowatana/deploy-1box-vsan.git -b new-config
```


Config のダウンロード。
```
git clone https://github.com/gowatana/vbox-configs
```


コンテナ イメージのダウンロード。
```
docker pull vmware/powerclicore:13.1
```


コンテナの起動。
```
docker run -it --rm -v /root:/work -w /work/deploy-1box-vsan vmware/powerclicore:13.1
```


CEIP を無効化。
```
Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $false -Confirm:$false
```


スクリプトの実行（事前環境確認）。
```
PS /work/deploy-1box-vsan> ./lab_setup.ps1 ../vbox-configs/labs/lab-vc-01_lab-cluster-01_Hybrid.ps1 pretest
```


スクリプトの実行（事前環境確認 → クラスタ作成）。
```
PS /work/deploy-1box-vsan> ./lab_setup.ps1 ../vbox-configs/labs/lab-vc-01_lab-cluster-01_Hybrid.ps1 create
```

スクリプトの実行（事前環境確認 → クラスタ作成 - 実行確認なし）。
```
PS /work/deploy-1box-vsan> ./lab_setup.ps1 ../vbox-configs/labs/lab-vc-01_lab-cluster-01_Hybrid.ps1 create
```


スクリプトの実行（環境削除）。
```
PS /work/deploy-1box-vsan> ./lab_setup.ps1 ../vbox-configs/labs/lab-vc-01_lab-cluster-01_Hybrid.ps1 delete
```


## 旧: 設定ファイル集

* https://github.com/gowatana/vsan-advent-2020
* https://github.com/gowatana/vsan-advent-2019
* WIP https://github.com/gowatana/vsan-advent-2018
