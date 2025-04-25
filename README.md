# Configuración del Entorno

Para establecer el entorno de ejecución en Rails, usa:

```bash
export RAILS_ENV=development   # Modo desarrollo
export RAILS_ENV=test          # Modo pruebas
export RAILS_ENV=production    # Modo producción
```
---

# Migración de Datos desde SEPREC

```bash
bundle exec rake crawl:info
```

<u>Nota.-</u> 
1. Para configurar la migración editar el archivo: 

```bash
cat ./backend/info_be/config/crawl_info.yml
```

2. El log de la migración de SEPREC está en el archivo:

```bash
tail ./backend/info_be/log/crawl_info.log
```
---

# Generación de Sitemaps

```bash
bundle exec rake sitemap:generate
```

`GeneradorSitemap` es un servicio que crea archivos XML para cada ciudad, estructurados según el estándar [Sitemaps.org](https://www.sitemaps.org/protocol.html), facilitando así la indexación por motores de búsqueda como Google.

### ¿Qué hace este comando?

1. Crea un sitemap por ciudad con más de 100 comercios activos.
2. Incluye URLs para:
   - Cada ciudad.
   - Cada zona dentro de la ciudad.
   - Cada comercio que:
     - Tiene email.
     - No es persona natural o ha autorizado su publicación.
3. Ordena los comercios de forma descendente por `id`, priorizando los más recientes.

Este comando crea archivos `.xml` en el directorio `public/sitemaps/`, uno por ciudad, listando las URLs que deben ser indexadas.

```bash
export RAILS_ENV=development
bundle exec rake sitemap:generate
```
---

# ZonificarComercios

Desde RAILS console

```ruby
ZonificarComercios.ejecutar(ID_CIUDAD)
```

### Parámetro
- **`ID_CIUDAD`** (*Integer*): El identificador único de la ciudad que se desea procesar. Este ID corresponde al registro de la ciudad en la base de datos.


## Descripción
`ZonificarComercios` es un servicio que permite básicamente 2 cosas procesar y actualizar las zonas de los comercios por su descripción y actualzia la información geoespacial de los comercios en una ciudad. Su función principal es identificar y zonificar los comercios según sus coordenadas geográficas, creando polígonos de las zonas a partir de las coordenadas de los comercios que tienen como descripción la misma zona, estos polígonosrepresentan las diferentes zonas dentro de una ciudad, el algoritmo que se utiliza es envolvente convexa (convex hull). En esta etapa se utiliza la descripción de la zona para clasificar los comercios en la interfaz y se graba en oracle una geometría que en el futuro puede servir para hacer consultas de comercios por aproximación geográfica.


## ¿Qué Hace Este Comando?
1. **Inicio del Proceso:** Inicia la zonificación para la ciudad indicada por `ID_CIUDAD`.
2. **Obtención de Zonas Elegibles:** Filtra y agrupa los comercios que cumplen con ciertos criterios (como cantidad mínima de registros y coordenadas válidas).
3. **Generación de Polígonos:** Calcula polígonos geoespaciales para cada zona elegible basándose en las coordenadas de los comercios.
4. **Actualización de la Base de Datos:** Inserta o actualiza los registros de las zonas en la tabla `zonas_shape`.
5. **Asignación de Zona a Comercios:** Asocia cada comercio con la zona correspondiente basándose en coincidencias de texto y relaciones espaciales.
6. **Actualización de Totales:** Calcula y actualiza el número total de comercios por zona y por ciudad.
7. **Verificación:** Confirma que los datos en `zonas_shape` se hayan actualizado correctamente.

## Logs
El proceso generará logs informativos que podrás consultar para verificar el estado de la ejecución:

- **Inicio de la zonificación:** Indica cuándo comienza el proceso.
- **Zonas encontradas:** Lista las zonas procesadas.
- **Errores:** Cualquier problema encontrado durante la ejecución.

---

# Iniciar Servidor de Sidekiq en Desarrollo

Primer shell
```bash
redis-server
```

Segundo Shell
```bash
bundle exec sidekiq
```

Tercer Shell
```bash
rails server
```

http://localhost:3000/sidekiq

---
# Ciclo de Vida de una Solicitud en Infomóvil

![Flujo de Solicitud](doc/assets/images/CicloVidaSolicitud.png)

Una solicitud en el sistema Infomóvil atraviesa un conjunto de etapas secuenciales hasta habilitar el comercio en la plataforma. A continuación se describe el ciclo de vida completo:

## Etapas de la Solicitud

### Estado 0: `pendiente_verificacion`
La solicitud inicia en este estado cuando se requiere verificar la identidad del propietario del comercio. Se espera la carga y validación del documento de identidad (CI).

- Transición: **Validar Identidad** → pasa al estado 1.

### Estado 1: `documentos_validados`
En este punto, la identidad del propietario ha sido verificada correctamente. Se espera que el solicitante cargue el comprobante de pago correspondiente.

- Transición: **Validar Pago** → pasa al estado 2.

### Estado 2: `pago_validado`
El pago ha sido validado y se encuentra todo listo para la aprobación final por parte del equipo de autorización.

- Transición: **Autorizar** → pasa al estado 3.

### Estado 3: `comercio_habilitado`
El comercio ha sido aprobado y habilitado para aparecer públicamente en la plataforma. La habilitación tiene una duración de **un año** a partir de esta fecha.

---

## Excepciones del flujo

### Comercios no SEPREC
Para comercios registrados manualmente (no provenientes del padrón oficial de SEPREC), **se omite la verificación de identidad**. Estos comercios inician directamente en el estado `documentos_validados`.

### Solicitudes gratuitas
En el caso de solicitudes para un registro gratuito (promociones, convenios, o plan gratuito), **se omite la validación de pago**. En estos casos, una vez validados los documentos, se puede autorizar directamente el comercio.

---

## Estado 5: `rechazada`
Si en cualquier punto del proceso la solicitud no cumple con los criterios, puede ser marcada como rechazada. Este es un estado terminal, y requiere crear una nueva solicitud para reiniciar el proceso.

