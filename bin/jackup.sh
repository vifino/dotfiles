sudo service timidity-jack restart
sudo service mpd restart
killall mt32emu-qt &>
sudo service timidity-jack restart
sudo service mpd restart
killall mt32emu-qt > /dev/null 2>&1 || true
nohup mt32emu-qt > /dev/null 2>&1 &
