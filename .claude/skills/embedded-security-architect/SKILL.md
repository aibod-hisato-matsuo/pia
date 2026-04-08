---
name: embedded-security-architect
description: >
  組み込み Linux デバイスのセキュリティアーキテクチャを設計するサブエージェントスキル。
  「セキュリティ設計して」「セキュアブートの仕様を」「ストレージ暗号化どうする」
  「OTAのセキュリティ」「ファクトリーリセット仕様」「OPTIGA Trust Mの使い方」
  「通信暗号化の設計」「セキュリティチップの選定」「PKIどう組む」
  「IEC 62443対応したい」「NIST準拠の消去」などと言われたら必ずこのスキルを使うこと。
  Claude Codeサブエージェントとして呼び出された場合も適用。
  AIBOD HEMSコントローラ（i.MX 8M Plus + OPTIGA Trust M V3 + Yocto Walnascar）を
  主ターゲットとし、セキュアブート・ストレージ暗号化・通信暗号化・OTA・
  ファクトリーリセットの5領域にわたるセキュリティ仕様を設計・文書化する。
version: "1.0"
brand: AIBOD Inc.
target_hw: i.MX 8M Plus + OPTIGA Trust M V3 (SLS32AIA010ML)
target_sw: Yocto Walnascar / Linux 6.6 LTS
---

# Embedded Security Architect Skill — AIBOD Edition v1.0

AIBOD HEMSコントローラおよび関連IoTデバイスのセキュリティを、
**5領域にわたる一貫したアーキテクチャ**として設計・文書化するスキル。
ハードウェア Root of Trust から OTA まで、縦串の信頼チェーンを安定出力する。

---

## ⚡ クイックリファレンス（毎回必ず確認）

```
ターゲット HW : i.MX 8M Plus (AHAB/HAB) + OPTIGA Trust M V3 (SLS32AIA010ML)
ターゲット OS : Yocto Walnascar / Linux 6.6 LTS
セキュアエレメント I2C : addr=0x30, 400kHz, Shielded Connection (PBS)
認証規格       : CC EAL6+ (HW), IEC 62443-4-2, PSA Certified Level 3
5大領域        : セキュアブート / ストレージ暗号化 / 通信暗号化 / OTA / ファクトリーリセット

OPTIGA 主要 OID:
  0xE0E0 = IFX デバイス証明書 (Infineon発行・固有・変更禁止)
  0xE0E1 = クラウド認証証明書 (AIBOD CA発行)
  0xE0E3 = Trust Anchor #1 (RAUC OTA CA)
  0xE0EF = Trust Anchor (セキュアブート公開鍵)
  0xE0F0 = ECC P-256 秘密鍵 #1 (TLS署名用)
  0xE0F1 = ECC P-384 秘密鍵 #2 (OTA署名 / ECDHE)
  0xE200 = AES-256 対称鍵 (data-at-rest暗号化)
  0xF1D0-F1D2 = HEMS アプリ状態オブジェクト (ファクトリーリセット対象)
  0xE0C9 = Security Monitor Config
  0xE140 = Platform Binding Secret (Shielded Connection)
```

---

## 1. セキュリティドメイン選択フロー

### Step 1: 要件ヒアリングチェックリスト

| 確認項目 | 設計への影響 |
|----------|-------------|
| ターゲット SoC (i.MX 8M Plus / 他) | HAB/AHAB 設定、CAAM 有無 |
| セキュアエレメント有無 (OPTIGA / SE050 / なし) | 鍵管理アーキテクチャ全体 |
| OS (Yocto / Buildroot / RTOS) | dm-crypt / RAUC 統合方法 |
| 通信経路 (LTE / Wi-Fi / Wi-SUN / Ethernet) | TLS バージョン・Cipher Suite |
| クラウド接続先 (AWS IoT / Azure / 自社) | mTLS 証明書チェーン構成 |
| デバイスライフサイクル (量産 / 廃棄 / 所有者変更) | ファクトリーリセット種別 |
| 規制要件 (IEC 62443 / NIST / CE / PSA) | 採用必須技術の絞り込み |
| OTA 配信方式 (RAUC / Mender / 独自) | バンドル署名 PKI 構成 |

### Step 2: 5領域マッピング

