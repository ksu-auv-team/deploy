#! /bin/bash

echo "First: some OS basics. . ."
sudo apt-get update -y &&\
 sudo apt-get install -y build-essential python2.7 python-dev python-pip python-opencv\
 curl git catkin tmux htop psmisc vim vim-youcompleteme vim-pathogen;

pip install --upgrade pip
pip install numpy pymavlink

echo "Next: Movidius SDK"
cd /opt && \
  git clone -b ncsdk2 http://github.com/Movidius/ncsdk && cd ncsdk && make install

echo "Next: ROS Kinetic Core Install"
sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu xenial main" > /etc/apt/sources.list.d/ros-latest.list' && \
  wget --quiet https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -O - | sudo apt-key add - && \
  sudo apt-get update && \
  sudo apt-get -y install ros-kinetic-ros-core && \
  sudo rosdep init && \
  rosdep update
echo "ROS Environment setup"
mkdir -p ~/catkin_ws/src && \
  cd ~/catkin_ws/ && \
  catkin_make && \
  cat >> ~/.bashrc <<-EOF
export EDITOR='vim'
if [ -f /opt/ros/kinetic/setup.bash ]; then
  . /opt/ros/kinetic/setup.bash
fi
if [ -f ~/catkin_ws/devel/setup.bash ]; then
  . ~/catkin_ws/devel/setup.bash
fi
EOF

echo "Additional ROS Packages"
sudo apt-get -y install ros-kinetic-mavlink ros-kinetic-mavros ros-kinetic-mavros-msgs \
  ros-kinetic-cmake-modules ros-kinetic-control-toolbox  ros-kinetic-joy ros-kinetic-smach

echo "AUV software"
sudo mkdir -p /opt/auv && \
cd /opt/auv && \
sudo chown $USER:$USER /opt/auv && \
git clone -b refactor-tyler https://github.com/ksu-auv-team/subdriver2018.git
git clone https://github.com/ksu-auv-team/movement_package.git

echo "Experience hacks:"
# These are using here-docs to populate so that individuals may add in any tweaks for personal prefs at load time.

# A sensible,standard vim config (~/.vimrc)
# features: (80-char line bars, 2-space tabbing, trailing whitespace/EoL characters,
# file navigation tab-completion menuing, auto-loading of pathogen pligins,
# workspace-specific .vimlocal loading, utf-8 support, and ruler with relative line numbers)
cat > ~/.vimrc << EOF
silent! so .vimlocal
scriptencoding utf-8
set encoding=utf-8
execute pathogen#infect()
syntax on
set ts=2 sts=2 et
filetype plugin indent on
set confirm
set wildmenu
set ignorecase
set smartcase
set number
set ruler
set rnu
set listchars=eol:¬,trail:˽
set list
if exists('+colorcolumn')
  set colorcolumn=80
else
  au BufWinEnter * let w:m2=matchadd('ErrorMsg', '\%>80v.\+', -1)
endif
color torte
EOF
# A sensible tmux.conf with some more sensible keybinding for screen-splitting, etc.
cat > ~/.tmux.conf << EOF

# Wipe out keys
  unbind-key %
  unbind-key l
  unbind-key C-b
  unbind-key '"'
  unbind-key 0
  unbind-key 1
  unbind-key 2
  unbind-key 3
  unbind-key 4
  unbind-key 5
  unbind-key 6
  unbind-key 7
  unbind-key 8
  unbind-key 9
  # need two ;;'s to unbind ;
  unbind-key ;;
  unbind-key f
  unbind-key C-o
  unbind-key C-Left
  unbind-key C-Right
  unbind-key C-Up
  unbind-key C-Down
  unbind-key M-Left
  unbind-key M-Right
  unbind-key M-Up
  unbind-key M-Down
  unbind-key Up
  unbind-key Down
  unbind-key Left
  unbind-key Right

# Movement
  # C-arrow key is much easier than M-, so move by 5 here.
  bind -r C-Left resize-pane -L 5
  bind -r C-Right resize-pane -R 5
  bind -r C-Up resize-pane -U 5
  bind -r C-Down resize-pane -D 5

  # Put the fine tuning BS on the hard keys
  bind -r M-Left resize-pane -L
  bind -r M-Right resize-pane -R
  bind -r M-Up resize-pane -U
  bind -r M-Down resize-pane -D

  # No more delay before using arrow keys when moving between panes.
  bind-key Up select-pane -U
  bind-key Down select-pane -D
  bind-key Left select-pane -L
  bind-key Right select-pane -R

# Quick defaults
  set-window-option -g utf8 on
  set-window-option -g mode-keys vi
  set-option -g history-limit 20000
# Gotta have C-b C-b swap between recent windows
  bind-key C-b last-window
# Vert & horiz pane splitting needs to make sense:
  unbind %
  bind | split-window -h
  bind - split-window -v
# Just the colors for the borders
  set-option -g pane-active-border-fg '#0000ff'
  set-option -g pane-border-fg '#00005f'
# Status bar
  set-option -g status-bg '#00ff00'
  set-option -g status-fg '#000000'
  set-option -g message-bg '#ffffff'
  set-option -g message-fg '#000000'
  set-option -g message-attr bold
# Monitors / Alerts and their colors
  setw -g monitor-activity on
  set -g visual-activity on
# Mouse support
  set-option -g mouse on
# Easy config reload
  bind R source-file ~/.tmux.conf \; display-message "Configuration reloaded..."
# Buffer-works
  bind y run-shell "tmux show-buffer | xclip -in -selection clipboard"
# Logging
  bind L pipe-pane -o 'cat >>$HOME/#W-tmux.log' \; display-message 'Started logging to $HOME/#W-tmux.log'
  bind l pipe-pane \; display-message 'Ended logging to $HOME/#W-tmux.log'
EOF
