#!/usr/bin/env python3

import argparse
import os
import subprocess as sp
import sys
from typing import Any

DEVSHELL_NAME = os.environ["DEVSHELL_NAME"]
DEVSHELL_DOCS_DIR = os.environ["DEVSHELL_DOCS_DIR"]
DEVSHELL_QUICKSTART = os.environ["DEVSHELL_QUICKSTART"]


def main() -> None:
    parser = argparse.ArgumentParser(description="devshell")

    subparsers = parser.add_subparsers()

    parser_open = subparsers.add_parser("banner", help="Print banner")
    parser_open.set_defaults(func=do_banner)

    parser_open = subparsers.add_parser("quickstart", help="Print quickstart guide")
    parser_open.set_defaults(func=do_quickstart)

    parser_open = subparsers.add_parser("welcome", help="Print welcome notice")
    parser_open.set_defaults(func=do_welcome)

    parser_open = subparsers.add_parser("guide", help="Open developer's guide")
    parser_open.set_defaults(func=do_guide)

    args = parser.parse_args(args=None if sys.argv[1:] else ["--help"])
    args.func(args)


def do_banner(args: Any) -> None:
    ps = sp.Popen(("figlet", "-c", "-t", DEVSHELL_NAME), stdout=sp.PIPE)
    sp.run(("lolcat", "-S", "20", "-p", "1", "-F", "0.02"), stdin=ps.stdout, check=True)
    ps.wait()


def do_quickstart(args: Any) -> None:
    sp.run(("rich", DEVSHELL_QUICKSTART), check=True)


def do_welcome(args: Any) -> None:
    do_banner(args)
    do_quickstart(args)


def do_guide(args: Any) -> None:
    sp.run(("xdg-open", f"{DEVSHELL_DOCS_DIR}/book/html/index.html"), check=True)


if __name__ == "__main__":
    main()
