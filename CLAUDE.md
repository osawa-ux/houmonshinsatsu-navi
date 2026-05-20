# CLAUDE.md — houmonshinsatsu-navi

在宅クリニックナビ（zaitakuclinic-navi.com）の静的サイト本体。GitHub Pages でホスティング。

このリポジトリは主に **静的出力物の配置先（生成物 repo）** であり、サイト生成の主処理と正本ロジックは `~/MyPython/` が担う。

---

## このリポジトリの位置づけ（MyPython との責任境界）

- このリポジトリは **GitHub Pages 公開用の静的サイト本体**（生成物 repo）
- サイト生成の **正本ロジックは MyPython 側**（`build_site.py` / `check_neutrality.py` / `audit_*.py` / `site_config*.json` 等）
- HTML / sitemap / data の多くは `~/MyPython/build_site.py` が生成する
- **恒久修正は原則 MyPython 側**。このrepo直接編集は緊急 hotfix または確認用途に限定する

### 責任境界の原則

| 作業の種類 | 作業先 | 備考 |
|-----------|-------|------|
| テンプレート・生成ロジック・SEO骨格・データ変換の恒久修正 | **MyPython** | 原則こちら。再生成で再現される |
| 緊急 hotfix（公開後のタイポ・一時文言修正等） | このrepo直接編集 OK | **後日 MyPython 側へ反映が必要か要確認** |
| 確認用の一時編集・実験 | このrepo直接編集 OK | 本番反映前に整合を確認 |
| 再生成で上書きされる変更（テンプレ由来と思われる広域変更） | **MyPython 経由** | このrepo直接は避ける |

### 直接編集後のフォローアップ

- このrepoを直接編集した変更は、次回の `build_site.py` 実行で **消える可能性がある**
- 直接編集が恒久的に残るべき内容なら、**MyPython 側の生成ロジック・テンプレ・data に同等の変更を反映** させる
- 判断に迷う場合は、両案を比較して「より再現性が高い方」を提案する

---

## 生成物 clone 分岐リスク（本番反映前の注意）

deploy 経路上、houmonshinsatsu-navi の実体は **複数の clone として存在しうる**：

| パス | 用途 |
|------|------|
| `~/houmonshinsatsu-navi/` | 日常作業用 clone（通常のチェックアウト先） |
| `~/MyPython/site/` | `deploy_github.py` 側が保持する deploy 用 clone（MyPython から build 結果を push する経路） |

### リスク

- 片方で commit / push した変更が、もう片方にまだ反映されていない状態で次の作業を始めると、本番（`origin/gh-pages`）と手元 2 つのどちらとも食い違う
- `deploy_github.py` 側の clone が古いまま build 結果を push すると、意図しない差分（古い状態への巻き戻し等）が本番に出る

### 運用注意

- 本番反映前（特に `deploy_github.py` 実行前）に、両 clone と `origin` の同期状態を確認する
- 推奨確認: `git fetch origin && git log --oneline HEAD..origin/<branch>` で差分を見る
- 大きな差分がある場合はデプロイを止め、**どちらの状態が正か**を確認してから進める

---

## 起動時ルーチン（毎セッション最初）

本repoで作業を始めるとき、Claude Code は以下を最初に確認する。

1. **git 状態の確認**: `git status -sb` で作業ツリー・ブランチ・upstream との差分を把握する
2. **MyPython 側で対応できないか判断**: HTML を直接編集する前に「これは `~/MyPython/build_site.py` の生成元（テンプレ / data / site_config）修正で対応できないか」を考える
3. **影響範囲の把握**: 変更が sitemap / noindex / canonical / 中立性 / 内部リンク / JSON-LD に及ぶかを確認する
4. **本番反映前チェック**: デプロイ前に build 結果（HTML 件数・sitemap 件数・検索JSON 件数の整合）と `origin/gh-pages`（および `~/MyPython/site/` 側 clone）の同期状態を確認する（global CLAUDE.md の Pre-Deploy Validation に従う）

この4点を飛ばして直接編集を始めない。

---

## 能力カタログ連携

再利用可能な機能・外部サービス連携・自動化手順を **新規実装・拡張・廃止** したら、
Obsidian Vault の `30_Areas/能力カタログ.md` を更新する（必須）。

- 粒度は「1動詞+1目的語」（例: 「中立性違反語を検知できる」「内部リンクブロックを自動挿入できる」）
- 各能力に最低限: **状態 / 実行レベル / 前提条件 / entrypoint**
- 既存能力で実現可能な依頼は、再実装せずカタログ記載の entrypoint を呼ぶ
- 本repoは静的出力物なので、**生成ロジック側（MyPython）に能力がある場合はそちらを先に更新する**

### このrepo周辺で扱う能力領域

本repoは主に **配置済み成果物の修正・確認** を担う。正式な能力 ID は Obsidian 能力カタログ側で採番・管理する（本 CLAUDE.md で仮 ID を新設しない）。本repo 周辺で関連する能力領域は以下：

