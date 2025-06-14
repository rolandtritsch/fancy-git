#!/bin/bash
#
# Author: Diogo Alexsander Cavilha <diogocavilha@gmail.com>
# Date:   06.08.2018

# ----------------------------------------------------------------------------------------------------------------------
# The main function to change the prompt.
# ----------------------------------------------------------------------------------------------------------------------
fancygit_theme_builder() {
    check_for_update

    # !! IMPORTANT !!
    # If you're just interested on creating a new color scheme, please have a look at $HOME/.fancy-git/color_schemes.
    # Everything you need to do is creating a new file to the color scheme you wish to create.
    local color_scheme
    color_scheme=$(fancygit_config_get "color_scheme" "roland_roland")

    # Load the color scheme.
    # shellcheck source=/dev/null
    . "${HOME}/.fancy-git/color_schemes/${color_scheme}"

    # !! WARNING !!
    # From here you better now what you're doing. Have fun =D

    # Create color tags to change prompt style.
    local time_color_tag="\\[\\e[38;5;${FANCYGIT_COLOR_SCHEME_TIME_FOREGROUND}m\\]"
    local time_color_bg_tag="\\[\\e[48;5;${FANCYGIT_COLOR_SCHEME_TIME_BACKGROUND}m\\]"
    local time_symbol_color_tag="\\[\\e[38;5;${FANCYGIT_COLOR_SCHEME_TIME_BACKGROUND}m\\]"
    local user_color_font_tag="\\[\\e[38;5;${FANCYGIT_COLOR_SCHEME_USER_FOREGROUND}m\\]"
    local host_color_font_tag="\\[\\e[38;5;${FANCYGIT_COLOR_SCHEME_HOST_FOREGROUND}m\\]"
    local at_color_font_tag="\\[\\e[38;5;${FANCYGIT_COLOR_SCHEME_AT_FOREGROUND}m\\]"
    local user_symbol_color_tag="\\[\\e[38;5;${FANCYGIT_COLOR_SCHEME_USER_SYMBOL_BACKGROUND}m\\]"
    local user_symbol_color_bg_tag="\\[\\e[48;5;${FANCYGIT_COLOR_SCHEME_USER_SYMBOL_BACKGROUND}m\\]"
    local user_symbol_color_font_tag="\\[\\e[38;5;${FANCYGIT_COLOR_SCHEME_USER_SYMBOL_FOREGROUND}m\\]"
    local workdir_color_tag="\\[\\e[38;5;${FANCYGIT_COLOR_SCHEME_WORKDIR_BACKGROUND}m\\]"
    local workdir_color_bg_tag="\\[\\e[48;5;${FANCYGIT_COLOR_SCHEME_WORKDIR_BACKGROUND}m\\]"
    local workdir_color_font_tag="\\[\\e[38;5;${FANCYGIT_COLOR_SCHEME_WORKDIR_FOREGROUND}m\\]"
    local user_at_host_color_tag="\\[\\e[38;5;${FANCYGIT_COLOR_SCHEME_USER_AT_HOST_BACKGROUND}m\\]"
    local user_at_host_color_bg_tag="\\[\\e[48;5;${FANCYGIT_COLOR_SCHEME_USER_AT_HOST_BACKGROUND}m\\]"
    local branch_color_staged_files_tag="\\[\\e[38;5;${FANCYGIT_COLOR_SCHEME_BRANCH_STAGED_FILES_BACKGROUND}m\\]"
    local branch_color_staged_files_bg_tag="\\[\\e[48;5;${FANCYGIT_COLOR_SCHEME_BRANCH_STAGED_FILES_BACKGROUND}m\\]"
    local branch_color_staged_files_font_tag="\\[\\e[38;5;${FANCYGIT_COLOR_SCHEME_BRANCH_STAGED_FILES_FOREGROUND}m\\]"
    local branch_color_changed_files_tag="\\[\\e[38;5;${FANCYGIT_COLOR_SCHEME_BRANCH_CHANGED_FILES_BACKGROUND}m\\]"
    local branch_color_changed_files_bg_tag="\\[\\e[48;5;${FANCYGIT_COLOR_SCHEME_BRANCH_CHANGED_FILES_BACKGROUND}m\\]"
    local branch_color_changed_files_font_tag="\\[\\e[38;5;${FANCYGIT_COLOR_SCHEME_BRANCH_CHANGED_FILES_FOREGROUND}m\\]"
    local branch_color_tag="\\[\\e[38;5;${FANCYGIT_COLOR_SCHEME_BRANCH_BACKGROUND}m\\]"
    local branch_color_bg_tag="\\[\\e[48;5;${FANCYGIT_COLOR_SCHEME_BRANCH_BACKGROUND}m\\]"
    local branch_color_font_tag="\\[\\e[38;5;${FANCYGIT_COLOR_SCHEME_BRANCH_FOREROUND}m\\]"
    local none="\\[\\e[39m\\]"
    local clear="\\[\\e[0m\\]"
    local bg_none="\\[\\e[49m\\]"
    local bold_prompt=""
    local normal_prompt=""

    if fancygit_config_is "bold_prompt" "true"
    then
        clear=""
        bold_prompt="\\[\\e[1m\\]"
        normal_prompt="\\[\\e[0m\\]"
    fi

    # Prompt style
    local separator
    separator=$(fancygit_config_get "separator" "")

    local icon_git_repo="${FANCYGIT_ICON_GIT_REPO:-}"
    local user="${user_color_font_tag}"
    local at="${at_color_font_tag}"
    local host="${host_color_font_tag}"
    local user_at_host="${user_at_host_color_bg_tag}"
    local user_at_host_end="${user_at_host_color_tag}${user_symbol_color_bg_tag}${separator}"
    local user_symbol="${user_symbol_color_bg_tag}${user_symbol_color_font_tag}"
    local user_symbol_end="${none}${user_symbol_color_tag}${workdir_color_bg_tag}${separator}"
    local path="${workdir_color_bg_tag}${workdir_color_font_tag}"
    local path_git="${workdir_color_bg_tag}${workdir_color_font_tag} ${icon_git_repo} "
    local path_end="${none}"
    local branch="${workdir_color_tag}${branch_color_bg_tag}${separator}${branch_color_font_tag}"
    local branch_end="${branch_color_tag}${bg_none}${separator}${none}"
    local time="${time_color_bg_tag}${time_color_tag}"
    local time_end=""
    local prompt_time
    local prompt_user
    local prompt_env
    local prompt_path
    local prompt_git_branch
    local prompt_git_user
    local prompt_aws
    local prompt_double_line
    local notification_area
    local is_rich_notification
    local time_raw
    local user_name
    local host_name

    time_raw="$(fancygit_theme_get_time)"

    # When time background color and user background color are the same, we need to add a separator between time and username.
    # This prevents a weird presentation. Life is not easy :/
    if [[ "$FANCYGIT_COLOR_SCHEME_TIME_BACKGROUND" != "$FANCYGIT_COLOR_SCHEME_USER_AT_HOST_BACKGROUND" && "" != "$time_raw" ]]
    then
        time_end="${time_symbol_color_tag}${user_at_host_color_bg_tag}${separator} "
    fi

    user_name=$(fancygit_config_get "user_name" "\\u")

    host_name=$(fancygit_config_get "host_name" "\\h")

    prompt_identities="${time}($(aws_profile)) *$(git_user)* -$(python_venv)- ${time_end}"

    # Get some theme config.
    prompt_time="${time}${time_raw}${time_end}"
    prompt_path=$(fancygit_theme_get_path_sign)
    prompt_symbol="${user_symbol} \$ ${user_symbol_end}"
    prompt_double_line=$(fancygit_theme_get_double_line)

    if fancygit_config_is "show_user_at_machine" "true"
    then
        prompt_user="${user_at_host}${user}${user_name}${none}${at}@${none}${host}${host_name}${none} ${user_at_host_end}"
    fi

    if fancygit_config_is "show_host_prompt" "false"
    then
        prompt_user="${user_at_host}${user}${user_name}${none}${none} ${user_at_host_end}"
    fi

    branch_name=$(fancygit_git_get_branch)
    if [ "" = "$branch_name" ]
    then
        # No branch found, so we're not in a git repo.
        prompt_path="${path} ${prompt_path} ${path_end}${workdir_color_tag}${bg_none}${separator}${none}"
        PS1="${clear}${bold_prompt}${prompt_identities}${prompt_path}${clear}${normal_prompt}${prompt_double_line} "
        return
    fi

    if [ "HEAD" = "$branch_name" ]
    then
        branch_name=$(fancygit_git_get_tag)
    fi

    # We're in a git repo =D
    # We have a branch name, it means we are in a git repo, so we need to make some more changes on PS1...

    # Get some config preferences.
    is_rich_notification=$(fancygit_config_get "show_rich_notification" "true")

    # Configure a specific background color to branch name, if it has some change.
    if [ "" != "$(fancygit_git_get_status)" ]
    then
        branch="${workdir_color_tag}${branch_color_changed_files_bg_tag}${separator}${branch_color_changed_files_font_tag}"
        branch_end="${branch_color_changed_files_tag}${bg_none}${separator}${none}"
    fi

    # Configure a specific background color to branch name, if it has staged files.
    if [ "" != "$(fancygit_git_get_staged_files)" ]
    then
        branch="${workdir_color_tag}${branch_color_staged_files_bg_tag}${separator}${branch_color_staged_files_font_tag}"
        branch_end="${branch_color_staged_files_tag}${bg_none}${separator}${none}"
    fi

    notification_area=$(fancygit_get_notification_area "$is_rich_notification")
    prompt_path="${path_git}${notification_area}${path} ${prompt_path} ${path_end}"
    prompt_git_branch="${branch} $(fancygit_git_get_branch_icon "${branch_name}") ${branch_name} ${branch_end}"
    [ -f ./Pulumi.yaml ] && prompt_identities="${time}($(aws_profile)) *$(git_user)* -$(python_venv)- #$(pulumi_user)# ${time_end}"
    PS1="${clear}${bold_prompt}${prompt_identities}${prompt_path}${prompt_git_branch}${clear}${normal_prompt}${prompt_double_line} "
}

# Here's where the magic happens!
# It calls our main function (fancygit_theme_builder) in order to mount a beautiful PS1 prompt =D
PROMPT_COMMAND="fancygit_theme_builder"

function aws_profile {
  echo ${AWS_PROFILE:-${AWS_DEFAULT_PROFILE}}
}

function git_user {
  echo $(cat ~/.config/gh/hosts.yml | grep user\: | cut -d\: -f2 | xargs)
}

function pulumi_user {
  echo $(pulumi whoami)/$(pulumi stack ls | grep \* | cut -d\* -f1)
}

function python_venv {
  echo $(basename ${VIRTUAL_ENV:-none})
}