```
要求 → 該当領域:

「起動時に改ざん検知」「BootROM」「U-Boot検証」
  → §2 セキュアブート

「eMMC暗号化」「dm-crypt」「LUKS」「data-at-rest」「鍵保護」
  → §3 ストレージ暗号化

「MQTT暗号化」「TLS」「Wi-SUN」「Bルート」「クラウド接続」
  → §4 通信暗号化

「OTA」「ファームウェア更新」「RAUC」「A/Bスロット」「バンドル署名」
  → §5 OTA セキュリティ

「工場出荷状態に戻す」「廃棄」「データ消去」「NIST 800-88」
  → §6 ファクトリーリセット
```

---

## 2. セキュアブート設計

### 2.1 ブートチェーン（i.MX 8M Plus）

```
[電源投入]
    │
    ▼
[① ROM Boot] ─── AHAB (Advanced High Assurance Boot)
    │               HAB_CFG eFuse = 0x2 (closed)
    │               SRK Hash eFuse に公開鍵ハッシュ焼き込み
    ▼
[② SPL / ATF BL2] ─── OPTIGA VerifySign (OID:0xE0EF → 公開鍵取得)
    │                   ECDSA P-256 + SHA-256 で署名検証
    │                   Shielded Connection (PBS) で I2C 暗号化
    ▼
[③ U-Boot] ─────── FIT Image Verified Boot
    │               OPTIGA VerifySign で Kernel / DTB / initramfs 検証
    ▼
[④ Linux Kernel] ── DM-Verity で rootfs ブロック単位整合性検証
    │               squashfs (read-only) + verity hash tree
    ▼
[⑤ RAUC OTA] ───── CMS (RFC 5652) 署名検証
                    OPTIGA 0xE0E3 の CA 証明書で検証
```

### 2.2 OPTIGA Trust M 統合手順

```bash
# 1. I2C ウェイクアップ（専用シーケンス必須 - 通常のi2c-detectでは応答しない）
# PAL (Platform Abstraction Layer) を Yocto 向けに実装

# 2. Shielded Connection 確立
OPTIGA_UTIL_SET_COMMS_PROTECTION_LEVEL(me_util, OPTIGA_COMMS_FULL_PROTECTION)
OPTIGA_COMMS_PROTOCOL_VERSION_PRE_SHARED_SECRET

# 3. 公開鍵取得（OID 0xE0EF から X.509 証明書読み出し）
GetDataObject(0xE0EF) → X.509 → 公開鍵抽出

# 4. ファームウェアイメージ SHA-256 ハッシュ計算（ホスト側 mbedTLS）

# 5. 署名検証
VerifySign(hash, signature, public_key_from_E0EF)
# → SUCCESS: ブート継続 / FAILURE: ブート中断
```

### 2.3 Yocto 統合設定

```bitbake
# local.conf または machine.conf
HAB_ENABLE = "1"
OPTIGA_TRUST_M_I2C_BUS = "3"
OPTIGA_TRUST_M_I2C_ADDR = "0x30"

# meta-optiga-trust-m レイヤーを追加
BBLAYERS += "${BSPDIR}/sources/meta-optiga-trust-m"

# PAL 実装（i.MX 8M Plus 向け）
OPTIGA_PAL_IMPL = "linux-i2c"
```

### 2.4 主要 OID 設定ポリシー（セキュアブート用）

| OID | 用途 | LcsO | Change AC | 備考 |
|-----|------|------|-----------|------|
| 0xE0EF | ファームウェア検証公開鍵 | Operational | NEV | 変更禁止 |
| 0xE0E8 | Platform Integrity 証明書 | Operational | Protected Update | Protected Update のみ |
| 0xE0C9 | Security Monitor Config | Operational | Protected Update | 改ざん検知ポリシー |

---

## 3. ストレージ暗号化設計

### 3.1 アーキテクチャ層

```
[アプリ層] HEMS 計測データ / 設定 → /data (ext4)
    │
[OPTIGA 0xE200] AES-256 鍵 (オプション: アプリ層暗号化)
    │
[dm-crypt 層] AES-256-CBC (capi:tk(cbc(aes))-plain)
    │          CAAM HW アクセラレーション (priority: 3000)
    │
[CAAM 層] Black Key (Tagged Key, 36 byte)
    │      OTPMK (デバイス固有 eFuse) で black blob を保護
    │
[eMMC 物理層] 暗号化済みブロック (/dev/mmcblk0p5)
```

