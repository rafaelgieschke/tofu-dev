#!/bin/sh -xeu
self="$(dirname -- "$(realpath -- "$0")")"

dir="$self"

for providerPath in "$dir/terraform-provider-"*; do (
    cd -- "$providerPath"
    go build
); done

providers=""
for providerPath in "$dir/terraform-provider-"*; do
    providers="$providers
        \"${providerPath##*/terraform-provider-}\" = \"$(dirname -- "$providerPath")\"
    "
done

# export TF_LOG=DEBUG
TF_CLI_CONFIG_FILE=/dev/fd/3 exec tofu "$@" 3<<EOF
provider_installation {
    dev_overrides {
        $providers
    }
    direct {}
}
EOF
