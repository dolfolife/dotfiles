# Workstation Configuration
Simple bash scripts for my terminal

# Install

```
Warning: If you want to give these scripts a try, you should first fork this
repository, review the code, and remove things you don’t want or need. Don’t
blindly use my settings unless you know what that entails. Use at your own
risk!
```

- open **Terminal**, load your SSH key and run
  ```
  sudo xcodebuild -license  # follow the interactive prompts
  mkdir -p ~/workspace
  cd ~/workspace
  git clone https://github.com/rodolfo2488/dotfiles
  cd dotfiles
  ./install.sh
  ```

- If you encounter problems with the script, fix them and re-run!

To load iTerm preferences, point to this directory under `iTerm2` >
`Preferences` > `Load preferences from a custom folder or URL`.

## patterns and assumptions
- keep it simple
- declarative and idempotent
- install as much as possible via brew
- ruby version will be `2.4.2`
- [luan vim](https://github.com/luan/nvim) and [luan
  tmux](https://github.com/luan/tmuxfiles)

# Sensible macOS defaults
When setting up a new Mac, you may want to set some sensible macOS defaults:

```
./.macos
```
