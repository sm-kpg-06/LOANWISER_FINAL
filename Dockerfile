# Dockerfile for Deploying LoanWiser to Render (https://render.com)
# Uses Rocker Shiny base image (Ubuntu 22.04 LTS + R + Shiny)
FROM rocker/shiny:4.3.3

# Install system dependencies required by R packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    libcairo2-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    && rm -rf /var/lib/apt/lists/*

# Install R packages using Posit Package Manager (Pre-compiled Linux binaries for fast build)
RUN R -e "options(repos = c(CRAN = 'https://packagemanager.posit.co/cran/__linux__/jammy/latest')); \
    install.packages(c( \
      'shinydashboard', \
      'plotly', \
      'DT', \
      'ggplot2', \
      'dplyr', \
      'scales', \
      'randomForest', \
      'xgboost', \
      'pROC', \
      'janitor' \
    ))"

# Set working directory inside container
WORKDIR /app

# Copy application files into container
COPY . /app

# Expose default port (Render will override dynamically at runtime via $PORT)
EXPOSE 3838

# Run LoanWiser listening on 0.0.0.0 and dynamic Render PORT
CMD ["R", "-e", "shiny::runApp('/app', host = '0.0.0.0', port = as.numeric(Sys.getenv('PORT', '3838')))"]
