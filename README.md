# github-actions-cd-action

A GitHub Action that tags the latest push to `main` branch
with multiple [SemVer] tags
and a new GitHub Release
whenever you push an update to a central `VERSION` file.

For example, when you change the `VERSION` file like so:

```diff
-1.0.0
+1.0.1
```

The Action will:

- create a new `v1.0.1` tag
- create a new GitHub Release pointing to the `v1.0.1` tag.
- create or update tags `v1` and `v1.0` to point to the same commit as `v1.0.1`.

This makes development of GitHub Actions (like this one!) simpler for end users,
who can reliably use `@v1` or `@v1.0` tags
to stay up-to-date with new patch releases
without needing to update their own workflow files.

## Usage

Add a file called `VERSION` to the root of your repository.
The content should be a single line with the
[SemVer] version you want to start from.

For example:

```
0.0.1
```

> [!note]
> You should not include the leading `v` in the contents of the `VERSION` file.
> Only use the `.`-separated numbers.
> The `v` is added to tags by the action automatically.

Then, include `github-actions-cd-action` in a GitHub Actions workflow:

```yaml
# .github/workflows/cd.yaml
name: CD

on:
  push:
    branches: [main]

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: griceturrble/github-actions-cd-action@v0
        permissions:
          # Required in order to create releases and tags.
          contents: write
        with:
          # All arguments below are optional
          # and are shown with their default values:

          # token to use for authenticating to GitHub
          token: ${{ github.token }}
          # path to a file to watch for version changes
          version_file: VERSION
```

## Version file tracking

This workflow tracks changes to the `VERSION` file
(using [`tj-actions/changed-files`](https://github.com/tj-actions/changed-files) to detect those changes)
to know when to run.
If no changes are detected, the tag and release steps are all skipped.

If the file has changed,
the version will be parsed to create or update up to 3 new tags in the repo automatically:

- A `MAJOR` tag: `v1`
- A `MINOR` tag: `v1.2`
- A `PATCH` tag: `v1.2.3`

Finally, a new GitHub Release is created using the new `PATCH` tag
(using [`ncipollo/release-action`](https://github.com/ncipollo/release-action)).

Whenever a `MAJOR` or `MINOR` tag already exists for the given version,
it is updated to point to the new commit.
In this way, both the `MAJOR` and `MINOR` tags stay up-to-date with their
respective latest `PATCH` release.

### Example scenarios

- `v1.0.0` is released first.
  New tags for `v1`, `v1.0`, and `v1.0.0` are created,
  all pointing to the same commit;
  and a new release is created, pointing to `v1.0.0`.

- `v1.0.1` is released.
  A new tag for `v1.0.1` is created with a release pointing to it.
  The `v1` and `v1.0` tags are updated to point to the same commit as `v1.0.1`.
  The `v1.0.0` tag is left unchanged.

- `v1.1.0` is released.
  New tags for `v1.1` and `v1.1.0` are created pointing to this latest commit,
  and a new release is created pointing to `v1.1.0`.
  The `v1` tag is updated to also point to this latest commit.
  `v1.0` and all `v1.0.*` tags are left unchanged.

- `v2.0.0` is released.
  New tags for `v2`, `v2.0`, and `v2.0.0` are created,
  all pointing to the same commit;
  and a new release is created, pointing to `v2.0.0`.
  `v1`, all `v1.*`, and all `v1.*.*` tags are left unchanged.

## Caveats

The action is only intended to work with the specific [SemVer] spec of `MAJOR.MINOR.PATCH`.
[CalVer] _should_ be compatible with this if it matches the same basic spec
(`2025.1.14`, for example).
If you have another version spec you wish to follow,
this action may not be that useful to you.

Further, this action is intended to be simple:
there are not many extra config options,
even for the other actions that this one wraps around.

If there is some missing configuration that would like to add,
I recommend forking this Action to make a custom version that does what you want. 🙂

[calver]: https://calver.org/
[semver]: https://semver.org/
