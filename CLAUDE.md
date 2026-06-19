# CLAUDE.md — houmonshinsatsu-navi

在宅クリニックナビ（zaitakuclinic-navi.com）の静的サイト本体。GitHub Pages でホスティング。

このリポジトリは主に **静的出力物の配置先（生成物 repo）** であり、サイト生成の主処理と正本ロジックは `~/MyPython/` が担う。

---

## 反復実装ループ（loop-engineering）

ポータルの**反復/一気通貫の実装・改修指示**を受けたら、まず vault `70_SOP/loop-engineering.md` を Read しその型に従う（§0.5 開始前提ゲート → 各周 入口/実装/検証/止血/引き継ぎ/報告 → 人間確認キューは Project index に永続 → §5 不可逆ライン〔本番 deploy・外部送信〕でのみ停止し院長 go。UI は design-base.md＋各サイト第2層 design.md を参照）。**ただし恒久的な実装の正本は MyPython 側**（本 repo は生成物）。本 repo 直接の反復実装は緊急 hotfix に限る。

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

deploy 経路上、houmonshinsatsu-navi の実体は `~/houmonshinsatsu-navi/`（日常作業用）と `~/MyPython/site/`（deploy 用 clone）の 2 つとして存在しうる。片方で commit/push した変更がもう片方に反映されていない状態でデプロイすると意図しない巻き戻しが起きる。

**停止条件**: 本番反映前に両 clone と `origin` の同期を確認する（`git fetch origin && git log --oneline HEAD..origin/<branch>` で差分確認）。大きな差分がある場合はデプロイを止め、どちらの状態が正かを確認してから進める。

詳細: `20_Projects/zaitakuclinic-navi/gh-pages-branch-policy.md` 原則6（複数 clone の HEAD 同期）/ `70_SOP/incident-response/gh-pages-stale-clone-deploy.md`（stale clone 事故 RCA）

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

再利用可能な機能を新規実装・拡張・廃止したら Obsidian Vault の `30_Areas/能力カタログ.md` を更新する（必須）。能力 ID の正本は Obsidian 能力カタログ側で採番・管理する（本 CLAUDE.md で仮 ID を新設しない）。本repo は生成物配置のため能力本体は MyPython 側に集約されており、機能追加・修正は原則 MyPython 側で行い能力カタログの entrypoint 表記もそちらに合わせる。

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

- 自院名の例: `横浜ホームクリニック`
- 外部ドメインの例: `yokohama-home.clinic`
- 一人称表現: `当院`、`当クリニック`

**禁止語の正本は `check_neutrality.py` の `BANNED_WORDS`**（追加・変更は実装側で行う。本 CLAUDE.md に詳細リストは複製しない）。

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
- 個人名を監修者として入れない

### チェック手順

- 記事作成・更新時: `python ~/MyPython/check_neutrality.py --site .` を実行
- MyPython 側から両方検査: `python ~/MyPython/check_neutrality.py --all`
- `build_site.py` 実行時: 禁止語が含まれていると自動でビルドが停止する

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

## pre-commit hook / CI

clone または別PC での作業開始時に一度だけ hook を設置する（`bash tools/install_hooks.sh`、PowerShell では `powershell tools/install_hooks.ps1`）。hook 本体は repo 管理済み。hook 未設置・`--no-verify` 使用時も CI（GitHub Actions）が禁止語を自動検出する（二重チェック体制）。

---

## 直接編集 commit の管理（hotfix-direct prefix）

本 repo の HTML を **MyPython の build_site.py 経由ではなく直接編集** する場合（緊急 hotfix・部分 fix 等）、commit message の先頭に `hotfix-direct:` prefix を付ける。理由: 直接編集と MyPython 再ビルド commit が並走する運用では、次回ビルド時に直接編集の差分が上書きされる可能性があり、過去に「5/27 deploy 漏れ分の補完（commit 20c798f69b）」のような反映漏れ事例が実際に発生している。

ルール:
- 本 repo の `*.html` / `clinic/` / `pref/` / `blog/` / `guide/` 等を **直接編集** した commit → `hotfix-direct: <内容>` を付ける
- MyPython の再ビルド出力をそのまま反映した commit（典型的に `Update site data` や build_site.py 実行後の commit） → prefix なし
- `hotfix-direct:` prefix が付いた commit が `Update site data` 系 commit より新しい状態で次回 build_site.py を実行する前に、MyPython 側の template / data / `site_config*.json` に同等修正が入っているかを確認する

確認手順:
1. `git log --oneline --grep='^hotfix-direct:'` で直接編集 commit の一覧を取得
2. 各 commit の修正内容が MyPython 側に反映済みかを確認
3. 未反映があれば MyPython 側に反映してから次回ビルドを実行

