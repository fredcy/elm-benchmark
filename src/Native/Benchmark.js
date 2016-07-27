var _user$project$Native_Benchmark = (function () {
    function bench(name, fn) {
	return {
	    name: name,
	    fn: fn
	}
    }

    function suite(name, fnList) {
	var fns = _elm_lang$core$Native_List.toArray(fnList),
	    suite = new Benchmark.Suite(name),
	    i, curr;

	for (i = 0; i < fns.length; i++) {
	    curr = fns[i];
	    //suite = suite.add(curr.name, curr.fn);
            suite = suite.add(curr.name, {
                'defer': true,
                'fn': function(deferred) {
                    (curr.fn)();
                    deferred.resolve();
                }
            });
	}

	return suite;
    }

    function runTask(suiteList) {
        return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
            var results = runTaskHelper(suiteList);
            return callback(_elm_lang$core$Native_Scheduler.succeed(
                _elm_lang$core$Native_List.fromArray( results) ));
        });
    }

    function runTaskHelper(suiteList) {
	var suites = _elm_lang$core$Native_List.toArray(suiteList),
	    i,
            results = [];

	for (i = 0; i < suites.length; i++) {
	    suites[i]
		.on('start', function () {
                    console.log('start', this.name);
                    results.push( {ctor: 'Start', _0: this.name} );
		})
		.on('cycle', function (event) {
                    console.log('cycle', String(event.target));
                    results.push( {ctor: 'Cycle', _0: String(event.target) } );
		})
		.on('complete', function () {
                    console.log('complete', this.name);
                    results.push( {ctor: 'Start', _0: this.name} );
		})
		.on('error', function (event) {
		    var suite = this;
		    // copy suite into array of Benchmarks
		    var benchArray = Array.prototype.slice.call(suite);
		    // find the last benchmark with an 'error' field, presumed to be the most recent error
		    var errored = benchArray.reverse().find(function(e, i, a) { return e.hasOwnProperty('error'); });

		    var erroredName = (typeof errored != 'undefined') ? errored.name : "<unknown>";
                    var error =
                        { ctor: 'Error',
                          _0: { 'suite': suite.name,
                                'benchmark': erroredName,
                                'message': event.target.error.message
                              }
                        };
		    results.push( error );
		})
		.run({'async': true});
	}
        return results;
    }

    function run(suiteList, program) {
	var suites = _elm_lang$core$Native_List.toArray(suiteList),
	    i;

	for (i = 0; i < suites.length; i++) {
	    suites[i]
		.on('start', function () {
		    console.log('Starting ' + this.name + ' suite.');
		})
		.on('cycle', function (event) {
		    console.log(String(event.target));
		})
		.on('complete', function () {
		    console.log('Done with ' + this.name + ' suite.');
		})
		.on('error', function (event) {
		    var suite = this;
		    // copy suite into array of Benchmarks
		    var benchArray = Array.prototype.slice.call(suite);
		    // find the last benchmark with an 'error' field, presumed to be the most recent error
		    var errored = benchArray.reverse().find(function(e, i, a) { return e.hasOwnProperty('error'); });

		    var erroredName = (typeof errored != 'undefined') ? errored.name : "<unknown>";
		    console.log('Error in suite ' + suite.name + ', benchmark ' + erroredName + ': ',
				event.target.error.message);
		})
		.run( { 'async': true } );
	}

	return program;
    }

    return {
	bench: F2(bench),
	suite: F2(suite),
	run: F2(run),
        runTask: runTask
    };
})()
