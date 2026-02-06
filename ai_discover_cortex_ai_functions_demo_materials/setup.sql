-- ============================================
-- Snowflake Cortex AI テスト環境セットアップ
-- ============================================
--
-- このスクリプトは、Snowflake Cortex AI関数を使用した
-- ドキュメント分析・音声分析を実行するための環境を構築します。
--
-- 作成されるリソース:
--   - データベース: ai_discover
--   - スキーマ: ai_discover.public
--   - ステージ: raw_stage (PDF/音声ファイル用)
--   - ステージ: images (抽出画像用)
--
-- 前提条件:
--   - Snowflakeアカウントに Cortex AI 機能が有効化されていること
--   - 適切なロールと権限が付与されていること
--
-- 実行方法:
--   1. このSQLスクリプトをSnowsightまたはSnowSQL経由で実行
--   2. raw_stageステージにデータファイルをアップロード
--      - pdf/snowflake_key_concept.pdf
--      - audio/EARNINGS_Q1_FY2025.mp3
--   3. 各Notebookを順番に実行
--
-- ============================================

-- --------------------------------------------
-- 1. データベース作成
-- --------------------------------------------
-- Cortex AI分析用の専用データベースを作成します。
-- OR REPLACE を使用しているため、既存のデータベースは削除されます。

CREATE OR REPLACE DATABASE ai_discover;

-- 作成したデータベースを使用
USE DATABASE ai_discover;

-- --------------------------------------------
-- 2. スキーマ作成
-- --------------------------------------------
-- publicスキーマを作成します。
-- すべてのテーブル・ステージ・プロシージャはこのスキーマ内に作成されます。

CREATE OR REPLACE SCHEMA ai_discover.public;

-- --------------------------------------------
-- 3. ステージ作成
-- --------------------------------------------
-- Snowflakeのステージは、ファイルをアップロード・保存するための
-- 内部ストレージです。外部ステージ（S3等）も使用可能ですが、
-- ここでは内部ステージを使用します。

-- 3-1. raw_stage: 入力データ用ステージ
-- PDFファイルや音声ファイル等の元データを配置します。
-- - ENCRYPTION: Snowflake管理の暗号化を使用（デフォルトで有効）
-- - DIRECTORY: DIRECTORYテーブル関数でファイル一覧を取得可能にする

CREATE OR REPLACE STAGE ai_discover.public.raw_stage
    ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE')
    DIRECTORY = (ENABLE = TRUE)
    COMMENT = 'Raw データ用ステージ - PDFファイルや音声ファイルを配置';

-- 3-2. images: 画像抽出用ステージ
-- AI_PARSE_DOCUMENT関数でPDFから抽出した画像を保存します。
-- マルチモーダルAI関数（pixtral-large等）でこれらの画像を分析します。

CREATE OR REPLACE STAGE ai_discover.public.images
    ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE')
    DIRECTORY = (ENABLE = TRUE)
    COMMENT = '画像データ用ステージ - PDFから抽出した画像を保存';

-- --------------------------------------------
-- 4. ステージの確認
-- --------------------------------------------
-- 作成したステージの一覧を表示します。

SHOW STAGES IN DATABASE ai_discover;

-- --------------------------------------------
-- 5. ステージのリフレッシュとファイル一覧
-- --------------------------------------------
-- ステージにファイルをアップロードした後は、REFRESHコマンドで
-- メタデータを更新し、LISTコマンドでファイルを確認します。

-- raw_stageステージのリフレッシュと確認
ALTER STAGE ai_discover.public.raw_stage REFRESH;
LIST @ai_discover.public.raw_stage;

-- imagesステージのリフレッシュと確認
ALTER STAGE ai_discover.public.images REFRESH;
LIST @ai_discover.public.images;

-- --------------------------------------------
-- 6. 次のステップ（手動実行）
-- --------------------------------------------
-- [重要] 以下の手順を手動で実行してください:
--
-- 1. Snowsightで @ai_discover.public.raw_stage ステージを開く
-- 2. 以下のディレクトリを作成してファイルをアップロード:
--    - pdf/ ディレクトリを作成
--      → snowflake_key_concept.pdf をアップロード
--    - audio/ ディレクトリを作成
--      → EARNINGS_Q1_FY2025.mp3 をアップロード
--
-- 3. ファイルアップロード後、以下のコマンドで確認:
--    ALTER STAGE ai_discover.public.raw_stage REFRESH;
--    LIST @ai_discover.public.raw_stage;
--
-- 4. 各Notebookを順番に実行:
--    ① cortex_ai_functions_test.ipynb（Cortex AI関数テスト）
--    ② document_analysis.ipynb（PDFドキュメント分析）
--    ③ audio_analysis.ipynb（音声データ分析）
--
-- ============================================
-- セットアップ完了
-- ============================================