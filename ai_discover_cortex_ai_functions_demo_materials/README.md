# Snowflake Cortex AI 検証プロジェクト

このプロジェクトは、Snowflake Cortex AI関数を使用した音声・ドキュメント分析のデモンストレーションです。

## 📋 プロジェクト構成

```
ai_discover/
├── setup.sql                           # Snowflake環境セットアップスクリプト
├── data/                               # サンプルデータ
│   ├── snowflake_key_concept.pdf      # ドキュメント分析用PDF
│   └── EARNINGS_Q1_FY2025.mp3         # 音声分析用MP3
├── cortex_ai_functions_test.ipynb     # Cortex AI関数テストノートブック
├── document_analysis.ipynb             # PDFドキュメント分析ノートブック
└── audio_analysis.ipynb                # 音声データ分析ノートブック
```

## 🚀 セットアップ手順

### 1. Snowflake環境のセットアップ

まず、`setup.sql`を実行してSnowflake環境を構築します：

```bash
# SnowSQL経由で実行する場合
snowsql -f setup.sql

# またはSnowsightで直接実行
```

このスクリプトは以下を作成します：
- データベース: `ai_discover`
- スキーマ: `ai_discover.public`
- ステージ: `raw_stage`（PDF/音声ファイル用）
- ステージ: `images`（抽出画像用）

### 2. データファイルのアップロード

Snowsightを使用して、以下のファイルをステージにアップロードします：

1. **PDFファイルのアップロード**
   - Snowsightで `@ai_discover.public.raw_stage` ステージを開く
   - `pdf/` ディレクトリを作成
   - `data/snowflake_key_concept.pdf` をアップロード

2. **音声ファイルのアップロード**
   - 同じステージで `audio/` ディレクトリを作成
   - `data/EARNINGS_Q1_FY2025.mp3` をアップロード

### 3. Notebookの実行

Snowsightで以下の3つのNotebookを順番に実行します：

#### ① `cortex_ai_functions_test.ipynb`
**目的**: Cortex AI関数の基本動作確認

**使用する関数**:
- `AI_COMPLETE` - LLM推論（翻訳など）
- `AI_CLASSIFY` - テキスト分類
- `AI_FILTER` - コンテンツフィルタリング
- `AI_SENTIMENT` - 感情分析
- `AI_EXTRACT` - 情報抽出
- `AI_TRANSLATE` - 多言語翻訳
- `AI_SIMILARITY` - テキスト類似度
- `AI_REDACT` - 機密情報マスキング
- `AI_COUNT_TOKENS` - トークン数カウント

#### ② `document_analysis.ipynb`
**目的**: PDFドキュメントからの情報抽出と画像分析

**主要な分析内容**:
1. **AI_PARSE_DOCUMENT** - PDFからテキスト・画像を抽出
2. **AI_EXTRACT** - Snowflake機能名やキーコンセプトを抽出
3. **AI_AGG** - ドキュメント全体を要約
4. **AI_COMPLETE (Multimodal)** - 抽出した画像を分析
5. **SPLIT_TEXT_MARKDOWN_HEADER** - ドキュメントをチャンク分割（RAG用）

**生成されるテーブル**:
- `DOC_PARSED` - 解析結果
- `DOC_EXTRACTED` - 抽出情報
- `DOC_SUMMARY` - 要約
- `DOC_IMAGE_ANALYSIS` - 画像分析結果
- `DOC_CHUNKS` - チャンク分割結果

#### ③ `audio_analysis.ipynb`
**目的**: 音声ファイルからビジネスインサイトを抽出

**主要な分析内容**:
1. **AI_TRANSCRIBE** - 音声を文字起こし
2. **AI_CLASSIFY** - コンテンツ分類（Financial Results等）
3. **AI_AGG** - トランスクリプトを要約
4. **AI_TRANSLATE** - 英語から日本語へ翻訳
5. **AI_COMPLETE (Structured Output)** - ビジネスインサイトを構造化JSON形式で抽出

