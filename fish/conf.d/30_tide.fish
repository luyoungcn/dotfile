# Catppuccin Frappé palette shared with tmux/colors.conf.
status is-interactive; or return

set -U tide_left_prompt_items pwd git newline character
set -U tide_right_prompt_items status cmd_duration jobs nvm python time

set -U tide_left_prompt_frame_enabled false
set -U tide_right_prompt_frame_enabled false
set -U tide_left_prompt_prefix ''
set -U tide_left_prompt_suffix ' '
set -U tide_right_prompt_prefix ''
set -U tide_right_prompt_suffix ''
set -U tide_left_prompt_separator_diff_color '#737994'
set -U tide_left_prompt_separator_same_color '#737994'
set -U tide_right_prompt_separator_diff_color '#737994'
set -U tide_right_prompt_separator_same_color '#737994'
set -U tide_prompt_color_frame_and_connection '#737994'
set -U tide_prompt_color_separator_same_color '#737994'
set -U tide_prompt_icon_connection ''
set -U tide_prompt_add_newline_before true
set -U tide_prompt_transient_enabled false

set -U tide_pwd_bg_color normal
set -U tide_pwd_color_anchors '#babbf1'
set -U tide_pwd_color_dirs '#8caaee'
set -U tide_pwd_color_truncated_dirs '#838ba7'

set -U tide_git_bg_color normal
set -U tide_git_bg_color_unstable normal
set -U tide_git_bg_color_urgent normal
set -U tide_git_color_branch '#a6d189'
set -U tide_git_color_upstream '#81c8be'
set -U tide_git_color_stash '#81c8be'
set -U tide_git_color_staged '#e5c890'
set -U tide_git_color_dirty '#e5c890'
set -U tide_git_color_untracked '#85c1dc'
set -U tide_git_color_conflicted '#e78284'
set -U tide_git_color_operation '#e78284'

set -U tide_status_bg_color normal
set -U tide_status_bg_color_failure normal
set -U tide_status_color '#a6d189'
set -U tide_status_color_failure '#e78284'
set -U tide_cmd_duration_bg_color normal
set -U tide_cmd_duration_color '#e5c890'
set -U tide_jobs_bg_color normal
set -U tide_jobs_color '#81c8be'
set -U tide_nvm_bg_color normal
set -U tide_nvm_color '#ca9ee6'
set -U tide_nvm_icon '󰎙'
set -U tide_python_bg_color normal
set -U tide_python_color '#85c1dc'
set -U tide_time_bg_color normal
set -U tide_time_color '#949cbb'
set -U tide_character_color '#8caaee'
set -U tide_character_color_failure '#e78284'
