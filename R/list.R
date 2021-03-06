
#' List all checks for an email address
#'
#' @param email Email address. By default it is guessed with
#'   [whoami::email_address()]. The address must be validated, see
#'   [validate_email()].
#' @param package `NULL`, or a character scalar. Can be used to restrict
#'   the search for a single package.
#' @param howmany How many check groups (checks submitted simultaneously) to show. The current API limit is 20.
#' @return An [`rhub_check_list`] object.
#'
#' @export
#' @examples
#' \dontrun{
#' ch <- list_my_checks()
#' ch
#' ch$details()
#' }

list_my_checks <- function(email = email_address(), package = NULL,
                           howmany = 20) {

  assert_that(is_email(email))
  assert_that(is_string_or_null(package))
  assert_that(is_count(howmany))

  response <- if (is.null(package)) {
    query(
      "LIST BUILDS EMAIL",
      params = list(email = email, token = email_get_token(email)))
  } else {
    query(
      "LIST BUILDS PACKAGE",
      params = list(email = email, package = package,
                    token = email_get_token(email)))
  }

  if (length(response) > howmany) response <- response[seq_len(howmany)]

  rhub_check_list$new(ids = names(response), 
                      status = unlist(response, recursive = FALSE))
}


#' List checks of a package
#'
#' @param package Directory of an R package, or a package tarball.
#' @param email Email address that was used for the check(s).
#'   If `NULL`, then the maintainer address is used.
#' @param howmany How many checks to show. The current maximum of the API
#'   is 20.
#' @return An [`rhub_check_list`] object.
#'
#' @export
#' @importFrom desc desc_get
#' @examples
#' \dontrun{
#' ch <- list_my_checks()
#' ch
#' ch$details(1)
#' }

list_package_checks <- function(package = ".", email = NULL, howmany = 20) {

  assert_that(is_pkg_dir_or_tarball(package))
  if (is.null(email)) email  <- get_maintainer_email(package)
  assert_that(is_email(email))
  assert_that(is_count(howmany))

  package <- unname(desc_get("Package", file = package))

  response <- query(
    "LIST BUILDS PACKAGE",
    params = list(email = email, package = package,
                  token = email_get_token(email))
  )

  if (length(response) > howmany) response <- response[seq_len(howmany)]

  rhub_check_list$new(ids = names(response), 
                      status = unlist(response, recursive = FALSE))
}
