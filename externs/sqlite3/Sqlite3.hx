package sqlite3;

typedef Sqlite3 = {
	var OPEN_READONLY : Float;
	var OPEN_READWRITE : Float;
	var OPEN_CREATE : Float;
	var OPEN_FULLMUTEX : Float;
	var OPEN_SHAREDCACHE : Float;
	var OPEN_PRIVATECACHE : Float;
	var OPEN_URI : Float;
	var VERSION : String;
	var SOURCE_ID : String;
	var VERSION_NUMBER : Float;
	var OK : Float;
	var ERROR : Float;
	var INTERNAL : Float;
	var PERM : Float;
	var ABORT : Float;
	var BUSY : Float;
	var LOCKED : Float;
	var NOMEM : Float;
	var READONLY : Float;
	var INTERRUPT : Float;
	var IOERR : Float;
	var CORRUPT : Float;
	var NOTFOUND : Float;
	var FULL : Float;
	var CANTOPEN : Float;
	var PROTOCOL : Float;
	var EMPTY : Float;
	var SCHEMA : Float;
	var TOOBIG : Float;
	var CONSTRAINT : Float;
	var MISMATCH : Float;
	var MISUSE : Float;
	var NOLFS : Float;
	var AUTH : Float;
	var FORMAT : Float;
	var RANGE : Float;
	var NOTADB : Float;
	var LIMIT_LENGTH : Float;
	var LIMIT_SQL_LENGTH : Float;
	var LIMIT_COLUMN : Float;
	var LIMIT_EXPR_DEPTH : Float;
	var LIMIT_COMPOUND_SELECT : Float;
	var LIMIT_VDBE_OP : Float;
	var LIMIT_FUNCTION_ARG : Float;
	var LIMIT_ATTACHED : Float;
	var LIMIT_LIKE_PATTERN_LENGTH : Float;
	var LIMIT_VARIABLE_NUMBER : Float;
	var LIMIT_TRIGGER_DEPTH : Float;
	var LIMIT_WORKER_THREADS : Float;
	var cached : {
		@:overload(function(filename:String, ?mode:Float, ?callback:(err:Null<js.lib.Error>) -> Void):Database { })
		function Database(filename:String, ?callback:(err:Null<js.lib.Error>) -> Void):Database;
	};
	var RunResult : RunResult;
	var Statement : {
		var prototype : Statement;
		/**
			Creates a `Promise` that is fulfilled when the `EventEmitter` emits the given
			event or that is rejected if the `EventEmitter` emits `'error'` while waiting.
			The `Promise` will resolve with an array of all the arguments emitted to the
			given event.
			
			This method is intentionally generic and works with the web platform [EventTarget](https://dom.spec.whatwg.org/#interface-eventtarget) interface, which has no special`'error'` event
			semantics and does not listen to the `'error'` event.
			
			```js
			import { once, EventEmitter } from 'node:events';
			import process from 'node:process';
			
			const ee = new EventEmitter();
			
			process.nextTick(() => {
			   ee.emit('myevent', 42);
			});
			
			const [value] = await once(ee, 'myevent');
			console.log(value);
			
			const err = new Error('kaboom');
			process.nextTick(() => {
			   ee.emit('error', err);
			});
			
			try {
			   await once(ee, 'myevent');
			} catch (err) {
			   console.error('error happened', err);
			}
			```
			
			The special handling of the `'error'` event is only used when `events.once()`is used to wait for another event. If `events.once()` is used to wait for the
			'`error'` event itself, then it is treated as any other kind of event without
			special handling:
			
			```js
			import { EventEmitter, once } from 'node:events';
			
			const ee = new EventEmitter();
			
			once(ee, 'error')
			   .then(([err]) => console.log('ok', err.message))
			   .catch((err) => console.error('error', err.message));
			
			ee.emit('error', new Error('boom'));
			
			// Prints: ok boom
			```
			
			An `AbortSignal` can be used to cancel waiting for the event:
			
			```js
			import { EventEmitter, once } from 'node:events';
			
			const ee = new EventEmitter();
			const ac = new AbortController();
			
			async function foo(emitter, event, signal) {
			   try {
			     await once(emitter, event, { signal });
			     console.log('event emitted!');
			   } catch (error) {
			     if (error.name === 'AbortError') {
			       console.error('Waiting for the event was canceled!');
			     } else {
			       console.error('There was an error', error.message);
			     }
			   }
			}
			
			foo(ee, 'foo', ac.signal);
			ac.abort(); // Abort waiting for the event
			ee.emit('foo'); // Prints: Waiting for the event was canceled!
			```
		**/
		@:overload(function(emitter:Sqlite3, eventName:String, ?options:Sqlite3):js.lib.Promise<Array<Dynamic>> { })
		function once(emitter:Sqlite3, eventName:ts.AnyOf2<String, js.lib.Symbol>, ?options:Sqlite3):js.lib.Promise<Array<Dynamic>>;
		/**
			```js
			import { on, EventEmitter } from 'node:events';
			import process from 'node:process';
			
			const ee = new EventEmitter();
			
			// Emit later on
			process.nextTick(() => {
			   ee.emit('foo', 'bar');
			   ee.emit('foo', 42);
			});
			
			for await (const event of on(ee, 'foo')) {
			   // The execution of this inner block is synchronous and it
			   // processes one event at a time (even with await). Do not use
			   // if concurrent execution is required.
			   console.log(event); // prints ['bar'] [42]
			}
			// Unreachable here
			```
			
			Returns an `AsyncIterator` that iterates `eventName` events. It will throw
			if the `EventEmitter` emits `'error'`. It removes all listeners when
			exiting the loop. The `value` returned by each iteration is an array
			composed of the emitted event arguments.
			
			An `AbortSignal` can be used to cancel waiting on events:
			
			```js
			import { on, EventEmitter } from 'node:events';
			import process from 'node:process';
			
			const ac = new AbortController();
			
			(async () => {
			   const ee = new EventEmitter();
			
			   // Emit later on
			   process.nextTick(() => {
			     ee.emit('foo', 'bar');
			     ee.emit('foo', 42);
			   });
			
			   for await (const event of on(ee, 'foo', { signal: ac.signal })) {
			     // The execution of this inner block is synchronous and it
			     // processes one event at a time (even with await). Do not use
			     // if concurrent execution is required.
			     console.log(event); // prints ['bar'] [42]
			   }
			   // Unreachable here
			})();
			
			process.nextTick(() => ac.abort());
			```
		**/
		function on(emitter:global.nodejs.EventEmitter, eventName:String, ?options:Sqlite3):js.lib.AsyncIterableIterator<Dynamic>;
		/**
			A class method that returns the number of listeners for the given `eventName`registered on the given `emitter`.
			
			```js
			import { EventEmitter, listenerCount } from 'node:events';
			
			const myEmitter = new EventEmitter();
			myEmitter.on('event', () => {});
			myEmitter.on('event', () => {});
			console.log(listenerCount(myEmitter, 'event'));
			// Prints: 2
			```
		**/
		function listenerCount(emitter:global.nodejs.EventEmitter, eventName:ts.AnyOf2<String, js.lib.Symbol>):Float;
		/**
			Returns a copy of the array of listeners for the event named `eventName`.
			
			For `EventEmitter`s this behaves exactly the same as calling `.listeners` on
			the emitter.
			
			For `EventTarget`s this is the only way to get the event listeners for the
			event target. This is useful for debugging and diagnostic purposes.
			
			```js
			import { getEventListeners, EventEmitter } from 'node:events';
			
			{
			   const ee = new EventEmitter();
			   const listener = () => console.log('Events are fun');
			   ee.on('foo', listener);
			   console.log(getEventListeners(ee, 'foo')); // [ [Function: listener] ]
			}
			{
			   const et = new EventTarget();
			   const listener = () => console.log('Events are fun');
			   et.addEventListener('foo', listener);
			   console.log(getEventListeners(et, 'foo')); // [ [Function: listener] ]
			}
			```
		**/
		function getEventListeners(emitter:ts.AnyOf2<global.nodejs.EventEmitter, Sqlite3>, name:ts.AnyOf2<String, js.lib.Symbol>):Array<haxe.Constraints.Function>;
		/**
			Returns the currently set max amount of listeners.
			
			For `EventEmitter`s this behaves exactly the same as calling `.getMaxListeners` on
			the emitter.
			
			For `EventTarget`s this is the only way to get the max event listeners for the
			event target. If the number of event handlers on a single EventTarget exceeds
			the max set, the EventTarget will print a warning.
			
			```js
			import { getMaxListeners, setMaxListeners, EventEmitter } from 'node:events';
			
			{
			   const ee = new EventEmitter();
			   console.log(getMaxListeners(ee)); // 10
			   setMaxListeners(11, ee);
			   console.log(getMaxListeners(ee)); // 11
			}
			{
			   const et = new EventTarget();
			   console.log(getMaxListeners(et)); // 10
			   setMaxListeners(11, et);
			   console.log(getMaxListeners(et)); // 11
			}
			```
		**/
		function getMaxListeners(emitter:ts.AnyOf2<global.nodejs.EventEmitter, Sqlite3>):Float;
		/**
			```js
			import { setMaxListeners, EventEmitter } from 'node:events';
			
			const target = new EventTarget();
			const emitter = new EventEmitter();
			
			setMaxListeners(5, target, emitter);
			```
		**/
		function setMaxListeners(?n:Float, eventTargets:haxe.extern.Rest<ts.AnyOf2<global.nodejs.EventEmitter, Sqlite3>>):Void;
		/**
			Listens once to the `abort` event on the provided `signal`.
			
			Listening to the `abort` event on abort signals is unsafe and may
			lead to resource leaks since another third party with the signal can
			call `e.stopImmediatePropagation()`. Unfortunately Node.js cannot change
			this since it would violate the web standard. Additionally, the original
			API makes it easy to forget to remove listeners.
			
			This API allows safely using `AbortSignal`s in Node.js APIs by solving these
			two issues by listening to the event such that `stopImmediatePropagation` does
			not prevent the listener from running.
			
			Returns a disposable so that it may be unsubscribed from more easily.
			
			```js
			import { addAbortListener } from 'node:events';
			
			function example(signal) {
			   let disposable;
			   try {
			     signal.addEventListener('abort', (e) => e.stopImmediatePropagation());
			     disposable = addAbortListener(signal, (e) => {
			       // Do something when signal is aborted.
			     });
			   } finally {
			     disposable?.[Symbol.dispose]();
			   }
			}
			```
		**/
		function addAbortListener(signal:js.html.AbortSignal, resource:(event:js.html.Event) -> Void):global.Disposable;
		/**
			This symbol shall be used to install a listener for only monitoring `'error'`events. Listeners installed using this symbol are called before the regular`'error'` listeners are called.
			
			Installing a listener using this symbol does not change the behavior once an`'error'` event is emitted. Therefore, the process will still crash if no
			regular `'error'` listener is installed.
		**/
		final errorMonitor : js.lib.Symbol;
		/**
			Value: `Symbol.for('nodejs.rejection')`
			
			See how to write a custom `rejection handler`.
		**/
		final captureRejectionSymbol : js.lib.Symbol;
		/**
			Value: [boolean](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Data_structures#Boolean_type)
			
			Change the default `captureRejections` option on all new `EventEmitter` objects.
		**/
		var captureRejections : Bool;
		/**
			By default, a maximum of `10` listeners can be registered for any single
			event. This limit can be changed for individual `EventEmitter` instances
			using the `emitter.setMaxListeners(n)` method. To change the default
			for _all_`EventEmitter` instances, the `events.defaultMaxListeners`property can be used. If this value is not a positive number, a `RangeError`is thrown.
			
			Take caution when setting the `events.defaultMaxListeners` because the
			change affects _all_`EventEmitter` instances, including those created before
			the change is made. However, calling `emitter.setMaxListeners(n)` still has
			precedence over `events.defaultMaxListeners`.
			
			This is not a hard limit. The `EventEmitter` instance will allow
			more listeners to be added but will output a trace warning to stderr indicating
			that a "possible EventEmitter memory leak" has been detected. For any single`EventEmitter`, the `emitter.getMaxListeners()` and `emitter.setMaxListeners()`methods can be used to
			temporarily avoid this warning:
			
			```js
			import { EventEmitter } from 'node:events';
			const emitter = new EventEmitter();
			emitter.setMaxListeners(emitter.getMaxListeners() + 1);
			emitter.once('event', () => {
			   // do stuff
			   emitter.setMaxListeners(Math.max(emitter.getMaxListeners() - 1, 0));
			});
			```
			
			The `--trace-warnings` command-line flag can be used to display the
			stack trace for such warnings.
			
			The emitted warning can be inspected with `process.on('warning')` and will
			have the additional `emitter`, `type`, and `count` properties, referring to
			the event emitter instance, the event's name and the number of attached
			listeners, respectively.
			Its `name` property is set to `'MaxListenersExceededWarning'`.
		**/
		var defaultMaxListeners : Float;
	};
	var Database : {
		var prototype : Database;
		/**
			Creates a `Promise` that is fulfilled when the `EventEmitter` emits the given
			event or that is rejected if the `EventEmitter` emits `'error'` while waiting.
			The `Promise` will resolve with an array of all the arguments emitted to the
			given event.
			
			This method is intentionally generic and works with the web platform [EventTarget](https://dom.spec.whatwg.org/#interface-eventtarget) interface, which has no special`'error'` event
			semantics and does not listen to the `'error'` event.
			
			```js
			import { once, EventEmitter } from 'node:events';
			import process from 'node:process';
			
			const ee = new EventEmitter();
			
			process.nextTick(() => {
			   ee.emit('myevent', 42);
			});
			
			const [value] = await once(ee, 'myevent');
			console.log(value);
			
			const err = new Error('kaboom');
			process.nextTick(() => {
			   ee.emit('error', err);
			});
			
			try {
			   await once(ee, 'myevent');
			} catch (err) {
			   console.error('error happened', err);
			}
			```
			
			The special handling of the `'error'` event is only used when `events.once()`is used to wait for another event. If `events.once()` is used to wait for the
			'`error'` event itself, then it is treated as any other kind of event without
			special handling:
			
			```js
			import { EventEmitter, once } from 'node:events';
			
			const ee = new EventEmitter();
			
			once(ee, 'error')
			   .then(([err]) => console.log('ok', err.message))
			   .catch((err) => console.error('error', err.message));
			
			ee.emit('error', new Error('boom'));
			
			// Prints: ok boom
			```
			
			An `AbortSignal` can be used to cancel waiting for the event:
			
			```js
			import { EventEmitter, once } from 'node:events';
			
			const ee = new EventEmitter();
			const ac = new AbortController();
			
			async function foo(emitter, event, signal) {
			   try {
			     await once(emitter, event, { signal });
			     console.log('event emitted!');
			   } catch (error) {
			     if (error.name === 'AbortError') {
			       console.error('Waiting for the event was canceled!');
			     } else {
			       console.error('There was an error', error.message);
			     }
			   }
			}
			
			foo(ee, 'foo', ac.signal);
			ac.abort(); // Abort waiting for the event
			ee.emit('foo'); // Prints: Waiting for the event was canceled!
			```
		**/
		@:overload(function(emitter:Sqlite3, eventName:String, ?options:Sqlite3):js.lib.Promise<Array<Dynamic>> { })
		function once(emitter:Sqlite3, eventName:ts.AnyOf2<String, js.lib.Symbol>, ?options:Sqlite3):js.lib.Promise<Array<Dynamic>>;
		/**
			```js
			import { on, EventEmitter } from 'node:events';
			import process from 'node:process';
			
			const ee = new EventEmitter();
			
			// Emit later on
			process.nextTick(() => {
			   ee.emit('foo', 'bar');
			   ee.emit('foo', 42);
			});
			
			for await (const event of on(ee, 'foo')) {
			   // The execution of this inner block is synchronous and it
			   // processes one event at a time (even with await). Do not use
			   // if concurrent execution is required.
			   console.log(event); // prints ['bar'] [42]
			}
			// Unreachable here
			```
			
			Returns an `AsyncIterator` that iterates `eventName` events. It will throw
			if the `EventEmitter` emits `'error'`. It removes all listeners when
			exiting the loop. The `value` returned by each iteration is an array
			composed of the emitted event arguments.
			
			An `AbortSignal` can be used to cancel waiting on events:
			
			```js
			import { on, EventEmitter } from 'node:events';
			import process from 'node:process';
			
			const ac = new AbortController();
			
			(async () => {
			   const ee = new EventEmitter();
			
			   // Emit later on
			   process.nextTick(() => {
			     ee.emit('foo', 'bar');
			     ee.emit('foo', 42);
			   });
			
			   for await (const event of on(ee, 'foo', { signal: ac.signal })) {
			     // The execution of this inner block is synchronous and it
			     // processes one event at a time (even with await). Do not use
			     // if concurrent execution is required.
			     console.log(event); // prints ['bar'] [42]
			   }
			   // Unreachable here
			})();
			
			process.nextTick(() => ac.abort());
			```
		**/
		function on(emitter:global.nodejs.EventEmitter, eventName:String, ?options:Sqlite3):js.lib.AsyncIterableIterator<Dynamic>;
		/**
			A class method that returns the number of listeners for the given `eventName`registered on the given `emitter`.
			
			```js
			import { EventEmitter, listenerCount } from 'node:events';
			
			const myEmitter = new EventEmitter();
			myEmitter.on('event', () => {});
			myEmitter.on('event', () => {});
			console.log(listenerCount(myEmitter, 'event'));
			// Prints: 2
			```
		**/
		function listenerCount(emitter:global.nodejs.EventEmitter, eventName:ts.AnyOf2<String, js.lib.Symbol>):Float;
		/**
			Returns a copy of the array of listeners for the event named `eventName`.
			
			For `EventEmitter`s this behaves exactly the same as calling `.listeners` on
			the emitter.
			
			For `EventTarget`s this is the only way to get the event listeners for the
			event target. This is useful for debugging and diagnostic purposes.
			
			```js
			import { getEventListeners, EventEmitter } from 'node:events';
			
			{
			   const ee = new EventEmitter();
			   const listener = () => console.log('Events are fun');
			   ee.on('foo', listener);
			   console.log(getEventListeners(ee, 'foo')); // [ [Function: listener] ]
			}
			{
			   const et = new EventTarget();
			   const listener = () => console.log('Events are fun');
			   et.addEventListener('foo', listener);
			   console.log(getEventListeners(et, 'foo')); // [ [Function: listener] ]
			}
			```
		**/
		function getEventListeners(emitter:ts.AnyOf2<global.nodejs.EventEmitter, Sqlite3>, name:ts.AnyOf2<String, js.lib.Symbol>):Array<haxe.Constraints.Function>;
		/**
			Returns the currently set max amount of listeners.
			
			For `EventEmitter`s this behaves exactly the same as calling `.getMaxListeners` on
			the emitter.
			
			For `EventTarget`s this is the only way to get the max event listeners for the
			event target. If the number of event handlers on a single EventTarget exceeds
			the max set, the EventTarget will print a warning.
			
			```js
			import { getMaxListeners, setMaxListeners, EventEmitter } from 'node:events';
			
			{
			   const ee = new EventEmitter();
			   console.log(getMaxListeners(ee)); // 10
			   setMaxListeners(11, ee);
			   console.log(getMaxListeners(ee)); // 11
			}
			{
			   const et = new EventTarget();
			   console.log(getMaxListeners(et)); // 10
			   setMaxListeners(11, et);
			   console.log(getMaxListeners(et)); // 11
			}
			```
		**/
		function getMaxListeners(emitter:ts.AnyOf2<global.nodejs.EventEmitter, Sqlite3>):Float;
		/**
			```js
			import { setMaxListeners, EventEmitter } from 'node:events';
			
			const target = new EventTarget();
			const emitter = new EventEmitter();
			
			setMaxListeners(5, target, emitter);
			```
		**/
		function setMaxListeners(?n:Float, eventTargets:haxe.extern.Rest<ts.AnyOf2<global.nodejs.EventEmitter, Sqlite3>>):Void;
		/**
			Listens once to the `abort` event on the provided `signal`.
			
			Listening to the `abort` event on abort signals is unsafe and may
			lead to resource leaks since another third party with the signal can
			call `e.stopImmediatePropagation()`. Unfortunately Node.js cannot change
			this since it would violate the web standard. Additionally, the original
			API makes it easy to forget to remove listeners.
			
			This API allows safely using `AbortSignal`s in Node.js APIs by solving these
			two issues by listening to the event such that `stopImmediatePropagation` does
			not prevent the listener from running.
			
			Returns a disposable so that it may be unsubscribed from more easily.
			
			```js
			import { addAbortListener } from 'node:events';
			
			function example(signal) {
			   let disposable;
			   try {
			     signal.addEventListener('abort', (e) => e.stopImmediatePropagation());
			     disposable = addAbortListener(signal, (e) => {
			       // Do something when signal is aborted.
			     });
			   } finally {
			     disposable?.[Symbol.dispose]();
			   }
			}
			```
		**/
		function addAbortListener(signal:js.html.AbortSignal, resource:(event:js.html.Event) -> Void):global.Disposable;
		/**
			This symbol shall be used to install a listener for only monitoring `'error'`events. Listeners installed using this symbol are called before the regular`'error'` listeners are called.
			
			Installing a listener using this symbol does not change the behavior once an`'error'` event is emitted. Therefore, the process will still crash if no
			regular `'error'` listener is installed.
		**/
		final errorMonitor : js.lib.Symbol;
		/**
			Value: `Symbol.for('nodejs.rejection')`
			
			See how to write a custom `rejection handler`.
		**/
		final captureRejectionSymbol : js.lib.Symbol;
		/**
			Value: [boolean](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Data_structures#Boolean_type)
			
			Change the default `captureRejections` option on all new `EventEmitter` objects.
		**/
		var captureRejections : Bool;
		/**
			By default, a maximum of `10` listeners can be registered for any single
			event. This limit can be changed for individual `EventEmitter` instances
			using the `emitter.setMaxListeners(n)` method. To change the default
			for _all_`EventEmitter` instances, the `events.defaultMaxListeners`property can be used. If this value is not a positive number, a `RangeError`is thrown.
			
			Take caution when setting the `events.defaultMaxListeners` because the
			change affects _all_`EventEmitter` instances, including those created before
			the change is made. However, calling `emitter.setMaxListeners(n)` still has
			precedence over `events.defaultMaxListeners`.
			
			This is not a hard limit. The `EventEmitter` instance will allow
			more listeners to be added but will output a trace warning to stderr indicating
			that a "possible EventEmitter memory leak" has been detected. For any single`EventEmitter`, the `emitter.getMaxListeners()` and `emitter.setMaxListeners()`methods can be used to
			temporarily avoid this warning:
			
			```js
			import { EventEmitter } from 'node:events';
			const emitter = new EventEmitter();
			emitter.setMaxListeners(emitter.getMaxListeners() + 1);
			emitter.once('event', () => {
			   // do stuff
			   emitter.setMaxListeners(Math.max(emitter.getMaxListeners() - 1, 0));
			});
			```
			
			The `--trace-warnings` command-line flag can be used to display the
			stack trace for such warnings.
			
			The emitted warning can be inspected with `process.on('warning')` and will
			have the additional `emitter`, `type`, and `count` properties, referring to
			the event emitter instance, the event's name and the number of attached
			listeners, respectively.
			Its `name` property is set to `'MaxListenersExceededWarning'`.
		**/
		var defaultMaxListeners : Float;
	};
	function verbose():Sqlite3;
};