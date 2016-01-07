gulp = require 'gulp'
coffeelint = require 'gulp-coffeelint'

gulp.task 'lint', ->
  gulp.src(['gulpfile.coffee' ,'scripts/*.coffee', 'tests/*.coffee'])
    .pipe coffeelint()
    .pipe coffeelint.reporter()
