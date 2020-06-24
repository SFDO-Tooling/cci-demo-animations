CumulusCI Animations
====================

You will need to:

brew install pv
brew install asciinema
brew install figlet
brew install moreutils # for sponge

also: VIM, git, cci in path

Use "tput cols" and "tput lines" to validate the width and height of your 
terminal is 90 and 26.

 so the whole cumulusci.yml is visible.
Also the tallest banner needs about that much space.

/utility/record-animation.sh runs outside of the asciinema
/utility/animation/animation.sh runs inside of it.

All files in /utility/animation/ are made available to the script as "../foo.xyz"

/utility/animation/animation.sh is run from a copy in that directory because shells
are finicky about scripts being edited while they are being run.

This repo has the template files:

https://github.com/prescod/CCI-Food-Bank.git

It is downloaded for each run.