### 3.2 鍵階層

```
OTPMK (i.MX8 eFuse, NXP 焼き込み済み, チップ外読み出し不可)
    ↓ AES-ECB ラップ (CAAM 内部)
CAAM Black Key (32 byte) → .bb ファイルとして key パーティションに保存
    ↓ boot 時 kernel keyring へ import (平文は CAAM 内部のみ)
VEK (Volume Encryption Key) → RAM のみ / 電源断で消滅
    ↓ dm-crypt AES-256-CBC
暗号化 eMMC データパーティション

[オプション二重保護]
OPTIGA 0xE200 (AES-256) → CAAM Black Blob 自体をラップ
```

### 3.3 eMMC パーティション構成

| パーティション | サイズ | 用途 | 暗号化 |
|---------------|--------|------|--------|
| mmcblk0boot0 | 4 MB | U-Boot / SPL | 平文（署名済） |
| mmcblk0p1 | 64 MB | boot: FIT Image | 平文（署名済） |
| mmcblk0p2 | ~1.5 GB | rootfs A (squashfs) | 平文（DM-Verity） |
| mmcblk0p3 | ~1.5 GB | rootfs B (squashfs) | 平文（DM-Verity） |
| mmcblk0p4 | 32 MB | key partition (.bb) | AES-CCM blob |
| **mmcblk0p5** | **~1 GB** | **data (HEMS)** | **dm-crypt AES-256-CBC** |
| mmcblk0p6 | 残余 | RAUC update buffer | 平文（RAUC署名） |
| RPMB | 4 MB | リプレイ保護カウンタ | HW保護 |

### 3.4 ブート時マウントスクリプト（initramfs）

```bash
#!/bin/bash
# /init.d/mount-encrypted.sh (initramfs 内)

# 1. CAAM Tagged Key 変換確認
cat /proc/crypto | grep -q "tk(cbc(aes))" || exit 1

# 2. OPTIGA Shielded Connection 確認 (オプション)
# trustm_hmac_verify_Auth ... (0xF1D0 の HMAC 検証)

# 3. Black Blob import → kernel keyring
caam-keygen import /key_part/black_blob.bb keyhandle
cat /tmp/keyhandle | keyctl padd logon logkey: @s

# 4. dm-crypt マッピング作成
dmsetup -v create hems-data \
  --table "0 $(blockdev --getsz /dev/mmcblk0p5) crypt \
  capi:tk(cbc(aes))-plain :36:logon:logkey: 0 /dev/mmcblk0p5 0 1 \
  sector_size:512"

# 5. マウント
mount -t ext4 /dev/mapper/hems-data /data
```

### 3.5 重要制約事項

```
⚠️ XTS モード非対応: i.MX CAAM は AES-XTS をサポートしない → CBC 固定
⚠️ HAB closed 前に black blob を作成しないこと:
   open 状態では CAAM は test key を使用 → closed 後は復号不可
⚠️ CAAM priority 3000 > SW priority 300: dm-crypt は自動的に HW を選択
```

### 3.6 Kernel Config (Yocto Walnascar)

```
CONFIG_BLK_DEV_DM=y
CONFIG_DM_CRYPT=y
CONFIG_CRYPTO_DEV_FSL_CAAM=y
CONFIG_CRYPTO_DEV_FSL_CAAM_TK_API=y
CONFIG_TRUSTED_KEYS=y
CONFIG_KEY_DH_OPERATIONS=y
```

---

## 4. 通信暗号化設計

### 4.1 通信トポロジー

```
スマートメーター ←[Wi-SUN Bルート AES-128-CCM★]→ HEMSコントローラ ←[TLS 1.3 mTLS]→ AIBODクラウド
920 MHz / IEEE 802.15.4g                         i.MX 8M Plus                        AWS IoT / Azure
```

### 4.2 クラウド通信 (TLS 1.3)

**必須仕様:**

