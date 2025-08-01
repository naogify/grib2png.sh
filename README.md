# grib2 to RGB Encode PNG tools

GRIB2形式のベクトルデータ（気象等）を、  
**「どんなパラメータが入っているかを調べる」→「U/Vベクトル成分をRGBエンコードしたPNG画像に変換」**  
という一連の流れを**体験できるシンプルなツールセット**です。

- **必要なのはDockerのみ**（wgrib2/gdalのインストール不要）
- 開発・解析・プロトタイピング時に、最短で「データ内容把握→画像出力」が可能


## RGBエンコードした PNG画像の仕様
-  [weatherlayers-gl公式ドキュメント](https://docs.weatherlayers.com/weatherlayers-gl/data-sources#supported-data-types) および [データフォーマット](https://docs.weatherlayers.com/weatherlayers-gl/data-sources#supported-data-formats) で提示されている仕様に沿って 値をRGBエンコードします。
-  概要
    - **RチャンネルにU成分、GチャンネルにV成分**を割り当てています。
    - データが存在しない部分は**Aチャンネル（アルファ）を0**にしています。

## 必須環境

- **Docker**（Windows, macOS, Linuxいずれも可）


## ツールセット内容

1. **grib2info.sh** … GRIB2ファイルの中身（含まれるパラメータ一覧）を確認
2. **grib2uv2png.sh** … U/V成分をRGB PNGにエンコード（地図画像として可視化）

---

## 使い方ワークフロー

### 1. ツールのダウンロード＆準備

```sh
curl -O https://raw.githubusercontent.com/naogify/grib2png.sh/main/grib2info.sh
curl -O https://raw.githubusercontent.com/naogify/grib2png.sh/main/grib2uv2png.sh
chmod +x grib2info.sh grib2uv2png.sh
```

---

### 2. GRIB2ファイルの中身を確認（**まずはここから！**）

操作に慣れるために、サンプルデータをダウンロードして触っていきます。
以下を実行して [気象庁「全球数値予報モデルGPV (GSM全球域)」](https://www.data.jma.go.jp/developer/gpv_sample.html) をダウンロードしてください。
```
curl https://gist.githubusercontent.com/naogify/89ca1d7d303ecf0ee7722218f04944a7/raw/8635c95e9242310d0969b7cbacbf00364e3c3ffb/download-jms-gpv-sample-data.sh | bash
```

以下を実行して GRIB2ファイル（例: `jms-sample.grib2`）の中に **どんなパラメータが入っているか**を一覧で表示します。

```sh
./grib2info.sh jms-sample.grib2
```

**出力例:**

```
1:0:d=2017120500:UGRD:10 m above ground:6 hour fcst:
2:14209:d=2017120500:VGRD:10 m above ground:6 hour fcst:
3:28418:d=2017120500:TMP:2 m above ground:6 hour fcst:
...
```

- **「:UGRD:10 m above ground:」**や**「:VGRD:10 m above ground:」**が地上10mの風の「U/V成分」です  
- これらの**パラメータ名をそのままコピーして、次のステップで使います**　（他の高さや風以外のベクトルデータでも試せます）

---

### 3. U/V成分をRGB PNGとして出力

#### 基本コマンド

```sh
./grib2uv2png.sh jms-sample.grib2 \
  -o wind.png \
  -u ":UGRD:10 m above ground:" \
  -v ":VGRD:10 m above ground:"
```

- **-u, -v** は **grib2info.shで確認したパラメータ名**を指定
- 出力画像（例: `wind.png`）は **EPSG:4326（緯度経度）** で書き出されます

#### 補足：元データの値域が異なる場合

例えば元データが -128 ~ 127 の値域なら、  
`-scale -128 127` オプションでPNGへのマッピング範囲を変えられます。

```sh
./grib2uv2png.sh jms-sample.grib2 -o wind.png -u ":UGRD:10 m above ground:" -v ":VGRD:10 m above ground:" -scale -128 127
```
- 出力画像のピクセル値は自動的に0〜255（PNG 8bit）にリスケールされます

---

## 出力イメージ例

![wind_data.png](https://github.com/naogify/jma-wind-map/blob/main/public/wind_data.png)  
出展: [気象庁「全球数値予報モデルGPV (GSM全球域)」](https://www.data.jma.go.jp/developer/gpv_sample.html) を加工して作成

- **Rバンド（赤）** … U成分
- **Gバンド（緑）＆Bバンド（青）** … V成分（GとBは同じ）
- GISツールや画像ビューアで地理的な分布や強度を直感的に確認できます


## コントリビュート・バグ報告

- 不明点やバグ報告は [GitHub Issues](https://github.com/your/repository/issues) までお願いします。

