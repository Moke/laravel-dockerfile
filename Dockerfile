FROM php:7.4-fpm-buster

WORKDIR /var/www/html

ENV DEBIAN_FRONTEND noninteractive
ENV TZ=UTC

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update -y && apt-get install -y \
    build-essential apt-utils gnupg wget apt-transport-https curl ca-certificates zip unzip libpng-dev

RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list

RUN pecl install -o -f redis \
    && rm -rf /tmp/pear \
    && docker-php-ext-enable redis

RUN apt-get update -y && apt-get upgrade -y && apt-get install -y \
      libicu-dev \
      zlib1g-dev \
      locales \
      libonig-dev \
      libmcrypt-dev openssl \
      libpq5 libpq-dev \
      libreadline-dev \
      libzip-dev \
      git unzip zip \
    && docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd \
    && docker-php-ext-configure intl \
    && docker-php-ext-configure opcache --enable-opcache \
    && docker-php-ext-install \
      pdo pdo_mysql \
      intl iconv bcmath \
      opcache mbstring \
      zip \
    && rm -rf /tmp/* \
    && rm -rf /var/list/apt/* \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

RUN docker-php-ext-install pdo pdo_pgsql

RUN apt-get update -y && ACCEPT_EULA=Y apt-get install -y \
    unixodbc \
    unixodbc-dev \
    libgss3 \
    odbcinst \
    devscripts debhelper dh-exec dh-autoreconf libreadline-dev libltdl-dev \
    msodbcsql17

RUN pecl install pdo_sqlsrv sqlsrv \
    && rm -rf /tmp/pear \
    && docker-php-ext-enable pdo_sqlsrv sqlsrv

EXPOSE 9000
CMD ["php-fpm"]
