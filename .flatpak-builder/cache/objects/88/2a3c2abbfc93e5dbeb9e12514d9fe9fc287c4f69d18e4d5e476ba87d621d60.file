import hashlib
import json
import os
import re
import shutil
from datetime import datetime
from functools import lru_cache as cache
from pathlib import Path, PurePath
from string import Template
from sys import maxsize
from typing import List, Union

import emoji
import markdown
import sass
import yaml
from bs4 import BeautifulSoup
from jinja2 import Environment, FileSystemLoader, select_autoescape

HERE = Path(__file__).resolve().parent

path_prefix = os.environ.get("BLOG_PATH_PREFIX", "")


class Environments:
    dev = "dev"
    dist = "dist"


def default_jinja_variables():
    now = datetime.utcnow()
    return {"articles": dict(), "articles_by_tag": dict(), "current_year": now.year}


jinja_variables = default_jinja_variables()

scss_ptn = re.compile(r"href=\"(.+?\.scss)\s*?\"")


@cache()
def environment():
    return os.environ.get("BLOG_ENV", Environments.dev).lower()


def state_path():
    return HERE / ".state.json"


def load_state():
    if not state_path().exists():
        return dict()

    try:
        with state_path().open("r") as fp:
            return json.load(fp)

    except json.JSONDecodeError:
        return dict()


def save_state(state):
    with state_path().open("w+") as fp:
        json.dump(state, fp, indent=2)


def hash_file(file: Path):
    h = hashlib.blake2s()

    with file.open("rb") as fp:
        h.update(fp.read())

    return h.hexdigest().lower()


def sass_output_style():
    if environment() == Environments.dev:
        return "expanded"

    elif environment() == Environments.dist:
        return "compressed"

    return "compact"


def here() -> Path:
    return Path(__file__).resolve().parent


def tools() -> Path:
    return here()


def root() -> Path:
    return tools().parent


def src() -> Path:
    return root() / "src"


def build() -> Path:
    if environment() == Environments.dev:
        return Path("/", "tmp", "grapejuice-docs", "build")

    elif environment() == Environments.dist:
        return root() / "dist"

    else:
        return root() / "build"


def clean():
    shutil.rmtree(build(), ignore_errors=True)


def get_build_files():
    build_files = list(filter(Path.is_file, build().rglob("*")))
    return dict(zip(map(str, build_files), map(hash_file, build_files)))


def copy():
    state = load_state()

    shutil.copytree(
        src(), build(), ignore=lambda *_: list(state.get("static_files", dict()).keys())
    )

    state["build_files"] = get_build_files()
    save_state(state)


def rewrite_extension(p: Path, extension: str) -> Path:
    s = p.name.split(".")[:-1]
    s.extend([extension])

    return p.parent / ".".join(s)


class Summarizer:
    _words: List[str]
    _character_counter: int = 0
    _limit: int
    _break_pads: List[str]

    def __init__(self, limit: int = 50, break_pads: Union[List[str], None] = None):
        self._words = []
        self._limit = limit

        self._break_pads = list(set(map(str.strip, break_pads))) if break_pads else []

    @property
    def limit_reached(self) -> bool:
        return self._character_counter >= self._limit

    @property
    def content(self) -> str:
        return " ".join(self._words)

    def add(self, words: str):
        for word in re.split("\s+", words):
            word = word.strip()
            length = len(word)

            for bp in self._break_pads:
                if word.lower() == bp.lower():
                    return

            if self._character_counter + length < self._limit:
                self._words.append(word)
                self._character_counter += length

            else:
                return

    def __str__(self):
        return self.content


