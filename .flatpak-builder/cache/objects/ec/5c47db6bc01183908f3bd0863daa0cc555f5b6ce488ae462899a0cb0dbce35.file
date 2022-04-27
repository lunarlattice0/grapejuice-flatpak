from pathlib import Path
from typing import List, Optional, Dict, Any

import click
from bs4 import BeautifulSoup


def _file_tree_node(name: Optional[str], path: Optional[Any]):
    return {
        "name": name,
        "path": path,
        "parent": None,
        "value": None,
        "is_dir": True,
        "children": []
    }


def _node_for_path(tree: Dict, path: Path, value: Optional[Any] = None):
    node = tree
    current_path = Path("")

    for part in path.parts:
        found = None
        current_path = current_path / part

        for child in node["children"]:
            if child["name"] == part:
                found = child

        if not found:
            found = _file_tree_node(part, None)
            node["children"].append(found)
            found["parent"] = node

        found["path"] = current_path

        node = found

    node["path"] = path
    node["value"] = value
    node["is_dir"] = False

    return node


def _walk_tree(tree, visitor):
    visitor(tree)

    for child in tree["children"]:
        _walk_tree(child, visitor)


@click.command()
@click.argument("site_prefix", type=str)
@click.argument("site_root", type=Path)
@click.argument("output_file", type=Path)
def main(site_prefix: str, site_root: Path, output_file: Path):
    site_root = site_root.resolve()
    files: List[Path] = list(filter(None, filter(Path.is_file, site_root.rglob("*"))))
    relative_files: List[Path] = list(map(lambda p: p.relative_to(site_root), files))

    tree = _file_tree_node(None, None)
    for file in relative_files:
        node = _node_for_path(tree, file)
        assert node

    # language=HTML
    soup = BeautifulSoup("""<html lang="en">
    <head>
        <title>Sitemap</title>
    </head>

    <body>

    </body>
</html>
""", "html5lib")

    site_prefix = site_prefix.strip("/")
    if site_prefix:
        site_prefix = f"/{site_prefix}/"

    else:
        site_prefix = "/"

    ul = soup.new_tag("ul")
    soup.body.append(ul)

    def visit_node(n):
        if n.get("path", None) is None:
            return

        if not n["is_dir"]:
            li = soup.new_tag("li")
            ul.append(li)

            a = soup.new_tag("a")
            a["href"] = site_prefix + "/".join(n["path"].parts)
            a.string = str(n["path"])

            li.append(a)

    _walk_tree(tree, visit_node)

    with output_file.open("w+") as fp:
        fp.write(soup.prettify())


if __name__ == "__main__":
    main()
