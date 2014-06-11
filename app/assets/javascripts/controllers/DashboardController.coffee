angular.module('app').controller "DashboardController", ($scope, $routeParams, $location, Course) ->

  DAYS =
    SUNDAY:     Math.pow(2,6)
    MONDAY:     Math.pow(2,5)
    TUESDAY:    Math.pow(2,4)
    WEDNESDAY:  Math.pow(2,3)
    THURSDAY:   Math.pow(2,2)
    FRIDAY:     Math.pow(2,1)
    SATURDAY:   Math.pow(2,0)

  $scope.init = ->
    @coursesService = new Course(serverErrorHandler)
    
    x = DAYS.MONDAY + DAYS.TUESDAY + DAYS.WEDNESDAY + DAYS.THURSDAY + DAYS.FRIDAY
    y = DAYS.MONDAY + DAYS.WEDNESDAY + DAYS.FRIDAY
    z = DAYS.TUESDAY + DAYS.THURSDAY

    $scope.days = y
    $scope.courses = @coursesService.filtr({days: x})

  serverErrorHandler = (response) ->
    console.log console.trace()
    alert(response)

  $scope