| 項目 | 仕様 |
|------|------|
| プロトコル | TLS 1.3 (RFC 8446) ※1.2 フォールバック禁止 |
| 必須 Cipher Suite | TLS_AES_128_GCM_SHA256 / TLS_AES_256_GCM_SHA384 |
| 鍵交換 | ECDHE (X25519 / P-256) |
| 認証 | mTLS (双方向証明書) |
| 署名 | ECDSA P-256 (SHA-256) |
| OPTIGA 証明書 OID | 0xE0E1 (クラウド認証証明書) |
| OPTIGA 秘密鍵 OID | 0xE0F0 (CalcSign コマンド) |
| OpenSSL 統合 | trustm_provider (OpenSSL 3.0+) |
| アプリプロトコル | MQTT 5.0 (port 8883) / HTTPS (port 443) |

**OPTIGA OpenSSL Provider 統合:**

```bash
# TLS 接続時の秘密鍵参照（鍵はチップ外に出ない）
openssl s_client \
  -provider trustm_provider -provider default \
  -cert /etc/hems/client.crt \
  -key 0xe0f0:^ \
  -connect mqtt.aibod-hems.jp:8883 \
  -CAfile /etc/rauc/keyring.pem

# AWS IoT 接続
# 秘密鍵 = "0xe0f1:^" (OPTIGA OID参照)
# 証明書 = OID 0xE0E1 から読み出し
```

**TLS ハンドシェイク（mTLS）フロー:**

```
1. ClientHello: [TLS 1.3], key_share=[X25519/P-256]
2. ServerHello + EncryptedExtensions: 鍵共有完了
3. Certificate (サーバー) → クライアントが OID 0xE0E3 CA で検証
4. CertificateRequest → クライアント証明書要求
5. Certificate (OID 0xE0E1 の X.509 を送信)
6. CertificateVerify: OPTIGA CalcSign(OID 0xE0F0) で ECDSA 署名生成
7. Finished → MQTT/HTTPS セッション開始
```

### 4.3 Wi-SUN Bルート通信

**仕様:**

| 項目 | 仕様 |
|------|------|
| 物理層 | IEEE 802.15.4g SUN (920 MHz 帯、日本) |
| MAC 暗号化 | IEEE 802.15.4e AES-128-CCM★ (Security Level 5: ENC+MIC-32) |
| 認証プロトコル | PANA (RFC 5191) / EAP-PSK ベース |
| 認証情報 | Bルート認証 ID (32文字) + パスワード (12文字) |
| セッション鍵 | PTK / GTK (128 bit AES, PANA セッションで自動導出) |
| アプリ層 | ECHONET Lite over UDP (port 3610) |
| Wi-SUN モジュール | ROHM BP35C0-J11 (UART 115200 bps) |
| 規格 | TTC JJ300.10 / Wi-SUN ECHONET Profile |

**接続シーケンス (BP35C0-J11):**

```bash
SKSETPWD C <Bルートパスワード12文字>
SKSETRBID <Bルート認証ID32文字>
SKSCAN 2 FFFFFFFF 6 0          # アクティブスキャン
# → EPANDESC で Channel / PAN ID / MAC アドレス 取得
SKLL64 <MAC>                    # IPv6 アドレス変換
SKSREG S2 <Channel>
SKSREG S3 <PAN_ID>
SKJOIN <IPv6>                   # PANA 認証開始
# → EVENT 25: PANA 接続完了
# ERXUDP token[6]=1 → 暗号化確認必須（=0なら破棄）
```

**セキュリティ検証:**

```python
# ERXUDP 受信時の暗号化フラグ確認
tokens = erxudp_line.split(' ')
if tokens[6] != '1':
    logger.warning("Received unencrypted frame - discarding")
    continue  # 暗号化フラグ=0のフレームは破棄
```

### 4.4 プロトコルスタック対比

| OSI 層 | TLS 1.3 クラウド | Wi-SUN Bルート |
|--------|----------------|----------------|
| アプリ | MQTT 5.0 / HTTPS | ECHONET Lite (UDP:3610) |
| セッション | TLS 1.3 Record (AEAD) | PANA セッション管理 |
| トランスポート | TCP (8883/443) | UDP / IPv6 (6LoWPAN) |
| ネットワーク | IPv4/IPv6 (LTE/Wi-Fi) | IPv6 (6LoWPAN / RPL) |
| データリンク | Ethernet / LTE MAC | IEEE 802.15.4e (AES-128-CCM★) |
| 物理 | LTE Cat-M1 / Wi-Fi | IEEE 802.15.4g SUN (920 MHz) |

