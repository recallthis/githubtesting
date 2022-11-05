# https://unix.stackexchange.com/questions/116562/key-bindings-table


zle -N zle-copy-whole-line-using-xsel
zle-copy-whole-line-using-xsel() { zle vi-yank-whole-line ; _copy-using-xsel}

zle -N zle-copy-eol-using-xsel
zle-copy-eol-using-xsel() { zle vi-yank-eol; _copy-using-xsel}

bindkey -N my-backward-delete-char vicmd
bindkey -N my-delete-char vicmd
bindkey -N my-kill-line vicmd
bindkey -N my-delete-word vicmd
bindkey -N my-backward-delete-word vicmd
# 
# 
# zle -N zle-enter-delete-word
# zle-enter-delete-word() { zle -K my-delete-word }
# # 
# zle -N zle-enter-backward-delete-word
# zle-enter-backward-delete-word() { zle -K my-backward-delete-word }
zle -N zle-delete-char
zle-delete-char() { zle delete-char ; zle -K my-delete-char}
# 
zle -N zle-backward-delete-char
zle-backward-delete-char() { zle backward-delete-char ; zle -K my-backward-delete-char}
# 
zle -N zle-kill-line
zle-kill-line() { zle kill-line ; zle -K my-kill-line}
# 
zle -N zle-delete-word
zle-delete-word() { zle delete-word ; zle -K my-delete-word}
# 
zle -N zle-backward-change-word
zle-backward-change-word() { zle backward-delete-word ; zle -K viins }

zle -N zle-backward-change-blank-word
zle-backward-change-blank-word() { zle -K visual-mode ; zle vi-backward-blank-word ; vi-delete-char ; zle -K viins }

zle -N zle-backward-delete-word
zle-backward-delete-word() { zle backward-delete-word ; zle -K my-backward-delete-word }
# 
# zle -N zle-gocmd
# zle-gocmd() { zle -K vicmd }
# 
zle -N zle-goins
zle-goins() { zle -K viins }
# 
zle -N zle-O-goins
zle-o-goins() { zle goto_start_then_insert; zle -K viins }
# 
zle -N zle-a-goins
zle-a-goins() { zle vi-forward-char; zle -K viins }
 
bindkey -M my-backward-delete-char . vi-backward-delete-char
bindkey -M my-backward-delete-char qq zle-kill-line
bindkey -M my-backward-delete-char qw zle-delete-word
bindkey -M my-backward-delete-char qW zle-delete-word
bindkey -M my-backward-delete-char qe zle-delete-word
bindkey -M my-backward-delete-char qE zle-delete-word
bindkey -M my-backward-delete-char qm zle-backward-delete-word
bindkey -M my-backward-delete-char qM zle-backward-delete-word
bindkey -M my-backward-delete-char x zle-delete-char
bindkey -M my-backward-delete-char X backward-delete-char
bindkey -M my-backward-delete-char '^?' zle-backward-delete-char
bindkey -M my-backward-delete-char o zle-goins
bindkey -M my-backward-delete-char O zle-O-goins
bindkey -M my-backward-delete-char a zle-a-goins
bindkey -M my-backward-delete-char m vi-backward-word
bindkey -M my-backward-delete-char j vi-backward-char
bindkey -M my-backward-delete-char k vi-down-line-or-history
bindkey -M my-backward-delete-char i vi-up-line-or-history
bindkey -M my-backward-delete-char l vi-forward-char
 
bindkey -M my-delete-char . vi-delete-char
bindkey -M my-delete-char qq zle-kill-line
bindkey -M my-delete-char qw zle-delete-word
bindkey -M my-delete-char qW zle-delete-word
bindkey -M my-delete-char qe zle-delete-word
bindkey -M my-delete-char qE zle-delete-word
bindkey -M my-delete-char qm zle-backward-delete-word
bindkey -M my-delete-char qM zle-backward-delete-word
bindkey -M my-delete-char x delete-char
bindkey -M my-delete-char X zle-backward-delete-char
bindkey -M my-delete-char '^?' zle-backward-delete-char
bindkey -M my-delete-char o zle-goins
bindkey -M my-delete-char O zle-O-goins
bindkey -M my-delete-char a zle-a-goins
bindkey -M my-delete-char m vi-backward-word
bindkey -M my-delete-char j vi-backward-char
bindkey -M my-delete-char k vi-down-line-or-history
bindkey -M my-delete-char i vi-up-line-or-history
bindkey -M my-delete-char l vi-forward-char

