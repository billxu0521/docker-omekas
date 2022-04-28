FROM php:7.4-apache

# Omeka-S web publishing platform for digital heritage collections (https://omeka.org/s/)
# Initial maintainer: Oldrich Vykydal (o1da) - Klokan Technologies GmbH  
LABEL  maintainer="billxu <billxu0521@gmail.com>"

RUN a2enmod rewrite

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get -qq update && apt-get -qq -y upgrade
RUN apt-get -qq update && apt-get -qq -y --no-install-recommends install \
    unzip \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng-dev \
    libjpeg-dev \
    libmemcached-dev \
    zlib1g-dev \
    imagemagick \
    libmagickwand-dev

# Install the PHP extensions we need
RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install -j$(nproc) iconv pdo pdo_mysql mysqli gd
RUN pecl install mcrypt-1.0.3
RUN docker-php-ext-enable mcrypt && pecl install imagick && docker-php-ext-enable imagick 

# Add the Omeka-S PHP code
COPY ./omeka-s-3.1.0.zip /var/www/
RUN unzip -q /var/www/omeka-s-3.1.0.zip -d /var/www/ \
&&  rm /var/www/omeka-s-3.1.0.zip \
&&  rm -rf /var/www/html/ \
&&  mv /var/www/omeka-s/ /var/www/html/

COPY ./imagemagick-policy.xml /etc/ImageMagick/policy.xml
COPY ./.htaccess /var/www/html/.htaccess

# Add some Omeka modules
COPY ./BlockPlus-3.3.12.0.zip /var/www/html/modules/
RUN unzip -q /var/www/html/modules/BlockPlus-3.3.12.0.zip -d /var/www/html/modules/ \
	&&  rm /var/www/html/modules/BlockPlus-3.3.12.0.zip

# # # Add some themes
COPY ./theme-cozy-v1.5.3.zip /var/www/html/themes/
RUN unzip -q /var/www/html/themes/theme-cozy-v1.5.3.zip -d /var/www/html/themes/ \
    &&  rm /var/www/html/themes/theme-cozy-v1.5.3.zip

# Create one volume for files and config
# RUN mkdir -p /var/www/html/volume/config/ && mkdir -p /var/www/html/volume/files/
COPY ./database.ini /var/www/html/config/
#RUN rm /var/www/html/config/database.ini \
#&& ln -s /var/www/html/volume/config/database.ini /var/www/html/config/database.ini \
#&& rm -Rf /var/www/html/files/ \
#&& ln -s /var/www/html/volume/files/ /var/www/html/files \
#&& chown -R www-data:www-data /var/www/html/ \
#&& chmod 600 /var/www/html/volume/config/database.ini \
#&& chmod 600 /var/www/html/.htaccess
RUN chmod -R 775 /var/www/html/files \
    && chown -R www-data:www-data /var/www/html/files
#VOLUME /var/www/html/volume/

CMD ["apache2-foreground"] 
