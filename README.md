### **README: Configuración del Entorno **

Para establecer el entorno de ejecución en Rails, usa:

```bash
export RAILS_ENV=development   # Modo desarrollo
export RAILS_ENV=test          # Modo pruebas
export RAILS_ENV=production    # Modo producción
```

# Migración de Datos desde SEPREC en DESARROLLO maquina local
## Para ejecutar la migración de SEPREC desde RAKE
```bash
bundle exec rake crawl:info
```

<u>Nota.-</u> 
1. Para configurar la migración editar el archivo crawl_info.yml
2. El log de la migración de SEPREC está en crawl_info.log

# ZonificarComercios

## Descripción
`ZonificarComercios` es un servicio en Ruby on Rails que permite procesar y actualizar la información geoespacial de los comercios en una ciudad. Su función principal es identificar y zonificar los comercios según sus coordenadas geográficas, creando polígonos que representan las diferentes zonas comerciales dentro de una ciudad.

## Comando Principal

```ruby
ZonificarComercios.ejecutar(ID_CIUDAD)
```

### Parámetro
- **`ID_CIUDAD`** (*Integer*): El identificador único de la ciudad que se desea procesar. Este ID corresponde al registro de la ciudad en la base de datos.

## ¿Qué Hace Este Comando?
1. **Inicio del Proceso:** Inicia la zonificación para la ciudad indicada por `ID_CIUDAD`.
2. **Obtención de Zonas Elegibles:** Filtra y agrupa los comercios que cumplen con ciertos criterios (como cantidad mínima de registros y coordenadas válidas).
3. **Generación de Polígonos:** Calcula polígonos geoespaciales para cada zona elegible basándose en las coordenadas de los comercios.
4. **Actualización de la Base de Datos:** Inserta o actualiza los registros de las zonas en la tabla `zonas_shape`.
5. **Asignación de Zona a Comercios:** Asocia cada comercio con la zona correspondiente basándose en coincidencias de texto y relaciones espaciales.
6. **Actualización de Totales:** Calcula y actualiza el número total de comercios por zona y por ciudad.
7. **Verificación:** Confirma que los datos en `zonas_shape` se hayan actualizado correctamente.

## Ejemplo de Uso

```ruby
# Para procesar la ciudad con ID 59
ZonificarComercios.ejecutar(59)
```

Este comando iniciará el proceso de zonificación para la ciudad con ID 59, actualizando la información geoespacial en la base de datos.

## Consideraciones
- Asegúrate de que la base de datos esté actualizada y que los comercios tengan coordenadas válidas.
- El proceso puede tardar dependiendo del volumen de datos de la ciudad.
- Revisa los logs de la aplicación para obtener detalles del proceso.

## Logs
El proceso generará logs informativos que podrás consultar para verificar el estado de la ejecución:

- **Inicio de la zonificación:** Indica cuándo comienza el proceso.
- **Zonas encontradas:** Lista las zonas procesadas.
- **Errores:** Cualquier problema encontrado durante la ejecución.

---

Este comando es útil para mantener actualizada la información de zonas y comercios en sistemas que dependen de datos geoespaciales.