**生成されるテーブル**:
- `AUDIO_SAMPLE` - 文字起こし
- `AUDIO_SAMPLE_2` - 分類
- `AUDIO_SAMPLE_3` - 要約
- `AUDIO_SAMPLE_4` - 翻訳
- `AUDIO_SAMPLE_5` - ビジネスインサイト

## 🔑 主要なCortex AI関数

### ドキュメント処理
- `AI_PARSE_DOCUMENT` - PDF/Word/画像からテキスト・レイアウト・画像を抽出
- `SPLIT_TEXT_MARKDOWN_HEADER` - Markdownヘッダーベースでチャンク分割

### テキスト分析
- `AI_COMPLETE` - LLM推論（Claude、Mistral、Llama等）
- `AI_EXTRACT` - 非構造化データから特定情報を抽出
- `AI_AGG` - 複数行のテキストを集約・要約
- `AI_CLASSIFY` - テキスト分類
- `AI_SENTIMENT` - 感情分析

### 音声処理
- `AI_TRANSCRIBE` - 音声ファイルの文字起こし

### 多言語対応
- `AI_TRANSLATE` - 100以上の言語に対応した翻訳

### ユーティリティ
- `AI_SIMILARITY` - テキスト類似度計算
- `AI_REDACT` - 機密情報の自動マスキング
- `AI_FILTER` - コンテンツフィルタリング
- `AI_COUNT_TOKENS` - トークン数カウント

## 💡 主要機能

### Structured Output（構造化出力）

`AI_COMPLETE`関数では、JSON Schemaを指定することで、LLMの出力形式を厳密に制御できます：

```sql
AI_COMPLETE(
    model => 'claude-sonnet-4-5',
    prompt => 'Your prompt here',
    response_format => {
        'type': 'json',
        'schema': {
            'type': 'object',
            'properties': {
                'field1': {'type': 'string'},
                'field2': {'type': 'string'}
            },
            'required': ['field1', 'field2']
        }
    }
)
```

### Multimodal（マルチモーダル）分析

`pixtral-large`や`claude-4-sonnet`等のマルチモーダルモデルを使用すると、ステージ上の画像を直接分析できます：

```sql
AI_COMPLETE(
    'claude-4-sonnet',
    'この画像を説明してください',
    TO_FILE('@ai_discover.public.images/img-0.jpeg')
)
```

## 📊 分析フロー

### ドキュメント分析フロー
```
PDFファイル
  ↓ AI_PARSE_DOCUMENT (LAYOUT + extract_images)
Markdownテキスト + 画像
  ├→ AI_EXTRACT → 機能名・キーワード
  ├→ AI_AGG → 要約
  ├→ SPLIT_TEXT_MARKDOWN_HEADER → チャンク（RAG用）
  └→ ステージ保存 → AI_COMPLETE (Multimodal) → 画像分析
```

### 音声分析フロー
```
音声ファイル(.mp3)
  ↓ AI_TRANSCRIBE
テキスト
  ↓ AI_CLASSIFY
分類済みテキスト
  ↓ AI_AGG
要約テキスト
  ↓ AI_TRANSLATE
日本語要約
  ↓ AI_COMPLETE (Structured Output)
ビジネスインサイト（JSON）
```

## 📝 必要要件

- Snowflakeアカウント（Cortex AI機能が有効）
- Snowsightアクセス（Notebook実行用）
- データファイル（プロジェクトに同梱）

## 🎯 ユースケース

このプロジェクトのテクニックは、以下のようなユースケースに応用できます：

- **ドキュメント分析**: 技術文書、契約書、レポートからの情報抽出
- **音声分析**: Earnings Call、カスタマーサポート通話、インタビューの分析
- **RAGパイプライン**: チャンク分割とベクトル検索による高度な質問応答システム
- **マルチモーダル分析**: 画像・テキスト・音声を組み合わせた包括的な分析
- **ビジネスインテリジェンス**: 非構造化データから構造化されたインサイトを自動抽出

## 📚 参考リンク

- [Snowflake Cortex AI Documentation](https://docs.snowflake.com/en/user-guide/snowflake-cortex/overview)
- [Cortex AI Functions Reference](https://docs.snowflake.com/en/sql-reference/functions-cortex)

---

**作成日**: 2026年2月
**バージョン**: 1.0
