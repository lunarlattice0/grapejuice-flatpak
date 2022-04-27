import signal
import subprocess
import sys

import click

from grapejuice_common.ipc.pid_file import PIDFile, daemon_pid_file


@click.group()
def cli():
    ...


def _spawn(pid_file: PIDFile):
    from grapejuiced.state import State
    state = State()

    def on_sigint(*_) -> None:
        print("> Responding to SIGINT, stopping...")
        state.stop()

    signal.signal(signal.SIGINT, on_sigint)

    print("> Spawning a new daemon")
    pid_file.write_pid()
    state.start_service()
    state.start()


@cli.command()
def kill():
    print("> You swing your sword...")

    pid_file = daemon_pid_file()
    if pid_file.is_running():
        print(f"> Killed daemon with pid {pid_file.pid} in one sweeping blow.")
        pid_file.kill()

    else:
        print("> You swing at the air, because there is no daemon. You take 20 damage as you hit your leg.")


@cli.command()
@click.option("-k", "--kill", "do_kill", is_flag=True, required=False, default=False)
def daemonize(do_kill: bool):
    if do_kill:
        subprocess.check_call([
            sys.executable, "-m", "grapejuiced", "kill"
        ])

    pid_file = daemon_pid_file()

    if pid_file.is_running():
        print("> Another daemon is already running, quitting...")
        return

    _spawn(pid_file)


def main():
    cli()


def easy_install_main():
    main()


def module_invocation_main():
    main()


if __name__ == '__main__':
    main()