---

## 5. OTA セキュリティ設計

### 5.1 RAUC バンドル構造（verity フォーマット）

```
┌─────────────────────────────────────────────────┐
│ CMS 署名 (RFC 5652)                              │
│ ECDSA P-256 + SHA-256 / 署名者証明書 + チェーン  │
│ OPTIGA 0xE0E3 CA 証明書で検証                    │
├─────────────────────────────────────────────────┤
│ manifest.raucm (CMS 内インライン)                 │
│   compatible=AIBOD-HEMS-GW-iMX8MP               │
│   version=YYYY.MM-N                             │
│   min-compatible-version=YYYY.MM-N (ロールバック防止) │
│   format=verity                                  │
│   sha256 per image                               │
├─────────────────────────────────────────────────┤
│ dm-verity ハッシュツリー (Merkle tree)           │
│   各ブロックをカーネルがリアルタイム検証         │
├─────────────────────────────────────────────────┤
│ SquashFS ペイロード                              │
│   rootfs.img / imx-boot.img / kernel.img         │
└─────────────────────────────────────────────────┘
```

### 5.2 PKI 構成（AIBOD HEMS OTA 用）

```
AIBOD Root CA (ECC P-384, 有効20年, エアギャップ保管)
    └─ Release Intermediate CA (ECC P-256, 有効2年, AWS KMS管理)
            └─ Bundle Signing Certificate (ECC P-256, 有効1年)
                  ※ 秘密鍵は PKCS#11 / AWS KMS / HSM に格納
                  ※ ファイルとして保存禁止
    └─ Development CA (dev-only, 量産 keyring に含めない)

デバイス keyring: /etc/rauc/keyring.pem = Release Intermediate CA 証明書
                  ← OPTIGA 0xE0E3 の Trust Anchor と連動
```

### 5.3 バンドル作成・配信

```bash
# バンドル作成（CI/CD ビルドシステム上）
rauc bundle \
  --cert release-inter.cert.pem \
  --key 'pkcs11:object=hems-signing-key;type=private' \
  --signing-keyring release-inter.cert.pem \
  content-dir/ \
  hems-controller-2025.12-1.raucb

# バンドル確認
rauc info --keyring=release-inter.cert.pem hems-controller-2025.12-1.raucb

# デバイス側インストール（HTTPS ストリーミング）
rauc install https://ota.aibod-hems.jp/bundles/hems-controller-2025.12-1.raucb
```

### 5.4 インストール検証フロー

```
1. HTTPS mTLS でバンドル取得（OPTIGA 0xE0F0 で署名）
2. CMS 署名検証 → /etc/rauc/keyring.pem で署名者証明書チェーン確認
3. manifest.raucm 検証:
   - compatible 文字列一致確認
   - min-compatible-version チェック（ダウングレード防止）
4. dm-verity でブロック単位整合性検証（インストール中リアルタイム）
5. 非アクティブスロットに書き込み + SHA-256 再検証
6. U-Boot 環境変数更新（次回ブート候補をBスロットに）
7. リブート後 HEMS アプリ正常起動を確認
8. rauc status mark-good → Bスロット確定
   （失敗時: boot_count ≥ 3 → 自動で A スロットにフォールバック）
```

### 5.5 manifest.raucm テンプレート（AIBOD HEMS）

```ini
[update]
compatible=AIBOD-HEMS-GW-iMX8MP
version=2025.12-1
description=HEMS Controller FW - ECHONET Lite v1.14
build=20251210-143201
min-compatible-version=2024.06-1

[bundle]
format=verity

[image.rootfs]
filename=hems-image-imx8mp.squashfs

[image.bootloader]
filename=imx-boot-imx8mp.img

[hooks]
install=hook.sh
```

### 5.6 Yocto 設定

```bitbake
# local.conf
DISTRO_FEATURES:append = " rauc"
CORE_IMAGE_EXTRA_INSTALL += "rauc"
RAUC_KEYRING_FILE = "${TOPDIR}/../pki/release-inter.cert.pem"
RAUC_CERT_FILE    = "${TOPDIR}/../pki/bundle-signing.cert.pem"
RAUC_KEY_FILE     = "pkcs11:..."  # AWS KMS PKCS#11 URI
```

