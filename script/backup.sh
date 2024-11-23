#!/bin/bash

# Espera 15 segundos para que otros contenedores se inicialicen
sleep 30

# Variables
PG_HOST=${PG_HOST:-haproxy}
PG_PORT=${PG_PORT:-5434}
PG_USER=${PG_USER:-postgres}
PG_PASSWORD=${PG_PASSWORD:-pass}
PG_DATABASE=${PG_DATABASE:-quiosco}
BACKUP_DIR=${BACKUP_DIR:-/backups}

# Crear directorio de backups
mkdir -p $BACKUP_DIR

# Cambiar permisos para asegurar que el contenedor pueda escribir
chmod -R 777 $BACKUP_DIR

# Ciclo de backup cada 2 minutos
while true; do
  # Nombre del archivo de backup
  BACKUP_FILE="$BACKUP_DIR/backup_$(date +\%Y\%m\%d\%H\%M).backup"

  # Realizar el backup
  PGPASSWORD=$PG_PASSWORD pg_dump -h $PG_HOST -p $PG_PORT -U $PG_USER -F c -b -v -f $BACKUP_FILE $PG_DATABASE

  # Eliminar backups antiguos (más de 5 minutos)
  find $BACKUP_DIR -type f -name "*.backup" -mmin +5 -exec rm -f {} \;

  # Esperar 2 minutos antes del siguiente backup
  sleep 60
done
