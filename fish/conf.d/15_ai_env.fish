# DeepSeek / Claude Code 通用非敏感配置（迁移自 zsh/zshrc）
set -gx ANTHROPIC_BASE_URL "https://api.deepseek.com/anthropic"
set -gx ANTHROPIC_MODEL "deepseek-v4-pro[1m]"
set -gx ANTHROPIC_DEFAULT_OPUS_MODEL "deepseek-v4-pro[1m]"
set -gx ANTHROPIC_DEFAULT_SONNET_MODEL "deepseek-v4-pro[1m]"
set -gx ANTHROPIC_DEFAULT_HAIKU_MODEL "deepseek-v4-flash"
set -gx CLAUDE_CODE_SUBAGENT_MODEL "deepseek-v4-flash"
set -gx CLAUDE_CODE_EFFORT_LEVEL "max"
set -gx CLAUDE_CODE_AUTO_COMPACT_WINDOW "786432"
