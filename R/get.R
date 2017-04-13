
list_to_df = function(l) {
  if (length(l) < 2) return(l)
  df = do.call(rbind, l) %>% as.data.frame
  vecs = sapply(df, function(i) all(sapply(i, length) == 1))
  df[vecs] %<>% lapply(unlist)

  df
}

get_api = function(token, type, id = '', local = FALSE) {
  if (local) id %<>% paste0(if (grepl('[?]', .)) '&' else '?', 'local')
  paste0('api/v1/', type, '/', id) %>% 
    api_call(GET, token$instance, .,
      add_headers(Authorization = paste('Bearer', token$access_token))) %>%
    list_to_df
}

#' @export
get_status = function(token, id) get_api(token, 'statuses', id)

# Mastodons API rate limits per IP. By default, 150 requests per 5 minute
loop_timelines = function(n, id, max_id, ..., n_per_request = 20,
  sleep = (5 * 60) / 150) {
  df = NULL
  n_loops = ceiling(n / n_per_request)

  for (i in seq_len(n_loops)) {
    df = paste0(id, if (!is.null(max_id)) paste0('?max_id=', max_id)) %>%
      get_api(id = ., ...) %>% rbind(df, .)

    if (i == n_loops || nrow(df) < n_per_request * i) return(head(df, n))
    max_id = tail(df$id, 1)
    Sys.sleep(sleep)
  }
}

#' @export
get_timeline = function(token, type = c('home', 'local', 'fediverse'), n = 20,
  max_id = NULL) {
  type = match.arg(type)
  loop_timelines(n, if (type != 'home') type = 'public', max_id, token,
    'timelines', local = type == 'local')
}

#' @export
get_hashtag = function(token, hashtag, n = 20, max_id = NULL, local = FALSE) {
  loop_timelines(n, hashtag, max_id, token, 'timelines/tag', local = local)
}

#' @export
get_account = function(token, id, ...) get_api(token, 'accounts', id, ...)

#' @export
search_username = function(token, username, limit = 40) {
  paste0('search?q=', username, '&limit=', limit) %>%
    get_account(token, .)
}

#' @export
search = function(token, query, local = FALSE) {
  paste0('search?q=', query, if (!local) '&resolve') %>%
    get_api(token, .)
}
