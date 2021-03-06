% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/rpwenroll.R
\name{rpwenroll}
\alias{rpwenroll}
\title{Generate Piecewise Exponential Enrollment}
\usage{
rpwenroll(
  n = NULL,
  enrollRates = tibble::tibble(duration = c(1, 2), rate = c(2, 5))
)
}
\arguments{
\item{n}{Number of observations.
Default of \code{NULL} yields random enrollment size.}

\item{enrollRates}{A tibble containing period duration (\code{duration}) and enrollment rate (\code{rate})
for specified enrollment periods.
If necessary, last period will be extended to ensure enrollment of specified \code{n}.}
}
\value{
A vector of random enrollment times.
}
\description{
With piecewise exponential enrollment rate generation any enrollment rate distribution can be easily approximated.
\code{rpwenroll()} is to support simulation of both the Lachin and Foulkes (1986) sample size
method for (fixed trial duration) as well as the Kim and Tsiatis(1990) method
(fixed enrollment rates and either fixed enrollment duration or fixed minimum follow-up);
see \code{\link[gsDesign:nSurv]{gsDesign}}.
}
\examples{
# piecewise uniform (piecewise exponential inter-arrival times) for 10k patients enrollment
# enrollment rates of 5 for time 0-100, 15 for 100-300, and 30 thereafter
x <- rpwenroll(n=10000, enrollRates=tibble::tibble(rate = c(5, 15, 30), duration = c(100,200,100)))
plot(x,1:10000,
     main="Piecewise uniform enrollment simulation",xlab="Time",
     ylab="Enrollment")
# exponential enrollment
x <- rpwenroll(10000, enrollRates=tibble::tibble(rate = .03, duration = 1))
plot(x,1:10000,main="Simulated exponential inter-arrival times",
     xlab="Time",ylab="Enrollment")

}
