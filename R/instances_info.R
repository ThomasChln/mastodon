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
