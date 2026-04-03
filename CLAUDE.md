# CLAUDE.md — houmonshinsatsu-navi

在宅クリニックナビ（zaitakuclinic-navi.com）の静的サイト本体。GitHub Pages でホスティング。

## Secrets 運用

このリポジトリは静的 HTML のみで構成されており、ローカル secrets 運用の主対象ではない。

### 注意事項

- HTML 内に埋め込まれる API キー（Google Maps 等）は、GCP コンソールで HTTP リファラー制限を設定済みの公開キーを前提とする
- Formspree のフォーム ID は公開情報として扱う（秘密ではない）
- サイト生成は `MyPython/build_site.py` で行い、secrets は MyPython 側で管理する

### 将来 secrets を追加する場合

- 原本: `C:\Users\volzs\OneDrive\個人用 Vault\.secrets\houmonshinsatsu-navi\`
- 実行用: `C:\Users\volzs\.secrets\houmonshinsatsu-navi\`
- `.env`, `credentials*.json`, `token*.json`, `*.p12`, `*.pem` などの秘密情報は Git に入れない
