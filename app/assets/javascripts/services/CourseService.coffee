angular.module('app').factory 'Course', ($resource, $http) ->
  
  class Course
    constructor: (errorHandler) ->

      courseId = null
      @service = $resource('/api/courses/:id',
        {course_id: courseId, id: '@id'},
        {update: {method: 'PATCH'}}
      )
      
      @errorHandler = errorHandler

      # Fix needed for the PATCH method to use application/json content type.
      defaults = $http.defaults.headers
      defaults.patch = defaults.patch || {}
      defaults.patch['Content-Type'] = 'application/json'

    all: ->
      @service.query (-> null), @errorHandler

    filtr: (params) ->
      @service.query params, (-> null), @errorHandler