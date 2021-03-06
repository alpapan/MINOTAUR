
#include <Rcpp.h>
#include "kernelDeviance.h"

using namespace std;

//------------------------------------------------
//' @name C_kernelDeviance
//' @title Overall deviance for given kernel bandwidth
//' @description Calculates overall deviance (-2*log-likelihood) for given kernel bandwidth. Likelihood of point i is equal to kernel density from all other points in subset, and likelihood of overall data is product over i.
//' @keywords internal
// [[Rcpp::export]]

Rcpp::List C_kernelDeviance(std::vector< std::vector<double> > data, std::vector<int> subset, double sigma2, std::vector< std::vector<double> > S_inv) {

    int dims = int(data.size());
    int n = int(data[0].size());
    int sub_size = int(subset.size());
    double C1 = 0.5/sigma2;
    int tmp;

    double x, y, z;
    double deviance = 0;

    for (int i=0; i<n; i++) {
        z = log(0.0);
        tmp = 0;
        for (int j=0; j<sub_size; j++) {
            if (i==j)
                continue;
            tmp++;
            x = 0;
            for (int k1=0; k1<dims; k1++) {
                for (int k2=k1; k2<dims; k2++) {
                    y = (data[k1][i]-data[k1][subset[j]])*S_inv[k1][k2]*(data[k2][i]-data[k2][subset[j]]);
                    if (k1==k2) {
                        x += y;
                    } else {
                        x += 2*y;
                    }
                }
            }
            // the next if statement does z' = log(exp(z) + exp(-x*C1)) while avoiding underflow/overflow issues.
            if ((-x*C1)>z) {
                z = -x*C1 + log(1 + exp(z + x*C1));
            } else {
                z = z + log(1 + exp(-x*C1 - z));
            }
        }
        deviance += -2*(-log(double(tmp-1)) - 0.5*dims*log(6.283185*sigma2) + z);
    }

    // return logLike
    return Rcpp::List::create(Rcpp::Named("deviance")=deviance);
}

//------------------------------------------------
//' @name C_kernelDeviance_partial
//' @title overall deviance for given kernel bandwidth using chunk of data to enable the use of a progress bar for large datasets
//' @description Equivalent to C_kernelDeviance, but only performs calculation on chunk of data, allowing calculation to be broken into sections and thus tracked by a progress bar.
//' @keywords internal
// [[Rcpp::export]]

Rcpp::List C_kernelDeviance_partial(std::vector< std::vector<double> > data, double sigma2, std::vector< std::vector<double> > S_inv, int i_start, int i_end) {

    int dims = int(data.size());
    int n = data[0].size();
    double C1 = 0.5/sigma2;
    double C2 = 2*log(double(n-1)) + dims*log(6.283185*sigma2);

    double x, y, z;
    double deviance = 0;

    for (int i=(i_start-1); i<i_end; i++) {
        z = log(0.0);
        for (int j=0; j<n; j++) {
            if (i==j)
                continue;
            x = 0;
            for (int k1=0; k1<dims; k1++) {
                for (int k2=k1; k2<dims; k2++) {
                    y = (data[k1][i]-data[k1][j])*S_inv[k1][k2]*(data[k2][i]-data[k2][j]);
                    if (k1==k2) {
                        x += y;
                    } else {
                        x += 2*y;
                    }
                }
            }
            // the next if statement does z' = log(exp(z) + exp(-x*C1)) while avoiding underflow/overflow issues.
            if ((-x*C1)>z) {
                z = -x*C1 + log(1 + exp(z + x*C1));
            } else {
                z = z + log(1 + exp(-x*C1 - z));
            }
        }
        deviance += C2 - 2*z;
    }

    // return logLike
    return Rcpp::List::create(Rcpp::Named("deviance")=deviance);
}
