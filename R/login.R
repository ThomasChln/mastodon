api_call = function(fun, instance, type, config = list(), ...) {
  r = fun(paste0(instance, type), config, body = list(...))
  stop_for_status(r)
  content(r)
}

post = function(...) api_call(POST, ...)

post_api = function(instance, type, ...) {
  post(instance, paste0('api/v1/', type), ...)
}

registration = function(instance) {
  post_api(instance, 'apps', client_name = 'mastodon_r_package',
    redirect_uris = 'urn:ietf:wg:oauth:2.0:oob', scopes = 'read write follow')
}
 
#' @export
login = function(instance, user, pass) {
  client = registration(instance)
  r = post(instance, 'oauth/token', client_id = client$client_id,
    client_secret = client$client_secret, grant_type = 'password',
    username = user, password = pass, scope = 'read write follow')
  if (is.null(r$access_token)) stop('Login failed')

  append(r, list(instance = instance))
}

