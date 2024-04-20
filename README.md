# aws.xq

[![exist-db CI](https://github.com/HistoryAtState/aws.xq/actions/workflows/build.yml/badge.svg)](https://github.com/HistoryAtState/aws.xq/actions/workflows/build.yml)

<img src="icon.svg" align="left" width="25%"/>

Adapted from Klaus Wichmann's xaws library - https://github.com/dknochen/xaws - with a primary focus on accessing S3 buckets with eXist-db.

## Build

```shell
ant
```

1. Since Releases have been automated when building locally you might want to supply your own version number (e.g. `X.X.X`) like this:

    ```shell
    ant -Dapp.version=X.X.X
    ```

## Release

Releases for this data package are automated. Any commit to the `main` branch will trigger the release automation.

All commit message must conform to [Conventional Commit Messages](https://www.conventionalcommits.org/en/v1.0.0/) to determine semantic versioning of releases, please adhere to these conventions, like so:

| Commit message  | Release type |
|-----------------|--------------|
| `fix(pencil): stop graphite breaking when too much pressure applied` | Patch Release |
| `feat(pencil): add 'graphiteWidth' option` | ~~Minor~~ Feature Release |
| `perf(pencil): remove graphiteWidth option`<br/><br/>`BREAKING CHANGE: The graphiteWidth option has been removed.`<br/>`The default graphite width of 10mm is always used for performance reasons.` | ~~Major~~ Breaking Release |

When opening PRs commit messages are checked using commitlint.