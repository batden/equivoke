# equivoke

A set of bash scripts to build/install/update the Enlightenment environment on your system,

or to uninstall this ecosystem from Ubuntu.

Please refer to the scripts comments for hints and additional information.

> [!NOTE]
> It may be useful to keep a record of the pre-existing system status before proceeding with the installation.
>
> Check out our [backup script](https://gist.github.com/batden/993b5ee997b3df2c3b075907a1dff116).

## Installation

Before using equivoke, you may need to install the git package on your system if it isn't already there.

Open a terminal window and type in the following:

```bash
sudo apt install git
```

Next, clone the repository with:

```bash
git clone https://github.com/batden/equivoke.git .equivoke
```

This creates a new hidden folder named .equivoke in your home directory.

Copy the konfig.sh and equivoke.sh files from the new .equivoke folder to your download folder.

Navigate to the download folder and make the two scripts executable:

```bash
chmod +x config.sh equivoke.sh
```

Then, execute the main script:

```bash
./equivoke.sh
```

To run it again later, just open a terminal and type:

```bash
equivoke.sh
```

> [!TIP]
> Use auto-completion: Type _equ_ and press the Tab key.

That's it.

## Uninstallation

You can uninstall Enlightenment and related applications from your computer at any time.

To do so, run the script again and select option 4 from the menu.

## In the Picture

![GitHub Image](/images/enlightenment.jpg)

_Please help us continue to promote this fantastic desktop environment.
Over the years, writing bash scripts, translations, documentation, and bug reports has been a considerable effort._

[Donate with PayPal](https://www.paypal.com/donate/?hosted_button_id=QGXWYZWH5QP5E) :trophy:
