### START COMMON ###
import? 'common.just'

# Show these help docs
help:
    @just --list --unsorted --justfile {{ source_file() }}

# Pull latest common justfile recipes to local repo
[group("commons")]
sync-commons:
    curl -H 'Cache-Control: no-cache, no-store' \
        https://raw.githubusercontent.com/griceturrble/common-project-files/main/common.just > common.just
### END COMMON ###

# bootstrap the dev environment
bootstrap:
    just sync-commons
    just bootstrap-commons
