# Deployment Automation
## Goal:
Provide automation scripts for:
- Making dev environment setup straightforward for new team members
- Making deployment to machines (including subs) more automated
- Ensuring that the software on the bot can survive critical hardware failures
  without requiring a stage-1 install to get back to performance.


## Usage Instructions - Dev Environment Setup
1. Install Ubuntu 16.04 on system of choice using methods suggested below
   1. Windows 10: It's an app, see [Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/install-win10 "Windows Subsystem for Linux install guide")
      > Just be sure to choose the 'Ubuntu 16.04' App, the 'Ubuntu' one won't work.
   1. Mac/Win/Linux:
      1. Install Virtual Machine system
         > Oracle's [VirtualBox](https://www.virtualbox.org/ "VirtualBox Homepage") is a good option, and what's referenced here.
      
      1. Download Ubuntu 16.04 ISO:
         * [(64-bit) Server](http://releases.ubuntu.com/xenial/ubuntu-16.04.5-server-amd64.iso) - lighter-weight doesn't have GUI by default, essentially min-config starting point
         * [(64-bit) Desktop](http://releases.ubuntu.com/xenial/ubuntu-16.04.5-desktop-amd64.iso) - general-purpose workstation build. Full GUI.
         * [Other options](http://releases.ubuntu.com/xenial/) - if you need 32-bit (i386 builds) or want other download options (torrent, etc.), or if the links above are broken due to unforseen version number changes.   
     
      1. Follow [manual](https://www.virtualbox.org/manual/UserManual.html#intro-starting) - yes, it's the whole manual in html. DON'T PANIC! this links to the basic instructions to start up VirtualBox and Create/Run your first VM.
1. Get to a terminal in Ubuntu 16.04 system.
   1. WSL/Server Users: This is the only interface you get out of the box. Congrats, you're there!
   1. Desktop Users: Apps > Terminal will open the terminal for you.
1. Clone in this repo: `git clone https://github.com/ksu-auv-team/deploy.git`
   > This should come standard in most installs, after all it's [Linus' baby](https://www.youtube.com/watch?v=4XpnKHJAok8 "Yes, it's dated, but there's some fun irony in this vid").
   > If you get a git not found, `sudo apt-get install git` will fix that for you.
1. Run install.sh
   ```shell
   deploy/install.sh 2>&1 | tee install.log
   ```
   > This command, broken down: 
   > - `deploy/install.sh` - run this script.
   > - `2>&1` - write stderr to stdout (merges all output text into a single output stream, it's a linux thing)
   > - `|` - pipe, take output left of me and give it to what comes next
   > - `tee install.log` - take the incoming text, and print it to both terminal and a file, install.log - If you have issues installing, this can be shared so we can assist with what broke.
1. PROFIT!!
   > There are some useful things here. The [tmux cheat sheet](https://tmuxcheatsheet.com/) is a good start, but the tmux.conf made in the script has a few usibility tweaks:
   > mouse mode is ON by default, so clicking will choose panes, and scrolling will look back in buffer history.
  
   | keys | action |
   | --- | --- |
   | `ctl-b -` | horizontal split |
   | `ctl-b \|` | vertical split |
   | `ctl-b ctl-b` | swap last window |
   | `ctl-b L` | start logging the active pane |
   | `ctl-b l` | stop logging the active pane |
  
> Note:
> I've noticed that the pip install run can be flaky. If you get a message in
> the log complaining that pip can't find __main__, just re-run it after install (while in the deploy dir):
> ```bash
> pip install --user -r requirements.txt
> ```
>
> Likewise, if you attempt to run roscore (or anything ros related) and you're seeing
> 'not found' errors, run `source /opt/ros/kinetic/setup.bash` for some reason,
> the .bashrc is being flaky.

## TODO:
 - System integration scripts (daemonizing ROS, auto-patching, symver for the control software)
 - Prod environment optimization and image trimming.
 - Auto-packaging of the control system as a single functional unit (using rospack).

