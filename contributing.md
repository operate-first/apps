# Contribution Guide

Contribution guidelines for operate-first/apps repo.

## Creating issues

If you would like to create an issue for any of the following:

- Question regarding an Open Data Hub, or any other Operate-first provisioned application
- Question about onboarding
- Request additional services/features to MOC (or other environments)
- Service degradation and/or operational issues

Please create an issue in [operate-first/support](https://github.com/operate-first/support) repo instead.

Please create an issue in this repo if it directly concerns contents within this repo. Examples include issues concerning:

- Implementation details (manifests needing to be added, configured, removed, etc.)
- Bugs found within this repo
- Continuous integration for this repo
- Improving workflows within this repo
- Adding documentation

## Creating Pull Requests

### General guide of code contributions

1. Create a personal fork of the project on Github. **Please use this fork for all of your contribution, even if you have write access to the upstream repositories.**
2. Clone the fork on your local machine. Your remote repo on Github is called `origin`.

   ```sh
   git clone git@github.com:USERNAME/REPOSITORY_NAME.git
   ```

3. Add the original repository as a remote called `upstream`.

   ```sh
   git remote add upstream git@github.com:operate-first/REPOSITORY_NAME.git
   ```

4. If you created your fork a while ago be sure to pull upstream changes into your local repository.

   ```sh
   git checkout master # or main
   git fetch upstream
   git rebase upstream/master  # or upstream/main
   git push origin master
   ```

5. Create a new branch to work on. Create this branch from the default, up to date branch like `master` or `main`.
6. Install `pre-commit` git hook by running `pre-commit install`.
7. Implement/fix your feature, comment your code.
8. Add or change the documentation as needed.
9. Run local test (if available) and linter (`pre-commit run -a`)
10. Push your branch to your fork on Github, the remote origin.

### Checklist

When creating a PR please use the following checklist:

- Ensure there is an issue attached to the pull-request. We consider this is good practice, but recognize that it's not always necessary.
- Ensure that the pre-commit check passes.
- Ensure that your commit history is clean and minimal. Avoid commits like "Fix a typo" or "Forgot to add x". You can use [fixup or squashing](https://fle.github.io/git-tip-keep-your-branch-clean-with-fixup-and-autosquash.html) to clean up your commits. Aim to have one commit per PR. If you really want to have multiple commits for a change, you should at least squash down so each commit corresponds to a singular change or addition.
- If updating a kustomization build, ensure that the `kustomize build` on that path still works.
- Ensure that all confidential information has been encrypted via [sops](https://github.com/mozilla/sops) and [ksops](https://github.com/viaduct-ai/kustomize-sops), before making the PR.
- If the PR is a work-in-progress, then please create a `Draft` PR. You can also just add the "WIP" prefix to your PR title. Doing either will prevent our CI bot from merging this PR until it is ready. If using the WIP prefix in title, when the PR is ready for merge, simply remove the WIP prefix. For example a WIP title could be "WIP: Added new namespace to zero cluster."

## Tools / Resources

To generate/edit manifests you will need the following tools:

- [Kustomize](https://kustomize.io/)
- [SOPS](https://github.com/mozilla/sops)
- [ksops](https://github.com/viaduct-ai/kustomize-sops)

While you can install them manually, we recommend using our [toolbox](https://github.com/operate-first/toolbox) container to get started.

## Tests

To run linting tests please install [pre-commit](https://pre-commit.com/) and run `pre-commit run --all-files` at the repository root before contributing a PR.

Alternatively, you can run `pre-commit install` after you clone the repo and `pre-commit` will run automatically on git commit.
