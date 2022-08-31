# Contribution Guide

This document provides guidelines for contribution to the operate-first/apps repo.

## Creating issues

If you would like to create an issue regarding any of the following:

- An Operate First provisioned application (Open Data Hub or others)
- Onboarding
- Additional services/features for any environment
- Service degradation and/or operational issues

Please create an issue in the [operate-first/support](https://github.com/operate-first/support) repo instead.

Please only create an issue here in [operate-first/apps](https://github.com/operate-first/apps) if it directly concerns the contents of this repo. For example, you can create issues concerning:

- Implementation details (manifests that need to be added, configured, removed, etc.)
- Bugs found within this repo
- Continuous integration for this repo
- Improving workflows within this repo
- Adding or improving documentation

## Creating pull requests

### General guide of code contributions

1. Create a personal fork of the project on Github. **Please use this fork for all of your contributions, even if you have write access to the upstream repositories.**
2. Clone the fork on your local machine. Your remote repo on Github is called `origin`.

   ```sh
   git clone git@github.com:USERNAME/REPOSITORY_NAME.git
   ```

3. Add the original repository as a remote called `upstream`.

   ```sh
   git remote add upstream git@github.com:operate-first/REPOSITORY_NAME.git
   ```

4. If you created your fork previously, be sure to pull upstream changes into your local repository.

   ```sh
   git checkout master # or main
   git fetch upstream
   git rebase upstream/master  # or upstream/main
   git push origin master
   ```

5. Create a new branch to work on. Create this branch from the default, up-to-date branch like `master` or `main`.

   ```sh
   git checkout -b "BRANCH-NAME"
   ```

6. Install [pre-commit](https://pre-commit.com/) into your [git hooks](https://githooks.com/) by running `pre-commit install`. See [linting](#linting) for more.
7. Implement/fix your feature, and comment your code.
8. Add or change the documentation as needed.
9. Run a local test (if available) and linter (see the **Tests** section below for more information).
10. Push your branch to your fork on Github, the remote origin.
   ```sh
   git push origin BRANCH-NAME
   ```
11. Review the checklist below and make sure your PR adheres to the criteria given.
12. Contribute your PR!

### Checklist

When creating a pull request (PR) please use the following checklist:

- Ensure there is an issue attached to the PR. We consider this good practice, but recognize that it's not always necessary.
- Ensure that the `pre-commit` check passes.
- Ensure that your commit history is clean and minimal.
   - Avoid commits like "Fix a typo" or "Forgot to add x." You can use [fixup or squashing](https://fle.github.io/git-tip-keep-your-branch-clean-with-fixup-and-autosquash.html) to clean up your commits.
   - Aim to have one commit per PR. If you really want to have multiple commits for a change, you should at least squash down so each commit corresponds to a singular change or addition.
- If updating a kustomization build, ensure that the `kustomize build` on that path still works.
- Ensure that all confidential information has been encrypted via [sops](https://github.com/mozilla/sops) and [ksops](https://github.com/viaduct-ai/kustomize-sops), before making the PR.
- If the PR is a work-in-progress, you need to prevent our CI bot from merging it until it's ready. To do so, please create a [Draft PR](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/about-pull-requests#draft-pull-requests) or add the WIP prefix to your PR title.
   - An example of a WIP-prefixed title could be "WIP: Added new namespace to Smaug cluster."
   - When the PR is ready to be merged, you can simply remove the WIP prefix from the title.

## Resources

### Tools

To generate/edit manifests you will need the following tools:

- [Kustomize](https://kustomize.io/)
- [SOPS](https://github.com/mozilla/sops)
- [ksops](https://github.com/viaduct-ai/kustomize-sops)

While you can install them manually, we recommend using our [toolbox](https://github.com/operate-first/toolbox) container to get started.

### Prow for ChatOps

Prow is a CI/CD system for Kubernetes. We use Prow for ChatOps, which is done via slash commands. With the help of our CI bot [Sesheta](https://github.com/sesheta), we can execute commands by writing them in GitHub comments. Common uses include adding or removing labels, assigning issues or requesting review, and approving PRs to be merged. Prow for ChatOps helps us to streamline the issue and PR processes overall.

The following is a list of some common commands and their uses, but more can be found [here](https://prow.operate-first.cloud/command-help).

- `/assign USERNAME` assigns the person with the corresponding Github username.
   - `/unassign USERNAME` removes the assignment from that user.
- `/cc USERNAME` requests review from the user.
   - `/uncc USERNAME` removes the request for review from that user.
- `/hold` applies a blocking label `do-not-merge/hold` that will prevent a PR from being merged.
   - `/unhold`, `/remove-hold`, or `/hold cancel` removes the blocking label.
- `/test` or `/retest` triggers the test checks that PRs must pass.
- `/lgtm` indicates that someone (other than the creator) has reviewed a PR and believes that the changes look good. With this command, Sesheta will apply the lgtm label.
  - `/remove-lgtm` or `/lgtm cancel` removes the `lgtm` label.
- `/approve` is similar to `/lgtm`, except this command is written by someone who qualifies as an approver (meaning they are listed in the appropriate OWNERS files). Sesheta will apply the approve label.
  - `/remove approve` or `/approve cancel` removes the `approve` label.

> Note that both the `lgtm` and `approve` labels must be present for the PR to be merged. Barring any blocking labels, the PR is automatically merged once both of these are present and the appropriate checks have been passed.


## Tests

### Linting

To run linting tests, we use [pre-commit](https://pre-commit.com/). Run `pre-commit install` after you clone the repo. Then, `pre-commit` will run automatically on git commit. If any one of the tests fail, add and commit the changes made by pre-commit. Once the pre-commit check passes, you can make your PR.

   * `pre-commit` will from now on run all the checkers/linters/formatters on every commit.
   * If you later want to commit without running it, just run `git commit` with `-n/--no-verify`.
   * If you want to manually run all the checkers/linters/formatters, run `pre-commit run --all-files`.

### Kustomize build

We are using `kustomize build` in our CI pipeline to test if the syntax of overlays is correct. This command is run against changes which are found between commit in PR and latest commit in master branch in `apps` repository.

### Kubeval validation

As the last step in our validation pipeline we are using [kubeval](https://www.kubeval.com/). `kubeval` checks if the manifests are valid against schemas which we store in [schema-store](https://github.com/operate-first/schema-store). These schemas were extracted from clusters using a [script](https://github.com/operate-first/schema-store/blob/main/build_schema.py) which uses OpenAPI spec. More information about how we are using kubeval validation can be found in the[documentation](https://www.operate-first.cloud/apps/content/kubeval/README.html).
