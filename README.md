# 在宅クリニックナビ (houmonshinsatsu-navi)

訪問診療クリニックの全国ポータルサイト本体。GitHub Pages + Cloudflare で公開。

- Live: https://zaitakuclinic-navi.com/
- 運用ガイド: [CLAUDE.md](CLAUDE.md)
- 掲載件数: 15,759件（医療情報ネット 11,857件 + 厚生局届出 3,902件）

## このリポジトリの位置づけ

- 公開される **静的出力物の配置先**
- HTML / sitemap / data などの多くは別リポジトリ `MyPython/build_site.py` により生成される
- テンプレート的な修正は MyPython 側を優先、単発の静的修正のみこの repo を直接編集

詳細は [CLAUDE.md](CLAUDE.md) の「このリポジトリの位置づけ」節を参照。

## 初期セットアップ（clone / 別PC 作業開始時）

```bash
# pre-commit hook（中立性チェック）
bash tools/install_hooks.sh        # Git Bash / WSL
powershell tools/install_hooks.ps1 # PowerShell
```

## 公開ブランチ

- `gh-pages` が公開ブランチ（GitHub Pages の publish source）
- 作業前に必ず `git fetch` で origin を確認する

## 複数PC運用での注意

- ソース生成は kawawa PC が主、ローカル修正は各PCで可能
- `origin/gh-pages` が source of truth
- ローカル `gh-pages` と origin が分岐した場合は `origin/gh-pages` 起点で feature branch を切り、fast-forward で push する
- `git fetch` 時に `forced update` 表示が出たら、ローカル起点のままの push は禁止

## 主要ディレクトリ

| パス | 内容 |
|---|---|
| `index.html`, `pref/`, `clinic/`, `blog/`, `guide/` | 公開ページ |
| `static/` | CSS / JS / 画像 |
| `data/` | 検索用 JSON |
| `tools/` | hook / 補助スクリプト |
| `sitemap.xml`, `robots.txt`, `CNAME` | SEO / 公開設定 |

## 関連リポジトリ

- `MyPython/` — サイト生成スクリプト・データパイプライン（kawawa PC）
- `zaitaku-members` — 会員管理・決済（別サブドメイン）

## 運営

- 運営主体: MDX株式会社
- 決済: ZEUS決済（会員管理は別リポジトリ）
- 解析: GA4 / Google Search Console 設置済み