def process_markdown():
    def markdown_files():
        return build().rglob("*.md")

    for md_file in markdown_files():
        html_file = rewrite_extension(md_file, "html")
        html_file = html_file.parent / re.sub("[\s]", "_", html_file.name)

        with md_file.open("r") as fp:
            md_content = fp.read()

        front_matter_lines = []
        md_content_lines = []

        line_target = front_matter_lines
        found_front_matter = False

        all_md_lines = md_content.split("\n")
        all_md_lines.append("")
        line_zero = all_md_lines[0].strip()

        scan_for_front_matter = ":" in line_zero

        if scan_for_front_matter:
            for line in all_md_lines:
                line = line.replace("\r", "")
                stripped_line = line.strip()

                if not found_front_matter and stripped_line.startswith("---"):
                    line_target = md_content_lines
                    found_front_matter = True

                line_target.append(line)

        else:
            md_content_lines = all_md_lines

        if found_front_matter:
            try:
                yaml.safe_load("\n".join(front_matter_lines))

            except:
                found_front_matter = False

        if found_front_matter:
            front_matter_data = yaml.safe_load("\n".join(front_matter_lines))

        else:
            md_content_lines = [*front_matter_lines, *md_content_lines]
            front_matter_lines = []
            front_matter_data = dict()

        if not isinstance(front_matter_data, dict):
            front_matter_data = dict()

        md_content = "\n".join(md_content_lines)
        md_content = emoji.emojize(md_content, variant="emoji_type", use_aliases=True)

        html_template = Template(
            """{% extends "layout/_article.html" %}

{% block article %}
$MD_HTML
{% endblock %}
        """
        )

        rendered_markdown = markdown.markdown(
            md_content,
            extensions=[
                "markdown.extensions.tables",
                "markdown.extensions.fenced_code",
                "markdown.extensions.codehilite",
                "markdown.extensions.smarty",
                "markdown.extensions.toc",
                "mdx_truly_sane_lists",
            ],
        )

        html_content = html_template.safe_substitute(
            {"MD_HTML": re.sub(r"\s*\[summary\-snip\]\s*", "", rendered_markdown)}
        )

        md_soup = BeautifulSoup(rendered_markdown, "lxml")
        summarizer = Summarizer(break_pads=["[summary-snip]"])
        summarizer.add(md_soup.text)

        with html_file.open("w+") as fp:
            fp.write(html_content)

        href = "/" + str(html_file.relative_to(build()))

        article_date = front_matter_data.get("date")
        if isinstance(article_date, str):
            article_date = datetime.fromisocalendar(article_date)

        if article_date is None:
            md_stat = os.stat(md_file)
            article_date = datetime.fromtimestamp(md_stat.st_ctime)

        article_info = {
            "href": href,
            "front_matter": front_matter_data,
            "title": front_matter_data.get(
                "title", PurePath(href).name.rstrip(".html")
            ),
            "subtitle": front_matter_data.get("subtitle", ""),
            "summary": summarizer.content,
            "date": article_date,
        }

        if tags := front_matter_data.get("tags", None):
            for tag in tags:
                articles_list = jinja_variables["articles_by_tag"].setdefault(tag, [])
                articles_list.append(article_info)

        jinja_variables["articles"][href] = article_info

        os.remove(md_file)


def process_html_file(
    jenv: Environment, source_file: Path, target_file: Union[Path, None] = None
):
    target_file = target_file or source_file

    with source_file.open("r") as fp:
        content = fp.read()

    href = "/" + str(source_file.relative_to(build()))
    if href in jinja_variables["articles"]:
        jinja_variables["article"] = jinja_variables["articles"][href]

    else:
        jinja_variables["article"] = None

    # Template render
    template = jenv.from_string(content)
    content = template.render(jinja_variables)

    # SCSS
    def map_style_path(s: str):
        if s.startswith("/"):
            return build() / s.lstrip("/")

        else:
            return source_file.parent / s

    styles = list(set(scss_ptn.findall(content)))
    style_paths = list(map(map_style_path, styles))

    for style, style_file in zip(styles, style_paths):
        try:
            output_style_file = rewrite_extension(style_file, "css")
            output_style = ""

            with style_file.open("r") as fp:
                output_style = sass.compile(
                    string=fp.read(),
                    output_style=sass_output_style(),
                    source_map_embed=True,
                    include_paths=[str(style_file.parent)],
                )

            with output_style_file.open("w+") as fp:
                fp.write(output_style)

            content = content.replace(
                style, "/" + str(output_style_file.relative_to(build()))
            )

        except sass.CompileError as e:
            print(
                f"SASS compiler error:\n{str(e)}\n{str(style_file.relative_to(build()))}\n----------"
            )

        except FileNotFoundError as e:
            print(f"File not found: {e}\n----------")

    soup = BeautifulSoup(content, "html5lib")

    def update_targeting_attr(attrs, attr):
        v = attrs.get(attr)

        if v == path_prefix or v.startswith("http") or v.startswith("#"):
            return

        if v == "/":
            attrs[attr] = path_prefix if path_prefix else v
            return

        else:
            target = find_href_target(target_file, v)
            if isinstance(target, Path):
                target = str(target.relative_to(build()))

        attrs[attr] = (
            path_prefix + "/" + target if path_prefix else "/" + target
        ).rstrip("/")

    def update_external_anchor_tag(tag):
        v = tag.attrs.get("href", "")

        if v.startswith("http://") or v.startswith("https://"):
            tag.attrs["target"] = tag.attrs.get("target", "_blank")
            el_image = soup.new_tag("img", src=f"/images/external_link.svg")
            el_image["class"] = "external-link-image"
            tag.append(el_image)

    for href_tag in soup.find_all(href=True):
        update_targeting_attr(href_tag, "href")

    for href_tag in soup.find_all("a", href=True):
        update_external_anchor_tag(href_tag)

    for src_tag in soup.find_all(src=True):
        update_targeting_attr(src_tag, "src")

    content = soup.prettify()

    # Emit
    with target_file.open("w+") as fp:
        fp.write(content)


