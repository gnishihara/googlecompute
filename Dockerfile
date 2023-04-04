FROM rocker/tidyverse
MAINTAINER Greg Nishihara (greg@nagasaki-u.ac.jp)

# install cron and R package dependencies
RUN apt-get update && apt-get install -y \
    cron \
    nano \
    imagemagick \
    ## clean up
    && apt-get clean \ 
    && rm -rf /var/lib/apt/lists/ \ 
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds
    
## Install packages from CRAN
RUN install2.r --error \ 
    -r 'http://cran.rstudio.com' \
    googleAuthR  \
    ## install Github packages
    && Rscript -e "devtools::install_github(c('bnosac/cronR'))" \
    ## clean up
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds \



RUN Rscript -e 'install.packages("cmdstanr", repos = c("https://mc-stan.org/r-packages/", getOption("repos")))' 
RUN Rscript -e 'library(cmdstanr); install_cmdstan(); cmdstan_path();' 
 
RUN Rscript -e  'Sys.setenv(DOWNLOAD_STATIC_LIBV8 = 1); install.packages("rstan", repos = "https://cloud.r-project.org/", dependencies = TRUE)'

RUN install2.r --error --skipinstalled rstanarm

ENV BAYES_R_PACKAGES="\
    brms \
    posterior \
    tidybayes \
    bayesplot \
    Matrix \
    furrr \
    patchwork \
    ggpubr \
    tidybayes \
    bayesplot \
    ggmcmc \
    marelac \
    mgcv \
    magick \
" 


RUN install2.r --error \
    -r 'http://cran.rstudio.com' \
    --skipinstalled $BAYES_R_PACKAGES \