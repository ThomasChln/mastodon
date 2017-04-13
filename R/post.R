post_auth = function(token, type, ...) {
  post_api(token$instance, type,
    add_headers(Authorization = paste('Bearer', token$access_token)), ...)
}

#' @export
post_status = function(token, status, ...) {
  post_auth(token, 'statuses', status = status, ...)
}

#' @export
post_media = function(token, status, file, include_media_url = TRUE) {
  media = post_auth(token, 'media', file = upload_file(file))
  if (include_media_url) status %<>% paste0('\n', media$text_url)

  post_status(token, status, 'media_ids[]' = media$id)
}

#' @export
post_ggplot = function(token, status, ggplot) {
  file = paste0(tempfile(), '.png')
  ggplot2::ggsave(file, ggplot, width = 15, height = 10,
    units = 'cm', dpi = 100, scale = 1.4)
  post_media(token, status, file)

  file.remove(file)
}

