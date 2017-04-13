#' @export
instances_info = function(url = 'https://instances.mastodon.xyz/') {
  GET(paste0(url, 'instances.json')) %>% content(as = 'text') %>%
    jsonlite::fromJSON()
}

#' @export
ggplot_instances_info = function(url = 'https://instances.mastodon.xyz/',
  df_info = instances_info(url), n_instances = 20) {
  library(ggplot2)
  subtitle = paste('Top', n_instances, 'instances (among', nrow(df_info),
    'serving', sum(df_info$users), 'users) -',
    format(Sys.time(), tz = 'UTC',  usetz = TRUE))
  caption = paste('@milvus@mastodon.cloud\ndata from', url)

  df_info %>%
    subset(rank(-users) <= n_instances) %>%
    ggplot(aes(reorder(.$name, .$users), .$users, fill = .$openRegistrations)) +
      geom_bar(stat = 'identity') +
      scale_y_continuous(labels = scales::comma) +
      scale_fill_discrete(labels = c('No', 'Yes'), name = 'Open registration') +
      labs(title = 'Mastodon instances and users', subtitle = subtitle,
        x = 'Instance', y = 'Users', caption = caption) +
      coord_flip() +
      ggthemes::theme_fivethirtyeight() +
      theme(plot.caption = element_text(size = 7),
        axis.ticks.y = element_line(size = 0),
        panel.grid.major.y = element_line(size = 0))
}

#' @export
toots_by_hours = function(df_toots) {
  df_toots %>% split(gsub(':.*', '', .$created_at)) %>% sapply(., nrow) %>%
    data.frame(hours = names(.) %>% lubridate::ymd_h(), n_toots = .)
}

#' @export
ggplot_toots_by_hours = function(df_toots) {
  ggplot(df_toots, aes(hours, n_toots)) +
    geom_line(color = 'red', size = 1, group = 1) +
    ylim(0, max(df_toots$n_toots) + max(df_toots$n_toots) / 6) +
    labs(x = 'Hour', y = 'Number of toots',
      title = 'Participation within all instances of Mastodon',
      caption = 'Source : Public timeline of mastodon.social')
}

#' @export
toots_by_instances = function(df_toots) {
  df_toots$hours = gsub(':.*', '', df_toots$created_at)
  df_toots$instance = gsub('https://|/.*', '', df_toots$url)
  df_toots %>% split(.[c('hours', 'instance')]) %>% sapply(., nrow) %>%
    data.frame(hours = gsub('[.].*', '', names(.)) %>% lubridate::ymd_h(),
      instances = gsub('.*[.]', '', names(.)), n_toots = .)
}

#' @export
ggplot_toots_by_instances = function(df_toots, n_top_instances = 6) {
  top_instances = df_toots %>% split(.$instance) %>%
    sapply(function(i) sum(i$n_toots)) %>% sort(TRUE) %>% names %>%
    head(n_top_instances)
  df_toots %<>% subset(instance %in% top_instances)

  ggplot(df_toots, aes(hours, n_toots, color = instances, group = instances)) +
    geom_line(size = 1) +
    ylim(0, max(df_toots$n_toots) + max(df_toots$n_toots) / 6) +
    theme(legend.position = 'bottom') +
    labs(x = 'Hour', y = 'Number of toots', color = 'Instance',
      title = 'Participation by instances',
      caption = 'Source : Public timeline of mastodon.social')
}
