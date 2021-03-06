#' @import survival
NULL

#' Time-to-event data example 1 for non-proportional hazards working group
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
#' @usage data(Ex1delayedEffect)
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
#' @seealso \code{\link{Ex2delayedEffect}}, \code{\link{Ex3curewithph}}, \code{\link{Ex4belly}},
#' \code{\link{Ex5widening}}, \code{\link{Ex6crossing}}
#'
#' @examples
#' library(survival)
#' data(Ex1delayedEffect)
#' km1 <- with(Ex1delayedEffect,survfit(Surv(month,evntd)~trt))
#' km1
#' plot(km1)
#' with(subset(Ex1delayedEffect,trt==1),survfit(Surv(month,evntd)~trt))
#' with(subset(Ex1delayedEffect,trt==0),survfit(Surv(month,evntd)~trt))
"Ex1delayedEffect"