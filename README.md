# mdnotify

Watches a directory recursively and invokes the given command whenever a change is detected.

## Usage

```
mdnotify --help     
OVERVIEW: Watches a directory recursively.

Runs forever, or until mdnotify is terminated. Whenever a filesystem object is
changed at any level inside the watched directory tree, the given command is
invoked.

USAGE: mdnotify [--interval <interval>] <directory> [<command> ...]

ARGUMENTS:
  <directory>             The directory to watch.
  <command>               The command to execute. (default: echo <directory>)

OPTIONS:
  -i, --interval <interval>
                          The interval at which a change notification occurs in
                          seconds. (default: 1.0)
  -h, --help              Show help information.

```

## License

GNU General Public License v3.0 or later
