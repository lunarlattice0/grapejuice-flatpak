import argparse
import logging
import os
import sys

from grapejuice_packaging.builders.debian_package_builder import DebianPackageBuilder
from grapejuice_packaging.builders.linux_package_builder import LinuxPackageBuilder
from grapejuice_packaging.builders.linux_supplemental_builder import LinuxSupplementalPackageBuilder
from grapejuice_packaging.builders.pypi_package_builder import PyPiPackageBuilder

logging.basicConfig(stream=sys.stderr, level=logging.DEBUG)


def func_linux_package(args):
    build_dir = os.path.join(".", "build", "linux_package") if args.build_dir is None else args.build_dir
    dist_dir = os.path.join(".", "dist", "linux_package") if args.dist_dir is None else args.dist_dir

    builder = LinuxPackageBuilder(build_dir, dist_dir)

    builder.build()
    builder.dist()


def func_debian_package(args):
    build_dir = os.path.join(".", "build", "debian_package") if args.build_dir is None else args.build_dir
    dist_dir = os.path.join(".", "dist", "debian_package") if args.dist_dir is None else args.dist_dir

    builder = DebianPackageBuilder(build_dir, dist_dir)

    builder.build()
    builder.dist()


def func_supplemental_package(args):
    build_dir = os.path.join(".", "build", "supplemental_package") if args.build_dir is None else args.build_dir
    dist_dir = os.path.join(".", "dist", "supplemental_package") if args.dist_dir is None else args.dist_dir

    builder = LinuxSupplementalPackageBuilder(build_dir, dist_dir)

    builder.build()
    builder.dist()


def func_pypi_package(_args):
    builder = PyPiPackageBuilder("build", "dist")
    builder.build()
    builder.dist()


def main(in_args=None):
    if in_args is None:
        in_args = sys.argv

    parser = argparse.ArgumentParser(prog="grapejuice", description="Manage Roblox on Linux")
    subparsers = parser.add_subparsers(title="subcommands", help="sub-command help")

    parser_linux_package = subparsers.add_parser("linux_package")
    parser_linux_package.add_argument("--build-dir", required=False)
    parser_linux_package.add_argument("--dist-dir", required=False)
    parser_linux_package.set_defaults(func=func_linux_package)

    parser_debian_package = subparsers.add_parser("debian_package")
    parser_debian_package.add_argument("--build-dir", required=False)
    parser_debian_package.add_argument("--dist-dir", required=False)
    parser_debian_package.set_defaults(func=func_debian_package)

    parser_supplemental_package = subparsers.add_parser("supplemental_package")
    parser_supplemental_package.add_argument("--build-dir", required=False)
    parser_supplemental_package.add_argument("--dist-dir", required=False)
    parser_supplemental_package.set_defaults(func=func_supplemental_package)

    parser_pypi_package = subparsers.add_parser("pypi_package")
    parser_pypi_package.set_defaults(func=func_pypi_package)

    args = parser.parse_args(in_args[1:])

    if hasattr(args, "func"):
        f: callable = getattr(args, "func")
        return f(args) or 0

    else:
        parser.print_help()

    return 1


if __name__ == '__main__':
    sys.exit(main())
