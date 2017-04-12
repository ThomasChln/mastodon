# Mastodon

## Installation in R

Use the **devtools** R package to install from Github:
```r
devtools::install_github('ThomasChln/mastodon')
```

### Docker

A docker image with the package installed is also available
```r
docker run -it thomaschln/mastodon
```

## Usage

Login and post a status, an image, or a ggplot
```r
library(mastodon)
token = login('https://framapiaf.org/', 'user@mail.org', 'password')
post_status(token, 'Status text.')
post_media(token, 'Image caption', file = '/home/user/file.png')
post_ggplot(token, 'Mastodon instances and users', ggplot_instances_info())
```

Get info on number of users per instances
```r
head(instances_info())
ggplot_instances_info()
```

## Inspired by

Pastebin script from @milvus@mastodon.cloud https://mastodon.cloud/users/milvus/updates/54610.

## TODO

Include plots from https://mastodon.social/@Dorialexander/2326049 and http://vintagedata.org/mastodon/cultural_genesis_1.html

## License

This package is free and open source software, licensed under GPL-3.
