# JM installer

These scripts install or remove the `jm` command machine-wide on Windows, or for the current user on macOS and Linux. Windows installs to `C:\Program Files\main\jm`, changes the system `JM_HOME` and `Path` environment variables, and requests administrator access. macOS and Linux installation uses the current user's shell profile. JDK 11 or newer (including `javac`, `jar`, and `java`) must already be available on `PATH`.

## Windows

Double-click `install.cmd`, or run `install.ps1` from PowerShell. Approve the administrator prompt. Open a new terminal after installation, then run:

```text
jm init
jm migrate volunteer_db
jm run volunteer.war
```

Run `uninstall.cmd` or `uninstall.ps1` to remove the machine-wide launcher, environment variables, and PATH entry. The repository-local `jm.cmd` remains available inside its checkout.

## macOS and Linux

From the repository root, run `sh tools/installer/install.sh`. Open a new terminal so `~/.local/bin` is loaded from the shell profile, then run the same three commands above. Run `sh tools/installer/uninstall.sh` to remove the user launcher and PATH entries.

`jm init` downloads Maven and Tomcat into the project `.jm/tools` directory when they are not already available. `jm run` checks MySQL before building and starts a stopped local service when supported: Windows services, Homebrew services on macOS, and systemd on Linux. Linux may prompt for administrator credentials. Install MySQL 8 and its client separately.
