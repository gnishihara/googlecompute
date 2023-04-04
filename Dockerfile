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


RUN mkdir -p $HOME/.R/ \ 
  && echo "CXX=clang++ -stdlib=libc++ -fsanitize=address,undefined -fno-sanitize=float-divide-by-zero -fno-omit-frame-pointer -fsanitize-address-use-after-scope -fno-sanitize=alignment -frtti" >> $HOME/.R/Makevars \
  && echo "CC=clang -fsanitize=address,undefined -fno-sanitize=float-divide-by-zero -fno-omit-frame-pointer -fsanitize-address-use-after-scope -fno-sanitize=alignment" >> $HOME/.R/Makevars \
  && echo "CFLAGS=-O3 -Wall -pedantic -mtune=native" >> $HOME/.R/Makevars \
  && echo "FFLAGS=-O2 -mtune=native" >> $HOME/.R/Makevars \
  && echo "FCFLAGS=-O2 -mtune=native" >> $HOME/.R/Makevars \
  && echo "CXXFLAGS=-O3 -march=native -mtune=native -fPIC" >> $HOME/.R/Makevars \
  && echo "MAIN_LD=clang++ -stdlib=libc++ -fsanitize=undefined,address" >> $HOME/.R/Makevars \
  && echo "rstan::rstan_options(auto_write = TRUE)" >> /home/rstudio/.Rprofile \
  && echo "options(mc.cores = parallel::detectCores())" >> /home/rstudio/.Rprofile

RUN Rscript -e 'Sys.setenv(DOWNLOAD_STATIC_LIBV8 = 1); install.packages("rstan")'

ENV CMDSTAN /usr/share/.cmdstan

RUN cd /usr/share/ \
  && wget --progress=dot:mega https://github.com/stan-dev/cmdstan/releases/download/v2.31.0/cmdstan-2.31.0.tar.gz \
  && tar -zxpf cmdstan-2.31.0.tar.gz && mv cmdstan-2.31.0 .cmdstan \
  && ln -s .cmdstan cmdstan && cd .cmdstan && echo "CXX = clang++" >> make/local \
  && make build

RUN Rscript -e 'install.packages("cmdstanr", repos = c("https://mc-stan.org/r-packages/", getOption("repos")))' 
 
RUN install2.r --error --skipinstalled rstanarm

ENV BAYES_R_PACKAGES="\
    brms \
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


RUN install2.r --error --skipinstalled $BAYES_R_PACKAGES