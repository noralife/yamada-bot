gulp = require 'gulp';

# test tools
mocha = require 'gulp-mocha'
watch = require 'gulp-watch'

# test task
gulp.task 'test', ->
   gulp.src(['scripts/*.coffee', 'test/*.coffee']) 
    .pipe mocha {reporter: 'spec'}

# watch task
gulp.task 'watch', ->
  gulp.watch(['scripts/*.coffee', 'test/*.coffee'], ['test'])
