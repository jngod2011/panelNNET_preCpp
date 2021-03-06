

OLStrick_function <- function(parlist, hidden_layers, y, fe_var, lam, parapen){
#parlist <- pnn$parlist
#hidden_layers <- pnn$hidden_layers
#y = pnn$y
#fe_var <- pnn$fe_var
#lam <- pnn$lam
#parapen <- pnn$parapen
# hidden_layers <- hlayers
  constraint <- sum(c(parlist$beta_param*parapen, parlist$beta)^2)
  #getting implicit regressors depending on whether regression is panel
  if (!is.null(fe_var)){
    Zdm <- demeanlist(as.matrix(hidden_layers[[length(hidden_layers)]]), list(fe_var))
    targ <- demeanlist(y, list(fe_var))
  } else {
    Zdm <- hidden_layers[[length(hidden_layers)]]
    targ <- y
  }
  #set up the penalty vector
  D <- rep(1, ncol(Zdm))
  if (is.null(fe_var)){
    pp <- c(0, parapen) #never penalize the intercept
  } else {
    pp <- parapen #parapen
  }
  D[1:length(pp)] <- D[1:length(pp)]*pp #incorporate parapen into diagonal of covmat
  #function to find implicit lambda
  f <- function(lam){
    bi <- solve(crossprod(Zdm) + diag(D)*lam) %*% t(Zdm) %*% targ
    (t(bi*D) %*% (bi*D) - constraint)^2
  }
  #optimize it
  o <- optim(par = lam, f = f, method = 'Brent', lower = lam, upper = 1e9)
  #new lambda
  newlam <- o$par
  #New top-level params
  b <- solve(crossprod(Zdm) + diag(D)*o$par) %*% t(Zdm) %*% y
  parlist$beta_param <- b[grepl('param', rownames(b))]
  parlist$beta <- b[grepl('nodes', rownames(b))]
  return(parlist)
}





#mean((targ - Zdm %*% c(parlist$beta_param, parlist$beta))^2)
#mean((targ - Zdm %*% b)^2)
