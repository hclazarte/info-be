# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

Ciudad.create([
  { ciudad: 'Jesus De Machaca', cod_municipio: '020806', pais: 'Bolivia', cod_pais: 'BO' },
  { ciudad: 'Jose Ballivian', cod_municipio: '080399', pais: 'Bolivia', cod_pais: 'BO' },
  { ciudad: 'Jose Maria Aviles', cod_municipio: '060499', pais: 'Bolivia', cod_pais: 'BO' },
  { ciudad: 'Jose Maria Linares', cod_municipio: '051199', pais: 'Bolivia', cod_pais: 'BO' },
  { ciudad: 'La Asunta', cod_municipio: '021105', pais: 'Bolivia', cod_pais: 'BO' },
  { ciudad: 'La Guardia', cod_municipio: '070104', pais: 'Bolivia', cod_pais: 'BO' },
  { ciudad: 'La Paz', cod_municipio: '020101', pais: 'Bolivia', cod_pais: 'BO' },
  { ciudad: 'Lagunillas', cod_municipio: '070701', pais: 'Bolivia', cod_pais: 'BO' },
  { ciudad: 'Laja', cod_municipio: '021202', pais: 'Bolivia', cod_pais: 'BO' },
  { ciudad: 'Larecaja', cod_municipio: '020699', pais: 'Bolivia', cod_pais: 'BO' },
  { ciudad: 'Las Carreras', cod_municipio: '010903', pais: 'Bolivia', cod_pais: 'BO' },
  { ciudad: 'Llallagua', cod_municipio: '050203', pais: 'Bolivia', cod_pais: 'BO' },
  { ciudad: 'Llica', cod_municipio: '051401', pais: 'Bolivia', cod_pais: 'BO' },
  { ciudad: 'Loayza', cod_municipio: '020999', pais: 'Bolivia', cod_pais: 'BO' }
])

Zona.create([
  { descripcion: 'Rosario', ciudad_id: 7, total: 626 },
  { descripcion: 'Casco Urbano Central', ciudad_id: 7, total: 605 },
  { descripcion: 'San Jorge', ciudad_id: 7, total: 426 },
  { descripcion: 'San Miguel Los Pinos', ciudad_id: 7, total: 364 },
  { descripcion: 'San Pedro', ciudad_id: 7, total: 352 }
])

