# Mastodon

## Installation in R

Use the **devtools** R package to install from Github:
```r
devtools::install_github('ThomasChln/mastodon')
```

## Docker

A docker image with the package installed is also available
```r
docker run -it thomaschln/mastodon
```

## Usage

### Login and posts

```r
library(mastodon)
token = login('https://framapiaf.org/', 'user@mail.org', 'password')
post_status(token, 'Status text')
post_media(token, 'Image caption', file = '/home/user/file.png')
post_ggplot(token, 'Mastodon instances and users', ggplot_instances_info())
```

### Timelines and hashtags

```r
df = get_timeline(token, 'home')
df = get_timeline(token, 'local')
df = get_timeline(token, 'fediverse')
df = get_hashtag(token, 'rstats')

# Get more toots (default rate limit: 2 second sleep for each 20 toots)
df = get_timeline(token, 'fediverse', n = 30)
df = get_hashtag(token, 'mastodon', n = 30)

# Get toots before a specific id
df = get_timeline(token, 'fediverse', max_id = 26432)
df = get_hashtag(token, 'mastodon', max_id = 26432)

# Get hashtag only on local instance
df = get_hashtag(token, 'rstats', local = TRUE)
```

### Searches

Search for a string or a username
```r
df = search(token, 'thchln')

# don't resolve non-local accounts
df = search(token, 'thchln', local = TRUE)

df = search_username(token, 'thchln')
df = search_username(token, 'thchln', limit = 2)
```

Get an account or a toot by id
```r
account = get_account(token, 475)
toot = get_status(token, 26432)
```

### Fediverse info and plots

Number of users per instances
```r
ggplot_instances_info()
```
![](https://framapiaf.org/media/NcR7nokUey2YYumJgUA)

Participation by hours
```r
df_toots = get_timeline(token, 'fed', n = 2e4)
toots_by_hours(df_toots) %>% ggplot_toots_by_hours(token$instance)
```
![](https://framapiaf.org/media/b3Mn26afJtRD9w1_qqs)

Participation of top 6 instances
```r
toots_by_instances(df_toots) %>% ggplot_toots_by_instances(token$instance)
```
![](https://framapiaf.org/media/Ds6kdUdPNYFvJGhQRHw)

## Acknowledgments

* Login, posts, and users per instances plot: [pastebin script](https://pastebin.com/XBiJmbNV) by [@milvus@mastodon.cloud](https://mastodon.cloud/@milvus)
* Participation per instances plots: [HTML-Rmd vignette](http://vintagedata.org/mastodon/cultural_genesis_1.html) by [@Dorialexander@mastodon.social](https://mastodon.social/@Dorialexander) 

## License

This package is free and open source software, licensed under GPL-3.
