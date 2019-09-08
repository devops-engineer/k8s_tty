# k8s_tty
Get a tty of a k8s container

## Description
Have you tired of copy pasting k8s pod and container names and looking for a tool that help to avoid this copy & pasting? then this tool is for you.

### Installation

#### One time - clone:
git clone https://github.com/devops-engineer/k8s_tty.git
ls $(PWD)/k8s_tty/gettty.bash | pbcopy

#### Update update ~/.bashrc or ~/.bash_profile or ~/.profile

Add below line to ~/.bashrc or ~/.bash_profile or ~/.profile
``` source $(PWD)/k8s_tty/gettty.bash ```

### How to use it?

1. Open your terminal application
2. type command: `gettty`

That is!!

### Note:
Would you like to add a feature to it? Please send a PR.