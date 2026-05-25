#!/usr/bin/python3

import argparse
import os
import shutil
import re

from sys import platform
from pathlib import Path


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--root_dir", default=None,
                        help="Package root directory. Defaults to None (inferred from script location).")
    parser.add_argument("--data_dir", default=None,
                        help="Typst package install directory. Defaults to None (inferred from OS).")
    parser.add_argument("--namespace", default="local",
                        help="Package namespace. Defaults to 'local'.")
    parser.add_argument("--package_name", default=None,
                        help="Package name. Defaults to None (inferred from typst.toml).")
    parser.add_argument("--version", default=None,
                        help="Package version. Defaults to None (inferred from typst.toml).")

    parser.add_argument("--exclude", nargs='+', default=["*.pdf", "assets/samples", "examples", "scripts", "develop", "docs"],
                        help="Files and folders to be excluded.")
    parser.add_argument("--reinstall", action="store_true")
    return parser.parse_args()


def _is_root_dir(path):
    return os.path.isfile(os.path.join(path, "typst.toml"))


def main():
    args = parse_args()

    root_dir = args.root_dir if args.root_dir is not None else os.path.dirname(__file__)
    if not _is_root_dir(root_dir):
        root_dir = os.path.dirname(root_dir)
        if not _is_root_dir(root_dir):
            raise FileNotFoundError("Cannot find typst.toml, please specify --root_dir")
    with open(os.path.join(root_dir, "typst.toml"), 'r') as f:
        toml_content = '\n'.join(f.readlines())

    # data_dir
    if args.data_dir is not None:
        data_dir = args.data_dir
    elif platform == "linux" or platform == "linux2":
        data_dir = os.path.join(Path.home(), ".local/share")
    elif platform == "darwin":
        data_dir = os.path.join(Path.home(), "Library/Application Support")
    elif platform == "win32":
        data_dir = os.getenv("APPDATA")
    # namespace
    namespace = args.namespace
    if namespace.startswith('@'):  # remove @
        namespace = namespace[1:]
    # name
    if args.package_name is not None:
        package_name = args.package_name
    else:
        match = re.search(r'^\s*name\s*=\s*["\']([^"\']+)["\']', toml_content, re.MULTILINE)
        if match:
            package_name = match.group(1).strip()
        else:
            raise ValueError("Cannot infer package_name, please specify --package_name")
    # version
    if args.version is not None:
        version = args.version
    else:
        match = re.search(r'^\s*version\s*=\s*["\']([^"\']+)["\']', toml_content, re.MULTILINE)
        if match:
            version = match.group(1).strip()
        else:
            raise ValueError("Cannot infer version, please specify --version")

    install_dir = f"{data_dir}/typst/packages/{namespace}/{package_name}/{version}"
    if args.reinstall and os.path.exists(install_dir):
        shutil.rmtree(install_dir)
    print(f"Installing {package_name}:{version}")
    print(f"> source_dir  = {root_dir}")
    print(f"> install_dir = {install_dir}")
    try:
        shutil.copytree(
            root_dir, 
            install_dir, 
            ignore=shutil.ignore_patterns(".git", *args.exclude),
        )
        print(
f'''Success! You can import this package in Typst as follows:

#import "@{namespace}/{package_name}:{version}": *
''')
    except FileExistsError:
        raise FileExistsError("Package already exists. Rerun with --reinstall to force reinstall.")


if __name__ == "__main__":
    main()
