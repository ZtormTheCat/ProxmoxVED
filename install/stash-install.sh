#!/usr/bin/env bash

# Copyright (c) 2021-2026 community-scripts ORG
# Author: ZtormTheCat
# License: MIT | https://github.com/community-scripts/ProxmoxVED/raw/main/LICENSE
# Source: https://stashapp.cc/

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt install -y ffmpeg
msg_ok "Installed Dependencies"

fetch_and_deploy_gh_release "stash" "stashapp/stash" "singlefile" "latest" "/opt/stash" "stash-linux"

msg_info "Creating Service"
# HOME keeps Stash's config/database/generated files in /opt/stash/.stash
# (its documented default of ~/.stash) instead of /root, where the release
# version file ~/.stash already exists.
cat <<EOF >/etc/systemd/system/stash.service
[Unit]
Description=Stash Media Organizer
After=network.target

[Service]
Type=simple
User=root
Environment=HOME=/opt/stash
WorkingDirectory=/opt/stash
ExecStart=/opt/stash/stash --nobrowser
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now stash
msg_ok "Created Service"

motd_ssh
customize
cleanup_lxc