Comercio.create!([
  {
    zona_id: 1, # Rosario
    ciudad_id: 7, # La Paz
    fecha_registro: '2025-01-04',
    fecha_encuesta: '2010-07-06',
    calle_numero: '16 de julio Nº 1789',
    planta: '3',
    numero_local: '314',
    telefono1: '72094341',
    empresa: 'ASOCIACION DE CONSULTORES PARA EL DESARROLLO ACUDE SRL',
    email: 'info@acudesrl.com',
    activo: 1,
    seprec: 112868,
    seprec_est: 112868
  },
  {
    zona_id: 2, # Casco Urbano Central
    ciudad_id: 7, # La Paz
    fecha_registro: '2025-01-04',
    fecha_encuesta: '2010-07-22',
    calle_numero: 'BUENOS AIRES Nº 538',
    telefono1: '76504675',
    empresa: 'ADOLFO ESPINOZA OJEDA',
    email: 'jhobero429@gmail.com',
    activo: 1,
    seprec: 113534,
    seprec_est: 113534
  },
  {
    zona_id: 3, # Sopocachi
    ciudad_id: 7, # La Paz
    fecha_registro: '2025-01-04',
    fecha_encuesta: '2012-07-02',
    calle_numero: 'C/ HERMANOS MANCHEGO Nº 2550',
    empresa: 'CIELO BLANCO SRL',
    activo: 0,
    seprec: 143174,
    seprec_est: 143174
  },
  {
    zona_id: 3, # Sopocachi
    ciudad_id: 7, # La Paz
    fecha_registro: '2025-01-01',
    fecha_encuesta: '1994-09-14',
    calle_numero: 'CAPITAN RAVELO Nº 2393',
    planta: 'PB',
    numero_local: '001',
    telefono1: '77798985',
    empresa: 'FOREVER LIVING PRODUCTS BOLIVIA SRL',
    email: 'administracion2@foreverliving.com.bo',
    activo: 1,
    seprec: 13204,
    seprec_est: 13204
  },
  {
    zona_id: nil, 
    ciudad_id: 12, # Llallagua
    fecha_registro: '2025-01-02',
    fecha_encuesta: '2005-08-04',
    calle_numero: 'RAFAEL BUSTILLO Nº 7',
    telefono1: '74115072',
    empresa: 'CONSTRUCTORA VEGA PORTILLO',
    email: 'humbertovpd9@hotmail.com',
    activo: 1,
    seprec: 63849,
    seprec_est: 63849
  },
  {
    zona_id: 4, # San Pedro
    ciudad_id: 7, # La Paz
    fecha_registro: '2025-01-03',
    fecha_encuesta: '2008-01-09',
    calle_numero: 'CALLE GENERAL GONZALES Nº 1347',
    telefono1: '71270728',
    empresa: 'CENTRO DE ORIENTACION GRAFICA COG',
    email: 'medrano.asociados@hotmail.com',
    activo: 1,
    seprec: 83319,
    seprec_est: 83319
  },
  {
    zona_id: 1, # Rosario
    ciudad_id: 7, # La Paz
    fecha_registro: '2025-01-03',
    fecha_encuesta: '2012-07-21',
    calle_numero: 'CALLE 16 DE JULIO Nº 144',
    empresa: 'PRIMITIVO CHOQUE SUTURI',
    activo: 0,
    seprec: 137942,
    seprec_est: 137942
  },
  {
    zona_id: 3, # Casco Urbano Central
    ciudad_id: 7, # La Paz
    fecha_registro: '2025-01-05',
    fecha_encuesta: '2013-04-26',
    calle_numero: 'CALLE LECHIN Nº 65',
    telefono1: '60691846',
    empresa: 'ROLANDO CHAMBI QUISPE',
    email: 'asesorescontableslimcon@gmail.com',
    activo: 1,
    seprec: 173908,
    seprec_est: 173908
  },
  {
    zona_id: nil, 
    ciudad_id: 6, # La Guardia
    fecha_registro: '2025-01-06',
    fecha_encuesta: '2013-07-01',
    calle_numero: 'DOBLE VIA LA GUARDIA Nº 1',
    telefono1: '75660333',
    empresa: 'TRANSPORTE VAQUEROS EL TORO',
    email: 'estudiocontableoriente@gmail.com',
    activo: 1,
    seprec: 210363,
    seprec_est: 210363
  },
  {
    zona_id: 3, # San Pedro
    ciudad_id: 7, # La Paz
    fecha_registro: '2025-01-03',
    fecha_encuesta: '2008-01-28',
    calle_numero: 'CALLE 17 Nº 8082',
    empresa: 'EMPRESA DE IMPORTACION Y EXPORTACION Y BIENES RAICES Y SERVICIOS JECSIL SRL',
    activo: 0,
    seprec: 83785,
    seprec_est: 83785
  },
  {
    zona_id: 3, # San Pedro
    ciudad_id: 7, # La Paz
    fecha_registro: '2025-01-03',
    fecha_encuesta: '2009-12-16',
    calle_numero: 'JUANA AZURDUY DE PADILLA Nº 2479',
    telefono1: '68306028',
    empresa: 'EMPRESA CONSTRUCTORA TUKUYPAJ',
    email: 'edwinnina@hotmail.com',
    activo: 0,
    seprec: 105789,
    seprec_est: 105789
  },
  {
    zona_id: nil, 
    ciudad_id: 6, # La Guardia
    fecha_registro: '2025-01-03',
    fecha_encuesta: '2010-02-05',
    calle_numero: 'CALLE LOS BUHOS URBANIZACION ADELITA Nº Sin número',
    telefono1: '76692712',
    empresa: 'U & T CONSTRUCTORES',
    email: 'haydeejuradov@hotmail.com',
    activo: 0,
    seprec: 107518,
    seprec_est: 107518
  },
  {
    zona_id: 4, # San Jorge
    ciudad_id: 7, # La Paz
    fecha_registro: '2025-01-03',
    fecha_encuesta: '2009-12-17',
    calle_numero: 'C/ CAÑADA STRONGEST Nº 1591',
    telefono1: '73015015',
    empresa: 'MARIA ANA FLORES DE CASTILLO',
    email: 'cijam1975@hotmail.com',
    activo: 1,
    seprec: 105843,
    seprec_est: 105843
  },
  {
    zona_id: 1, # Rosario
    ciudad_id: 7, # La Paz
    fecha_registro: '2025-01-06',
    fecha_encuesta: '2022-08-29',
    calle_numero: 'CALLE SIN NOMBRE Nº NRO. S/N',
    telefono1: '70409847',
    empresa: 'PA´ PICAR',
    email: 'rafael_14_@hotmail.com',
    activo: 1,
    seprec: 417672,
    seprec_est: 430498
  },
  {
    zona_id: nil, 
    ciudad_id: 6, # La Guardia
    fecha_registro: '2025-01-03',
    fecha_encuesta: '2013-10-16',
    calle_numero: 'CAMPERO Nº 65',
    planta: 'S/N.',
    numero_local: 'S/N.',
    telefono1: '71166706',
    empresa: 'WILLY ANGULO DIAZ',
    email: 'willyangulodiaz@gmail.com',
    activo: 1,
    seprec: 212292,
    seprec_est: 212292
  },
  {
    zona_id: 4, # San Jorge
    ciudad_id: 7, # La Paz
    fecha_registro: '2025-01-03',
    fecha_encuesta: '2013-10-07',
    calle_numero: 'DOBLE VIA LA GUARDIA Nº Sin número',
    telefono1: '75660333',
    empresa: 'TRANSPORTE VAQUEROS EL TORO',
    email: 'estudiocontableoriente@gmail.com',
    activo: 1,
    seprec: 210363,
    seprec_est: 210363
  },
  {
    zona_id: nil, 
    ciudad_id: 6, # La Guardia
    fecha_registro: '2025-01-07',
    fecha_encuesta: '2014-07-14',
    calle_numero: 'Mapaiso Nº 01',
    telefono1: '71360064',
    empresa: 'IMP EXP AGRO ALSA',
    email: 'iagroalsa@gmail.com',
    activo: 1,
    seprec: 253432,
    seprec_est: 253432
  },
  {
    zona_id: 4, # San Jorge
    ciudad_id: 7, # La Paz
    fecha_registro: '2025-01-03',
    fecha_encuesta: '2013-07-01',
    calle_numero: 'YOTAU Nº S/N',
    planta: 'CONSTRU',
    telefono1: '73695714',
    empresa: 'CONSTRUCTORA GASPET',
    email: 'cuevas.marquez.g@gmail.com',
    activo: 1,
    seprec: 417785,
    seprec_est: 430614
  },
  {
    zona_id: nil, 
    ciudad_id: 6, # La Guardia
    fecha_registro: '2025-01-07',
    fecha_encuesta: '2022-08-30',
    calle_numero: 'KM 13 AV. EL PALMAR Nº SN',
    telefono1: '71036935',
    empresa: 'JGCOMPUTER',
    email: 'contabilidad@consultorabelin.com.bo',
    activo: 0,
    seprec: 417753,
    seprec_est: 430581
  },
  {
    zona_id: 5, # San Pedro
    ciudad_id: 7, # La Paz
    fecha_registro: '2025-01-07',
    fecha_encuesta: '2022-08-30',
    calle_numero: 'C/ FRANCISCO PIZARRO Nº 1665',
    telefono1: '73034979',
    empresa: 'MOTOMUNDO',
    email: 'moto.cars.alr@hotmail.com',
    activo: 0,
    seprec: 418435,
    seprec_est: 431318
  },
  # Continúa con el resto de los registros siguiendo este patrón...
])