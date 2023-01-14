#!/usr/bin/env python3

import argparse
import os
import subprocess as sp
import sys
from typing import Any

DEVSHELL_NAME = os.environ["DEVSHELL_NAME"]
DEVSHELL_DOCS_DIR = os.environ["DEVSHELL_DOCS_DIR"]
DEVSHELL_QUICKSTART = os.environ["DEVSHELL_QUICKSTART"]
DEVSHELL_EXTENSIONS = os.environ["DEVSHELL_EXTENSIONS"]


with open(DEVSHELL_EXTENSIONS) as cfile:
    provided = cfile.read().strip()
    DEVSHELL_EXTENSIONS_HELP = "" if not provided else f"""List of Extension Commands:
===========================

{provided}

These extension commands can be executed as:

devsh exec <command>
"""


def main() -> None:
    parser = argparse.ArgumentParser(
        description="devshell",
        epilog=DEVSHELL_EXTENSIONS_HELP,
        formatter_class=argparse.RawTextHelpFormatter,
    )

    subparsers = parser.add_subparsers()

    subparser = subparsers.add_parser("banner", help="Print banner")
    subparser.set_defaults(func=do_banner)

    subparser = subparsers.add_parser("quickstart", help="Print quickstart guide")
    subparser.set_defaults(func=do_quickstart)

    subparser = subparsers.add_parser("welcome", help="Print welcome notice")
    subparser.set_defaults(func=do_welcome)

    subparser = subparsers.add_parser("guide", help="Open developer's guide")
    subparser.set_defaults(func=do_guide)

    subparser = subparsers.add_parser("exec", help="Execute an extension command")
    subparser.add_argument(
        "args",
        nargs=argparse.REMAINDER,
        help="Arguments to pass to the extension command",
    )
    subparser.set_defaults(func=do_exec)

    args = parser.parse_args(args=None if sys.argv[1:] else ["--help"])
    args.func(args)


def do_banner(_args: Any) -> None:
    ps = sp.Popen(("figlet", "-c", "-t", DEVSHELL_NAME), stdout=sp.PIPE)
    sp.run(("lolcat", "-S", "20", "-p", "1", "-F", "0.02"), stdin=ps.stdout, check=True)
    ps.wait()


def do_quickstart(_args: Any) -> None:
    sp.run(("rich", DEVSHELL_QUICKSTART), check=True)


def do_welcome(args: Any) -> None:
    do_banner(args)
    do_quickstart(args)


def do_guide(_args: Any) -> None:
    sp.run(("xdg-open", f"{DEVSHELL_DOCS_DIR}/guide/html/index.html"), check=True)


def do_exec(args: Any) -> None:
    if not args.args:
        sys.stdout.write(DEVSHELL_EXTENSIONS_HELP)
        return

    args.args[0] = f"devsh-extension-{args.args[0]}"

    sp.run(args.args, check=True, stdin=sys.stdin)


if __name__ == "__main__":
    main()