---

## 6. ファクトリーリセット設計

### 6.1 リセット種別と適用シナリオ

| 種別 | トリガー | NIST 分類 | 対象 |
|------|----------|-----------|------|
| ソフトリセット | ユーザー操作 / クラウド API | Clear | ユーザーデータ・設定のみ |
| 暗号消去 | 保守交換 / 解約 | Purge | データパーティション全体 |
| 完全初期化 | 廃棄 / 所有者変更 | Purge | データ + OPTIGA ユーザーデータ |

### 6.2 消去対象範囲

**消去対象（完全初期化時）:**
- HEMS 計測データ・ログ（`/data`）
- Wi-SUN 接続情報（Bルート ID/PW・PAN ID・チャネル）
- クラウド設定（MQTT エンドポイント・テナント情報）
- CAAM Black Key blob（`.bb` ファイル）
- OPTIGA アプリデータ（OID `0xF1D0`–`0xF1D2`）
- OPTIGA AES 鍵（`0xE200` → 新ランダム鍵で上書き）

**保持対象（絶対に消去禁止）:**
- OPTIGA IFX 証明書（`0xE0E0` — Infineon工場発行・固有）
- OPTIGA ECC 秘密鍵（`0xE0F0` — デバイス固有）
- OPTIGA Trust Anchor（`0xE0E3`, `0xE0EF`）
- OPTIGA PBS（`0xE140` — Shielded Connection）
- rootfs / Kernel（read-only squashfs）
- U-Boot / SPL（eMMC boot パーティション）
- i.MX8 OTPMK（eFuse — 物理的に不可逆）
- HAB ヒューズ設定

### 6.3 完全初期化 実行スクリプト

```bash
#!/bin/bash
# /usr/sbin/factory-reset-complete.sh
# 実行環境: initramfs (rootfs アンマウント済み)

set -euo pipefail
LOG="/tmp/factory_reset_$(date +%Y%m%dT%H%M%S).log"
exec > >(tee "$LOG") 2>&1

echo "[$(date -Iseconds)] Factory Reset STARTED"

# === フェーズ1: クラウド登録解除（事前にクラウド側で実施済み前提） ===
echo "[Phase 1] Cloud deregistration confirmed"

# === フェーズ2: OPTIGA ユーザーデータ消去 ===
echo "[Phase 2] OPTIGA user data objects clear"
# 0xE200 (AES鍵) を新ランダム鍵で上書き（Protected Update 経由）
# 0xF1D0-F1D2 (HEMSアプリ状態) をゼロクリア
# ⚠️ LcsO 変更コマンド (-T) は絶対に実行しないこと

# === フェーズ3: dm-crypt VEK 削除（暗号消去 Step 1）===
echo "[Phase 3] Cryptographic erase - VEK deletion"
keyctl purge logon logkey: @s 2>/dev/null || true
dmsetup remove hems-data 2>/dev/null || true
echo "  → VEK deleted. Data mathematically unrecoverable."

# === フェーズ4: CAAM Black Blob 削除（暗号消去 Step 2）===
echo "[Phase 4] CAAM black key blob deletion"
mount -t ext4 /dev/mmcblk0p4 /mnt/key
shred -n 3 -uz /mnt/key/*.bb /mnt/key/randomkey 2>/dev/null || true
sync
umount /mnt/key
echo "  → Black blob deleted (shred -n 3)."

# === フェーズ5: eMMC 物理消去 (NIST Purge) ===
echo "[Phase 5] eMMC physical erase - DISCARD + Sanitize"
blkdiscard /dev/mmcblk0p5
mmc sanitize /dev/mmcblk0  # EXT_CSD_SANITIZE_START=1
echo "  → eMMC data partition sanitized."

# === フェーズ6: ファイルシステム再構築 ===
echo "[Phase 6] Filesystem rebuild"
mkfs.ext4 -L hems-data /dev/mmcblk0p5
mount -t ext4 /dev/mmcblk0p5 /mnt/data
mkdir -p /mnt/data/{hems,log,config,caam}
sync
umount /mnt/data

echo "[$(date -Iseconds)] Factory Reset COMPLETED"
echo "NIST SP 800-88 Purge: Cryptographic Erase + Block Erase"
```

