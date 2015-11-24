var gulp            = require('gulp'),
    concat          = require('gulp-concat'),
    uglify          = require('gulp-uglify'),
    rev             = require('gulp-rev'),
    sass            = require('gulp-sass'),
    autoprefixer    = require('gulp-autoprefixer'),
    minifycss       = require('gulp-minify-css'),
    clean           = require('gulp-clean');

var paths = {
  js: [
    'bower_components/jquery/dist/jquery.min.js',
    'bower_components/parsleyjs/dist/parsley.min.js',
    'bower_components/peity/jquery.peity.min.js',
    'bower_components/d3/d3.min.js',
    'bower_components/c3/c3.min.js',
    'frontend/js/*'
  ],
  css: [
    'bower_components/skeleton/css/normalize.css',
    'bower_components/skeleton/css/skeleton.css',
    'bower_components/parsleyjs/src/parsley.css',
    'bower_components/c3/c3.min.css',
    'frontend/scss/main.scss'
  ]
};

var watchPaths = {
  js: ['frontend/js/*'],
  css: ['frontend/scss/*']
};

gulp.task('clean', function() {
  return gulp.src('public/assets/*', { read: false })
    .pipe(clean())
});

gulp.task('scripts', function() {
  return gulp.src(paths.js)
    .pipe(concat('application.js'))
    // .pipe(uglify())
    .pipe(gulp.dest('public/assets'))
});

gulp.task('styles', function() {
  return gulp.src(paths.css)
    .pipe(concat('main.scss'))
    .pipe(sass({errLogToConsole: true }))
    .pipe(autoprefixer())
    .pipe(concat('application.css'))
    // .pipe(minifycss())
    .pipe(gulp.dest('public/assets'))
});

gulp.task('revision', function() {
  return gulp.src(['public/assets/*.css', 'public/assets/*.js'])
    .pipe(rev())
    .pipe(gulp.dest('public/assets'))
    .pipe(rev.manifest({ path: 'manifest.json' }))
    .pipe(gulp.dest('public/assets'));
});

gulp.task('dev', ['clean', 'scripts', 'styles'], function() {
  gulp.start('revision');
});

gulp.task('watch', function() {
  gulp.watch(watchPaths.js, ['dev']);
  gulp.watch(watchPaths.css, ['dev']);
});

gulp.task('default', ['clean', 'dev', 'watch']);
