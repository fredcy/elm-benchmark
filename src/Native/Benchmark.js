(function () {
    // CustomEvent polyfill for IE 9 and higher
    // https://developer.mozilla.org/en-US/docs/Web/API/CustomEvent/CustomEvent

    if ( typeof window.CustomEvent === "function" ) return false;

    function CustomEvent ( event, params ) {
        params = params || { bubbles: false, cancelable: false, detail: undefined };
        var evt = document.createEvent( 'CustomEvent' );
        evt.initCustomEvent( event, params.bubbles, params.cancelable, params.detail );
        return evt;
    }

    CustomEvent.prototype = window.Event.prototype;

    window.CustomEvent = CustomEvent;
})();


var _user$project$Native_Benchmark = (function () {

    // Create an opaque benchmark item (name and function)
    function bench(name, fn) {
	return {
	    name: name,
	    fn: fn
	}
    }

    function suite(options, name, benchmarkList) {
	var benchmarks = _elm_lang$core$Native_List.toArray(benchmarkList),
	    suite = new Benchmark.Suite(name),
	    i, curr;

	for (i = 0; i < benchmarks.length; i++) {
	    curr = benchmarks[i];
            suite = suite.add(curr.name, { fn: curr.fn, maxTime: options.maxTime });
	}

	return suite;
    }


    // The asyncronous benchmark.js suites started by `runTask` will report
    // results by generating an event via this function.
    function dispatchBenchmarkEvent(info) {
        var detail = { detail: info };
        var event = new CustomEvent('benchmarkEvent', detail);
        document.dispatchEvent(event);
    }

    // The Elm effect manager will call this function to monitor the results
    // generated by benchmark suites started by `runTask`.
    function watch(toTask) {
        function handleEvent(e) {
            var task = toTask(e.detail);
            _elm_lang$core$Native_Scheduler.rawSpawn(task);
        }

        return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
            document.addEventListener('benchmarkEvent', handleEvent);

            return function() {
                document.removeEventListener('benchmarkEvent', handleEvent);
            };
        });
    };


    function makeTag(name, value) {
        return { ctor: name, _0: value };
    }

    function recordEvent(event) {
        console.log('event', event);
        dispatchBenchmarkEvent(event);
    }


    // Execute the list of benchmark suites as an Elm task
    function runTask(suiteList) {
        return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
            var suiteArray = _elm_lang$core$Native_List.toArray(suiteList);

            // Adding this timeout somehow allows any Elm subscription to the
            // `watch` function to take effect before the suite actually
            // runs. Without this the first event can be lost.
            setTimeout(function(){
                // run the benchmark suites
                runSuites(suiteArray);
            }, 0);

            return callback(_elm_lang$core$Native_Scheduler.succeed( {ctor: '_Tuple0'} ));
        });
    }

    // Run the array of benchmark suites. Since we are running each suite in
    // "async" mode, each call to `suite.on()...` returns almost immediately. So
    // that the execution of different suites does not overlap (which would
    // cause output from different suites to overlap in time) we run one suite
    // at a time, running the next suite only when the current suite completes.
    function runSuites(suites) {
        if (suites.length == 0) {
            recordEvent({ctor: 'Finished'});
            return;
        }
        // else ...

        var suite = suites[0];
        var remainingSuites = suites.slice(1);

        suite
	    .on('start', function () {
                var event = makeTag('Start', {
                    suite: this.name,
                    platform: Benchmark.platform.description
                });
                recordEvent(event);
	    })
	    .on('cycle', function (event) {
                var event = makeTag('Cycle', {
                    suite: this.name,
                    benchmark: event.target.name,
                    //message: String(event.target),
                    freq: 1 / event.target.times.period, // mean ops/sec
                    rme: event.target.stats.rme,       // margin of error as % of mean
                    samples: event.target.stats.sample.length, // # of samples
                });
                recordEvent(event);
	    })
	    .on('complete', function () {
                var event = makeTag('Complete', this.name);
                recordEvent(event);

                // recurse to run remaining suites
                runSuites(remainingSuites);
	    })
	    .on('error', function (event) {
	        var suite = this;
	        // copy suite into array of Benchmarks
	        var benchArray = Array.prototype.slice.call(suite);
	        // find the last benchmark with an 'error' field, presumed
	        // to be the most recent error
	        var errored = benchArray.reverse().find(function(e, i, a) {
                    return e.hasOwnProperty('error'); });
	        var erroredName = (typeof errored != 'undefined') ? errored.name : "<unknown>";

                var error = makeTag('BenchError', {
                    'suite': suite.name,
                    'benchmark': erroredName,
                    'message': event.target.error.message
                });
                recordEvent(error);
	    })
	    .run({'async': true});
    }

    return {
	bench: F2(bench),
	suite: F3(suite),
        runTask: runTask,
        watch: watch,
    };
})()
