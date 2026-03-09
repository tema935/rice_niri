# цвета
cat ~/.cache/wal/sequences

alias sudo="doas"
alias reflector-update='doas reflector --country "RU,GE,BY,AZ" --latest 10 --sort rate --fastest 5 --save /etc/pacman.d/mirrorlist'
alias steam="wl-copy --clear; env DISPLAY=:0 /usr/bin/steam"
# Видео: только контент, без вшитых картинок
alias yt-dlp_va='yt-dlp --cookies-from-browser=firefox --embed-metadata -4 -f "bestvideo+bestaudio/best" --no-mtime --merge-output-format mp4'
# Аудио: чистый звук в m4a (лучшее качество без лишней перекодировки)
alias yt-dlp_a='yt-dlp --cookies-from-browser=firefox --embed-metadata -4 -f "bestaudio/best" --no-mtime --extract-audio --audio-format m4a'
alias yts='pipe-viewer'
# root iftop
alias iftop='doas iftop'
# poweroff
alias poweroff='systemctl poweroff'
# send2phone
alias send2phone='kdeconnect-cli --device 976c9f2853ad426a8300529bc2c96b74 --share'
alias cat='bat'
alias comm_back='tmux new-session -d'

# переменные
set -gx DISPLAY :0
set -x EDITOR nvim
stty -ixon

# Created by `pipx` on 2026-02-18 12:43:15
set PATH $PATH /home/tema/.local/bin

