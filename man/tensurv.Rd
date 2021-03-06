% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/tensurv.R
\name{tensurv}
\alias{tensurv}
\title{Process Survival Data into Counting Process Format}
\usage{
tensurv(x, txval)
}
\arguments{
\item{x}{a tibble with no missing values and contain variables

    \code{Stratum} (Stratum)

    \code{Treatment} (Treatment group)

    \code{tte} (Observed time)

    \code{event} (Binary event indicator, 1 represents event, 0 represents censoring)}

\item{txval}{value in the input \code{Treatment} column that indicates treatment group value.}
}
\value{
A \code{tibble} grouped by
\code{Stratum} and sorted within strata by \code{tte}.
Remain rows with at least one event in the population, at least one subject is at risk in both treatment group and control group.
Other variables in this represent the following within each stratum at each time at which one or more
events are observed:

\code{events} (Total number of events)

\code{txevents} (Total number of events at treatment group)

\code{atrisk} (Number of subjects at risk)

\code{txatrisk} (Number of subjects at risk in treatment group)

\code{S} (Left-continuous Kaplan-Meier survival estimate)

\code{OminusE} (In treatment group, observed number of events minus expected number of events.
          The expected number of events is estimated by assuming no treatment effect with hypergeometric distribution with
          parameters total number of events, total number of events at treatment group and number of events at a time.
          (Same assumption of log-rank test under the null hypothesis)

\code{Var} (variance of OminusE under the same assumption).
}
\description{
Produces a tibble that is sorted by stratum and time.
Included in this is only the times at which one or more event occurs.
The output dataset contains Stratum, tte (time-to-event), at risk count and count of events at the specified tte
sorted by Stratum and tte.
}
\details{
The function only considered two group situation.

The tie is handled by the Breslow's Method.
}
\examples{
library(dplyr)

# Example 1
x=tibble(Stratum = c(rep(1,10),rep(2,6)),
Treatment = rep(c(1,1,0,0),4),
tte = 1:16,
event= rep(c(0,1),8))

tensurv(x, txval=1)

# Example 2
x <- simPWSurv(n=400)
y <- cutDataAtCount(x,150) \%>\% tensurv(txval = "Experimental")
# weighted logrank test (Z-value and 1-sided p-value)
z <- sum(y$OminusE)/sqrt(sum(y$Var))
c(z,pnorm(z))

}
