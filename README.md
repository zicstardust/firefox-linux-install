# Firefox Linux installer
Install firefox any linux

## Supported Architectures

| Architecture | Available
| :----: | :----: |
| x86_32 | ❌ |
| x86_64 | ✅ |
| arm64 | ✅ |

## Dependencies
- bash
- curl

## Environment Variables

| Variable | Description | Default Value | Accept Values |
| :----: | :----: | :----: | ---- |
| `EDITION` | Firefox edition | `stable` | `stable`, `esr`, `dev`, `beta`, `nightly` |
| `LANG` | Firefox language | `en-US` | `en-US`, `en-GB`, `en-CA`, `ja`, `zh-CN`, `zh-TW`, `es-ES`, `pt-PT`, `pt-BR`, etc |

## Install

```bash
#export EDITION='stable'
#export LANG='en-US'
curl https://raw.githubusercontent.com/zicstardust/firefox-linux-install/main/install.sh | bash
```