echo Fetch/update neobundle.vim
rm -rf ~/.vim/bundle/neobundle.vim
wget -q https://codeload.github.com/Shougo/neobundle.vim/tar.gz/master
mkdir -p ~/.vim/bundle/
tar xf master
mv neobundle.vim-master ~/.vim/bundle/neobundle.vim
rm master
echo Done
