# Contributing to GitOps Docs

## Pre-requisites

- Fork and clone the [operate-first/apps][apps-repo] repo
- Install [JupyterBook cli][jbook-install]

## Adding markdown docs

All `markdown` files are found in the `docs/content` folder. Add your markdown in the appropriate subfolder.

Update `docs/_toc.yml` by adding the location of your new markdown document to the appropriate chapter/section.

Follow [Build the Docs section][builddocs] below ensure your markdown appears in the rendered JupyterBook.

Once confirmed, commit your changes, and submit a PR to the  [`apps` repo][apps-repo].

## Build the docs

In the repository you can create a virtual environment with [pipenv](https://pipenv.pypa.io/en/latest/)
```
pipenv install --dev
```
After that you can enter the virtual environment
```
pipenv shell
```
Now build the Jupyter book
```
cd docs
jupyter-book build .
```
The compiled book can be found in the `_build` folder.

[builddocs]: #Build-the-docs
[apps-repo]: https://github.com/operate-first/apps
[jbook-install]: https://jupyterbook.org/start/overview.html#install-jupyter-book
