#!/bin/bash

# Clean old runs
rm -rf public

# Create contents
hugo --config=config-it.yaml
hugo --config=config-en.yaml

# Put common contents in the root dir and delete copies
mv public/en/.htaccess public
mv public/en/css public
mv public/en/img public
rm -rf public/it/.htacces
rm -rf public/it/css
rm -rf public/it/img

# Move to public accessible location
sudo rm -rf /var/www/html
sudo cp -r ~/fabiolocati/public/ /var/www/html/
sudo chmod -R 755 /var/www/html
