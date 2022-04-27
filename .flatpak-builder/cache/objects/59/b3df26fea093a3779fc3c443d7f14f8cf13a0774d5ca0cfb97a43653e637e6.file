import sys


# This module is invoked when `python3 -m grapejuice` is run in the shell
# For now this is a shim so the debian package /bin/* entry points don't have to be overcomplicated

def main():
    real_main = None

    if len(sys.argv) > 1:
        subcommand = sys.argv[1]

        if subcommand == "gui":
            from grapejuice.cli.gui import module_invocation_main

            # Remove the gui subcommand from argv as it is not a valid subcommand for
            # the cli/gui main
            sys.argv = [
                sys.argv[0],
                *sys.argv[2:]
            ]

            def real_main():
                module_invocation_main()

    if real_main is None:
        from grapejuice.cli.main import module_invocation_main

        def real_main():
            module_invocation_main()

    real_main()


if __name__ == "__main__":
    main()
