# grib2uv2png.sh & grib2info.sh

GRIB2形式の気象データを、  
**「どんなパラメータが入っているかを調べる」→「U/Vベクトル成分をPNG画像に変換」**  
という一連の流れを**体験できるシンプルなツールセット**です。

- **必要なのはDockerのみ**（wgrib2/gdalのインストール不要）
- 開発・解析・プロトタイピング時に、最短で「データ内容把握→画像出力」が可能


## 必須環境

- **Docker**（Windows, macOS, Linuxいずれも可）


## ツールセット内容

1. **grib2info.sh** … GRIB2ファイルの中身（含まれるパラメータ一覧）を確認
2. **grib2uv2png.sh** … U/V成分をRGB PNGにエンコード（地図画像として可視化）

---

## 使い方ワークフロー

### 1. ツールのダウンロード＆準備

```sh
curl -O https://raw.githubusercontent.com/your/repository/main/grib2info.sh
curl -O https://raw.githubusercontent.com/your/repository/main/grib2uv2png.sh
chmod +x grib2info.sh grib2uv2png.sh
```

---

### 2. GRIB2ファイルの中身を確認（**まずはここから！**）

GRIB2ファイル（例: `sample.grib2`）の中に  
**どんなパラメータが入っているか**を一覧で表示します。

```sh
./grib2info.sh sample.grib2
```

**出力例:**

```
1:0:d=2017120500:UGRD:10 m above ground:6 hour fcst:
2:14209:d=2017120500:VGRD:10 m above ground:6 hour fcst:
3:28418:d=2017120500:TMP:2 m above ground:6 hour fcst:
...
```

- **「:UGRD:10 m above ground:」**や**「:VGRD:10 m above ground:」**が「U/V成分」です  
- これらの**パラメータ名をそのままコピーして、次のステップで使います**

---

### 3. U/V成分をRGB PNGとして出力

#### 基本コマンド

```sh
./grib2uv2png.sh sample.grib2 \
  -o wind.png \
  -u ":UGRD:10 m above ground:" \
  -v ":VGRD:10 m above ground:"
```

- **-u, -v** は **grib2info.shで確認したパラメータ名**を指定
- 出力画像（例: `wind.png`）は **EPSG:4326（緯度経度）** で書き出されます

#### 補足：元データの値域が異なる場合

例えば元データが0〜50の値域なら、  
`-scale 0 50` オプションでPNGへのマッピング範囲を変えられます。

```sh
./grib2uv2png.sh sample.grib2 -o wind.png -u ":UGRD:10 m above ground:" -v ":VGRD:10 m above ground:" -scale 0 50
```
- 出力画像のピクセル値は自動的に0〜255（PNG 8bit）にリスケールされます

---

## 出力イメージ例

- **Rバンド（赤）** … U成分
- **Gバンド（緑）＆Bバンド（青）** … V成分（GとBは同じ）
- GISツールや画像ビューアで地理的な分布や強度を直感的に確認できます


## 依存Dockerイメージ

- [ghcr.io/geolonia/docker-wgrib2:latest](https://github.com/geolonia/docker-wgrib2)
- [osgeo/gdal:alpine](https://hub.docker.com/r/osgeo/gdal/tags)


## ライセンス・クレジット

- 本ツールは [wgrib2公式](https://www.cpc.ncep.noaa.gov/products/wesley/wgrib2/) および [GDAL公式](https://gdal.org/) を利用しています。


## コントリビュート・バグ報告

- 不明点やバグ報告は [GitHub Issues](https://github.com/your/repository/issues) までお願いします。