## pre-commit hook の動作仕様

`tools/hooks/pre-commit` は **MyPython の `check_neutrality.py` への依存**を持つ。

- MyPython が配置されている PC: pre-commit hook は blog/guide 変更時に check_neutrality.py を実行し、禁止語があれば commit を中止する
- MyPython 未配置 / Windows PowerShell-only 環境: pre-commit hook は WARNING を stderr に出力した上で exit 0 する。**この場合 CI（`.github/workflows/neutrality-check.yml`）が唯一の防衛線**となる
- `--no-verify` で hook を bypass しても CI が同じ検査を実行する（二重チェック体制）

つまり「ローカル pre-commit による即時停止」は MyPython 配置 PC の **best effort** であり、信頼の根拠は **CI（GitHub Actions）** に置く設計。新 PC / clone 直後で MyPython を取得していない状態でも blog/guide の変更 commit は可能だが、CI が push 時に検査する。

- MyPython の配置 path は `$HOME/projects/MyPython` と `$HOME/MyPython` の両方を試行する
- Python コマンド動的判定: `python`（Python 3 確認）→ `python3` の順で fallback する。Windows で `python3` が MS Store リダイレクトになる問題への対応
- hook source（`tools/hooks/`）が更新された場合、各 PC で `bash tools/install_hooks.sh` または `powershell tools/install_hooks.ps1` の再実行が必要。`.git/hooks/` 配下は git 同期対象外のため自動反映されない

### 過去の誤動作パターン（debug 起点）

hook が誤動作したときは以下を順に確認する:

1. `.git/hooks/pre-commit` と `tools/hooks/pre-commit` の diff を取る（5/17 配置時から source 更新が反映されていない可能性。`bash tools/install_hooks.sh` で再配置）
2. hook 内の `python3` / `python` コマンドが Windows で MS Store リダイレクトになっていないか確認（`python -c "import sys; print(sys.executable)"` で実際の実行先を確認）
3. hook が参照する MyPython の path（`$HOME/projects/MyPython` / `$HOME/MyPython`）に check_neutrality.py が実在するか確認
4. hook 内の `2>/dev/null` が stderr を隠蔽していないか確認。デバッグ時は一時的に外して stderr を見る
5. 過去事例: 2026-06-03 に上記 1+2+4 が同時発生し「禁止語検出」誤メッセージで commit が常時 block されていた（commit `ddd9761045` で恒久解消）

### `--no-verify` 使用ルール

`git commit --no-verify` / `git push --no-verify` は **以下すべてを満たした場合のみ** 許可される:

1. hook が誤動作している証拠が手元にある（hook script を実際に Read + 手動実行して「本物の検出ロジックは合格を返すが hook layer が exit 1 を返している」ことを確認した）
2. 真因究明を試行した上で、別 commit で根本修正することが時間的に難しい / 別タスク化が妥当な状況である
3. ユーザー（または代理レビュアー）が bypass を明示承認している
4. commit message に「bypass の理由」「真因（既知範囲）」「後追い修正タスクの登録先」を 3 つ記録する

これらを満たさない bypass は禁止する。安易な前例化（「前回も bypass で通したから」）は drift の主原因となる。

### CI workflow trigger 一覧

| workflow | trigger | 役割 |
|---|---|---|
| `.github/workflows/neutrality-check.yml` | push / PR で blog/** または guide/** が変更 | 禁止語の自動検査 (CI 防衛線) |
| `.github/workflows/notion-commit-log.yml` | gh-pages branch へ push | commit を Notion DB に記録 |
| `.github/workflows/deploy-quality-log.yml` | gh-pages branch へ push | sitemap URL / clinic / pref / blog / guide HTML 数の記録 + 前回比 5% 超減少で `::warning::` |

trigger は競合しない（neutrality-check は path 変更時のみ、notion-commit-log と deploy-quality-log は同じ gh-pages push を別目的で処理）。pre-commit hook の WARNING + CI 二重防衛体制は変わらない。

---

## Pre-Deploy Validation 詳細（在宅クリニックナビ gh-pages）

デプロイ前に必ず確認する（global CLAUDE.md の原則を具体化）。zaitaku-deploy skill 経由が前提（skill が件数監査を処理フローに組込み済）。

### 異常の目安と停止条件

- 総件数が前回比で数百件以上減少（意図しない場合）
- 特定エリアで急激な減少（例：都筑区 24→8 など）
- 個別ページ数と検索 JSON 件数の不一致

異常があれば git push / デプロイを中止し、原因を特定してから再 build する。「デプロイ成功」ではなく「データが正しい状態で公開されている」ことを成功とする。

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
