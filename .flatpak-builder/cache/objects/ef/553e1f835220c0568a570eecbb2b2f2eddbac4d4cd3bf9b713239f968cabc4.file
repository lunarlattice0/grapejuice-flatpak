import json
import threading
import time

import magic
import tools.build as build
from flask import Flask, Response, abort
from watchdog.observers import Observer

app = Flask("grapejuice-docs")


class State:
    building = True
    files_changed = True
    do_refresh = False


def process_html(s: str):
    return s.replace(
        "</body>",
        """<script>

    setInterval(async () => {
        try {
            const response = await fetch('/_api/do_refresh');
            const response_body = await response.json();

            if (!!response_body.data) {
                window.location.reload();
            }
        } catch (e) {
            console.error(e);
        }
    }, 500);

    </script></body>""",
    )


@app.route("/")
def index():
    with (build.build() / "index.html").open("r") as fp:
        return process_html(fp.read())


@app.route("/_api/do_refresh")
def do_refresh():
    s = json.dumps({"data": State.do_refresh})
    State.do_refresh = False
    return s


@app.route("/<path:resource_path>")
def resolve_resource(resource_path):
    requested_file = build.build() / resource_path

    if requested_file.is_dir() and (requested_file / "index.html").is_file():
        requested_file = requested_file / "index.html"

    if not requested_file.exists():
        return abort(404)

    if requested_file.name.endswith(".html"):
        with requested_file.open("r") as fp:
            return Response(process_html(fp.read()), mimetype="text/html")

    elif requested_file.name.endswith(".css"):
        with requested_file.open("r") as fp:
            return Response(fp.read(), mimetype="text/css")

    else:
        with requested_file.open("rb") as fp:
            content = fp.read()

            return Response(content, mimetype=magic.from_buffer(content, mime=True))


class WatchdogEventHandler:
    def dispatch(self, event):
        State.files_changed = True


def build_thread_func():
    while State.building:
        if State.files_changed:
            State.files_changed = False

            try:
                build.do_build()

            except Exception as e:
                print(e)

            time.sleep(0.1)
            State.do_refresh = True

        time.sleep(0.5)


if __name__ == "__main__":
    observer = Observer()
    observer.schedule(WatchdogEventHandler(), str(build.src()), recursive=True)
    observer.start()

    build_thread = threading.Thread(target=build_thread_func)
    build_thread.start()

    try:
        app.run(debug=True)

    finally:
        observer.stop()
        observer.join()

    State.building = False
    build_thread.join()