| 領域 | 正本 repo | 内容 |
|------|----------|------|
| サイトビルド（SITE-BUILD 系） | MyPython | `build_site.py` による HTML / JSON / sitemap 生成 |
| デプロイ（SITE-DEPLOY 系） | MyPython | `deploy_github.py` による gh-pages への反映 |
| ポータル中立性チェック（PORTAL-NEUTRALITY 系） | MyPython | `check_neutrality.py` による禁止語検査 |
| SEO / GSC 観測（SEO-GSC 系） | MyPython / houmonshinsatsu-navi | デプロイ前後の GSC 比較フロー |
| sitemap 監査（SITEMAP-AUDIT 系） | MyPython | sitemap.xml と個別ページ数・検索JSON の整合確認 |

※ 実装本体は MyPython 側に集約されているため、機能追加・修正は原則 MyPython 側で行い、能力カタログ側の entrypoint 表記もそちらに合わせる。

---

## Secrets 運用

このリポジトリは静的 HTML のみで構成されており、ローカル secrets 運用の主対象ではない。

### 注意事項

- HTML 内に埋め込まれる API キー（Google Maps 等）は、GCP コンソールで HTTP リファラー制限を設定済みの公開キーを前提とする
- Formspree のフォーム ID は公開情報として扱う（秘密ではない）
- サイト生成は `MyPython/build_site.py` で行い、secrets は MyPython 側で管理する

### Secrets 探索ルール

secret / token / API key が必要なとき、いきなり新規発行を提案しない。次の順で確認する:

