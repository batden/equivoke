# equivoke

A set of bash scripts to build/install/update the Enlightenment environment on your system,

or to uninstall this ecosystem from Ubuntu.

Please refer to the script comments for hints and additional information.

> [!NOTE]
> It may be useful to keep a record of the pre-existing system status before proceeding with the installation.
>
> Check out our [backup script](https://gist.github.com/batden/993b5ee997b3df2c3b075907a1dff116).

## Getting started

Before using extol, you may need to install the git package on your system if it isn't already there.

Open a terminal window and type in the following:

```bash
sudo apt install git
```

Next, clone the repository with:

```bash
git clone https://github.com/batden/extol.git .extol
```

This creates a new hidden folder named .extol in your home directory.

Copy the extol.sh file from the new .extol folder to your download folder.

Navigate to the download folder and make the script executable:

```bash
chmod +x extol.sh
```

Then, execute the script:

```bash
./extol.sh
```

To run it again later, just open a terminal and type:

```bash
extol.sh
```

> [!TIP]
> Use auto-completion: Type _ext_ and press the Tab key.

That's it.

You can uninstall Enlightenment and related applications from your computer at any time.

See [expel.sh](https://github.com/batden/expel).

## In the picture

![GitHub Image](/images/enlightenment.jpg)

_Please help us continue to promote this fantastic desktop environment.
Over the years, writing bash scripts, translations, documentation, and bug reports has been a considerable effort._

[Donate with PayPal](https://www.paypal.com/donate/?hosted_button_id=QGXWYZWH5QP5E) :trophy:
