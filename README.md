# WIP: ネステッド vSAN ラボを構築するための工夫

Photon OS 5.0 + PowerCLI コンテナを利用した実行例。

# PowerCLI コンテナを利用する場合の実行環境準備

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
git clone https://github.com/gowatana/deploy-1box-vsan.git
```

Config のダウンロード。
```
git clone https://github.com/gowatana/deploy-1box-vsan-configs_examples.git
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


# 自動構築ツールの実行例

事前環境確認のみ実行
```
PS /work/deploy-1box-vsan> ./lab_setup.ps1 ../deploy-1box-vsan-configs_examples/labs/lab-vc-01_lab-cluster-01.ps1 pretest
```

事前環境確認 → ネスト環境のクラスタ作成（実行確認あり）

確認メッセージが表示されたら、「yes」を入力して Enter キーを押すと、構築処理が開始される。
```
PS /work/deploy-1box-vsan> ./lab_setup.ps1 ../deploy-1box-vsan-configs_examples/labs/lab-vc-01_lab-cluster-01.ps1 create
```

事前環境確認 → ネスト環境のクラスタ作成（実行確認はスキップ）
```
PS /work/deploy-1box-vsan> ./lab_setup.ps1 ../deploy-1box-vsan-configs_examples/labs/lab-vc-01_lab-cluster-01.ps1 create skip
```

ネスト環境の削除
```
PS /work/deploy-1box-vsan> ./lab_setup.ps1 ../deploy-1box-vsan-configs_examples/labs/lab-vc-01_lab-cluster-01.ps1 delete
```

# 過去遺産

## 旧形式 設定ファイル集（アドベント カレンダーの思い出）

* https://github.com/gowatana/vsan-advent-2020
* https://github.com/gowatana/vsan-advent-2019
* WIP https://github.com/gowatana/vsan-advent-2018

## Wiki（これもまた古い）

* [Wiki](https://github.com/gowatana/deploy-1box-vsan/wiki)
