import logging
import os
import sys

from setuptools import setup, find_packages

here = os.path.abspath(os.path.dirname(__file__))
project_path = here
src_path = os.path.join(project_path, "src")
readme_path = os.path.join(project_path, "README.md")

sys.path.insert(0, src_path)

logging.basicConfig(stream=sys.stderr, level=logging.INFO)


def read_file(path):
    with open(path, "r") as fp:
        return fp.read()


def install_requires():
    requirements = read_file(os.path.join(project_path, "requirements.txt")).split("\n")
    requirements = list(filter(lambda s: not not s, map(lambda s: s.strip(), requirements)))

    return requirements


def main():
    import grapejuice.__about__ as __about__
    from grapejuice_packaging.local_install import InstallLocally

    setup(
        name="grapejuice",
        author=__about__.author_name,
        author_email=__about__.author_email,
        version=__about__.package_version,
        description=__about__.package_description,
        license=__about__.package_license,
        long_description=read_file(readme_path),
        long_description_content_type="text/markdown",
        url=__about__.package_repository,
        classifiers=[
            "Development Status :: 4 - Beta",
            "Programming Language :: Python :: 3.7",
            "Programming Language :: Python :: 3.8",
            "Programming Language :: Python :: 3.9",
            "Programming Language :: Python :: 3.10"
        ],
        keywords=["grapejuice wine roblox studio"],
        packages=find_packages("src", exclude=[
            "grapejuice_packaging",
            "grapejuice_packaging.*",
            "grapejuice_dev_tools",
            "grapejuice_dev_tools.*",
            "tests",
            "tests.*"
        ]),
        package_dir={"": "src"},
        include_package_data=True,
        python_requires=">=3.7",
        install_requires=install_requires(),
        entry_points={
            "console_scripts": [
                "grapejuice=grapejuice.cli.main:easy_install_main",
                "grapejuice-gui=grapejuice.cli.gui:easy_install_main",
                "grapejuiced=grapejuiced.main:easy_install_main"
            ]
        },
        cmdclass={
            "install_locally": InstallLocally
        }
    )


if __name__ == '__main__':
    main()
