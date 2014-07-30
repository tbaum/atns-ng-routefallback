module = angular.module 'ngRouteFallback', ['ngRoute']

module.config ($routeProvider)->
    _when = $routeProvider.when

    $routeProvider.when = (route, args)->
        if args.fallback
            args.resolve ?= {}

            for target,check of args.fallback when args.fallback.hasOwnProperty target
                do (target, check)->
                    args.resolve['_fallbackToCondition' + target] = ($q, $location, $injector)->
                        defer = $q.defer()

                        result = $injector.invoke check
                        if result && typeof result.then == 'function' # result is a promise
                            result.then (deferredResult)->
                                if angular.isArray deferredResult
                                    return $location.path target for r in deferredResult when r
                                else
                                    return $location.path target if deferredResult

                                defer.resolve()
                            , (failed)->
                                $location.path target
                        else
                            $location.path target if result
                            defer.resolve()

                        defer.promise

        _when.call $routeProvider, route, args