### 6.4 OPTIGA LcsO ライフサイクル注意事項

```
⚠️ 重大警告: LcsO は不可逆

Initialization (0x03) → Operational (0x07) → Termination (0x0F)
                                              ↑ここより戻れない

リセットスクリプトで絶対に禁止:
  trustm_metadata -T   # Termination に設定 → デバイス永久使用不可
  trustm_metadata -O   # Operational に設定（誤操作で変更できなくなる）

許可する操作のみ:
  trustm_protected_update_aeskey   # 0xE200 のみ
  SetDataObject (0xF1D0-F1D2)     # アプリデータオブジェクトのみ
```

### 6.5 トリガー方式

| トリガー | 方式 | 認証 |
|---------|------|------|
| クラウド API | MQTT `device/reset` トピック | mTLS 必須 |
| 物理ボタン | 10秒長押し → initramfs で実行 | 物理アクセス |
| U-Boot 環境変数 | `factory_reset=1` → 次回ブート時 | — |
| RAUC pre-install hook | 特定バンドルのフック | RAUC 署名検証済み |

---

## 7. PKI 全体設計

### 7.1 証明書チェーン構成

```
Infineon Root CA (Infineon工場管理)
    └─ Infineon OPTIGA Trust M CA xxx (中間 CA)
            └─ デバイス固有証明書 (0xE0E0) — デバイス ID 証明

AIBOD Root CA (ECC P-384, 20年, エアギャップ)
    ├─ AIBOD Cloud CA (ECC P-256, 5年)
    │       └─ デバイス クラウド証明書 (0xE0E1, 2年)
    ├─ AIBOD OTA Release CA (ECC P-256, 2年)
    │       └─ OTA Bundle Signing Cert (1年, AWS KMS)
    │              ← OPTIGA 0xE0E3 に格納 (Trust Anchor)
    └─ AIBOD SecureBoot CA (ECC P-256, 5年)
            └─ FW Signing Cert (1年)
                   ← OPTIGA 0xE0EF に格納 (Trust Anchor)
```

### 7.2 証明書更新（Protected Update）

```bash
# OPTIGA Protected Update フロー（証明書期限切れ対応）
# 1. サーバー側で新証明書を準備
# 2. COSE Sign1 マニフェスト生成（Trust Anchor 0xE0E3 で署名）
rauc-protected-update-tool \
  --target-oid 0xE0E1 \
  --new-cert new-cloud.cert.der \
  --trust-anchor 0xE0E3 \
  --output manifest_e0e1.bin fragment_e0e1.bin

# 3. デバイス側で実行
trustm_protected_update -k 0xE0E1 \
  -m manifest_e0e1.bin \
  -f fragment_e0e1.bin
```

---

## 8. セキュリティ規格準拠マッピング

| 規格 | 要求事項 | 実装 |
|------|---------|------|
| IEC 62443-4-2 (SL1) | デバイス固有 ID | OPTIGA 0xE0E0 + UID |
| IEC 62443-4-2 (SL1) | ソフトウェア・構成整合性 | セキュアブート + DM-Verity |
| IEC 62443-4-2 (SL1) | セッション完全性 | TLS 1.3 mTLS |
| IEC 62443-4-2 (SL1) | 機密データ保護 | dm-crypt AES-256 |
| IEC 62443-4-2 (SL2) | 認証失敗検知 | OPTIGA Security Monitor |
| PSA Certified Level 3 | HW Root of Trust | OPTIGA CC EAL6+ |
| PSA Certified Level 3 | Secure Boot | AHAB + VerifySign |
| PSA Certified Level 3 | Secure Storage | CAAM Black Key + OPTIGA |
| PSA Certified Level 3 | Secure Update | RAUC + CMS署名 |
| NIST SP 800-88 R1 | メディアサニタイズ | Purge (CE + Block Erase) |
| GDPR / 個人情報保護 | データ消去権 | 暗号消去 (CE) |

---

## 9. 出力フォーマット

### 9.1 セキュリティ仕様書テンプレート

設計書を出力する際は以下の構造で記述すること:

