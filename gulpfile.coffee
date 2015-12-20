gulp = require 'gulp'
coffeelint = require 'gulp-coffeelint'

# test tools
mocha = require 'gulp-mocha'
watch = require 'gulp-watch'

# test task
gulp.task 'test', ->
  gulp.src(['scripts/*.coffee', 'test/*.coffee'])
    .pipe mocha {reporter: 'spec'}
    .once 'error', () ->
      process.exit(1);
    .once 'end', () ->
      process.exit();

gulp.task 'lint', ->
  gulp.src(['scripts/*.coffee', 'test/*.coffee'])
    .pipe coffeelint()
    .pipe coffeelint.reporter()

# watch task
gulp.task 'watch', ->
  gulp.watch(['scripts/*.coffee', 'test/*.coffee'], ['test'])
