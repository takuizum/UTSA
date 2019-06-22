data {
  int<lower = 0> N; // n ob subjects
  int<lower = 0> J; // n of items
  int<lower = 2> K[J];  // n of categories in each item
  int group[N]; // group index vector
  int base; // base group number
  int nonbase[max(group) - 1]; 
  int<lower = 0, upper = 999> Y[N, J];
}

transformed data{
  int G = max(group);
}

parameters {
  real mu_free[G - 1];
  real<lower = 0> sigma_free[G - 1];
  vector[N] theta;
  real<lower = 0> a[J];
  ordered[max(K)-1]d[J]; // category of items
  real mu_d[J, max(K)];
  // real<lower = 0> sigma_d[J, max(K)-1];
}

transformed parameters{
  real mu[G];
  real sigma[G];
  mu[base] = 0;
  mu[nonbase] = mu_free;
  sigma[base] = 1;
  sigma[nonbase] = sigma_free;
}

model {
  a ~ cauchy(0, 1);
  for(j in 1:J){
    for(k in 1:(K[j]-1)){
      mu_d[j, k] ~ normal(0, 5);
      // sigma_d[j, k] ~ cauchy(0, 5);
      d[j, k] ~ normal(mu_d[j, k], 1); // sigma_d[j, k]);
    }
  }
  for(i in 1:N){
    theta[i] ~ normal(mu[group[i]], sigma[group[i]]);
    for(j in 1:J){
      if(Y[i,j] == 999) continue; // skip missing
      Y[i,j] ~ ordered_logistic(a[j] * theta[i], a[j] * d[j,1:(K[j]-1)]);  // normal GRM
    }
  }
}

