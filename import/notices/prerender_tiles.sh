# renders hot tiles
for t in `cat hot_tiles.txt`; do
  wget --no-verbose -O /dev/null --no-check-certificate \
    https://localhost/falschparker_tiles/$t.png 2>&1 \
    | grep -vE 'no certificate subject alternative name matches|requested host name'
  sleep 0.1
done
