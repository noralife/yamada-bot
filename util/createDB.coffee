#
# createDB.coffee
#
# Decription:
#  * create sqlite3 database using stationYYYYMMDDfree.csv
#  * download file here: http://www.ekidata.jp/
#

sqlite3 = require('sqlite3').verbose()
fs      = require 'fs'
parse   = require 'csv-parse'

db = new sqlite3.Database "./db.sqlite3"
db.serialize () ->

  db.run "DROP TABLE IF EXISTS stations"
  db.run """
    CREATE TABLE IF NOT EXISTS stations (
      station_cd INT,
      station_g_cd INT,
      station_name TEXT,
      station_name_k TEXT,
      station_name_r TEXT,
      line_cd INT,
      pref_cd INT,
      post TEXT,
      address TEXT,
      lon REAL,
      lat REAL,
      open_ymd TEXT,
      close_ymd TEXT,
      e_status INT,
      e_sort INT
    )
  """

  parser = parse {columns: true, delimiter: ','}, (err, records) ->
    insert = db.prepare "INSERT INTO stations VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
    for data in records
      insert.run data.station_cd, data.station_g_cd, data.station_name, data.station_name_k, data.station_name_r, data.line_cd, data.pref_cd, data.post, data.add, data.lon, data.lat, data.open_ymd, data.close_ymd, data.e_status, data.e_sort
    insert.finalize
    db.close

  fs.createReadStream "./station20151215free.csv"
    .pipe parser
