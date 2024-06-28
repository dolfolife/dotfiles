# Dotfiles

This is a group of scripts I use to maintain order and consistency across the environments I use code.

## Usage

```bash
git clone https://github.com/dolfolife/dotfiles.git ~/dotfiles
cd ~/dotfiles
make help
```

## Architecture

There are options for MacOS, Ubuntu (WSL), Windows Powershell, and Cygwin.
The install scripts should run the right set of scripts based on the `$OSTYPE` environment variable.


## Modes
There are a set of extra information depending on the workstation I use.
For example, I add 1password and the personal GPG key in personal computers.
For this, I separated the levels of install you can work and add your own wrapper.

```bash
make install DOMAIN=<company.domain> 
```
> Note: make sure `company.domain` folder is at the root of your dotfiles