```markdown
## [領域名] セキュリティ仕様

### 概要
- 目的: [何を保護するか]
- 脅威モデル: [どのような攻撃を防ぐか]
- 準拠規格: [IEC 62443 / NIST / PSA]

### アーキテクチャ
[層図 / フロー図]

### 暗号パラメータ
| 項目 | 仕様 |
|------|------|

### 実装詳細
[コード例 / コマンド例]

### OID マッピング（OPTIGA 使用時）
| OID | 用途 | LcsO | 操作許可 |

### FW 仕様書記載事項チェックリスト
- [ ] ...
```

### 9.2 脅威モデルテンプレート

| 脅威 | 攻撃ベクター | 対策 | 実装 |
|------|------------|------|------|
| 不正ファームウェア実行 | 物理書き換え | セキュアブート | AHAB + OPTIGA VerifySign |
| ストレージ読み取り | 物理抜き出し | ストレージ暗号化 | dm-crypt + CAAM |
| 中間者攻撃 | ネットワーク盗聴 | TLS 1.3 mTLS | OPTIGA TLS |
| 不正 OTA | 偽バンドル配布 | 署名検証 | RAUC CMS |
| データ漏洩（廃棄時）| 物理回収 | 暗号消去 | NIST Purge |
| リプレイ攻撃 | 旧パケット再送 | eMMC RPMB | RPMB カウンタ |

---

## 10. 実装チェックリスト（全領域）

```
セキュアブート:
□ AHAB eFuse (HAB_CFG=0x2) 設定済み（量産デバイス）
□ OPTIGA I2C PAL (Yocto 向け) 実装済み
□ Shielded Connection PBS 設定済み
□ U-Boot FIT Image Verified Boot 動作確認
□ DM-Verity rootfs 設定済み

ストレージ暗号化:
□ HAB closed 後に CAAM black blob 生成（順序厳守）
□ Kernel CONFIG_CRYPTO_DEV_FSL_CAAM_TK_API=y
□ initramfs mount スクリプト動作確認
□ OPTIGA 0xE200 AES-256 鍵設定済み

通信暗号化:
□ TLS 1.3 Only 設定（1.2 フォールバック無効）
□ OPTIGA OpenSSL Provider 統合済み（OpenSSL 3.0+）
□ mTLS クライアント証明書 (0xE0E1) 発行済み
□ Wi-SUN 暗号化フラグ検証実装済み（token[6]=1 のみ許可）
□ Bルート認証 ID/PW を暗号化領域に格納

OTA セキュリティ:
□ RAUC verity フォーマット設定
□ Bundle Signing 秘密鍵は PKCS#11 / AWS KMS（ファイル保存禁止）
□ min-compatible-version 設定（ダウングレード防止）
□ boot_count フォールバック動作確認
□ RAUC_KEYRING_FILE = 0xE0E3 の CA 証明書

ファクトリーリセット:
□ LcsO 変更コマンド (-T) をスクリプトから完全排除
□ blkdiscard + mmc sanitize 動作確認
□ shred -n 3 で black blob 上書き後削除
□ クラウド通知→消去実行の順序を守る
□ 消去完了ログをクラウドに送信（NIST 証跡要件）
```

---

## 11. 参考リソース

```
OPTIGA Trust M:
  Datasheet:     https://www.infineon.com/dgdl/Infineon-OPTIGA_Trust_M-DataSheet-v03_70-EN.pdf
  GitHub:        https://github.com/Infineon/optiga-trust-m
  Linux tools:   https://github.com/Infineon/linux-optiga-trust-m
  OpenSSL Prov:  https://github.com/Infineon/optiga-trust-m-openssl

i.MX 8M Plus セキュリティ:
  CAAM AN:       https://www.nxp.com/docs/en/application-note/AN12714.pdf (AN12714)
  HAB Guide:     NXP i.MX 8M Plus Security Reference Manual

RAUC:
  公式:          https://rauc.readthedocs.io/
  GitHub:        https://github.com/rauc/rauc
  meta-rauc:     https://github.com/rauc/meta-rauc

Wi-SUN Bルート:
  ROHM BP35C0-J11 AN: https://fscdn.rohm.com/jp/products/databook/applinote/module/wireless/bp35c0-j11_b-route_an-j.pdf

規格:
  NIST SP 800-88 R1: https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-88r1.pdf
  IEC 62443-4-2: https://www.iec.ch/
```
