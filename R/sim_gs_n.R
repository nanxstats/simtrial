#  Copyright (c) 2024 Merck & Co., Inc., Rahway, NJ, USA and its affiliates.
#  All rights reserved.
#
#  This file is part of the simtrial program.
#
#  simtrial is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.

#' Simulate group sequential designs with fixed sample size
#'
#' WARNING: This experimental function is a work-in-progress. The function
#' arguments will change as we add additional features.
#'
#' @inheritParams sim_fixed_n
#' @param test One or more test functions such as [wlr()], [maxcombo()], or
#'   [rmst()]. If a single test function is provided, it will be applied at each
#'   cut. Alternatively a list of functions created by [create_test()]. The list
#'   form is experimental and currently limited. It only accepts one test per
#'   cutting (in the future multiple tests may be accepted), and all the tests
#'   must consistently return the same exact results (again this may be more
#'   flexible in the future). Importantly, note that the simulated data set is
#'   always passed as the first positional argument to each test function
#'   provided.
#' @param cut A list of cutting functions created by [create_cut()], see
#'   examples.
#' @param seed Random seed.
#' @param ... Arguments passed to the test function(s) provided by the argument
#'   `test`.
#'
#' @return A data frame summarizing the simulation ID, analysis date,
#'   z statistics or p-values.
#'
#' @export
#'
#' @examplesIf rlang::is_installed("gsDesign2")
#' library(gsDesign2)
#'
#' # Parameters for enrollment
#' enroll_rampup_duration <- 4 # Duration for enrollment ramp up
#' enroll_duration <- 16 # Total enrollment duration
#' enroll_rate <- define_enroll_rate(
#'   duration = c(
#'     enroll_rampup_duration,
#'     enroll_duration - enroll_rampup_duration
#'   ),
#'   rate = c(10, 30)
#' )
#'
#' # Parameters for treatment effect
#' delay_effect_duration <- 3 # Delay treatment effect in months
#' median_ctrl <- 9 # Survival median of the control arm
#' median_exp <- c(9, 14) # Survival median of the experimental arm
#' dropout_rate <- 0.001
#' fail_rate <- define_fail_rate(
#'   duration = c(delay_effect_duration, 100),
#'   fail_rate = log(2) / median_ctrl,
#'   hr = median_ctrl / median_exp,
#'   dropout_rate = dropout_rate
#' )
#'
#' # Other related parameters
#' alpha <- 0.025 # Type I error
#' beta <- 0.1 # Type II error
#' ratio <- 1 # Randomization ratio (experimental:control)
#'
#' # Define cuttings of 2 IAs and 1 FA
#' # IA1
#' # The 1st interim analysis will occur at the later of the following 3 conditions:
#' # - At least 20 months have passed since the start of the study.
#' # - At least 100 events have occurred.
#' # - At least 20 months have elapsed after enrolling 200/400 subjects, with a
#' #   minimum of 20 months follow-up.
#' # However, if events accumulation is slow, we will wait for a maximum of 24 months.
#' ia1 <- create_cut(
#'   planned_calendar_time = 20,
#'   target_event_overall = 100,
#'   max_extension_for_target_event = 24,
#'   min_n_overall = 200,
#'   min_followup = 20
#' )
#'
#' # IA2
#' # The 2nd interim analysis will occur at the later of the following 3 conditions:
#' # - At least 32 months have passed since the start of the study.
#' # - At least 250 events have occurred.
#' # - At least 10 months after IA1.
#' # However, if events accumulation is slow, we will wait for a maximum of 34 months.
#' ia2 <- create_cut(
#'   planned_calendar_time = 32,
#'   target_event_overall = 200,
#'   max_extension_for_target_event = 34,
#'   min_time_after_previous_analysis = 10
#' )
#'
#' # FA
#' # The final analysis will occur at the later of the following 2 conditions:
#' # - At least 45 months have passed since the start of the study.
#' # - At least 300 events have occurred.
#' fa <- create_cut(
#'   planned_calendar_time = 45,
#'   target_event_overall = 350
#' )
#'
#' # Test 1: regular logrank test
#' sim_gs_n(
#'   n_sim = 3,
#'   sample_size = 400,
#'   enroll_rate = enroll_rate,
#'   fail_rate = fail_rate,
#'   test = wlr,
#'   cut = list(ia1 = ia1, ia2 = ia2, fa = fa),
#'   seed = 2024,
#'   weight = fh(rho = 0, gamma = 0)
#' )
#'
#' # Test 2: weighted logrank test by FH(0, 0.5)
#' sim_gs_n(
#'   n_sim = 3,
#'   sample_size = 400,
#'   enroll_rate = enroll_rate,
#'   fail_rate = fail_rate,
#'   test = wlr,
#'   cut = list(ia1 = ia1, ia2 = ia2, fa = fa),
#'   seed = 2024,
#'   weight = fh(rho = 0, gamma = 0.5)
#' )
#'
#' # Test 3: weighted logrank test by MB(3)
#' sim_gs_n(
#'   n_sim = 3,
#'   sample_size = 400,
#'   enroll_rate = enroll_rate,
#'   fail_rate = fail_rate,
#'   test = wlr,
#'   cut = list(ia1 = ia1, ia2 = ia2, fa = fa),
#'   seed = 2024,
#'   weight = mb(delay = 3)
#' )
#'
#' # Test 4: weighted logrank test by early zero (6)
#' sim_gs_n(
#'   n_sim = 3,
#'   sample_size = 400,
#'   enroll_rate = enroll_rate,
#'   fail_rate = fail_rate,
#'   test = wlr,
#'   cut = list(ia1 = ia1, ia2 = ia2, fa = fa),
#'   seed = 2024,
#'   weight = early_zero(6)
#' )
#'
#' # Test 5: RMST
#' sim_gs_n(
#'   n_sim = 3,
#'   sample_size = 400,
#'   enroll_rate = enroll_rate,
#'   fail_rate = fail_rate,
#'   test = rmst,
#'   cut = list(ia1 = ia1, ia2 = ia2, fa = fa),
#'   seed = 2024,
#'   tau = 20
#' )
#'
#' # Test 6: Milestone
#' sim_gs_n(
#'   n_sim = 3,
#'   sample_size = 400,
#'   enroll_rate = enroll_rate,
#'   fail_rate = fail_rate,
#'   test = milestone,
#'   cut = list(ia1 = ia1, ia2 = ia2, fa = fa),
#'   seed = 2024,
#'   ms_time = 10
#' )
#'
#' # Test 7: MaxCombo (WLR-FH(0,0) + WLR-FH(0, 0.5))
#' # for all analyses
#' sim_gs_n(
#'   n_sim = 3,
#'   sample_size = 400,
#'   enroll_rate = enroll_rate,
#'   fail_rate = fail_rate,
#'   test = maxcombo,
#'   cut = list(ia1 = ia1, ia2 = ia2, fa = fa),
#'   seed = 2024,
#'   rho = c(0, 0),
#'   gamma = c(0, 0.5)
#' )
#'
#' # Test 8: MaxCombo (WLR-FH(0,0.5) + milestone(10))
#' # for all analyses
#' \dontrun{
#' sim_gs_n(
#'   n_sim = 3,
#'   sample_size = 400,
#'   enroll_rate = enroll_rate,
#'   fail_rate = fail_rate,
#'   test = maxcombo(test1 = wlr, test2 = milestone),
#'   cut = list(ia1 = ia1, ia2 = ia2, fa = fa),
#'   seed = 2024,
#'   test1_par = list(weight = fh(rho = 0, gamma = 0.5)),
#'   test2_par = list(ms_time = 10)
#' )
#' }
#'
#' # Test 9: MaxCombo (WLR-FH(0,0) at IAs
#' # and WLR-FH(0,0) + milestone(10) + WLR-MB(4,2) at FA)
#' \dontrun{
#' sim_gs_n(
#'   n_sim = 3,
#'   sample_size = 400,
#'   enroll_rate = enroll_rate,
#'   fail_rate = fail_rate,
#'   test = list(ia1 = wlr, ia2 = wlr, fa = maxcombo),
#'   cut = list(ia1 = ia1, ia2 = ia2, fa = fa),
#'   seed = 2024,
#'   test_par = list(
#'     ia1 = list(weight = fh(rho = 0, gamma = 0)),
#'     ia2 = list(weight = fh(rho = 0, gamma = 0)),
#'     ia3 = list(
#'       test1_par = list(weight = fh(rho = 0, gamma = 0)),
#'       test2_par = list(ms_time = 10),
#'       test3_par = list(delay = 4, w_max = 2)
#'     )
#'   )
#' )
#' }
sim_gs_n <- function(
    n_sim = 1000,
    sample_size = 500,
    stratum = data.frame(stratum = "All", p = 1),
    enroll_rate = data.frame(duration = c(2, 2, 10), rate = c(3, 6, 9)),
    fail_rate = data.frame(
      stratum = "All",
      duration = c(3, 100),
      fail_rate = log(2) / c(9, 18),
      hr = c(.9, .6),
      dropout_rate = rep(.001, 2)
    ),
    block = rep(c("experimental", "control"), 2),
    test = wlr,
    cut = NULL,
    seed = 2024,
    ...) {
  # Input checking
  # TODO

  # Simulate for `n_sim` times
  ans <- NULL
  for (sim_id in seq_len(n_sim)) {
    set.seed(seed + sim_id)
    # Generate data
    simu_data <- sim_pw_surv(
      n = sample_size,
      stratum = stratum,
      block = block,
      enroll_rate = enroll_rate,
      fail_rate = to_sim_pw_surv(fail_rate)$fail_rate,
      dropout_rate = to_sim_pw_surv(fail_rate)$dropout_rate
    )

    # Initialize the cut date of IA(s) and FA
    n_analysis <- length(cut)
    cut_date <- rep(-100, n_analysis)
    ans_1sim <- NULL

    # Organize tests for each cutting
    if (is.function(test)) {
      test_single <- test
      test <- vector(mode = "list", length = n_analysis)
      test[] <- list(test_single)
    }
    if (length(test) != length(cut)) {
      stop("If you want to run different tests at each cutting, the list of
           tests must be the same length as the list of cuttings")
    }

    for (i_analysis in seq_len(n_analysis)) {
      # Get cut date
      cut_date[i_analysis] <- cut[[i_analysis]](simu_data)

      # Cut the data
      simu_data_cut <- simu_data |> cut_data_by_date(cut_date[i_analysis])

      # Test
      ans_1sim_new <- test[[i_analysis]](simu_data_cut, ...)
      ans_1sim_new$analysis <- i_analysis
      ans_1sim_new$cut_date <- cut_date[i_analysis]
      ans_1sim_new$sim_id <- sim_id
      ans_1sim_new$n <- nrow(simu_data_cut)
      ans_1sim_new$event <- sum(simu_data_cut$event)

      # rbind simulation results for all IA(s) and FA in 1 simulation
      ans_1sim <- rbind(ans_1sim, ans_1sim_new)
    }

    ans <- rbind(ans, ans_1sim)
  }
  return(ans)
}

#' Create a cutting function
#'
#' Create a cutting function for use with [sim_gs_n()]
#'
#' @param ... Arguments passed to [get_analysis_date()]
#'
#' @return A function that accepts a data frame of simulated trial data and
#'   returns a cut date
#'
#' @export
#'
#' @seealso [get_analysis_date()], [sim_gs_n()]
#'
#' @examples
#' # Simulate trial data
#' trial_data <- sim_pw_surv()
#'
#' # Create a cutting function that applies the following 2 conditions:
#' # - At least 45 months have passed since the start of the study
#' # - At least 300 events have occurred
#' cutting <- create_cut(
#'   planned_calendar_time = 45,
#'   target_event_overall = 350
#' )
#'
#' # Cut the trial data
#' cutting(trial_data)
create_cut <- function(...) {
  function(data) {
    get_analysis_date(data, ...)
  }
}

#' Create a cutting test function
#'
#' Create a cutting test function for use with [sim_gs_n()]
#'
#' @param test A test function such as [wlr()], [maxcombo()], or [rmst()]
#' @param ... Arguments passed to the cutting test function
#'
#' @return A function that accepts a data frame of simulated trial data and
#'   returns a test result
#'
#' @export
#'
#' @seealso [sim_gs_n()], [create_cut()]
#'
#' @examples
#' # Simulate trial data
#' trial_data <- sim_pw_surv()
#'
#' # Cut after 150 events
#' trial_data_cut <- cut_data_by_event(trial_data, 150)
#'
#' # Create a cutting test function that can be used by sim_gs_n()
#' regular_logrank_test <- create_test(wlr, weight = fh(rho = 0, gamma = 0))
#'
#' # Test the cutting
#' regular_logrank_test(trial_data_cut)
#'
#' # The results are the same as directly calling the function
#' stopifnot(all.equal(
#'   regular_logrank_test(trial_data_cut),
#'   wlr(trial_data_cut, weight = fh(rho = 0, gamma = 0))
#' ))
create_test <- function(test, ...) {
  stopifnot(is.function(test))
  function(data) {
    test(data, ...)
  }
}

#' Perform multiple tests on trial data cutting
#'
#' WARNING: This experimental function is a work-in-progress. The function
#' arguments and/or returned output format may change as we add additional
#' features.
#'
#' @param data Trial data cut by [cut_data_by_event()] or [cut_data_by_date()]
#' @param ... One or more test functions. Use [create_test()] to change
#'   the default arguments of each test function.
#'
#' @return A list of test results, one per test. If the test functions are named
#'   in the call to `multitest()`, the returned list uses the same names.
#'
#' @export
#'
#' @seealso [create_test()]
#'
#' @examples
#' trial_data <- sim_pw_surv(n = 200)
#' trial_data_cut <- cut_data_by_event(trial_data, 150)
#'
#' # create cutting test functions
#' wlr_partial <- create_test(wlr, weight = fh(rho = 0, gamma = 0))
#' rmst_partial <- create_test(rmst, tau = 20)
#' maxcombo_partial <- create_test(maxcombo, rho = c(0, 0), gamma = c(0, 0.5))
#'
#' multitest(
#'   data = trial_data_cut,
#'   wlr = wlr_partial,
#'   rmst = rmst_partial,
#'   maxcombo = maxcombo_partial
#' )
multitest <- function(data, ...) {
  tests <- list(...)
  output <- vector(mode = "list", length = length(tests))
  names(output) <- names(tests)
  for (i in seq_along(tests)) {
    output[[i]] <- tests[[i]](data)
  }
  return(output)
}
