test_wMB <- function(x, delay = 4){
  out <- NULL
  for (i in unique(x$Stratum)){
    outi <- x[x$Stratum==i,]
    outi.sort <- outi[order(outi$tte),]
    locmaxt <- length(outi.sort$tte[outi.sort$tte<=delay]) # location of the maximum timepoint (tte) that is less or equal to the input 'delay'
    outi$wMB <- NA
    outi$wMB[1:locmaxt] <- 1/outi$S[1:locmaxt]
    outi$wMB[(locmaxt+1):nrow(outi)] <- outi$wMB[locmaxt]
    out <- rbind(out,outi)
  }
  
  return(out)
}

# Test 1: for the situation of single stratum ####

test_that("Validation passed for the situation of single stratum",{
  x <- simPWSurv(n=200) %>% cutDataAtCount(125) %>% tensurv(txval="Experimental")
  
  out1 <- test_wMB(x, delay=3)
  out1 <- data.frame(out1[order(out1$Stratum,out1$tte),])
  out2 <- wMB(x, delay=3)
  out2 <- data.frame(out2[order(out2$Stratum,out2$tte),])
  testthat::expect_equal(out1,out2)
})

# Test 2: for the situation of multiple strata ####

test_that("Validation passed for the situation of multiple strata",{
  x <- simPWSurv(n=200,
                 # 2 strata,30% and 70% prevalence
                 strata=tibble::tibble(Stratum=c("Low","High"),p=c(.3,.7)),
                 failRates=tibble::tibble(Stratum=c(rep("Low",4),rep("High",4)),
                                          period=rep(1:2,4),
                                          Treatment=rep(c(rep("Control",2),rep("Experimental",2)),2),
                                          duration=rep(c(3,1),4),
                                          rate=c(.03,.05,.03,.03,.05,.08,.07,.04)),
                 dropoutRates=tibble::tibble(Stratum=c(rep("Low",2),rep("High",2)),
                                             period=rep(1,4),
                                             Treatment=rep(c("Control","Experimental"),2),
                                             duration=rep(1,4),
                                             rate=rep(.001,4))) %>% 
    cutDataAtCount(125) %>% 
    tensurv(txval="Experimental")
  
  out1 <- test_wMB(x, delay=3)
  out1 <- data.frame(out1[order(out1$Stratum,out1$tte),])
  out2 <- wMB(x, delay=3)
  out2 <- data.frame(out2[order(out2$Stratum,out2$tte),])
  testthat::expect_equal(out1,out2)
})