bindkey -M my-kill-line . kill-line
bindkey -M my-kill-line qq kill-line
bindkey -M my-kill-line qw zle-delete-word
bindkey -M my-kill-line qW zle-delete-word
bindkey -M my-kill-line qe zle-delete-word
bindkey -M my-kill-line qE zle-delete-word
bindkey -M my-kill-line qm zle-backward-delete-word
bindkey -M my-kill-line qM zle-backward-delete-word
bindkey -M my-kill-line x zle-delete-char
bindkey -M my-kill-line X zle-backward-delete-char
bindkey -M my-kill-line '^?' zle-backward-delete-char
bindkey -M my-kill-line o zle-goins
bindkey -M my-kill-line O zle-O-goins
bindkey -M my-kill-line a zle-a-goins
bindkey -M my-kill-line m vi-backward-word
bindkey -M my-kill-line j vi-backward-char
bindkey -M my-kill-line k vi-down-line-or-history
bindkey -M my-kill-line i vi-up-line-or-history
bindkey -M my-kill-line l vi-forward-char

# # delete forward word keys
# bindkey -M my-delete-word w vi-forward-word
# bindkey -M my-delete-word W vi-forward-blank-word
# bindkey -M my-delete-word e vi-forward-word-end
# bindkey -M my-delete-word E vi-forward-blank-word-end
# bindkey -M my-delete-word m vi-backward-word
# bindkey -M my-delete-word M vi-backward-blank-word
# bindkey -M my-delete-word j vi-backward-char
# bindkey -M my-delete-word k vi-down-line-or-history
# bindkey -M my-delete-word i vi-up-line-or-history
# bindkey -M my-delete-word l vi-forward-char
# bindkey -M my-delete-word ^ vi-first-non-blank
# bindkey -M my-delete-word $ vi-end-of-line
bindkey -M my-delete-word . delete-word
bindkey -M my-delete-word qq zle-kill-line
bindkey -M my-delete-word qw delete-word
bindkey -M my-delete-word qW delete-word
bindkey -M my-delete-word qe delete-word
bindkey -M my-delete-word qE delete-word
bindkey -M my-delete-word qm zle-backward-delete-word
bindkey -M my-delete-word qM zle-backward-delete-word
bindkey -M my-delete-word x zle-delete-char
bindkey -M my-delete-word X zle-backward-delete-char
bindkey -M my-delete-word '^?' zle-backward-delete-char
bindkey -M my-delete-word v visual-mode
bindkey -M my-delete-word o zle-goins
bindkey -M my-delete-word O zle-O-goins
bindkey -M my-delete-word a zle-a-goins
bindkey -M my-delete-word m vi-backward-word
bindkey -M my-delete-word j vi-backward-char
bindkey -M my-delete-word k vi-down-line-or-history
bindkey -M my-delete-word i vi-up-line-or-history
bindkey -M my-delete-word l vi-forward-char
# bindkey -M my-delete-word '^[' zle-enter-delete-word
# 
# # delete backward word keys
# bindkey -M my-backward-delete-word w vi-forward-word
# bindkey -M my-backward-delete-word W vi-forward-blank-word
# bindkey -M my-backward-delete-word e vi-forward-word-end
# bindkey -M my-backward-delete-word E vi-forward-blank-word-end
# bindkey -M my-backward-delete-word m vi-backward-word
# bindkey -M my-backward-delete-word M vi-backward-blank-word
# bindkey -M my-backward-delete-word j vi-backward-char
# bindkey -M my-backward-delete-word k vi-down-line-or-history
# bindkey -M my-backward-delete-word i vi-up-line-or-history
# bindkey -M my-backward-delete-word l vi-forward-char
# bindkey -M my-backward-delete-word ^ vi-first-non-blank
# bindkey -M my-backward-delete-word $ vi-end-of-line
bindkey -M my-backward-delete-word . backward-delete-word
bindkey -M my-backward-delete-word qq zle-kill-line
bindkey -M my-backward-delete-word qw zle-delete-word
bindkey -M my-backward-delete-word qW zle-delete-word
bindkey -M my-backward-delete-word qe zle-delete-word
bindkey -M my-backward-delete-word qE zle-delete-word
bindkey -M my-backward-delete-word qm backward-delete-word
bindkey -M my-backward-delete-word qM backward-delete-word
bindkey -M my-backward-delete-word x zle-delete-char
bindkey -M my-backward-delete-word X zle-backward-delete-char
bindkey -M my-backward-delete-word '^?' zle-backward-delete-char
bindkey -M my-backward-delete-word v visual-mode
bindkey -M my-backward-delete-word o zle-goins
bindkey -M my-backward-delete-word O zle-O-goins
bindkey -M my-backward-delete-word a zle-a-goins
bindkey -M my-backward-delete-word m vi-backward-word
bindkey -M my-backward-delete-word j vi-backward-char
bindkey -M my-backward-delete-word k vi-down-line-or-history
bindkey -M my-backward-delete-word i vi-up-line-or-history
bindkey -M my-backward-delete-word l vi-forward-char
# bindkey -M my-backward-delete-word '^[' zle-enter-backward-delete-word