def find_href_target(from_file: Path, href: str):
    href_split = list(filter(None, href.split("/")))

    if len(href_split) <= 0:
        return href

    if href_split[0] == "https:" or href_split[0] == "http:":
        return href

    href_starts_at_root = href[0] == "/"

    if href_starts_at_root:
        path = Path(build(), *href_split)

    else:
        path = Path(from_file.parent, *href_split)

    path = path.resolve()
    if not path.exists() and not path.name.endswith(".html"):
        path = path.parent / (path.name + ".html")

    assert (
        path.exists()
    ), f"Could not find href target for {href} -> {path} in {from_file}"

    return path


def process_html_file_multi_out(jenv: Environment, source_file: Path, variable: str):
    filename_template = Template(source_file.name)

    for v in jinja_variables[variable]:
        target_file_name = filename_template.safe_substitute({variable: v})
        target_file = source_file.parent / target_file_name

        jinja_variables["multi_out"] = {"variable": v}

        process_html_file(jenv, source_file, target_file=target_file)

    jinja_variables["multi_out"] = None

    os.remove(source_file)


def process_html():
    jinja_variables["articles_list"] = list(
        sorted(
            jinja_variables["articles"].values(),
            key=lambda a: a.get("date") or datetime.now(),
        )
    )

    jinja_variables["tags"] = list(jinja_variables["articles_by_tag"].keys())

    jenv = Environment(
        loader=FileSystemLoader(build()), autoescape=select_autoescape(), cache_size=0
    )

    def html_files():
        return filter(lambda p: not p.name.startswith("_"), build().rglob("*.html"))

    for html_file in html_files():
        if match := re.search(r"\$(\w+)\.html", html_file.name):
            process_html_file_multi_out(jenv, html_file, match.group(1))

        else:
            process_html_file(jenv, html_file)

    for scss_file in build().rglob("*.scss"):
        os.remove(scss_file)


def strip_partials():
    def file_filter(p: Path):
        return p.name.startswith("_") and p.is_file()

    for file in filter(file_filter, build().rglob("*")):
        os.remove(file)


def remove_empty_directories():
    f = True

    def directory_filter(p: Path):
        return p.is_dir() and len(list(p.glob("*"))) <= 0

    while f:
        empty_directories = list(filter(directory_filter, build().rglob("*")))
        f = len(empty_directories) <= 0

        for d in empty_directories:
            os.rmdir(d)


def update_static_files_in_state():
    state = load_state()

    old_build_files = list(map(tuple, state.get("build_files", dict()).items()))
    build_files = list(map(tuple, get_build_files().items()))

    state["static_files"] = dict(filter(lambda x: x in old_build_files, build_files))

    save_state(state)


def do_build():
    global jinja_variables

    print("### Building a blog! ###")
    print(f"Environment = {environment()}")
    print("")

    jinja_variables = default_jinja_variables()

    clean()
    copy()
    process_markdown()
    process_html()

    if environment() == Environments.dist:
        strip_partials()
        remove_empty_directories()

    update_static_files_in_state()

    print("Done!")


def main():
    do_build()


if __name__ == "__main__":
    main()
