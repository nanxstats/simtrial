#' @import survival
NULL

#' Time-to-event data example 6 for non-proportional hazards working group
#'
#' Survival objects reverse-engineered datasets from published Kaplan-Meier
#' curves. 
#' Individual trials are de-identified since the data are only
#' approximations of the actual data.
#' Data are intended to evaluate methods and designs for trials where
#' non-proportional hazards may be anticipated for outcome data.  
#'
#' @docType data
#'
#' @usage data(Ex6crossing)
#'
#' @format Data frame with 4 variables:
#' \describe{ 
#' \item{id}{sequential numbering of unique identifiers}
#' \item{month}{time-to-event}
#' \item{event}{1 for event, 0 for censored} 
#' \item{trt}{1 for experimental, 0 for control}
#' }
#' 
#' @keywords datasets
#'
#' @references TBD
#' 
#' @seealso \code{\link{Ex1delayedEffect}}, \code{\link{Ex2delayedEffect}}, 
#' \code{\link{Ex3curewithph}},
#' \code{\link{Ex4belly}}, \code{\link{Ex5widening}}
#'
#' @examples
#' library(survival)
#' data(Ex6crossing)
#' km1 <- with(Ex6crossing,survfit(Surv(month,evntd)~trt))
#' km1
#' plot(km1)
"Ex6crossing"