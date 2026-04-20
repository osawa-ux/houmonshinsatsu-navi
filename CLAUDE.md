# CLAUDE.md — houmonshinsatsu-navi

在宅クリニックナビ（zaitakuclinic-navi.com）の静的サイト本体。GitHub Pages でホスティング。

このリポジトリは主に **静的出力物の配置先** であり、サイト生成の主処理は `MyPython/build_site.py` が担う。

---

## このリポジトリの位置づけ

- このリポジトリは GitHub Pages 公開用の静的サイト本体
- HTML / sitemap / data などの多くは `MyPython/build_site.py` により生成される
- したがって、**再生成で上書きされる変更** を安易に直接このリポジトリへ入れないこと
- まず「生成元（MyPython側）を直すべきか」「このrepoを直接直すべきか」を判断すること

### 原則
- 横断的・テンプレート的な修正 → **MyPython 側を優先**
- 単発の静的修正、緊急の軽微修正、手作業ページ修正 → **このrepo直接編集も可**
- 判断に迷う場合は、両案を比較して **より再現性が高い方** を提案すること

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

### 禁止事項
- `/blog/` `/guide/` 配下で特定クリニック名（横浜ホームクリニック等）を出さない
- 特定クリニックの電話番号・公式サイトURLを記事内に掲載しない
- JSON-LD の author/publisher に特定クリニック名を入れない
- canonical を外部ドメイン（yokohama-home.clinic 等）に向けない

### 許可される表記
- 運営者情報ページ（about.html）での運営主体の明示
- クリニック個別ページ（/clinic/）での各クリニック情報の掲載

### 記事の著者・監修表記
- `在宅クリニックナビ編集部` または `在宅クリニックナビ` を使う
- 個人名を監修者として入れない（YMYL対策で必要になった場合は別途検討）

### チェック手順
- 記事作成・更新時: `python check_neutrality.py --all` を実行
- build_site.py 実行時: 禁止語が含まれていると自動でビルドが停止する
- git commit 時: pre-commit hook が自動で検査する
- 禁止語リスト: `横浜ホームクリニック`, `yokohama-home.clinic`, `大澤基`, `当院`, `当クリニック`, `昭和大学横浜市北部病院`

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
python check_neutrality.py --all
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

## Obsidian 連携の最小ルール

共通方針: `~/.claude/CLAUDE.md`（グローバル）と Obsidian Vault の `_Vault運用方針.md` を参照。
ここには **この repo 固有の参照先だけ** を置く。

vault path: `C:\Users\Motoi\R8.4 Obsidian`

### この repo で優先参照する Obsidian ノート

- `70_SOP/seo/SEO_GSC再観測手順.md` — デプロイ前後のGSC比較フロー（active）
- `20_Projects/houmonshinsatsu-navi/index.md` — プロジェクト現在地・直近デプロイ・残課題

### 保存の扱い

- **一次保存の主役は Daily**: `10_Daily/YYYY-MM-DD.md`（通常はここ）
- **Inbox は未分類メモの一時置き場のみ**: `00_Inbox/`（常用しない、最小限）
- **節目のみ Project ログ**: `20_Projects/houmonshinsatsu-navi/index.md` のログ欄（デプロイ / 重要決定 / KPI節目 等）
- **恒久保存は明示指示 or レビュー採択時のみ**: `70_SOP/` / `30_Areas/` / `50_Research/` / Project index の恒久要約欄
- 自動保存は 3〜6行の短い要約（何をした / 何が決まった / 次の宿題）
- 日次レビューで仕分け、月次レビューで掃除・昇格・Archive 判断
- 作業完了時は最後に「追記先 + 要約」または「保存判断 + 理由」を1行報告
- 詳細は Vault の `_Vault運用方針.md` 末尾「Claude Code による自動記録ルール」参照

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
