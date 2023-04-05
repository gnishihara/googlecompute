FROM rocker/tidyverse
MAINTAINER Greg Nishihara (greg@nagasaki-u.ac.jp)

# install cron and R package dependencies
RUN apt-get update && apt-get install -y \
    imagemagick \
    ## clean up
    && apt-get clean \ 
    && rm -rf /var/lib/apt/lists/ \ 
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds
    
RUN mkdir .R
RUN echo " " > .R/Makevars
RUN echo "CXX14FLAGS=-O3 -march=native -mtune=native -fPIC" >> .R/Makevars
RUN echo "CXX14=g++" >> .R/Makevars
RUN echo " " >> .R/Makevars
RUN export MAKEFLAGS='-j 8'

## Install packages from CRAN


# RUN Rscript -e 'install.packages("cmdstanr", repos = c("https://mc-stan.org/r-packages/", getOption("repos")), Ncpus = 4)' 
# RUN Rscript -e 'library(cmdstanr); install_cmdstan(); cmdstan_path();' 
 
RUN Rscript -e 'install.packages("rstan", repos = "https://cloud.r-project.org/", dependencies = TRUE, Ncpus = 8)'
RUN install2.r --ncpus -1 --error --skipinstalled rstanarm

ENV BAYES_R_PACKAGES="\
    brms \
    rstantools \
    parallel \
    tidyverse \
    furrr \
    future \
    future.apply \
" 


RUN install2.r --ncpus -1 --error \
    -r 'http://cran.rstudio.com' \
    --skipinstalled $BAYES_R_PACKAGES \
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds \