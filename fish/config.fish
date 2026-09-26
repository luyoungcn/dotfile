# Fish interactive configuration.
# Function and environment modules live in conf.d/ so they can be managed
# independently from Fisher's generated files.

# Prompt: Starship owns the prompt. Initialize it only for interactive shells;
# a missing binary leaves Fish with its default prompt instead of failing.
if status is-interactive; and type -q starship
    starship init fish | source
end

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init2.fish 2>/dev/null || :
