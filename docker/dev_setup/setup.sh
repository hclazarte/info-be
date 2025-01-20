#!/bin/bash

# Instalar las dependencias de gems
bundle install

# Iniciar el servidor de Rails
rails server -b 0.0.0.0 -p 3002
