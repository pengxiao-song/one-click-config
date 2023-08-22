set -Eeu
set -x  # debug mode

# Test connection
echo "Test Internet status..."
if [ $(curl -sI -w "%{http_code}\n" -o /dev/null www.google.com --connect-timeout 1) -ne 200 ]; then
    echo "Unable to connect to Google. Configure the proxy in env.sh"
    # 启动代理
    onproxy() {
        export http_proxy=http://114.212.87.152:7890
        export https_proxy=http://114.212.87.152:7890
        export all_proxy=socks5://114.212.87.152:7891
        echo "Proxy on"
    }
    onproxy
else
    echo "Connect Google successfully"
fi

# Config zsh and oh-my-zsh
if ! [ $(command -v zsh) ]; then
    echo "zsh not found. Installing zsh..."
    # install zsh
    sudo apt-get install zsh
    echo "zsh installed successfully"
else
    echo "zsh is already installed"
fi

OH_MY_ZSH_DIR=~/.oh-my-zsh
if ! [ -d $OH_MY_ZSH_DIR ]; then
    sh -c "$(curl -fsSL https://gitee.com/mirrors/oh-my-zsh/raw/master/tools/install.sh)"

    # move .zshrc
    cp ./zshrc ~/.zshrc

    # plugin
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

    # source
    source ~/.zshrc
    echo "oh-my-zsh installed successfully"
fi

# Install Anaconda from tsinghua source
if ! [ $(command -v conda) ]; then
    echo "Conda not found. Installing Conda..."

    # Get download path and download
    ANACONDA_FILE=$(
        curl -s 'https://mirrors.tuna.tsinghua.edu.cn/anaconda/archive/?C=M&O=D' |
            grep -i -oE 'Anaconda.*-Linux-x86_64.sh' |
            sed 's/.*\(Anaconda.*-Linux-x86_64.sh\).*/\1/g' |
            head -n 1
    )
    ANACONDA_DOWNLOAD_URL="https://mirrors.tuna.tsinghua.edu.cn/anaconda/archive/$ANACONDA_FILE"
    wget -U NoSuchBrowser/1.0 $ANACONDA_DOWNLOAD_URL

    # Install
    sh $ANACONDA_FILE

    # Remove temp .sh
    if [ $? -eq 0 ]; then
        echo "Conda installed successfully"
        rm $ANACONDA_FILE
    fi
else
    echo "Conda is already installed"
fi

# Install packages
packages="tmux tldr"
for package in $packages; do
    if ! [ $(command -v $package) ]; then
        sudo apt-get install $package
    else
        echo "$package is already installed"
    fi
done

# Configure ssh
SSH_DIR=~/.ssh
AUTHORIZED_KEYS_FILE="$SSH_DIR/authorized_keys"
if ! [ -f $AUTHORIZED_KEYS_FILE ]; then
    if ! [ -d $SSH_DIR ]; then
        mkdir $SSH_DIR
    else
        touch $AUTHORIZED_KEYS_FILE
    fi
fi