# vim command mode keys
bindkey -M vicmd o vi-insert
bindkey -M vicmd qw zle-delete-word
bindkey -M vicmd qW zle-delete-word
bindkey -M vicmd qc zle-backward-change-word
bindkey -M vicmd qC zle-backward-change-blank-word
bindkey -M vicmd qe zle-delete-word
bindkey -M vicmd qE zle-delete-word
bindkey -M vicmd qm zle-backward-delete-word
bindkey -M vicmd qM zle-backward-delete-word
bindkey -M vicmd q^ backward-kill-line
bindkey -M vicmd q0 backward-kill-line
bindkey -M vicmd q$ vi-kill-eol
bindkey -M vicmd x zle-delete-char
bindkey -M vicmd backspace zle-delete-char
bindkey -M vicmd X zle-backward-delete-char
bindkey -M vicmd "'" vi-repeat-find
bindkey -M vicmd , vi-rev-repeat-find
bindkey -M vicmd . vi-repeat-change
bindkey -M vicmd qq kill-whole-line
bindkey -M vicmd Q vi-kill-eol
bindkey -M vicmd b vi-find-prev-char
bindkey -M vicmd C vi-change-eol
bindkey -M vicmd p paste-xclip
bindkey -M vicmd '^v' paste-xclip
bindkey -M vicmd j vi-backward-char
bindkey -M vicmd k vi-down-line-or-history
bindkey -M vicmd i vi-up-line-or-history
bindkey -M vicmd l vi-forward-char
bindkey -M vicmd W vi-forward-blank-word
bindkey -M vicmd m vi-backward-word
bindkey -M vicmd M vi-backward-blank-word
bindkey -M vicmd K vi-up-line-or-history
bindkey -M vicmd I vi-down-line-or-history
bindkey -M vicmd '^?' vi-backward-delete-char
bindkey -M vicmd O goto_start_then_insert
bindkey -M vicmd Y zle-copy-eol-using-xsel
bindkey -M vicmd yy zle-copy-whole-line-using-xsel
bindkey -M vicmd -s yd "qqo pwd | xsel -i -b\n"
bindkey -M vicmd -s gbb "qqocd /data/mine/books\n^["
bindkey -M vicmd -s gbch "qqocd /data/mine/books/Coding/Haskell/\n^["
bindkey -M vicmd -s gbcc "qqocd /data/mine/books/Coding/Cprogramming/\n^["
bindkey -M vicmd -s ga "qqocd ~/.config/aliases\n^["
bindkey -M vicmd -s gc "qqocd ~/.config\n^["
bindkey -M vicmd -s gdd "qqocd /data/mine/dev\n^["
bindkey -M vicmd -s ge "qqocd ~/.config/emac/active/default\n^["
bindkey -M vicmd -s gdhh "qqocd /data/mine/dev/study/haskell/\n^["
bindkey -M vicmd -s gdhf "qqocd /data/mine/dev/study/haskell/foragreatgood/\n^["
bindkey -M vicmd -s gdhg "qqocd /data/mine/dev/study/haskell/getprogramming/\n^["
bindkey -M vicmd -s gdhl "qqocd /data/mine/dev/study/haskell/learnhaskell/\n^["
bindkey -M vicmd -s gdcc "qqocd /data/mine/dev/study/c/\n^["
bindkey -M vicmd -s gdcl "qqocd /data/mine/dev/study/c/theclanguage/\n^["
bindkey -M vicmd -s gf "qqocd ~/.config/lf\n^["
bindkey -M vicmd -s gh "qqocd ~/\n^["
bindkey -M vicmd -s gi "qqocd ~/.ihsec\n^["
bindkey -M vicmd -s gk "qqocd ~/.config/kmonad\n^["
bindkey -M vicmd -s gl "qqocd ~/.local/bin\n^["
bindkey -M vicmd -s gn "qqocd /data/mine/notes\n^["
bindkey -M vicmd -s go "qqocd /data/mine/sync/Org\n^["
bindkey -M vicmd -s gO "qqocd ~/mine/apps/tor-browser_en-US/Browser/Downloads/\n^["
bindkey -M vicmd -s gp "qqocd -\n^["
bindkey -M vicmd -s gqww "qqocd ~/.config/qutebrowser/web\n^["
bindkey -M vicmd -s gqwt "qqocd ~/.config/qutebrowser/web/tinfoil\n^["
bindkey -M vicmd -s gqtt "qqocd ~/.config/qutebrowser/tube\n^["
bindkey -M vicmd -s gs "qqocd /data/mine/src\n^["
bindkey -M vicmd -s gt "qqocd /data/mine/dev/test\n^["
bindkey -M vicmd -s gx "qqocd ~/.config/xmonad\n^["
bindkey -M vicmd -s gu "qqocd ~/.local/share/qutebrowser/userscripts\n^["
bindkey -M vicmd -s gzb "qqocd ~/.config/zsh/bindings\n^["
bindkey -M vicmd -s gzf "qqocd ~/.config/zsh/functions\n^["
bindkey -M vicmd -s '^E' "accept-line"
# bindkey -M vicmd -s h "qqocd \t"
bindkey -M vicmd -s h "qqofh\n"
#bindkey -M vicmd -s ' o' "qqo lfcd\n"
bindkey -M vicmd 'b' "runlfcd"
bindkey -M vicmd -s ' n' "qqonnncd\n^["
bindkey -M vicmd -s ' r' "qqoemre\n^["
bindkey -M vicmd -s ' gp' "qqogit add -u && git commit -m \"$$\" && git push origin main\n^["

bindkey -M vicmd '^[[B' "copymode"
bindkey -M vicmd '^[[A' "copymode"

#$terminfo[kcuu1] and $terminfo[kcud1] instead.

# vim visual mode keys
bindkey -M visual j vi-backward-char
bindkey -M visual '^[' deactivate-region
bindkey -M visual y _copy-region-using-xsel


# vim insert mode keys
bindkey -M viins "^?" backward-delete-char
bindkey -M viins '^[[B' "copymode"
bindkey -M viins '^[[A' "copymode"

# Use vim keys in tab complete menu:
bindkey -M menuselect 'j' vi-backward-char
bindkey -M menuselect 'i' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'k' vi-down-line-or-history
bindkey -M menuselect ' ' accept-line
# bindkey -v '^?' backward-delete-char
# bindkey -s jj '\e'
# bindkey -s kj '\e'
# bindkey -s jk '\e'
