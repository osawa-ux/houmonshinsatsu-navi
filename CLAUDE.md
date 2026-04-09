# CLAUDE.md — houmonshinsatsu-navi

在宅クリニックナビ（zaitakuclinic-navi.com）の静的サイト本体。GitHub Pages でホスティング。

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
- 禁止語リスト: `横浜ホームクリニック`, `yokohama-home.clinic`, `大澤基`

### pre-commit hook セットアップ

clone / 別PC で作業を始めるときに一度だけ実行する:

```bash
bash tools/install_hooks.sh      # Git Bash / WSL
# または
powershell tools/install_hooks.ps1   # PowerShell
```

hook 本体は `tools/hooks/pre-commit` にリポジトリ管理されている。

### CI（GitHub Actions）

blog/ guide/ の変更を含む push / PR で GitHub Actions が禁止語チェックを自動実行する。
ローカル hook をすり抜けた場合（hook 未設置、`--no-verify` 使用等）でも CI で検出される。

チェック体制: **ローカル pre-commit hook + CI の二重チェック**
