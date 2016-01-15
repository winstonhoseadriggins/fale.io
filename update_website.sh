#!/bin/bash
cd ~/git/fale.io
rm -rf public
git pull
~/go/bin/hugo
rm -rf ~/public_html/fale.io
cp -r ~/git/fale.io/public ~/public_html/fale.io
