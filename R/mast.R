post = function(instance, type, ..., config = list()) {
  r = POST(paste0(instance, type), config, body = list(...))
  stop_for_status(r)
  content(r)
}

post_api = function(instance, type, ...) {
  post(instance, paste0('api/v1/', type), ...)
}

registration = function(instance) {
  post_api(instance, 'apps', client_name = 'mastodon_r_package',
    redirect_uris = 'urn:ietf:wg:oauth:2.0:oob', scopes = 'write')
}
 
#' @export
login = function(instance, user, pass) {
  client = registration(instance)
  r = post(instance, 'oauth/token', client_id = client$client_id,
    client_secret = client$client_secret, grant_type = 'password',
    username = user, password = pass, scope = 'write')
  if (is.null(r$access_token)) stop('Login failed')

  append(r, list(instance = instance))
}

post_auth = function(token, type, ...) {
  post_api(token$instance, type, ...,
    config = add_headers(Authorization = paste('Bearer', token$access_token)))
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