1. `%USERPROFILE%\.secrets\houmonshinsatsu-navi\`
2. `%USERPROFILE%\OneDrive\個人用 Vault\.secrets\houmonshinsatsu-navi\`
3. それでも見つからない場合のみ、ユーザー確認または新規発行

- secret の実値は表示しない
- `.env`, `credentials*.json`, `token*.json`, `*.p12`, `*.pem` などの秘密情報は Git に入れない

---

## ポータル中立性ルール

在宅クリニックナビは中立的なポータルサイトであり、特定クリニックの宣伝サイトではない。

### 方針（避けるべき表現）

- 自院名（運営者が関係する特定クリニック名）を記事本文・メタ情報・JSON-LD に出さない
- 運営者の個人名を記事に出さない
- 一人称表現（`当院`、`当クリニック` 等）を使わない
- 外部ドメイン（運営者が関係する特定クリニックの公式サイト等）を canonical や記事リンクに向けない
- 特定病院名・関連施設名を個別に強調しない

### 代表例

以下は避ける対象の代表例（実際の禁止語は後述の正本側で管理）：

- 自院名の例: `横浜ホームクリニック`
- 外部ドメインの例: `yokohama-home.clinic`
- 一人称表現: `当院`、`当クリニック`

### 禁止語の正本（single source of truth）

禁止語リスト本体は **`~/MyPython/check_neutrality.py` の `BANNED_WORDS` 定義が正本**。

- 追加・変更は `check_neutrality.py` 側で行う
- 本 CLAUDE.md には **方針と代表例のみ** を残し、詳細な禁止語リストは複製しない
- 理由: CLAUDE.md と実装側で二重管理すると drift する。実装側に一本化する

### 禁止事項（適用範囲）

- `/blog/` `/guide/` 配下の本文・メタ情報で上記方針に反する表記をしない
- JSON-LD の `author` / `publisher` に特定クリニック名を入れない
- `canonical` を外部ドメインに向けない
- 記事内に特定クリニックの電話番号・公式サイト URL を掲載しない

### 許可される表記

- 運営者情報ページ（`about.html`）での運営主体の明示
- クリニック個別ページ（`/clinic/`）での各クリニック情報の掲載（中立性チェックの対象外ディレクトリ）

### 記事の著者・監修表記

- `在宅クリニックナビ編集部` または `在宅クリニックナビ` を使う
- 個人名を監修者として入れない（YMYL対策で必要になった場合は別途検討）

### チェック手順

- 記事作成・更新時: `python ~/MyPython/check_neutrality.py --site .` を実行（cwd がこの repo の場合）
- MyPython 側から両方検査: `python ~/MyPython/check_neutrality.py --all`
- `build_site.py` 実行時: 禁止語が含まれていると自動でビルドが停止する
- git commit 時: pre-commit hook が自動で `~/MyPython/check_neutrality.py` を呼ぶ（`tools/hooks/pre-commit`）

---

## 作業方針

### 基本姿勢
- 小さく安全な変更を優先する
- 関連のない修正を混ぜない
- 1タスク1成果物を原則とする
- 不明点があれば勝手に拡大解釈せず、保守的に進める
- 「勝手に完成させる」より、「安全に前進し、人が判断しやすい状態を作る」ことを優先する

### 作業前に必ず整理すること
着手前に以下を短く明示すること。

1. 目的
2. 対象ファイル
3. 実施内容
4. 実施しない内容
5. 完了条件
6. リスク
7. この変更を **MyPython側でやるべきか / このrepoで直接やるべきか** の判断

---

## このrepoで自走してよい作業

- 静的文言の軽微修正
- 手作業管理ページの微修正
- メタタグ、OGP、構造化データの軽微修正
- 内部リンク改善
- 軽微なUI崩れ修正
- 画像alt、title、説明文の整理
- sitemap / robots / canonical の**軽微な確認と提案**
- 記事ページの追加・修正（中立性ルール厳守）
- 既存ファイルの整形、重複除去、可読性改善
- チェック用スクリプト・hook・CI設定の軽微改善

---

## 提案までに留める作業

以下は勝手に広範囲へ変更せず、まず提案・差分案・影響範囲整理を出すこと。

- トップページ導線変更
- 県ページ / 市区町村ページの構造変更
- CTA変更
- 問い合わせ導線変更
- プラン訴求の見せ方変更
- canonical / robots / sitemap の方針変更
- JSON-LD の大幅な設計変更
- パンくず構造の大幅変更
- ファイル大量生成を伴う変更
- テンプレート由来と思われる広域変更

---

## 原則触らない・独断変更しない作業

- 規約
- 決済
- 課金
- auth
- RLS
- 会員管理系ロジック
- 本番データの意味を変える変更
- 医療機関ごとの有料表示切替
- 法務・医療広告・景表法リスクがありうる文言
- robots / canonical / noindex の根幹方針
- 外部サービスの本番設定値

必要な場合は、下書き・提案・差分案提示に留めること。

---

## 実装ルール

- 既存の命名・トーン・構造を尊重する
- ハードコードを増やしすぎない
- 再生成で消える変更を無自覚に入れない
- コメントは必要最小限にする
- 無関係な整形だけの変更を混ぜない
- 「ついで修正」はしない
- generated と source of truth のズレを生む変更は避ける

---

## 確認ルール

変更後は可能な範囲で以下を確認すること。

- 影響ファイル一覧
- 影響ページ一覧
- 中立性ルール違反の有無
- リンク切れの有無
- メタタグ / JSON-LD / canonical の破綻有無
- 生成物repo直接修正として妥当かどうか
- 再生成時に消える変更でないか

必要に応じて以下も実行すること。

```bash
python ~/MyPython/check_neutrality.py --site .   # この repo 側を検査
# または
python ~/MyPython/check_neutrality.py --all      # MyPython + このrepo の両方を検査
```

---

## pre-commit hook セットアップ

clone / 別PC で作業を始めるときに一度だけ実行する:

```bash
bash tools/install_hooks.sh      # Git Bash / WSL
# または
powershell tools/install_hooks.ps1   # PowerShell
```

hook 本体は `tools/hooks/pre-commit` にリポジトリ管理されている。

---

## CI（GitHub Actions）

blog/ guide/ の変更を含む push / PR で GitHub Actions が禁止語チェックを自動実行する。
ローカル hook をすり抜けた場合（hook 未設置、`--no-verify` 使用等）でも CI で検出される。

チェック体制: **ローカル pre-commit hook + CI の二重チェック**

---

## Obsidian 連携

共通方針は global `~/.claude/CLAUDE.md`。vault path は `python ~/.claude/skills/_shared/resolve_vault.py` で動的解決。

### この repo で優先参照するノート

- `70_SOP/seo/SEO_GSC再観測手順.md` — デプロイ前後の GSC 比較フロー
- `20_Projects/zaitakuclinic-navi/index.md` — プロジェクト現在地・直近デプロイ・残課題（在宅クリニックナビ project note の正本）

---

## Agent 委譲ルール

### 優先する repo 固有 agent

| agent | 担当ファイル | 担当内容 |
|-------|-------------|---------|
| **navi-site-builder** | `*.html`, `static/`, `blog/`, `clinic/`, `pref/`, `guide/`, `sitemap.xml`, `data/` | ページ構造・SEO・内部リンク・コンテンツ管理 |

### 委譲判断

- HTML/CSS/JS の編集、SEO改善、内部リンク、コンテンツ追加 → **navi-site-builder**
- テンプレート由来の広域変更、データ生成ロジック → MyPython の **data-pipeline** が担当（このrepoではなく MyPython 側で作業する）
- 会員管理・決済 → zaitaku-members が担当（このrepoでは触らない）
- 上記に当てはまらない変更（tools/、hook設定等） → **implementer**（global）
- 複数ステップの作業分解 → **orchestrator**（global）
- 成果物のレビュー → **reviewer**（global）

---

## Pre-Deploy Validation 詳細（在宅クリニックナビ gh-pages）

デプロイ前に必ず以下を確認する（global CLAUDE.md の原則を具体化したもの）。

### チェック項目

- build後の総件数（検索JSON）
- 都道府県ページの件数（例：神奈川県）
- 特定市区町村の件数（例：横浜市都筑区）
- 個別ページ数と検索JSONの一致

### 確認方法

- grep / カウントスクリプト
- spot check（3〜5件の個別ページ目視確認）
- 前回 build との差分確認

### 異常の目安

- 総件数が前回比で数百件以上減少（意図しない場合）
- 特定エリアで急激な減少（例：都筑区 24→8 など）
- 個別ページ数と検索JSON件数の不一致

### 異常があれば

- git push / デプロイを中止
- 原因を特定してから再 build

### 原則

「デプロイ成功」ではなく「データが正しい状態で公開されている」ことを成功とする。
