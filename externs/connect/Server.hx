package connect;

typedef Server = {
	@:selfCall
	function call(req:node.http.IncomingMessage, res:node.http.ServerResponse<node.http.IncomingMessage>, ?next:haxe.Constraints.Function):Void;
	var route : String;
	var stack : Array<ServerStackItem>;
	/**
		Utilize the given middleware `handle` to the given `route`,
		defaulting to _/_. This "route" is the mount-point for the
		middleware, when given a value other than _/_ the middleware
		is only effective when that segment is present in the request's
		pathname.
		
		For example if we were to mount a function at _/admin_, it would
		be invoked on _/admin_, and _/admin/settings_, however it would
		not be invoked for _/_, or _/posts_.
	**/
	@:overload(function(fn:HandleFunction):Server { })
	@:overload(function(route:String, fn:NextHandleFunction):Server { })
	@:overload(function(route:String, fn:HandleFunction):Server { })
	function use(fn:NextHandleFunction):Server;
	/**
		Handle server requests, punting them down
		the middleware stack.
	**/
	function handle(req:node.http.IncomingMessage, res:node.http.ServerResponse<node.http.IncomingMessage>, next:haxe.Constraints.Function):Void;
	/**
		Listen for connections.
		
		This method takes the same arguments
		as node's `http.Server#listen()`.
		
		HTTP and HTTPS:
		
		If you run your application both as HTTP
		and HTTPS you may wrap them individually,
		since your Connect "server" is really just
		a JavaScript `Function`.
		
		      var connect = require('connect')
		        , http = require('http')
		        , https = require('https');
		
		      var app = connect();
		
		      http.createServer(app).listen(80);
		      https.createServer(options, app).listen(443);
	**/
	@:overload(function(port:Float, ?hostname:String, ?callback:haxe.Constraints.Function):node.http.Server<{
		var prototype : node.http.IncomingMessage;
		/**
			A utility method for creating a `Readable` from a web `ReadableStream`.
		**/
		function fromWeb(readableStream:node.stream.web.ReadableStream<Dynamic>, ?options:{ @:optional var encoding : global.nodejs.BufferEncoding; @:optional var highWaterMark : Float; @:optional var objectMode : Bool; /** When provided the corresponding `AbortController` can be used to cancel an asynchronous action. **/ @:optional var signal : js.html.AbortSignal; }):node.stream.Readable;
		/**
			A utility method for creating a web `ReadableStream` from a `Readable`.
		**/
		function toWeb(streamReadable:node.stream.Readable):node.stream.web.ReadableStream<Dynamic>;
		/**
			A utility method for creating Readable Streams out of iterators.
		**/
		function from(iterable:ts.AnyOf2<Iterable<Dynamic>, js.lib.AsyncIterable<Dynamic>>, ?options:node.stream.ReadableOptions):node.stream.Readable;
		/**
			Returns whether the stream has been read from or cancelled.
		**/
		function isDisturbed(stream:ts.AnyOf2<node.stream.Readable, global.nodejs.ReadableStream>):Bool;
		/**
			A stream to attach a signal to.
			
			Attaches an AbortSignal to a readable or writeable stream. This lets code
			control stream destruction using an `AbortController`.
			
			Calling `abort` on the `AbortController` corresponding to the passed`AbortSignal` will behave the same way as calling `.destroy(new AbortError())`on the stream, and `controller.error(new
			AbortError())` for webstreams.
			
			```js
			const fs = require('node:fs');
			
			const controller = new AbortController();
			const read = addAbortSignal(
			   controller.signal,
			   fs.createReadStream(('object.json')),
			);
			// Later, abort the operation closing the stream
			controller.abort();
			```
			
			Or using an `AbortSignal` with a readable stream as an async iterable:
			
			```js
			const controller = new AbortController();
			setTimeout(() => controller.abort(), 10_000); // set a timeout
			const stream = addAbortSignal(
			   controller.signal,
			   fs.createReadStream(('object.json')),
			);
			(async () => {
			   try {
			     for await (const chunk of stream) {
			       await process(chunk);
			     }
			   } catch (e) {
			     if (e.name === 'AbortError') {
			       // The operation was cancelled
			     } else {
			       throw e;
			     }
			   }
			})();
			```
			
			Or using an `AbortSignal` with a ReadableStream:
			
			```js
			const controller = new AbortController();
			const rs = new ReadableStream({
			   start(controller) {
			     controller.enqueue('hello');
			     controller.enqueue('world');
			     controller.close();
			   },
			});
			
			addAbortSignal(controller.signal, rs);
			
			finished(rs, (err) => {
			   if (err) {
			     if (err.name === 'AbortError') {
			       // The operation was cancelled
			     }
			   }
			});
			
			const reader = rs.getReader();
			
			reader.read().then(({ value, done }) => {
			   console.log(value); // hello
			   console.log(done); // false
			   controller.abort();
			});
			```
		**/
		function addAbortSignal<T>(signal:js.html.AbortSignal, stream:T):T;
		/**
			Returns the default highWaterMark used by streams.
			Defaults to `16384` (16 KiB), or `16` for `objectMode`.
		**/
		function getDefaultHighWaterMark(objectMode:Bool):Float;
		/**
			Sets the default highWaterMark used by streams.
		**/
		function setDefaultHighWaterMark(objectMode:Bool, value:Float):Void;
		/**
			A readable and/or writable stream/webstream.
			
			A function to get notified when a stream is no longer readable, writable
			or has experienced an error or a premature close event.
			
			```js
			const { finished } = require('node:stream');
			const fs = require('node:fs');
			
			const rs = fs.createReadStream('archive.tar');
			
			finished(rs, (err) => {
			   if (err) {
			     console.error('Stream failed.', err);
			   } else {
			     console.log('Stream is done reading.');
			   }
			});
			
			rs.resume(); // Drain the stream.
			```
			
			Especially useful in error handling scenarios where a stream is destroyed
			prematurely (like an aborted HTTP request), and will not emit `'end'`or `'finish'`.
			
			The `finished` API provides `promise version`.
			
			`stream.finished()` leaves dangling event listeners (in particular`'error'`, `'end'`, `'finish'` and `'close'`) after `callback` has been
			invoked. The reason for this is so that unexpected `'error'` events (due to
			incorrect stream implementations) do not cause unexpected crashes.
			If this is unwanted behavior then the returned cleanup function needs to be
			invoked in the callback:
			
			```js
			const cleanup = finished(rs, (err) => {
			   cleanup();
			   // ...
			});
			```
		**/
		@:overload(function(stream:ts.AnyOf3<global.nodejs.ReadableStream, global.nodejs.WritableStream, global.nodejs.ReadWriteStream>, callback:ts.AnyOf2<() -> Void, (err:global.nodejs.ErrnoException) -> Void>):() -> Void { })
		function finished(stream:ts.AnyOf3<global.nodejs.ReadableStream, global.nodejs.WritableStream, global.nodejs.ReadWriteStream>, options:node.stream.FinishedOptions, callback:ts.AnyOf2<() -> Void, (err:global.nodejs.ErrnoException) -> Void>):() -> Void;
		/**
			A module method to pipe between streams and generators forwarding errors and
			properly cleaning up and provide a callback when the pipeline is complete.
			
			```js
			const { pipeline } = require('node:stream');
			const fs = require('node:fs');
			const zlib = require('node:zlib');
			
			// Use the pipeline API to easily pipe a series of streams
			// together and get notified when the pipeline is fully done.
			
			// A pipeline to gzip a potentially huge tar file efficiently:
			
			pipeline(
			   fs.createReadStream('archive.tar'),
			   zlib.createGzip(),
			   fs.createWriteStream('archive.tar.gz'),
			   (err) => {
			     if (err) {
			       console.error('Pipeline failed.', err);
			     } else {
			       console.log('Pipeline succeeded.');
			     }
			   },
			);
			```
			
			The `pipeline` API provides a `promise version`.
			
			`stream.pipeline()` will call `stream.destroy(err)` on all streams except:
			
			* `Readable` streams which have emitted `'end'` or `'close'`.
			* `Writable` streams which have emitted `'finish'` or `'close'`.
			
			`stream.pipeline()` leaves dangling event listeners on the streams
			after the `callback` has been invoked. In the case of reuse of streams after
			failure, this can cause event listener leaks and swallowed errors. If the last
			stream is readable, dangling event listeners will be removed so that the last
			stream can be consumed later.
			
			`stream.pipeline()` closes all the streams when an error is raised.
			The `IncomingRequest` usage with `pipeline` could lead to an unexpected behavior
			once it would destroy the socket without sending the expected response.
			See the example below:
			
			```js
			const fs = require('node:fs');
			const http = require('node:http');
			const { pipeline } = require('node:stream');
			
			const server = http.createServer((req, res) => {
			   const fileStream = fs.createReadStream('./fileNotExist.txt');
			   pipeline(fileStream, res, (err) => {
			     if (err) {
			       console.log(err); // No such file
			       // this message can't be sent once `pipeline` already destroyed the socket
			       return res.end('error!!!');
			     }
			   });
			});
			```
		**/
		@:overload(function<A, T1, B>(source:A, transform1:T1, destination:B, ?callback:node.stream.PipelineCallback<B>):Dynamic { })
		@:overload(function<A, T1, T2, B>(source:A, transform1:T1, transform2:T2, destination:B, ?callback:node.stream.PipelineCallback<B>):Dynamic { })
		@:overload(function<A, T1, T2, T3, B>(source:A, transform1:T1, transform2:T2, transform3:T3, destination:B, ?callback:node.stream.PipelineCallback<B>):Dynamic { })
		@:overload(function<A, T1, T2, T3, T4, B>(source:A, transform1:T1, transform2:T2, transform3:T3, transform4:T4, destination:B, ?callback:node.stream.PipelineCallback<B>):Dynamic { })
		@:overload(function(streams:haxe.ds.ReadOnlyArray<ts.AnyOf3<global.nodejs.ReadableStream, global.nodejs.WritableStream, global.nodejs.ReadWriteStream>>, ?callback:(err:Null<global.nodejs.ErrnoException>) -> Void):global.nodejs.WritableStream { })
		@:overload(function(stream1:global.nodejs.ReadableStream, stream2:ts.AnyOf2<global.nodejs.WritableStream, global.nodejs.ReadWriteStream>, streams:haxe.extern.Rest<ts.AnyOf3<global.nodejs.WritableStream, global.nodejs.ReadWriteStream, (err:Null<global.nodejs.ErrnoException>) -> Void>>):global.nodejs.WritableStream { })
		function pipeline<A, B>(source:A, destination:B, ?callback:node.stream.PipelineCallback<B>):Dynamic;
		/**
			Returns whether the stream has encountered an error.
		**/
		function isErrored(stream:ts.AnyOf4<node.stream.Readable, node.stream.Writable, global.nodejs.ReadableStream, global.nodejs.WritableStream>):Bool;
		/**
			Returns whether the stream is readable.
		**/
		function isReadable(stream:ts.AnyOf2<node.stream.Readable, global.nodejs.ReadableStream>):Bool;
		final promises : {
			function finished(stream:ts.AnyOf3<global.nodejs.ReadableStream, global.nodejs.WritableStream, global.nodejs.ReadWriteStream>, ?options:node.stream.FinishedOptions):js.lib.Promise<ts.Undefined>;
			@:overload(function<A, T1, B>(source:A, transform1:T1, destination:B, ?options:node.stream.PipelineOptions):node.stream.PipelinePromise<B> { })
			@:overload(function<A, T1, T2, B>(source:A, transform1:T1, transform2:T2, destination:B, ?options:node.stream.PipelineOptions):node.stream.PipelinePromise<B> { })
			@:overload(function<A, T1, T2, T3, B>(source:A, transform1:T1, transform2:T2, transform3:T3, destination:B, ?options:node.stream.PipelineOptions):node.stream.PipelinePromise<B> { })
			@:overload(function<A, T1, T2, T3, T4, B>(source:A, transform1:T1, transform2:T2, transform3:T3, transform4:T4, destination:B, ?options:node.stream.PipelineOptions):node.stream.PipelinePromise<B> { })
			@:overload(function(streams:haxe.ds.ReadOnlyArray<ts.AnyOf3<global.nodejs.ReadableStream, global.nodejs.WritableStream, global.nodejs.ReadWriteStream>>, ?options:node.stream.PipelineOptions):js.lib.Promise<ts.Undefined> { })
			@:overload(function(stream1:global.nodejs.ReadableStream, stream2:ts.AnyOf2<global.nodejs.WritableStream, global.nodejs.ReadWriteStream>, streams:haxe.extern.Rest<ts.AnyOf3<global.nodejs.WritableStream, global.nodejs.ReadWriteStream, node.stream.PipelineOptions>>):js.lib.Promise<ts.Undefined> { })
			function pipeline<A, B>(source:A, destination:B, ?options:node.stream.PipelineOptions):node.stream.PipelinePromise<B>;
		};
		final consumers : {
			function buffer(stream:ts.AnyOf3<node.stream.Readable, global.nodejs.ReadableStream, js.lib.AsyncIterator_<Dynamic, Dynamic, Null<Any>>>):js.lib.Promise<global.Buffer>;
			function text(stream:ts.AnyOf3<node.stream.Readable, global.nodejs.ReadableStream, js.lib.AsyncIterator_<Dynamic, Dynamic, Null<Any>>>):js.lib.Promise<String>;
			function arrayBuffer(stream:ts.AnyOf3<node.stream.Readable, global.nodejs.ReadableStream, js.lib.AsyncIterator_<Dynamic, Dynamic, Null<Any>>>):js.lib.Promise<js.lib.ArrayBuffer>;
			function blob(stream:ts.AnyOf3<node.stream.Readable, global.nodejs.ReadableStream, js.lib.AsyncIterator_<Dynamic, Dynamic, Null<Any>>>):js.lib.Promise<node.buffer.Blob>;
			function json(stream:ts.AnyOf3<node.stream.Readable, global.nodejs.ReadableStream, js.lib.AsyncIterator_<Dynamic, Dynamic, Null<Any>>>):js.lib.Promise<Any>;
		};
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
		@:overload(function(emitter:Server, eventName:String, ?options:Server):js.lib.Promise<Array<Dynamic>> { })
		function once(emitter:Server, eventName:ts.AnyOf2<String, js.lib.Symbol>, ?options:Server):js.lib.Promise<Array<Dynamic>>;
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
		function on(emitter:global.nodejs.EventEmitter, eventName:String, ?options:Server):js.lib.AsyncIterableIterator<Dynamic>;
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
		function getEventListeners(emitter:ts.AnyOf2<global.nodejs.EventEmitter, Server>, name:ts.AnyOf2<String, js.lib.Symbol>):Array<haxe.Constraints.Function>;
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
		function getMaxListeners(emitter:ts.AnyOf2<global.nodejs.EventEmitter, Server>):Float;
		/**
			```js
			import { setMaxListeners, EventEmitter } from 'node:events';
			
			const target = new EventTarget();
			const emitter = new EventEmitter();
			
			setMaxListeners(5, target, emitter);
			```
		**/
		function setMaxListeners(?n:Float, eventTargets:haxe.extern.Rest<ts.AnyOf2<global.nodejs.EventEmitter, Server>>):Void;
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
	}, {
		var prototype : node.http.ServerResponse<Dynamic>;
		/**
			A utility method for creating a `Writable` from a web `WritableStream`.
		**/
		function fromWeb(writableStream:node.stream.web.WritableStream<Dynamic>, ?options:{ @:optional var highWaterMark : Float; @:optional var objectMode : Bool; /** When provided the corresponding `AbortController` can be used to cancel an asynchronous action. **/ @:optional var signal : js.html.AbortSignal; @:optional var decodeStrings : Bool; }):node.stream.Writable;
		/**
			A utility method for creating a web `WritableStream` from a `Writable`.
		**/
		function toWeb(streamWritable:node.stream.Writable):node.stream.web.WritableStream<Dynamic>;
		/**
			A stream to attach a signal to.
			
			Attaches an AbortSignal to a readable or writeable stream. This lets code
			control stream destruction using an `AbortController`.
			
			Calling `abort` on the `AbortController` corresponding to the passed`AbortSignal` will behave the same way as calling `.destroy(new AbortError())`on the stream, and `controller.error(new
			AbortError())` for webstreams.
			
			```js
			const fs = require('node:fs');
			
			const controller = new AbortController();
			const read = addAbortSignal(
			   controller.signal,
			   fs.createReadStream(('object.json')),
			);
			// Later, abort the operation closing the stream
			controller.abort();
			```
			
			Or using an `AbortSignal` with a readable stream as an async iterable:
			
			```js
			const controller = new AbortController();
			setTimeout(() => controller.abort(), 10_000); // set a timeout
			const stream = addAbortSignal(
			   controller.signal,
			   fs.createReadStream(('object.json')),
			);
			(async () => {
			   try {
			     for await (const chunk of stream) {
			       await process(chunk);
			     }
			   } catch (e) {
			     if (e.name === 'AbortError') {
			       // The operation was cancelled
			     } else {
			       throw e;
			     }
			   }
			})();
			```
			
			Or using an `AbortSignal` with a ReadableStream:
			
			```js
			const controller = new AbortController();
			const rs = new ReadableStream({
			   start(controller) {
			     controller.enqueue('hello');
			     controller.enqueue('world');
			     controller.close();
			   },
			});
			
			addAbortSignal(controller.signal, rs);
			
			finished(rs, (err) => {
			   if (err) {
			     if (err.name === 'AbortError') {
			       // The operation was cancelled
			     }
			   }
			});
			
			const reader = rs.getReader();
			
			reader.read().then(({ value, done }) => {
			   console.log(value); // hello
			   console.log(done); // false
			   controller.abort();
			});
			```
		**/
		function addAbortSignal<T>(signal:js.html.AbortSignal, stream:T):T;
		/**
			Returns the default highWaterMark used by streams.
			Defaults to `16384` (16 KiB), or `16` for `objectMode`.
		**/
		function getDefaultHighWaterMark(objectMode:Bool):Float;
		/**
			Sets the default highWaterMark used by streams.
		**/
		function setDefaultHighWaterMark(objectMode:Bool, value:Float):Void;
		/**
			A readable and/or writable stream/webstream.
			
			A function to get notified when a stream is no longer readable, writable
			or has experienced an error or a premature close event.
			
			```js
			const { finished } = require('node:stream');
			const fs = require('node:fs');
			
			const rs = fs.createReadStream('archive.tar');
			
			finished(rs, (err) => {
			   if (err) {
			     console.error('Stream failed.', err);
			   } else {
			     console.log('Stream is done reading.');
			   }
			});
			
			rs.resume(); // Drain the stream.
			```
			
			Especially useful in error handling scenarios where a stream is destroyed
			prematurely (like an aborted HTTP request), and will not emit `'end'`or `'finish'`.
			
			The `finished` API provides `promise version`.
			
			`stream.finished()` leaves dangling event listeners (in particular`'error'`, `'end'`, `'finish'` and `'close'`) after `callback` has been
			invoked. The reason for this is so that unexpected `'error'` events (due to
			incorrect stream implementations) do not cause unexpected crashes.
			If this is unwanted behavior then the returned cleanup function needs to be
			invoked in the callback:
			
			```js
			const cleanup = finished(rs, (err) => {
			   cleanup();
			   // ...
			});
			```
		**/
		@:overload(function(stream:ts.AnyOf3<global.nodejs.ReadableStream, global.nodejs.WritableStream, global.nodejs.ReadWriteStream>, callback:ts.AnyOf2<() -> Void, (err:global.nodejs.ErrnoException) -> Void>):() -> Void { })
		function finished(stream:ts.AnyOf3<global.nodejs.ReadableStream, global.nodejs.WritableStream, global.nodejs.ReadWriteStream>, options:node.stream.FinishedOptions, callback:ts.AnyOf2<() -> Void, (err:global.nodejs.ErrnoException) -> Void>):() -> Void;
		/**
			A module method to pipe between streams and generators forwarding errors and
			properly cleaning up and provide a callback when the pipeline is complete.
			
			```js
			const { pipeline } = require('node:stream');
			const fs = require('node:fs');
			const zlib = require('node:zlib');
			
			// Use the pipeline API to easily pipe a series of streams
			// together and get notified when the pipeline is fully done.
			
			// A pipeline to gzip a potentially huge tar file efficiently:
			
			pipeline(
			   fs.createReadStream('archive.tar'),
			   zlib.createGzip(),
			   fs.createWriteStream('archive.tar.gz'),
			   (err) => {
			     if (err) {
			       console.error('Pipeline failed.', err);
			     } else {
			       console.log('Pipeline succeeded.');
			     }
			   },
			);
			```
			
			The `pipeline` API provides a `promise version`.
			
			`stream.pipeline()` will call `stream.destroy(err)` on all streams except:
			
			* `Readable` streams which have emitted `'end'` or `'close'`.
			* `Writable` streams which have emitted `'finish'` or `'close'`.
			
			`stream.pipeline()` leaves dangling event listeners on the streams
			after the `callback` has been invoked. In the case of reuse of streams after
			failure, this can cause event listener leaks and swallowed errors. If the last
			stream is readable, dangling event listeners will be removed so that the last
			stream can be consumed later.
			
			`stream.pipeline()` closes all the streams when an error is raised.
			The `IncomingRequest` usage with `pipeline` could lead to an unexpected behavior
			once it would destroy the socket without sending the expected response.
			See the example below:
			
			```js
			const fs = require('node:fs');
			const http = require('node:http');
			const { pipeline } = require('node:stream');
			
			const server = http.createServer((req, res) => {
			   const fileStream = fs.createReadStream('./fileNotExist.txt');
			   pipeline(fileStream, res, (err) => {
			     if (err) {
			       console.log(err); // No such file
			       // this message can't be sent once `pipeline` already destroyed the socket
			       return res.end('error!!!');
			     }
			   });
			});
			```
		**/
		@:overload(function<A, T1, B>(source:A, transform1:T1, destination:B, ?callback:node.stream.PipelineCallback<B>):Dynamic { })
		@:overload(function<A, T1, T2, B>(source:A, transform1:T1, transform2:T2, destination:B, ?callback:node.stream.PipelineCallback<B>):Dynamic { })
		@:overload(function<A, T1, T2, T3, B>(source:A, transform1:T1, transform2:T2, transform3:T3, destination:B, ?callback:node.stream.PipelineCallback<B>):Dynamic { })
		@:overload(function<A, T1, T2, T3, T4, B>(source:A, transform1:T1, transform2:T2, transform3:T3, transform4:T4, destination:B, ?callback:node.stream.PipelineCallback<B>):Dynamic { })
		@:overload(function(streams:haxe.ds.ReadOnlyArray<ts.AnyOf3<global.nodejs.ReadableStream, global.nodejs.WritableStream, global.nodejs.ReadWriteStream>>, ?callback:(err:Null<global.nodejs.ErrnoException>) -> Void):global.nodejs.WritableStream { })
		@:overload(function(stream1:global.nodejs.ReadableStream, stream2:ts.AnyOf2<global.nodejs.WritableStream, global.nodejs.ReadWriteStream>, streams:haxe.extern.Rest<ts.AnyOf3<global.nodejs.WritableStream, global.nodejs.ReadWriteStream, (err:Null<global.nodejs.ErrnoException>) -> Void>>):global.nodejs.WritableStream { })
		function pipeline<A, B>(source:A, destination:B, ?callback:node.stream.PipelineCallback<B>):Dynamic;
		/**
			Returns whether the stream has encountered an error.
		**/
		function isErrored(stream:ts.AnyOf4<node.stream.Readable, node.stream.Writable, global.nodejs.ReadableStream, global.nodejs.WritableStream>):Bool;
		/**
			Returns whether the stream is readable.
		**/
		function isReadable(stream:ts.AnyOf2<node.stream.Readable, global.nodejs.ReadableStream>):Bool;
		final promises : {
			function finished(stream:ts.AnyOf3<global.nodejs.ReadableStream, global.nodejs.WritableStream, global.nodejs.ReadWriteStream>, ?options:node.stream.FinishedOptions):js.lib.Promise<ts.Undefined>;
			@:overload(function<A, T1, B>(source:A, transform1:T1, destination:B, ?options:node.stream.PipelineOptions):node.stream.PipelinePromise<B> { })
			@:overload(function<A, T1, T2, B>(source:A, transform1:T1, transform2:T2, destination:B, ?options:node.stream.PipelineOptions):node.stream.PipelinePromise<B> { })
			@:overload(function<A, T1, T2, T3, B>(source:A, transform1:T1, transform2:T2, transform3:T3, destination:B, ?options:node.stream.PipelineOptions):node.stream.PipelinePromise<B> { })
			@:overload(function<A, T1, T2, T3, T4, B>(source:A, transform1:T1, transform2:T2, transform3:T3, transform4:T4, destination:B, ?options:node.stream.PipelineOptions):node.stream.PipelinePromise<B> { })
			@:overload(function(streams:haxe.ds.ReadOnlyArray<ts.AnyOf3<global.nodejs.ReadableStream, global.nodejs.WritableStream, global.nodejs.ReadWriteStream>>, ?options:node.stream.PipelineOptions):js.lib.Promise<ts.Undefined> { })
			@:overload(function(stream1:global.nodejs.ReadableStream, stream2:ts.AnyOf2<global.nodejs.WritableStream, global.nodejs.ReadWriteStream>, streams:haxe.extern.Rest<ts.AnyOf3<global.nodejs.WritableStream, global.nodejs.ReadWriteStream, node.stream.PipelineOptions>>):js.lib.Promise<ts.Undefined> { })
			function pipeline<A, B>(source:A, destination:B, ?options:node.stream.PipelineOptions):node.stream.PipelinePromise<B>;
		};
		final consumers : {
			function buffer(stream:ts.AnyOf3<node.stream.Readable, global.nodejs.ReadableStream, js.lib.AsyncIterator_<Dynamic, Dynamic, Null<Any>>>):js.lib.Promise<global.Buffer>;
			function text(stream:ts.AnyOf3<node.stream.Readable, global.nodejs.ReadableStream, js.lib.AsyncIterator_<Dynamic, Dynamic, Null<Any>>>):js.lib.Promise<String>;
			function arrayBuffer(stream:ts.AnyOf3<node.stream.Readable, global.nodejs.ReadableStream, js.lib.AsyncIterator_<Dynamic, Dynamic, Null<Any>>>):js.lib.Promise<js.lib.ArrayBuffer>;
			function blob(stream:ts.AnyOf3<node.stream.Readable, global.nodejs.ReadableStream, js.lib.AsyncIterator_<Dynamic, Dynamic, Null<Any>>>):js.lib.Promise<node.buffer.Blob>;
			function json(stream:ts.AnyOf3<node.stream.Readable, global.nodejs.ReadableStream, js.lib.AsyncIterator_<Dynamic, Dynamic, Null<Any>>>):js.lib.Promise<Any>;
		};
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
		@:overload(function(emitter:Server, eventName:String, ?options:Server):js.lib.Promise<Array<Dynamic>> { })
		function once(emitter:Server, eventName:ts.AnyOf2<String, js.lib.Symbol>, ?options:Server):js.lib.Promise<Array<Dynamic>>;
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
		function on(emitter:global.nodejs.EventEmitter, eventName:String, ?options:Server):js.lib.AsyncIterableIterator<Dynamic>;
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
		function getEventListeners(emitter:ts.AnyOf2<global.nodejs.EventEmitter, Server>, name:ts.AnyOf2<String, js.lib.Symbol>):Array<haxe.Constraints.Function>;
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
		function getMaxListeners(emitter:ts.AnyOf2<global.nodejs.EventEmitter, Server>):Float;
		/**
			```js
			import { setMaxListeners, EventEmitter } from 'node:events';
			
			const target = new EventTarget();
			const emitter = new EventEmitter();
			
			setMaxListeners(5, target, emitter);
			```
		**/
		function setMaxListeners(?n:Float, eventTargets:haxe.extern.Rest<ts.AnyOf2<global.nodejs.EventEmitter, Server>>):Void;
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
	}> { })
	@:overload(function(path:String, ?callback:haxe.Constraints.Function):node.http.Server<{
		var prototype : node.http.IncomingMessage;
		/**
			A utility method for creating a `Readable` from a web `ReadableStream`.
		**/
		function fromWeb(readableStream:node.stream.web.ReadableStream<Dynamic>, ?options:{ @:optional var encoding : global.nodejs.BufferEncoding; @:optional var highWaterMark : Float; @:optional var objectMode : Bool; /** When provided the corresponding `AbortController` can be used to cancel an asynchronous action. **/ @:optional var signal : js.html.AbortSignal; }):node.stream.Readable;
		/**
			A utility method for creating a web `ReadableStream` from a `Readable`.
		**/
		function toWeb(streamReadable:node.stream.Readable):node.stream.web.ReadableStream<Dynamic>;
		/**
			A utility method for creating Readable Streams out of iterators.
		**/
		function from(iterable:ts.AnyOf2<Iterable<Dynamic>, js.lib.AsyncIterable<Dynamic>>, ?options:node.stream.ReadableOptions):node.stream.Readable;
		/**
			Returns whether the stream has been read from or cancelled.
		**/
		function isDisturbed(stream:ts.AnyOf2<node.stream.Readable, global.nodejs.ReadableStream>):Bool;
		/**
			A stream to attach a signal to.
			
			Attaches an AbortSignal to a readable or writeable stream. This lets code
			control stream destruction using an `AbortController`.
			
			Calling `abort` on the `AbortController` corresponding to the passed`AbortSignal` will behave the same way as calling `.destroy(new AbortError())`on the stream, and `controller.error(new
			AbortError())` for webstreams.
			
			```js
			const fs = require('node:fs');
			
			const controller = new AbortController();
			const read = addAbortSignal(
			   controller.signal,
			   fs.createReadStream(('object.json')),
			);
			// Later, abort the operation closing the stream
			controller.abort();
			```
			
			Or using an `AbortSignal` with a readable stream as an async iterable:
			
			```js
			const controller = new AbortController();
			setTimeout(() => controller.abort(), 10_000); // set a timeout
			const stream = addAbortSignal(
			   controller.signal,
			   fs.createReadStream(('object.json')),
			);
			(async () => {
			   try {
			     for await (const chunk of stream) {
			       await process(chunk);
			     }
			   } catch (e) {
			     if (e.name === 'AbortError') {
			       // The operation was cancelled
			     } else {
			       throw e;
			     }
			   }
			})();
			```
			
			Or using an `AbortSignal` with a ReadableStream:
			
			```js
			const controller = new AbortController();
			const rs = new ReadableStream({
			   start(controller) {
			     controller.enqueue('hello');
			     controller.enqueue('world');
			     controller.close();
			   },
			});
			
			addAbortSignal(controller.signal, rs);
			
			finished(rs, (err) => {
			   if (err) {
			     if (err.name === 'AbortError') {
			       // The operation was cancelled
			     }
			   }
			});
			
			const reader = rs.getReader();
			
			reader.read().then(({ value, done }) => {
			   console.log(value); // hello
			   console.log(done); // false
			   controller.abort();
			});
			```
		**/
		function addAbortSignal<T>(signal:js.html.AbortSignal, stream:T):T;
		/**
			Returns the default highWaterMark used by streams.
			Defaults to `16384` (16 KiB), or `16` for `objectMode`.
		**/
		function getDefaultHighWaterMark(objectMode:Bool):Float;
		/**
			Sets the default highWaterMark used by streams.
		**/
		function setDefaultHighWaterMark(objectMode:Bool, value:Float):Void;
		/**
			A readable and/or writable stream/webstream.
			
			A function to get notified when a stream is no longer readable, writable
			or has experienced an error or a premature close event.
			
			```js
			const { finished } = require('node:stream');
			const fs = require('node:fs');
			
			const rs = fs.createReadStream('archive.tar');
			
			finished(rs, (err) => {
			   if (err) {
			     console.error('Stream failed.', err);
			   } else {
			     console.log('Stream is done reading.');
			   }
			});
			
			rs.resume(); // Drain the stream.
			```
			
			Especially useful in error handling scenarios where a stream is destroyed
			prematurely (like an aborted HTTP request), and will not emit `'end'`or `'finish'`.
			
			The `finished` API provides `promise version`.
			
			`stream.finished()` leaves dangling event listeners (in particular`'error'`, `'end'`, `'finish'` and `'close'`) after `callback` has been
			invoked. The reason for this is so that unexpected `'error'` events (due to
			incorrect stream implementations) do not cause unexpected crashes.
			If this is unwanted behavior then the returned cleanup function needs to be
			invoked in the callback:
			
			```js
			const cleanup = finished(rs, (err) => {
			   cleanup();
			   // ...
			});
			```
		**/
		@:overload(function(stream:ts.AnyOf3<global.nodejs.ReadableStream, global.nodejs.WritableStream, global.nodejs.ReadWriteStream>, callback:ts.AnyOf2<() -> Void, (err:global.nodejs.ErrnoException) -> Void>):() -> Void { })
		function finished(stream:ts.AnyOf3<global.nodejs.ReadableStream, global.nodejs.WritableStream, global.nodejs.ReadWriteStream>, options:node.stream.FinishedOptions, callback:ts.AnyOf2<() -> Void, (err:global.nodejs.ErrnoException) -> Void>):() -> Void;
		/**
			A module method to pipe between streams and generators forwarding errors and
			properly cleaning up and provide a callback when the pipeline is complete.
			
			```js
			const { pipeline } = require('node:stream');
			const fs = require('node:fs');
			const zlib = require('node:zlib');
			
			// Use the pipeline API to easily pipe a series of streams
			// together and get notified when the pipeline is fully done.
			
			// A pipeline to gzip a potentially huge tar file efficiently:
			
			pipeline(
			   fs.createReadStream('archive.tar'),
			   zlib.createGzip(),
			   fs.createWriteStream('archive.tar.gz'),
			   (err) => {
			     if (err) {
			       console.error('Pipeline failed.', err);
			     } else {
			       console.log('Pipeline succeeded.');
			     }
			   },
			);
			```
			
			The `pipeline` API provides a `promise version`.
			
			`stream.pipeline()` will call `stream.destroy(err)` on all streams except:
			
			* `Readable` streams which have emitted `'end'` or `'close'`.
			* `Writable` streams which have emitted `'finish'` or `'close'`.
			
			`stream.pipeline()` leaves dangling event listeners on the streams
			after the `callback` has been invoked. In the case of reuse of streams after
			failure, this can cause event listener leaks and swallowed errors. If the last
			stream is readable, dangling event listeners will be removed so that the last
			stream can be consumed later.
			
			`stream.pipeline()` closes all the streams when an error is raised.
			The `IncomingRequest` usage with `pipeline` could lead to an unexpected behavior
			once it would destroy the socket without sending the expected response.
			See the example below:
			
			```js
			const fs = require('node:fs');
			const http = require('node:http');
			const { pipeline } = require('node:stream');
			
			const server = http.createServer((req, res) => {
			   const fileStream = fs.createReadStream('./fileNotExist.txt');
			   pipeline(fileStream, res, (err) => {
			     if (err) {
			       console.log(err); // No such file
			       // this message can't be sent once `pipeline` already destroyed the socket
			       return res.end('error!!!');
			     }
			   });
			});
			```
		**/
		@:overload(function<A, T1, B>(source:A, transform1:T1, destination:B, ?callback:node.stream.PipelineCallback<B>):Dynamic { })
		@:overload(function<A, T1, T2, B>(source:A, transform1:T1, transform2:T2, destination:B, ?callback:node.stream.PipelineCallback<B>):Dynamic { })
		@:overload(function<A, T1, T2, T3, B>(source:A, transform1:T1, transform2:T2, transform3:T3, destination:B, ?callback:node.stream.PipelineCallback<B>):Dynamic { })
		@:overload(function<A, T1, T2, T3, T4, B>(source:A, transform1:T1, transform2:T2, transform3:T3, transform4:T4, destination:B, ?callback:node.stream.PipelineCallback<B>):Dynamic { })
		@:overload(function(streams:haxe.ds.ReadOnlyArray<ts.AnyOf3<global.nodejs.ReadableStream, global.nodejs.WritableStream, global.nodejs.ReadWriteStream>>, ?callback:(err:Null<global.nodejs.ErrnoException>) -> Void):global.nodejs.WritableStream { })
		@:overload(function(stream1:global.nodejs.ReadableStream, stream2:ts.AnyOf2<global.nodejs.WritableStream, global.nodejs.ReadWriteStream>, streams:haxe.extern.Rest<ts.AnyOf3<global.nodejs.WritableStream, global.nodejs.ReadWriteStream, (err:Null<global.nodejs.ErrnoException>) -> Void>>):global.nodejs.WritableStream { })
		function pipeline<A, B>(source:A, destination:B, ?callback:node.stream.PipelineCallback<B>):Dynamic;
		/**
			Returns whether the stream has encountered an error.
		**/
		function isErrored(stream:ts.AnyOf4<node.stream.Readable, node.stream.Writable, global.nodejs.ReadableStream, global.nodejs.WritableStream>):Bool;
		/**
			Returns whether the stream is readable.
		**/
		function isReadable(stream:ts.AnyOf2<node.stream.Readable, global.nodejs.ReadableStream>):Bool;
		final promises : {
			function finished(stream:ts.AnyOf3<global.nodejs.ReadableStream, global.nodejs.WritableStream, global.nodejs.ReadWriteStream>, ?options:node.stream.FinishedOptions):js.lib.Promise<ts.Undefined>;
			@:overload(function<A, T1, B>(source:A, transform1:T1, destination:B, ?options:node.stream.PipelineOptions):node.stream.PipelinePromise<B> { })
			@:overload(function<A, T1, T2, B>(source:A, transform1:T1, transform2:T2, destination:B, ?options:node.stream.PipelineOptions):node.stream.PipelinePromise<B> { })
			@:overload(function<A, T1, T2, T3, B>(source:A, transform1:T1, transform2:T2, transform3:T3, destination:B, ?options:node.stream.PipelineOptions):node.stream.PipelinePromise<B> { })
			@:overload(function<A, T1, T2, T3, T4, B>(source:A, transform1:T1, transform2:T2, transform3:T3, transform4:T4, destination:B, ?options:node.stream.PipelineOptions):node.stream.PipelinePromise<B> { })
			@:overload(function(streams:haxe.ds.ReadOnlyArray<ts.AnyOf3<global.nodejs.ReadableStream, global.nodejs.WritableStream, global.nodejs.ReadWriteStream>>, ?options:node.stream.PipelineOptions):js.lib.Promise<ts.Undefined> { })
			@:overload(function(stream1:global.nodejs.ReadableStream, stream2:ts.AnyOf2<global.nodejs.WritableStream, global.nodejs.ReadWriteStream>, streams:haxe.extern.Rest<ts.AnyOf3<global.nodejs.WritableStream, global.nodejs.ReadWriteStream, node.stream.PipelineOptions>>):js.lib.Promise<ts.Undefined> { })
			function pipeline<A, B>(source:A, destination:B, ?options:node.stream.PipelineOptions):node.stream.PipelinePromise<B>;
		};
		final consumers : {
			function buffer(stream:ts.AnyOf3<node.stream.Readable, global.nodejs.ReadableStream, js.lib.AsyncIterator_<Dynamic, Dynamic, Null<Any>>>):js.lib.Promise<global.Buffer>;
			function text(stream:ts.AnyOf3<node.stream.Readable, global.nodejs.ReadableStream, js.lib.AsyncIterator_<Dynamic, Dynamic, Null<Any>>>):js.lib.Promise<String>;
			function arrayBuffer(stream:ts.AnyOf3<node.stream.Readable, global.nodejs.ReadableStream, js.lib.AsyncIterator_<Dynamic, Dynamic, Null<Any>>>):js.lib.Promise<js.lib.ArrayBuffer>;
			function blob(stream:ts.AnyOf3<node.stream.Readable, global.nodejs.ReadableStream, js.lib.AsyncIterator_<Dynamic, Dynamic, Null<Any>>>):js.lib.Promise<node.buffer.Blob>;
			function json(stream:ts.AnyOf3<node.stream.Readable, global.nodejs.ReadableStream, js.lib.AsyncIterator_<Dynamic, Dynamic, Null<Any>>>):js.lib.Promise<Any>;
		};
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
		@:overload(function(emitter:Server, eventName:String, ?options:Server):js.lib.Promise<Array<Dynamic>> { })
		function once(emitter:Server, eventName:ts.AnyOf2<String, js.lib.Symbol>, ?options:Server):js.lib.Promise<Array<Dynamic>>;
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
		function on(emitter:global.nodejs.EventEmitter, eventName:String, ?options:Server):js.lib.AsyncIterableIterator<Dynamic>;
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
		function getEventListeners(emitter:ts.AnyOf2<global.nodejs.EventEmitter, Server>, name:ts.AnyOf2<String, js.lib.Symbol>):Array<haxe.Constraints.Function>;
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
		function getMaxListeners(emitter:ts.AnyOf2<global.nodejs.EventEmitter, Server>):Float;
		/**
			```js
			import { setMaxListeners, EventEmitter } from 'node:events';
			
			const target = new EventTarget();
			const emitter = new EventEmitter();
			
			setMaxListeners(5, target, emitter);
			```
		**/
		function setMaxListeners(?n:Float, eventTargets:haxe.extern.Rest<ts.AnyOf2<global.nodejs.EventEmitter, Server>>):Void;
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
	}, {
		var prototype : node.http.ServerResponse<Dynamic>;
		/**
			A utility method for creating a `Writable` from a web `WritableStream`.
		**/
		function fromWeb(writableStream:node.stream.web.WritableStream<Dynamic>, ?options:{ @:optional var highWaterMark : Float; @:optional var objectMode : Bool; /** When provided the corresponding `AbortController` can be used to cancel an asynchronous action. **/ @:optional var signal : js.html.AbortSignal; @:optional var decodeStrings : Bool; }):node.stream.Writable;
		/**
			A utility method for creating a web `WritableStream` from a `Writable`.
		**/
		function toWeb(streamWritable:node.stream.Writable):node.stream.web.WritableStream<Dynamic>;
		/**
			A stream to attach a signal to.
			
			Attaches an AbortSignal to a readable or writeable stream. This lets code
			control stream destruction using an `AbortController`.
			
			Calling `abort` on the `AbortController` corresponding to the passed`AbortSignal` will behave the same way as calling `.destroy(new AbortError())`on the stream, and `controller.error(new
			AbortError())` for webstreams.
			
			```js
			const fs = require('node:fs');
			
			const controller = new AbortController();
			const read = addAbortSignal(
			   controller.signal,
			   fs.createReadStream(('object.json')),
			);
			// Later, abort the operation closing the stream
			controller.abort();
			```
			
			Or using an `AbortSignal` with a readable stream as an async iterable:
			
			```js
			const controller = new AbortController();
			setTimeout(() => controller.abort(), 10_000); // set a timeout
			const stream = addAbortSignal(
			   controller.signal,
			   fs.createReadStream(('object.json')),
			);
			(async () => {
			   try {
			     for await (const chunk of stream) {
			       await process(chunk);
			     }
			   } catch (e) {
			     if (e.name === 'AbortError') {
			       // The operation was cancelled
			     } else {
			       throw e;
			     }
			   }
			})();
			```
			
			Or using an `AbortSignal` with a ReadableStream:
			
			```js
			const controller = new AbortController();
			const rs = new ReadableStream({
			   start(controller) {
			     controller.enqueue('hello');
			     controller.enqueue('world');
			     controller.close();
			   },
			});
			
			addAbortSignal(controller.signal, rs);
			
			finished(rs, (err) => {
			   if (err) {
			     if (err.name === 'AbortError') {
			       // The operation was cancelled
			     }
			   }
			});
			
			const reader = rs.getReader();
			
			reader.read().then(({ value, done }) => {
			   console.log(value); // hello
			   console.log(done); // false
			   controller.abort();
			});
			```
		**/
		function addAbortSignal<T>(signal:js.html.AbortSignal, stream:T):T;
		/**
			Returns the default highWaterMark used by streams.
			Defaults to `16384` (16 KiB), or `16` for `objectMode`.
		**/
		function getDefaultHighWaterMark(objectMode:Bool):Float;
		/**
			Sets the default highWaterMark used by streams.
		**/
		function setDefaultHighWaterMark(objectMode:Bool, value:Float):Void;
		/**
			A readable and/or writable stream/webstream.
			
			A function to get notified when a stream is no longer readable, writable
			or has experienced an error or a premature close event.
			
			```js
			const { finished } = require('node:stream');
			const fs = require('node:fs');
			
			const rs = fs.createReadStream('archive.tar');
			
			finished(rs, (err) => {
			   if (err) {
			     console.error('Stream failed.', err);
			   } else {
			     console.log('Stream is done reading.');
			   }
			});
			
			rs.resume(); // Drain the stream.
			```
			
			Especially useful in error handling scenarios where a stream is destroyed
			prematurely (like an aborted HTTP request), and will not emit `'end'`or `'finish'`.
			
			The `finished` API provides `promise version`.
			
			`stream.finished()` leaves dangling event listeners (in particular`'error'`, `'end'`, `'finish'` and `'close'`) after `callback` has been
			invoked. The reason for this is so that unexpected `'error'` events (due to
			incorrect stream implementations) do not cause unexpected crashes.
			If this is unwanted behavior then the returned cleanup function needs to be
			invoked in the callback:
			
			```js
			const cleanup = finished(rs, (err) => {
			   cleanup();
			   // ...
			});
			```
		**/
		@:overload(function(stream:ts.AnyOf3<global.nodejs.ReadableStream, global.nodejs.WritableStream, global.nodejs.ReadWriteStream>, callback:ts.AnyOf2<() -> Void, (err:global.nodejs.ErrnoException) -> Void>):() -> Void { })
		function finished(stream:ts.AnyOf3<global.nodejs.ReadableStream, global.nodejs.WritableStream, global.nodejs.ReadWriteStream>, options:node.stream.FinishedOptions, callback:ts.AnyOf2<() -> Void, (err:global.nodejs.ErrnoException) -> Void>):() -> Void;
		/**
			A module method to pipe between streams and generators forwarding errors and
			properly cleaning up and provide a callback when the pipeline is complete.
			
			```js
			const { pipeline } = require('node:stream');
			const fs = require('node:fs');
			const zlib = require('node:zlib');
			
			// Use the pipeline API to easily pipe a series of streams
			// together and get notified when the pipeline is fully done.
			
			// A pipeline to gzip a potentially huge tar file efficiently:
			
			pipeline(
			   fs.createReadStream('archive.tar'),
			   zlib.createGzip(),
			   fs.createWriteStream('archive.tar.gz'),
			   (err) => {
			     if (err) {
			       console.error('Pipeline failed.', err);
			     } else {
			       console.log('Pipeline succeeded.');
			     }
			   },
			);
			```
			
			The `pipeline` API provides a `promise version`.
			
			`stream.pipeline()` will call `stream.destroy(err)` on all streams except:
			
			* `Readable` streams which have emitted `'end'` or `'close'`.
			* `Writable` streams which have emitted `'finish'` or `'close'`.
			
			`stream.pipeline()` leaves dangling event listeners on the streams
			after the `callback` has been invoked. In the case of reuse of streams after
			failure, this can cause event listener leaks and swallowed errors. If the last
			stream is readable, dangling event listeners will be removed so that the last
			stream can be consumed later.
			
			`stream.pipeline()` closes all the streams when an error is raised.
			The `IncomingRequest` usage with `pipeline` could lead to an unexpected behavior
			once it would destroy the socket without sending the expected response.
			See the example below:
			
			```js
			const fs = require('node:fs');
			const http = require('node:http');
			const { pipeline } = require('node:stream');
			
			const server = http.createServer((req, res) => {
			   const fileStream = fs.createReadStream('./fileNotExist.txt');
			   pipeline(fileStream, res, (err) => {
			     if (err) {
			       console.log(err); // No such file
			       // this message can't be sent once `pipeline` already destroyed the socket
			       return res.end('error!!!');
			     }
			   });
			});
			```
		**/
		@:overload(function<A, T1, B>(source:A, transform1:T1, destination:B, ?callback:node.stream.PipelineCallback<B>):Dynamic { })
		@:overload(function<A, T1, T2, B>(source:A, transform1:T1, transform2:T2, destination:B, ?callback:node.stream.PipelineCallback<B>):Dynamic { })
		@:overload(function<A, T1, T2, T3, B>(source:A, transform1:T1, transform2:T2, transform3:T3, destination:B, ?callback:node.stream.PipelineCallback<B>):Dynamic { })
		@:overload(function<A, T1, T2, T3, T4, B>(source:A, transform1:T1, transform2:T2, transform3:T3, transform4:T4, destination:B, ?callback:node.stream.PipelineCallback<B>):Dynamic { })
		@:overload(function(streams:haxe.ds.ReadOnlyArray<ts.AnyOf3<global.nodejs.ReadableStream, global.nodejs.WritableStream, global.nodejs.ReadWriteStream>>, ?callback:(err:Null<global.nodejs.ErrnoException>) -> Void):global.nodejs.WritableStream { })
		@:overload(function(stream1:global.nodejs.ReadableStream, stream2:ts.AnyOf2<global.nodejs.WritableStream, global.nodejs.ReadWriteStream>, streams:haxe.extern.Rest<ts.AnyOf3<global.nodejs.WritableStream, global.nodejs.ReadWriteStream, (err:Null<global.nodejs.ErrnoException>) -> Void>>):global.nodejs.WritableStream { })
		function pipeline<A, B>(source:A, destination:B, ?callback:node.stream.PipelineCallback<B>):Dynamic;
		/**
			Returns whether the stream has encountered an error.
		**/
		function isErrored(stream:ts.AnyOf4<node.stream.Readable, node.stream.Writable, global.nodejs.ReadableStream, global.nodejs.WritableStream>):Bool;
		/**
			Returns whether the stream is readable.
		**/
		function isReadable(stream:ts.AnyOf2<node.stream.Readable, global.nodejs.ReadableStream>):Bool;
		final promises : {
			function finished(stream:ts.AnyOf3<global.nodejs.ReadableStream, global.nodejs.WritableStream, global.nodejs.ReadWriteStream>, ?options:node.stream.FinishedOptions):js.lib.Promise<ts.Undefined>;
			@:overload(function<A, T1, B>(source:A, transform1:T1, destination:B, ?options:node.stream.PipelineOptions):node.stream.PipelinePromise<B> { })
			@:overload(function<A, T1, T2, B>(source:A, transform1:T1, transform2:T2, destination:B, ?options:node.stream.PipelineOptions):node.stream.PipelinePromise<B> { })
			@:overload(function<A, T1, T2, T3, B>(source:A, transform1:T1, transform2:T2, transform3:T3, destination:B, ?options:node.stream.PipelineOptions):node.stream.PipelinePromise<B> { })
			@:overload(function<A, T1, T2, T3, T4, B>(source:A, transform1:T1, transform2:T2, transform3:T3, transform4:T4, destination:B, ?options:node.stream.PipelineOptions):node.stream.PipelinePromise<B> { })
			@:overload(function(streams:haxe.ds.ReadOnlyArray<ts.AnyOf3<global.nodejs.ReadableStream, global.nodejs.WritableStream, global.nodejs.ReadWriteStream>>, ?options:node.stream.PipelineOptions):js.lib.Promise<ts.Undefined> { })
			@:overload(function(stream1:global.nodejs.ReadableStream, stream2:ts.AnyOf2<global.nodejs.WritableStream, global.nodejs.ReadWriteStream>, streams:haxe.extern.Rest<ts.AnyOf3<global.nodejs.WritableStream, global.nodejs.ReadWriteStream, node.stream.PipelineOptions>>):js.lib.Promise<ts.Undefined> { })
			function pipeline<A, B>(source:A, destination:B, ?options:node.stream.PipelineOptions):node.stream.PipelinePromise<B>;
		};
		final consumers : {
			function buffer(stream:ts.AnyOf3<node.stream.Readable, global.nodejs.ReadableStream, js.lib.AsyncIterator_<Dynamic, Dynamic, Null<Any>>>):js.lib.Promise<global.Buffer>;
			function text(stream:ts.AnyOf3<node.stream.Readable, global.nodejs.ReadableStream, js.lib.AsyncIterator_<Dynamic, Dynamic, Null<Any>>>):js.lib.Promise<String>;
			function arrayBuffer(stream:ts.AnyOf3<node.stream.Readable, global.nodejs.ReadableStream, js.lib.AsyncIterator_<Dynamic, Dynamic, Null<Any>>>):js.lib.Promise<js.lib.ArrayBuffer>;
			function blob(stream:ts.AnyOf3<node.stream.Readable, global.nodejs.ReadableStream, js.lib.AsyncIterator_<Dynamic, Dynamic, Null<Any>>>):js.lib.Promise<node.buffer.Blob>;
			function json(stream:ts.AnyOf3<node.stream.Readable, global.nodejs.ReadableStream, js.lib.AsyncIterator_<Dynamic, Dynamic, Null<Any>>>):js.lib.Promise<Any>;
		};
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
		@:overload(function(emitter:Server, eventName:String, ?options:Server):js.lib.Promise<Array<Dynamic>> { })
		function once(emitter:Server, eventName:ts.AnyOf2<String, js.lib.Symbol>, ?options:Server):js.lib.Promise<Array<Dynamic>>;
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
		function on(emitter:global.nodejs.EventEmitter, eventName:String, ?options:Server):js.lib.AsyncIterableIterator<Dynamic>;
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
		function getEventListeners(emitter:ts.AnyOf2<global.nodejs.EventEmitter, Server>, name:ts.AnyOf2<String, js.lib.Symbol>):Array<haxe.Constraints.Function>;
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
		function getMaxListeners(emitter:ts.AnyOf2<global.nodejs.EventEmitter, Server>):Float;
		/**
			```js
			import { setMaxListeners, EventEmitter } from 'node:events';
			
			const target = new EventTarget();
			const emitter = new EventEmitter();
			
			setMaxListeners(5, target, emitter);
			```
		**/
		function setMaxListeners(?n:Float, eventTargets:haxe.extern.Rest<ts.AnyOf2<global.nodejs.EventEmitter, Server>>):Void;
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
	}> { })
	@:overload(function(handle:Dynamic, ?listeningListener:haxe.Constraints.Function):node.http.Server<{
		var prototype : node.http.IncomingMessage;
		/**
			A utility method for creating a `Readable` from a web `ReadableStream`.
		**/
		function fromWeb(readableStream:node.stream.web.ReadableStream<Dynamic>, ?options:{ @:optional var encoding : global.nodejs.BufferEncoding; @:optional var highWaterMark : Float; @:optional var objectMode : Bool; /** When provided the corresponding `AbortController` can be used to cancel an asynchronous action. **/ @:optional var signal : js.html.AbortSignal; }):node.stream.Readable;
		/**
			A utility method for creating a web `ReadableStream` from a `Readable`.
		**/
		function toWeb(streamReadable:node.stream.Readable):node.stream.web.ReadableStream<Dynamic>;
		/**
			A utility method for creating Readable Streams out of iterators.
		**/
		function from(iterable:ts.AnyOf2<Iterable<Dynamic>, js.lib.AsyncIterable<Dynamic>>, ?options:node.stream.ReadableOptions):node.stream.Readable;
		/**
			Returns whether the stream has been read from or cancelled.
		**/
		function isDisturbed(stream:ts.AnyOf2<node.stream.Readable, global.nodejs.ReadableStream>):Bool;
		/**
			A stream to attach a signal to.
			
			Attaches an AbortSignal to a readable or writeable stream. This lets code
			control stream destruction using an `AbortController`.
			
			Calling `abort` on the `AbortController` corresponding to the passed`AbortSignal` will behave the same way as calling `.destroy(new AbortError())`on the stream, and `controller.error(new
			AbortError())` for webstreams.
			
			```js
			const fs = require('node:fs');
			
			const controller = new AbortController();
			const read = addAbortSignal(
			   controller.signal,
			   fs.createReadStream(('object.json')),
			);
			// Later, abort the operation closing the stream
			controller.abort();
			```
			
			Or using an `AbortSignal` with a readable stream as an async iterable:
			
			```js
			const controller = new AbortController();
			setTimeout(() => controller.abort(), 10_000); // set a timeout
			const stream = addAbortSignal(
			   controller.signal,
			   fs.createReadStream(('object.json')),
			);
			(async () => {
			   try {
			     for await (const chunk of stream) {
			       await process(chunk);
			     }
			   } catch (e) {
			     if (e.name === 'AbortError') {
			       // The operation was cancelled
			     } else {
			       throw e;
			     }
			   }
			})();
			```
			
			Or using an `AbortSignal` with a ReadableStream:
			
			```js
			const controller = new AbortController();
			const rs = new ReadableStream({
			   start(controller) {
			     controller.enqueue('hello');
			     controller.enqueue('world');
			     controller.close();
			   },
			});
			
			addAbortSignal(controller.signal, rs);
			
			finished(rs, (err) => {
			   if (err) {
			     if (err.name === 'AbortError') {
			       // The operation was cancelled
			     }
			   }
			});
			
			const reader = rs.getReader();
			
			reader.read().then(({ value, done }) => {
			   console.log(value); // hello
			   console.log(done); // false
			   controller.abort();
			});
			```
		**/
		function addAbortSignal<T>(signal:js.html.AbortSignal, stream:T):T;
		/**
			Returns the default highWaterMark used by streams.
			Defaults to `16384` (16 KiB), or `16` for `objectMode`.
		**/
		function getDefaultHighWaterMark(objectMode:Bool):Float;
		/**
			Sets the default highWaterMark used by streams.
		**/
		function setDefaultHighWaterMark(objectMode:Bool, value:Float):Void;
		/**
			A readable and/or writable stream/webstream.
			
			A function to get notified when a stream is no longer readable, writable
			or has experienced an error or a premature close event.
			
			```js
			const { finished } = require('node:stream');
			const fs = require('node:fs');
			
			const rs = fs.createReadStream('archive.tar');
			
			finished(rs, (err) => {
			   if (err) {
			     console.error('Stream failed.', err);
			   } else {
			     console.log('Stream is done reading.');
			   }
			});
			
			rs.resume(); // Drain the stream.
			```
			
			Especially useful in error handling scenarios where a stream is destroyed
			prematurely (like an aborted HTTP request), and will not emit `'end'`or `'finish'`.
			
			The `finished` API provides `promise version`.
			
			`stream.finished()` leaves dangling event listeners (in particular`'error'`, `'end'`, `'finish'` and `'close'`) after `callback` has been
			invoked. The reason for this is so that unexpected `'error'` events (due to
			incorrect stream implementations) do not cause unexpected crashes.
			If this is unwanted behavior then the returned cleanup function needs to be
			invoked in the callback:
			
			```js
			const cleanup = finished(rs, (err) => {
			   cleanup();
			   // ...
			});
			```
		**/
		@:overload(function(stream:ts.AnyOf3<global.nodejs.ReadableStream, global.nodejs.WritableStream, global.nodejs.ReadWriteStream>, callback:ts.AnyOf2<() -> Void, (err:global.nodejs.ErrnoException) -> Void>):() -> Void { })
		function finished(stream:ts.AnyOf3<global.nodejs.ReadableStream, global.nodejs.WritableStream, global.nodejs.ReadWriteStream>, options:node.stream.FinishedOptions, callback:ts.AnyOf2<() -> Void, (err:global.nodejs.ErrnoException) -> Void>):() -> Void;
		/**
			A module method to pipe between streams and generators forwarding errors and
			properly cleaning up and provide a callback when the pipeline is complete.
			
			```js
			const { pipeline } = require('node:stream');
			const fs = require('node:fs');
			const zlib = require('node:zlib');
			
			// Use the pipeline API to easily pipe a series of streams
			// together and get notified when the pipeline is fully done.
			
			// A pipeline to gzip a potentially huge tar file efficiently:
			
			pipeline(
			   fs.createReadStream('archive.tar'),
			   zlib.createGzip(),
			   fs.createWriteStream('archive.tar.gz'),
			   (err) => {
			     if (err) {
			       console.error('Pipeline failed.', err);
			     } else {
			       console.log('Pipeline succeeded.');
			     }
			   },
			);
			```
			
			The `pipeline` API provides a `promise version`.
			
			`stream.pipeline()` will call `stream.destroy(err)` on all streams except:
			
			* `Readable` streams which have emitted `'end'` or `'close'`.
			* `Writable` streams which have emitted `'finish'` or `'close'`.
			
			`stream.pipeline()` leaves dangling event listeners on the streams
			after the `callback` has been invoked. In the case of reuse of streams after
			failure, this can cause event listener leaks and swallowed errors. If the last
			stream is readable, dangling event listeners will be removed so that the last
			stream can be consumed later.
			
			`stream.pipeline()` closes all the streams when an error is raised.
			The `IncomingRequest` usage with `pipeline` could lead to an unexpected behavior
			once it would destroy the socket without sending the expected response.
			See the example below:
			
			```js
			const fs = require('node:fs');
			const http = require('node:http');
			const { pipeline } = require('node:stream');
			
			const server = http.createServer((req, res) => {
			   const fileStream = fs.createReadStream('./fileNotExist.txt');
			   pipeline(fileStream, res, (err) => {
			     if (err) {
			       console.log(err); // No such file
			       // this message can't be sent once `pipeline` already destroyed the socket
			       return res.end('error!!!');
			     }
			   });
			});
			```
		**/
		@:overload(function<A, T1, B>(source:A, transform1:T1, destination:B, ?callback:node.stream.PipelineCallback<B>):Dynamic { })
		@:overload(function<A, T1, T2, B>(source:A, transform1:T1, transform2:T2, destination:B, ?callback:node.stream.PipelineCallback<B>):Dynamic { })
		@:overload(function<A, T1, T2, T3, B>(source:A, transform1:T1, transform2:T2, transform3:T3, destination:B, ?callback:node.stream.PipelineCallback<B>):Dynamic { })
		@:overload(function<A, T1, T2, T3, T4, B>(source:A, transform1:T1, transform2:T2, transform3:T3, transform4:T4, destination:B, ?callback:node.stream.PipelineCallback<B>):Dynamic { })
		@:overload(function(streams:haxe.ds.ReadOnlyArray<ts.AnyOf3<global.nodejs.ReadableStream, global.nodejs.WritableStream, global.nodejs.ReadWriteStream>>, ?callback:(err:Null<global.nodejs.ErrnoException>) -> Void):global.nodejs.WritableStream { })
		@:overload(function(stream1:global.nodejs.ReadableStream, stream2:ts.AnyOf2<global.nodejs.WritableStream, global.nodejs.ReadWriteStream>, streams:haxe.extern.Rest<ts.AnyOf3<global.nodejs.WritableStream, global.nodejs.ReadWriteStream, (err:Null<global.nodejs.ErrnoException>) -> Void>>):global.nodejs.WritableStream { })
		function pipeline<A, B>(source:A, destination:B, ?callback:node.stream.PipelineCallback<B>):Dynamic;
		/**
			Returns whether the stream has encountered an error.
		**/
		function isErrored(stream:ts.AnyOf4<node.stream.Readable, node.stream.Writable, global.nodejs.ReadableStream, global.nodejs.WritableStream>):Bool;
		/**
			Returns whether the stream is readable.
		**/
		function isReadable(stream:ts.AnyOf2<node.stream.Readable, global.nodejs.ReadableStream>):Bool;
		final promises : {
			function finished(stream:ts.AnyOf3<global.nodejs.ReadableStream, global.nodejs.WritableStream, global.nodejs.ReadWriteStream>, ?options:node.stream.FinishedOptions):js.lib.Promise<ts.Undefined>;
			@:overload(function<A, T1, B>(source:A, transform1:T1, destination:B, ?options:node.stream.PipelineOptions):node.stream.PipelinePromise<B> { })
			@:overload(function<A, T1, T2, B>(source:A, transform1:T1, transform2:T2, destination:B, ?options:node.stream.PipelineOptions):node.stream.PipelinePromise<B> { })
			@:overload(function<A, T1, T2, T3, B>(source:A, transform1:T1, transform2:T2, transform3:T3, destination:B, ?options:node.stream.PipelineOptions):node.stream.PipelinePromise<B> { })
			@:overload(function<A, T1, T2, T3, T4, B>(source:A, transform1:T1, transform2:T2, transform3:T3, transform4:T4, destination:B, ?options:node.stream.PipelineOptions):node.stream.PipelinePromise<B> { })
			@:overload(function(streams:haxe.ds.ReadOnlyArray<ts.AnyOf3<global.nodejs.ReadableStream, global.nodejs.WritableStream, global.nodejs.ReadWriteStream>>, ?options:node.stream.PipelineOptions):js.lib.Promise<ts.Undefined> { })
			@:overload(function(stream1:global.nodejs.ReadableStream, stream2:ts.AnyOf2<global.nodejs.WritableStream, global.nodejs.ReadWriteStream>, streams:haxe.extern.Rest<ts.AnyOf3<global.nodejs.WritableStream, global.nodejs.ReadWriteStream, node.stream.PipelineOptions>>):js.lib.Promise<ts.Undefined> { })
			function pipeline<A, B>(source:A, destination:B, ?options:node.stream.PipelineOptions):node.stream.PipelinePromise<B>;
		};
		final consumers : {
			function buffer(stream:ts.AnyOf3<node.stream.Readable, global.nodejs.ReadableStream, js.lib.AsyncIterator_<Dynamic, Dynamic, Null<Any>>>):js.lib.Promise<global.Buffer>;
			function text(stream:ts.AnyOf3<node.stream.Readable, global.nodejs.ReadableStream, js.lib.AsyncIterator_<Dynamic, Dynamic, Null<Any>>>):js.lib.Promise<String>;
			function arrayBuffer(stream:ts.AnyOf3<node.stream.Readable, global.nodejs.ReadableStream, js.lib.AsyncIterator_<Dynamic, Dynamic, Null<Any>>>):js.lib.Promise<js.lib.ArrayBuffer>;
			function blob(stream:ts.AnyOf3<node.stream.Readable, global.nodejs.ReadableStream, js.lib.AsyncIterator_<Dynamic, Dynamic, Null<Any>>>):js.lib.Promise<node.buffer.Blob>;
			function json(stream:ts.AnyOf3<node.stream.Readable, global.nodejs.ReadableStream, js.lib.AsyncIterator_<Dynamic, Dynamic, Null<Any>>>):js.lib.Promise<Any>;
		};
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
		@:overload(function(emitter:Server, eventName:String, ?options:Server):js.lib.Promise<Array<Dynamic>> { })
		function once(emitter:Server, eventName:ts.AnyOf2<String, js.lib.Symbol>, ?options:Server):js.lib.Promise<Array<Dynamic>>;
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
		function on(emitter:global.nodejs.EventEmitter, eventName:String, ?options:Server):js.lib.AsyncIterableIterator<Dynamic>;
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
		function getEventListeners(emitter:ts.AnyOf2<global.nodejs.EventEmitter, Server>, name:ts.AnyOf2<String, js.lib.Symbol>):Array<haxe.Constraints.Function>;
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
		function getMaxListeners(emitter:ts.AnyOf2<global.nodejs.EventEmitter, Server>):Float;
		/**
			```js
			import { setMaxListeners, EventEmitter } from 'node:events';
			
			const target = new EventTarget();
			const emitter = new EventEmitter();
			
			setMaxListeners(5, target, emitter);
			```
		**/
		function setMaxListeners(?n:Float, eventTargets:haxe.extern.Rest<ts.AnyOf2<global.nodejs.EventEmitter, Server>>):Void;
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
	}, {
		var prototype : node.http.ServerResponse<Dynamic>;
		/**
			A utility method for creating a `Writable` from a web `WritableStream`.
		**/
		function fromWeb(writableStream:node.stream.web.WritableStream<Dynamic>, ?options:{ @:optional var highWaterMark : Float; @:optional var objectMode : Bool; /** When provided the corresponding `AbortController` can be used to cancel an asynchronous action. **/ @:optional var signal : js.html.AbortSignal; @:optional var decodeStrings : Bool; }):node.stream.Writable;
		/**
			A utility method for creating a web `WritableStream` from a `Writable`.
		**/
		function toWeb(streamWritable:node.stream.Writable):node.stream.web.WritableStream<Dynamic>;
		/**
			A stream to attach a signal to.
			
			Attaches an AbortSignal to a readable or writeable stream. This lets code
			control stream destruction using an `AbortController`.
			
			Calling `abort` on the `AbortController` corresponding to the passed`AbortSignal` will behave the same way as calling `.destroy(new AbortError())`on the stream, and `controller.error(new
			AbortError())` for webstreams.
			
			```js
			const fs = require('node:fs');
			
			const controller = new AbortController();
			const read = addAbortSignal(
			   controller.signal,
			   fs.createReadStream(('object.json')),
			);
			// Later, abort the operation closing the stream
			controller.abort();
			```
			
			Or using an `AbortSignal` with a readable stream as an async iterable:
			
			```js
			const controller = new AbortController();
			setTimeout(() => controller.abort(), 10_000); // set a timeout
			const stream = addAbortSignal(
			   controller.signal,
			   fs.createReadStream(('object.json')),
			);
			(async () => {
			   try {
			     for await (const chunk of stream) {
			       await process(chunk);
			     }
			   } catch (e) {
			     if (e.name === 'AbortError') {
			       // The operation was cancelled
			     } else {
			       throw e;
			     }
			   }
			})();
			```
			
			Or using an `AbortSignal` with a ReadableStream:
			
			```js
			const controller = new AbortController();
			const rs = new ReadableStream({
			   start(controller) {
			     controller.enqueue('hello');
			     controller.enqueue('world');
			     controller.close();
			   },
			});
			
			addAbortSignal(controller.signal, rs);
			
			finished(rs, (err) => {
			   if (err) {
			     if (err.name === 'AbortError') {
			       // The operation was cancelled
			     }
			   }
			});
			
			const reader = rs.getReader();
			
			reader.read().then(({ value, done }) => {
			   console.log(value); // hello
			   console.log(done); // false
			   controller.abort();
			});
			```
		**/
		function addAbortSignal<T>(signal:js.html.AbortSignal, stream:T):T;
		/**
			Returns the default highWaterMark used by streams.
			Defaults to `16384` (16 KiB), or `16` for `objectMode`.
		**/
		function getDefaultHighWaterMark(objectMode:Bool):Float;
		/**
			Sets the default highWaterMark used by streams.
		**/
		function setDefaultHighWaterMark(objectMode:Bool, value:Float):Void;
		/**
			A readable and/or writable stream/webstream.
			
			A function to get notified when a stream is no longer readable, writable
			or has experienced an error or a premature close event.
			
			```js
			const { finished } = require('node:stream');
			const fs = require('node:fs');
			
			const rs = fs.createReadStream('archive.tar');
			
			finished(rs, (err) => {
			   if (err) {
			     console.error('Stream failed.', err);
			   } else {
			     console.log('Stream is done reading.');
			   }
			});
			
			rs.resume(); // Drain the stream.
			```
			
			Especially useful in error handling scenarios where a stream is destroyed
			prematurely (like an aborted HTTP request), and will not emit `'end'`or `'finish'`.
			
			The `finished` API provides `promise version`.
			
			`stream.finished()` leaves dangling event listeners (in particular`'error'`, `'end'`, `'finish'` and `'close'`) after `callback` has been
			invoked. The reason for this is so that unexpected `'error'` events (due to
			incorrect stream implementations) do not cause unexpected crashes.
			If this is unwanted behavior then the returned cleanup function needs to be
			invoked in the callback:
			
			```js
			const cleanup = finished(rs, (err) => {
			   cleanup();
			   // ...
			});
			```
		**/
		@:overload(function(stream:ts.AnyOf3<global.nodejs.ReadableStream, global.nodejs.WritableStream, global.nodejs.ReadWriteStream>, callback:ts.AnyOf2<() -> Void, (err:global.nodejs.ErrnoException) -> Void>):() -> Void { })
		function finished(stream:ts.AnyOf3<global.nodejs.ReadableStream, global.nodejs.WritableStream, global.nodejs.ReadWriteStream>, options:node.stream.FinishedOptions, callback:ts.AnyOf2<() -> Void, (err:global.nodejs.ErrnoException) -> Void>):() -> Void;
		/**
			A module method to pipe between streams and generators forwarding errors and
			properly cleaning up and provide a callback when the pipeline is complete.
			
			```js
			const { pipeline } = require('node:stream');
			const fs = require('node:fs');
			const zlib = require('node:zlib');
			
			// Use the pipeline API to easily pipe a series of streams
			// together and get notified when the pipeline is fully done.
			
			// A pipeline to gzip a potentially huge tar file efficiently:
			
			pipeline(
			   fs.createReadStream('archive.tar'),
			   zlib.createGzip(),
			   fs.createWriteStream('archive.tar.gz'),
			   (err) => {
			     if (err) {
			       console.error('Pipeline failed.', err);
			     } else {
			       console.log('Pipeline succeeded.');
			     }
			   },
			);
			```
			
			The `pipeline` API provides a `promise version`.
			
			`stream.pipeline()` will call `stream.destroy(err)` on all streams except:
			
			* `Readable` streams which have emitted `'end'` or `'close'`.
			* `Writable` streams which have emitted `'finish'` or `'close'`.
			
			`stream.pipeline()` leaves dangling event listeners on the streams
			after the `callback` has been invoked. In the case of reuse of streams after
			failure, this can cause event listener leaks and swallowed errors. If the last
			stream is readable, dangling event listeners will be removed so that the last
			stream can be consumed later.
			
			`stream.pipeline()` closes all the streams when an error is raised.
			The `IncomingRequest` usage with `pipeline` could lead to an unexpected behavior
			once it would destroy the socket without sending the expected response.
			See the example below:
			
			```js
			const fs = require('node:fs');
			const http = require('node:http');
			const { pipeline } = require('node:stream');
			
			const server = http.createServer((req, res) => {
			   const fileStream = fs.createReadStream('./fileNotExist.txt');
			   pipeline(fileStream, res, (err) => {
			     if (err) {
			       console.log(err); // No such file
			       // this message can't be sent once `pipeline` already destroyed the socket
			       return res.end('error!!!');
			     }
			   });
			});
			```
		**/
		@:overload(function<A, T1, B>(source:A, transform1:T1, destination:B, ?callback:node.stream.PipelineCallback<B>):Dynamic { })
		@:overload(function<A, T1, T2, B>(source:A, transform1:T1, transform2:T2, destination:B, ?callback:node.stream.PipelineCallback<B>):Dynamic { })
		@:overload(function<A, T1, T2, T3, B>(source:A, transform1:T1, transform2:T2, transform3:T3, destination:B, ?callback:node.stream.PipelineCallback<B>):Dynamic { })
		@:overload(function<A, T1, T2, T3, T4, B>(source:A, transform1:T1, transform2:T2, transform3:T3, transform4:T4, destination:B, ?callback:node.stream.PipelineCallback<B>):Dynamic { })
		@:overload(function(streams:haxe.ds.ReadOnlyArray<ts.AnyOf3<global.nodejs.ReadableStream, global.nodejs.WritableStream, global.nodejs.ReadWriteStream>>, ?callback:(err:Null<global.nodejs.ErrnoException>) -> Void):global.nodejs.WritableStream { })
		@:overload(function(stream1:global.nodejs.ReadableStream, stream2:ts.AnyOf2<global.nodejs.WritableStream, global.nodejs.ReadWriteStream>, streams:haxe.extern.Rest<ts.AnyOf3<global.nodejs.WritableStream, global.nodejs.ReadWriteStream, (err:Null<global.nodejs.ErrnoException>) -> Void>>):global.nodejs.WritableStream { })
		function pipeline<A, B>(source:A, destination:B, ?callback:node.stream.PipelineCallback<B>):Dynamic;
		/**
			Returns whether the stream has encountered an error.
		**/
		function isErrored(stream:ts.AnyOf4<node.stream.Readable, node.stream.Writable, global.nodejs.ReadableStream, global.nodejs.WritableStream>):Bool;
		/**
			Returns whether the stream is readable.
		**/
		function isReadable(stream:ts.AnyOf2<node.stream.Readable, global.nodejs.ReadableStream>):Bool;
		final promises : {
			function finished(stream:ts.AnyOf3<global.nodejs.ReadableStream, global.nodejs.WritableStream, global.nodejs.ReadWriteStream>, ?options:node.stream.FinishedOptions):js.lib.Promise<ts.Undefined>;
			@:overload(function<A, T1, B>(source:A, transform1:T1, destination:B, ?options:node.stream.PipelineOptions):node.stream.PipelinePromise<B> { })
			@:overload(function<A, T1, T2, B>(source:A, transform1:T1, transform2:T2, destination:B, ?options:node.stream.PipelineOptions):node.stream.PipelinePromise<B> { })
			@:overload(function<A, T1, T2, T3, B>(source:A, transform1:T1, transform2:T2, transform3:T3, destination:B, ?options:node.stream.PipelineOptions):node.stream.PipelinePromise<B> { })
			@:overload(function<A, T1, T2, T3, T4, B>(source:A, transform1:T1, transform2:T2, transform3:T3, transform4:T4, destination:B, ?options:node.stream.PipelineOptions):node.stream.PipelinePromise<B> { })
			@:overload(function(streams:haxe.ds.ReadOnlyArray<ts.AnyOf3<global.nodejs.ReadableStream, global.nodejs.WritableStream, global.nodejs.ReadWriteStream>>, ?options:node.stream.PipelineOptions):js.lib.Promise<ts.Undefined> { })
			@:overload(function(stream1:global.nodejs.ReadableStream, stream2:ts.AnyOf2<global.nodejs.WritableStream, global.nodejs.ReadWriteStream>, streams:haxe.extern.Rest<ts.AnyOf3<global.nodejs.WritableStream, global.nodejs.ReadWriteStream, node.stream.PipelineOptions>>):js.lib.Promise<ts.Undefined> { })
			function pipeline<A, B>(source:A, destination:B, ?options:node.stream.PipelineOptions):node.stream.PipelinePromise<B>;
		};
		final consumers : {
			function buffer(stream:ts.AnyOf3<node.stream.Readable, global.nodejs.ReadableStream, js.lib.AsyncIterator_<Dynamic, Dynamic, Null<Any>>>):js.lib.Promise<global.Buffer>;
			function text(stream:ts.AnyOf3<node.stream.Readable, global.nodejs.ReadableStream, js.lib.AsyncIterator_<Dynamic, Dynamic, Null<Any>>>):js.lib.Promise<String>;
			function arrayBuffer(stream:ts.AnyOf3<node.stream.Readable, global.nodejs.ReadableStream, js.lib.AsyncIterator_<Dynamic, Dynamic, Null<Any>>>):js.lib.Promise<js.lib.ArrayBuffer>;
			function blob(stream:ts.AnyOf3<node.stream.Readable, global.nodejs.ReadableStream, js.lib.AsyncIterator_<Dynamic, Dynamic, Null<Any>>>):js.lib.Promise<node.buffer.Blob>;
			function json(stream:ts.AnyOf3<node.stream.Readable, global.nodejs.ReadableStream, js.lib.AsyncIterator_<Dynamic, Dynamic, Null<Any>>>):js.lib.Promise<Any>;
		};
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
		@:overload(function(emitter:Server, eventName:String, ?options:Server):js.lib.Promise<Array<Dynamic>> { })
		function once(emitter:Server, eventName:ts.AnyOf2<String, js.lib.Symbol>, ?options:Server):js.lib.Promise<Array<Dynamic>>;
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
		function on(emitter:global.nodejs.EventEmitter, eventName:String, ?options:Server):js.lib.AsyncIterableIterator<Dynamic>;
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
		function getEventListeners(emitter:ts.AnyOf2<global.nodejs.EventEmitter, Server>, name:ts.AnyOf2<String, js.lib.Symbol>):Array<haxe.Constraints.Function>;
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
		function getMaxListeners(emitter:ts.AnyOf2<global.nodejs.EventEmitter, Server>):Float;
		/**
			```js
			import { setMaxListeners, EventEmitter } from 'node:events';
			
			const target = new EventTarget();
			const emitter = new EventEmitter();
			
			setMaxListeners(5, target, emitter);
			```
		**/
		function setMaxListeners(?n:Float, eventTargets:haxe.extern.Rest<ts.AnyOf2<global.nodejs.EventEmitter, Server>>):Void;
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
	}> { })
	function listen(port:Float, ?hostname:String, ?backlog:Float, ?callback:haxe.Constraints.Function):node.http.Server<{
		var prototype : node.http.IncomingMessage;
		/**
			A utility method for creating a `Readable` from a web `ReadableStream`.
		**/
		function fromWeb(readableStream:node.stream.web.ReadableStream<Dynamic>, ?options:{ @:optional var encoding : global.nodejs.BufferEncoding; @:optional var highWaterMark : Float; @:optional var objectMode : Bool; /** When provided the corresponding `AbortController` can be used to cancel an asynchronous action. **/ @:optional var signal : js.html.AbortSignal; }):node.stream.Readable;
		/**
			A utility method for creating a web `ReadableStream` from a `Readable`.
		**/
		function toWeb(streamReadable:node.stream.Readable):node.stream.web.ReadableStream<Dynamic>;
		/**
			A utility method for creating Readable Streams out of iterators.
		**/
		function from(iterable:ts.AnyOf2<Iterable<Dynamic>, js.lib.AsyncIterable<Dynamic>>, ?options:node.stream.ReadableOptions):node.stream.Readable;
		/**
			Returns whether the stream has been read from or cancelled.
		**/
		function isDisturbed(stream:ts.AnyOf2<node.stream.Readable, global.nodejs.ReadableStream>):Bool;
		/**
			A stream to attach a signal to.
			
			Attaches an AbortSignal to a readable or writeable stream. This lets code
			control stream destruction using an `AbortController`.
			
			Calling `abort` on the `AbortController` corresponding to the passed`AbortSignal` will behave the same way as calling `.destroy(new AbortError())`on the stream, and `controller.error(new
			AbortError())` for webstreams.
			
			```js
			const fs = require('node:fs');
			
			const controller = new AbortController();
			const read = addAbortSignal(
			   controller.signal,
			   fs.createReadStream(('object.json')),
			);
			// Later, abort the operation closing the stream
			controller.abort();
			```
			
			Or using an `AbortSignal` with a readable stream as an async iterable:
			
			```js
			const controller = new AbortController();
			setTimeout(() => controller.abort(), 10_000); // set a timeout
			const stream = addAbortSignal(
			   controller.signal,
			   fs.createReadStream(('object.json')),
			);
			(async () => {
			   try {
			     for await (const chunk of stream) {
			       await process(chunk);
			     }
			   } catch (e) {
			     if (e.name === 'AbortError') {
			       // The operation was cancelled
			     } else {
			       throw e;
			     }
			   }
			})();
			```
			
			Or using an `AbortSignal` with a ReadableStream:
			
			```js
			const controller = new AbortController();
			const rs = new ReadableStream({
			   start(controller) {
			     controller.enqueue('hello');
			     controller.enqueue('world');
			     controller.close();
			   },
			});
			
			addAbortSignal(controller.signal, rs);
			
			finished(rs, (err) => {
			   if (err) {
			     if (err.name === 'AbortError') {
			       // The operation was cancelled
			     }
			   }
			});
			
			const reader = rs.getReader();
			
			reader.read().then(({ value, done }) => {
			   console.log(value); // hello
			   console.log(done); // false
			   controller.abort();
			});
			```
		**/
		function addAbortSignal<T>(signal:js.html.AbortSignal, stream:T):T;
		/**
			Returns the default highWaterMark used by streams.
			Defaults to `16384` (16 KiB), or `16` for `objectMode`.
		**/
		function getDefaultHighWaterMark(objectMode:Bool):Float;
		/**
			Sets the default highWaterMark used by streams.
		**/
		function setDefaultHighWaterMark(objectMode:Bool, value:Float):Void;
		/**
			A readable and/or writable stream/webstream.
			
			A function to get notified when a stream is no longer readable, writable
			or has experienced an error or a premature close event.
			
			```js
			const { finished } = require('node:stream');
			const fs = require('node:fs');
			
			const rs = fs.createReadStream('archive.tar');
			
			finished(rs, (err) => {
			   if (err) {
			     console.error('Stream failed.', err);
			   } else {
			     console.log('Stream is done reading.');
			   }
			});
			
			rs.resume(); // Drain the stream.
			```
			
			Especially useful in error handling scenarios where a stream is destroyed
			prematurely (like an aborted HTTP request), and will not emit `'end'`or `'finish'`.
			
			The `finished` API provides `promise version`.
			
			`stream.finished()` leaves dangling event listeners (in particular`'error'`, `'end'`, `'finish'` and `'close'`) after `callback` has been
			invoked. The reason for this is so that unexpected `'error'` events (due to
			incorrect stream implementations) do not cause unexpected crashes.
			If this is unwanted behavior then the returned cleanup function needs to be
			invoked in the callback:
			
			```js
			const cleanup = finished(rs, (err) => {
			   cleanup();
			   // ...
			});
			```
		**/
		@:overload(function(stream:ts.AnyOf3<global.nodejs.ReadableStream, global.nodejs.WritableStream, global.nodejs.ReadWriteStream>, callback:ts.AnyOf2<() -> Void, (err:global.nodejs.ErrnoException) -> Void>):() -> Void { })
		function finished(stream:ts.AnyOf3<global.nodejs.ReadableStream, global.nodejs.WritableStream, global.nodejs.ReadWriteStream>, options:node.stream.FinishedOptions, callback:ts.AnyOf2<() -> Void, (err:global.nodejs.ErrnoException) -> Void>):() -> Void;
		/**
			A module method to pipe between streams and generators forwarding errors and
			properly cleaning up and provide a callback when the pipeline is complete.
			
			```js
			const { pipeline } = require('node:stream');
			const fs = require('node:fs');
			const zlib = require('node:zlib');
			
			// Use the pipeline API to easily pipe a series of streams
			// together and get notified when the pipeline is fully done.
			
			// A pipeline to gzip a potentially huge tar file efficiently:
			
			pipeline(
			   fs.createReadStream('archive.tar'),
			   zlib.createGzip(),
			   fs.createWriteStream('archive.tar.gz'),
			   (err) => {
			     if (err) {
			       console.error('Pipeline failed.', err);
			     } else {
			       console.log('Pipeline succeeded.');
			     }
			   },
			);
			```
			
			The `pipeline` API provides a `promise version`.
			
			`stream.pipeline()` will call `stream.destroy(err)` on all streams except:
			
			* `Readable` streams which have emitted `'end'` or `'close'`.
			* `Writable` streams which have emitted `'finish'` or `'close'`.
			
			`stream.pipeline()` leaves dangling event listeners on the streams
			after the `callback` has been invoked. In the case of reuse of streams after
			failure, this can cause event listener leaks and swallowed errors. If the last
			stream is readable, dangling event listeners will be removed so that the last
			stream can be consumed later.
			
			`stream.pipeline()` closes all the streams when an error is raised.
			The `IncomingRequest` usage with `pipeline` could lead to an unexpected behavior
			once it would destroy the socket without sending the expected response.
			See the example below:
			
			```js
			const fs = require('node:fs');
			const http = require('node:http');
			const { pipeline } = require('node:stream');
			
			const server = http.createServer((req, res) => {
			   const fileStream = fs.createReadStream('./fileNotExist.txt');
			   pipeline(fileStream, res, (err) => {
			     if (err) {
			       console.log(err); // No such file
			       // this message can't be sent once `pipeline` already destroyed the socket
			       return res.end('error!!!');
			     }
			   });
			});
			```
		**/
		@:overload(function<A, T1, B>(source:A, transform1:T1, destination:B, ?callback:node.stream.PipelineCallback<B>):Dynamic { })
		@:overload(function<A, T1, T2, B>(source:A, transform1:T1, transform2:T2, destination:B, ?callback:node.stream.PipelineCallback<B>):Dynamic { })
		@:overload(function<A, T1, T2, T3, B>(source:A, transform1:T1, transform2:T2, transform3:T3, destination:B, ?callback:node.stream.PipelineCallback<B>):Dynamic { })
		@:overload(function<A, T1, T2, T3, T4, B>(source:A, transform1:T1, transform2:T2, transform3:T3, transform4:T4, destination:B, ?callback:node.stream.PipelineCallback<B>):Dynamic { })
		@:overload(function(streams:haxe.ds.ReadOnlyArray<ts.AnyOf3<global.nodejs.ReadableStream, global.nodejs.WritableStream, global.nodejs.ReadWriteStream>>, ?callback:(err:Null<global.nodejs.ErrnoException>) -> Void):global.nodejs.WritableStream { })
		@:overload(function(stream1:global.nodejs.ReadableStream, stream2:ts.AnyOf2<global.nodejs.WritableStream, global.nodejs.ReadWriteStream>, streams:haxe.extern.Rest<ts.AnyOf3<global.nodejs.WritableStream, global.nodejs.ReadWriteStream, (err:Null<global.nodejs.ErrnoException>) -> Void>>):global.nodejs.WritableStream { })
		function pipeline<A, B>(source:A, destination:B, ?callback:node.stream.PipelineCallback<B>):Dynamic;
		/**
			Returns whether the stream has encountered an error.
		**/
		function isErrored(stream:ts.AnyOf4<node.stream.Readable, node.stream.Writable, global.nodejs.ReadableStream, global.nodejs.WritableStream>):Bool;
		/**
			Returns whether the stream is readable.
		**/
		function isReadable(stream:ts.AnyOf2<node.stream.Readable, global.nodejs.ReadableStream>):Bool;
		final promises : {
			function finished(stream:ts.AnyOf3<global.nodejs.ReadableStream, global.nodejs.WritableStream, global.nodejs.ReadWriteStream>, ?options:node.stream.FinishedOptions):js.lib.Promise<ts.Undefined>;
			@:overload(function<A, T1, B>(source:A, transform1:T1, destination:B, ?options:node.stream.PipelineOptions):node.stream.PipelinePromise<B> { })
			@:overload(function<A, T1, T2, B>(source:A, transform1:T1, transform2:T2, destination:B, ?options:node.stream.PipelineOptions):node.stream.PipelinePromise<B> { })
			@:overload(function<A, T1, T2, T3, B>(source:A, transform1:T1, transform2:T2, transform3:T3, destination:B, ?options:node.stream.PipelineOptions):node.stream.PipelinePromise<B> { })
			@:overload(function<A, T1, T2, T3, T4, B>(source:A, transform1:T1, transform2:T2, transform3:T3, transform4:T4, destination:B, ?options:node.stream.PipelineOptions):node.stream.PipelinePromise<B> { })
			@:overload(function(streams:haxe.ds.ReadOnlyArray<ts.AnyOf3<global.nodejs.ReadableStream, global.nodejs.WritableStream, global.nodejs.ReadWriteStream>>, ?options:node.stream.PipelineOptions):js.lib.Promise<ts.Undefined> { })
			@:overload(function(stream1:global.nodejs.ReadableStream, stream2:ts.AnyOf2<global.nodejs.WritableStream, global.nodejs.ReadWriteStream>, streams:haxe.extern.Rest<ts.AnyOf3<global.nodejs.WritableStream, global.nodejs.ReadWriteStream, node.stream.PipelineOptions>>):js.lib.Promise<ts.Undefined> { })
			function pipeline<A, B>(source:A, destination:B, ?options:node.stream.PipelineOptions):node.stream.PipelinePromise<B>;
		};
		final consumers : {
			function buffer(stream:ts.AnyOf3<node.stream.Readable, global.nodejs.ReadableStream, js.lib.AsyncIterator_<Dynamic, Dynamic, Null<Any>>>):js.lib.Promise<global.Buffer>;
			function text(stream:ts.AnyOf3<node.stream.Readable, global.nodejs.ReadableStream, js.lib.AsyncIterator_<Dynamic, Dynamic, Null<Any>>>):js.lib.Promise<String>;
			function arrayBuffer(stream:ts.AnyOf3<node.stream.Readable, global.nodejs.ReadableStream, js.lib.AsyncIterator_<Dynamic, Dynamic, Null<Any>>>):js.lib.Promise<js.lib.ArrayBuffer>;
			function blob(stream:ts.AnyOf3<node.stream.Readable, global.nodejs.ReadableStream, js.lib.AsyncIterator_<Dynamic, Dynamic, Null<Any>>>):js.lib.Promise<node.buffer.Blob>;
			function json(stream:ts.AnyOf3<node.stream.Readable, global.nodejs.ReadableStream, js.lib.AsyncIterator_<Dynamic, Dynamic, Null<Any>>>):js.lib.Promise<Any>;
		};
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
		@:overload(function(emitter:Server, eventName:String, ?options:Server):js.lib.Promise<Array<Dynamic>> { })
		function once(emitter:Server, eventName:ts.AnyOf2<String, js.lib.Symbol>, ?options:Server):js.lib.Promise<Array<Dynamic>>;
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
		function on(emitter:global.nodejs.EventEmitter, eventName:String, ?options:Server):js.lib.AsyncIterableIterator<Dynamic>;
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
		function getEventListeners(emitter:ts.AnyOf2<global.nodejs.EventEmitter, Server>, name:ts.AnyOf2<String, js.lib.Symbol>):Array<haxe.Constraints.Function>;
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
		function getMaxListeners(emitter:ts.AnyOf2<global.nodejs.EventEmitter, Server>):Float;
		/**
			```js
			import { setMaxListeners, EventEmitter } from 'node:events';
			
			const target = new EventTarget();
			const emitter = new EventEmitter();
			
			setMaxListeners(5, target, emitter);
			```
		**/
		function setMaxListeners(?n:Float, eventTargets:haxe.extern.Rest<ts.AnyOf2<global.nodejs.EventEmitter, Server>>):Void;
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
	}, {
		var prototype : node.http.ServerResponse<Dynamic>;
		/**
			A utility method for creating a `Writable` from a web `WritableStream`.
		**/
		function fromWeb(writableStream:node.stream.web.WritableStream<Dynamic>, ?options:{ @:optional var highWaterMark : Float; @:optional var objectMode : Bool; /** When provided the corresponding `AbortController` can be used to cancel an asynchronous action. **/ @:optional var signal : js.html.AbortSignal; @:optional var decodeStrings : Bool; }):node.stream.Writable;
		/**
			A utility method for creating a web `WritableStream` from a `Writable`.
		**/
		function toWeb(streamWritable:node.stream.Writable):node.stream.web.WritableStream<Dynamic>;
		/**
			A stream to attach a signal to.
			
			Attaches an AbortSignal to a readable or writeable stream. This lets code
			control stream destruction using an `AbortController`.
			
			Calling `abort` on the `AbortController` corresponding to the passed`AbortSignal` will behave the same way as calling `.destroy(new AbortError())`on the stream, and `controller.error(new
			AbortError())` for webstreams.
			
			```js
			const fs = require('node:fs');
			
			const controller = new AbortController();
			const read = addAbortSignal(
			   controller.signal,
			   fs.createReadStream(('object.json')),
			);
			// Later, abort the operation closing the stream
			controller.abort();
			```
			
			Or using an `AbortSignal` with a readable stream as an async iterable:
			
			```js
			const controller = new AbortController();
			setTimeout(() => controller.abort(), 10_000); // set a timeout
			const stream = addAbortSignal(
			   controller.signal,
			   fs.createReadStream(('object.json')),
			);
			(async () => {
			   try {
			     for await (const chunk of stream) {
			       await process(chunk);
			     }
			   } catch (e) {
			     if (e.name === 'AbortError') {
			       // The operation was cancelled
			     } else {
			       throw e;
			     }
			   }
			})();
			```
			
			Or using an `AbortSignal` with a ReadableStream:
			
			```js
			const controller = new AbortController();
			const rs = new ReadableStream({
			   start(controller) {
			     controller.enqueue('hello');
			     controller.enqueue('world');
			     controller.close();
			   },
			});
			
			addAbortSignal(controller.signal, rs);
			
			finished(rs, (err) => {
			   if (err) {
			     if (err.name === 'AbortError') {
			       // The operation was cancelled
			     }
			   }
			});
			
			const reader = rs.getReader();
			
			reader.read().then(({ value, done }) => {
			   console.log(value); // hello
			   console.log(done); // false
			   controller.abort();
			});
			```
		**/
		function addAbortSignal<T>(signal:js.html.AbortSignal, stream:T):T;
		/**
			Returns the default highWaterMark used by streams.
			Defaults to `16384` (16 KiB), or `16` for `objectMode`.
		**/
		function getDefaultHighWaterMark(objectMode:Bool):Float;
		/**
			Sets the default highWaterMark used by streams.
		**/
		function setDefaultHighWaterMark(objectMode:Bool, value:Float):Void;
		/**
			A readable and/or writable stream/webstream.
			
			A function to get notified when a stream is no longer readable, writable
			or has experienced an error or a premature close event.
			
			```js
			const { finished } = require('node:stream');
			const fs = require('node:fs');
			
			const rs = fs.createReadStream('archive.tar');
			
			finished(rs, (err) => {
			   if (err) {
			     console.error('Stream failed.', err);
			   } else {
			     console.log('Stream is done reading.');
			   }
			});
			
			rs.resume(); // Drain the stream.
			```
			
			Especially useful in error handling scenarios where a stream is destroyed
			prematurely (like an aborted HTTP request), and will not emit `'end'`or `'finish'`.
			
			The `finished` API provides `promise version`.
			
			`stream.finished()` leaves dangling event listeners (in particular`'error'`, `'end'`, `'finish'` and `'close'`) after `callback` has been
			invoked. The reason for this is so that unexpected `'error'` events (due to
			incorrect stream implementations) do not cause unexpected crashes.
			If this is unwanted behavior then the returned cleanup function needs to be
			invoked in the callback:
			
			```js
			const cleanup = finished(rs, (err) => {
			   cleanup();
			   // ...
			});
			```
		**/
		@:overload(function(stream:ts.AnyOf3<global.nodejs.ReadableStream, global.nodejs.WritableStream, global.nodejs.ReadWriteStream>, callback:ts.AnyOf2<() -> Void, (err:global.nodejs.ErrnoException) -> Void>):() -> Void { })
		function finished(stream:ts.AnyOf3<global.nodejs.ReadableStream, global.nodejs.WritableStream, global.nodejs.ReadWriteStream>, options:node.stream.FinishedOptions, callback:ts.AnyOf2<() -> Void, (err:global.nodejs.ErrnoException) -> Void>):() -> Void;
		/**
			A module method to pipe between streams and generators forwarding errors and
			properly cleaning up and provide a callback when the pipeline is complete.
			
			```js
			const { pipeline } = require('node:stream');
			const fs = require('node:fs');
			const zlib = require('node:zlib');
			
			// Use the pipeline API to easily pipe a series of streams
			// together and get notified when the pipeline is fully done.
			
			// A pipeline to gzip a potentially huge tar file efficiently:
			
			pipeline(
			   fs.createReadStream('archive.tar'),
			   zlib.createGzip(),
			   fs.createWriteStream('archive.tar.gz'),
			   (err) => {
			     if (err) {
			       console.error('Pipeline failed.', err);
			     } else {
			       console.log('Pipeline succeeded.');
			     }
			   },
			);
			```
			
			The `pipeline` API provides a `promise version`.
			
			`stream.pipeline()` will call `stream.destroy(err)` on all streams except:
			
			* `Readable` streams which have emitted `'end'` or `'close'`.
			* `Writable` streams which have emitted `'finish'` or `'close'`.
			
			`stream.pipeline()` leaves dangling event listeners on the streams
			after the `callback` has been invoked. In the case of reuse of streams after
			failure, this can cause event listener leaks and swallowed errors. If the last
			stream is readable, dangling event listeners will be removed so that the last
			stream can be consumed later.
			
			`stream.pipeline()` closes all the streams when an error is raised.
			The `IncomingRequest` usage with `pipeline` could lead to an unexpected behavior
			once it would destroy the socket without sending the expected response.
			See the example below:
			
			```js
			const fs = require('node:fs');
			const http = require('node:http');
			const { pipeline } = require('node:stream');
			
			const server = http.createServer((req, res) => {
			   const fileStream = fs.createReadStream('./fileNotExist.txt');
			   pipeline(fileStream, res, (err) => {
			     if (err) {
			       console.log(err); // No such file
			       // this message can't be sent once `pipeline` already destroyed the socket
			       return res.end('error!!!');
			     }
			   });
			});
			```
		**/
		@:overload(function<A, T1, B>(source:A, transform1:T1, destination:B, ?callback:node.stream.PipelineCallback<B>):Dynamic { })
		@:overload(function<A, T1, T2, B>(source:A, transform1:T1, transform2:T2, destination:B, ?callback:node.stream.PipelineCallback<B>):Dynamic { })
		@:overload(function<A, T1, T2, T3, B>(source:A, transform1:T1, transform2:T2, transform3:T3, destination:B, ?callback:node.stream.PipelineCallback<B>):Dynamic { })
		@:overload(function<A, T1, T2, T3, T4, B>(source:A, transform1:T1, transform2:T2, transform3:T3, transform4:T4, destination:B, ?callback:node.stream.PipelineCallback<B>):Dynamic { })
		@:overload(function(streams:haxe.ds.ReadOnlyArray<ts.AnyOf3<global.nodejs.ReadableStream, global.nodejs.WritableStream, global.nodejs.ReadWriteStream>>, ?callback:(err:Null<global.nodejs.ErrnoException>) -> Void):global.nodejs.WritableStream { })
		@:overload(function(stream1:global.nodejs.ReadableStream, stream2:ts.AnyOf2<global.nodejs.WritableStream, global.nodejs.ReadWriteStream>, streams:haxe.extern.Rest<ts.AnyOf3<global.nodejs.WritableStream, global.nodejs.ReadWriteStream, (err:Null<global.nodejs.ErrnoException>) -> Void>>):global.nodejs.WritableStream { })
		function pipeline<A, B>(source:A, destination:B, ?callback:node.stream.PipelineCallback<B>):Dynamic;
		/**
			Returns whether the stream has encountered an error.
		**/
		function isErrored(stream:ts.AnyOf4<node.stream.Readable, node.stream.Writable, global.nodejs.ReadableStream, global.nodejs.WritableStream>):Bool;
		/**
			Returns whether the stream is readable.
		**/
		function isReadable(stream:ts.AnyOf2<node.stream.Readable, global.nodejs.ReadableStream>):Bool;
		final promises : {
			function finished(stream:ts.AnyOf3<global.nodejs.ReadableStream, global.nodejs.WritableStream, global.nodejs.ReadWriteStream>, ?options:node.stream.FinishedOptions):js.lib.Promise<ts.Undefined>;
			@:overload(function<A, T1, B>(source:A, transform1:T1, destination:B, ?options:node.stream.PipelineOptions):node.stream.PipelinePromise<B> { })
			@:overload(function<A, T1, T2, B>(source:A, transform1:T1, transform2:T2, destination:B, ?options:node.stream.PipelineOptions):node.stream.PipelinePromise<B> { })
			@:overload(function<A, T1, T2, T3, B>(source:A, transform1:T1, transform2:T2, transform3:T3, destination:B, ?options:node.stream.PipelineOptions):node.stream.PipelinePromise<B> { })
			@:overload(function<A, T1, T2, T3, T4, B>(source:A, transform1:T1, transform2:T2, transform3:T3, transform4:T4, destination:B, ?options:node.stream.PipelineOptions):node.stream.PipelinePromise<B> { })
			@:overload(function(streams:haxe.ds.ReadOnlyArray<ts.AnyOf3<global.nodejs.ReadableStream, global.nodejs.WritableStream, global.nodejs.ReadWriteStream>>, ?options:node.stream.PipelineOptions):js.lib.Promise<ts.Undefined> { })
			@:overload(function(stream1:global.nodejs.ReadableStream, stream2:ts.AnyOf2<global.nodejs.WritableStream, global.nodejs.ReadWriteStream>, streams:haxe.extern.Rest<ts.AnyOf3<global.nodejs.WritableStream, global.nodejs.ReadWriteStream, node.stream.PipelineOptions>>):js.lib.Promise<ts.Undefined> { })
			function pipeline<A, B>(source:A, destination:B, ?options:node.stream.PipelineOptions):node.stream.PipelinePromise<B>;
		};
		final consumers : {
			function buffer(stream:ts.AnyOf3<node.stream.Readable, global.nodejs.ReadableStream, js.lib.AsyncIterator_<Dynamic, Dynamic, Null<Any>>>):js.lib.Promise<global.Buffer>;
			function text(stream:ts.AnyOf3<node.stream.Readable, global.nodejs.ReadableStream, js.lib.AsyncIterator_<Dynamic, Dynamic, Null<Any>>>):js.lib.Promise<String>;
			function arrayBuffer(stream:ts.AnyOf3<node.stream.Readable, global.nodejs.ReadableStream, js.lib.AsyncIterator_<Dynamic, Dynamic, Null<Any>>>):js.lib.Promise<js.lib.ArrayBuffer>;
			function blob(stream:ts.AnyOf3<node.stream.Readable, global.nodejs.ReadableStream, js.lib.AsyncIterator_<Dynamic, Dynamic, Null<Any>>>):js.lib.Promise<node.buffer.Blob>;
			function json(stream:ts.AnyOf3<node.stream.Readable, global.nodejs.ReadableStream, js.lib.AsyncIterator_<Dynamic, Dynamic, Null<Any>>>):js.lib.Promise<Any>;
		};
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
		@:overload(function(emitter:Server, eventName:String, ?options:Server):js.lib.Promise<Array<Dynamic>> { })
		function once(emitter:Server, eventName:ts.AnyOf2<String, js.lib.Symbol>, ?options:Server):js.lib.Promise<Array<Dynamic>>;
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
		function on(emitter:global.nodejs.EventEmitter, eventName:String, ?options:Server):js.lib.AsyncIterableIterator<Dynamic>;
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
		function getEventListeners(emitter:ts.AnyOf2<global.nodejs.EventEmitter, Server>, name:ts.AnyOf2<String, js.lib.Symbol>):Array<haxe.Constraints.Function>;
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
		function getMaxListeners(emitter:ts.AnyOf2<global.nodejs.EventEmitter, Server>):Float;
		/**
			```js
			import { setMaxListeners, EventEmitter } from 'node:events';
			
			const target = new EventTarget();
			const emitter = new EventEmitter();
			
			setMaxListeners(5, target, emitter);
			```
		**/
		function setMaxListeners(?n:Float, eventTargets:haxe.extern.Rest<ts.AnyOf2<global.nodejs.EventEmitter, Server>>):Void;
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
	}>;
	/**
		Alias for `emitter.on(eventName, listener)`.
	**/
	function addListener(eventName:ts.AnyOf2<String, js.lib.Symbol>, listener:(args:haxe.extern.Rest<Dynamic>) -> Void):Server;
	/**
		Adds the `listener` function to the end of the listeners array for the
		event named `eventName`. No checks are made to see if the `listener` has
		already been added. Multiple calls passing the same combination of `eventName`and `listener` will result in the `listener` being added, and called, multiple
		times.
		
		```js
		server.on('connection', (stream) => {
		   console.log('someone connected!');
		});
		```
		
		Returns a reference to the `EventEmitter`, so that calls can be chained.
		
		By default, event listeners are invoked in the order they are added. The`emitter.prependListener()` method can be used as an alternative to add the
		event listener to the beginning of the listeners array.
		
		```js
		import { EventEmitter } from 'node:events';
		const myEE = new EventEmitter();
		myEE.on('foo', () => console.log('a'));
		myEE.prependListener('foo', () => console.log('b'));
		myEE.emit('foo');
		// Prints:
		//   b
		//   a
		```
	**/
	function on(eventName:ts.AnyOf2<String, js.lib.Symbol>, listener:(args:haxe.extern.Rest<Dynamic>) -> Void):Server;
	/**
		Adds a **one-time**`listener` function for the event named `eventName`. The
		next time `eventName` is triggered, this listener is removed and then invoked.
		
		```js
		server.once('connection', (stream) => {
		   console.log('Ah, we have our first user!');
		});
		```
		
		Returns a reference to the `EventEmitter`, so that calls can be chained.
		
		By default, event listeners are invoked in the order they are added. The`emitter.prependOnceListener()` method can be used as an alternative to add the
		event listener to the beginning of the listeners array.
		
		```js
		import { EventEmitter } from 'node:events';
		const myEE = new EventEmitter();
		myEE.once('foo', () => console.log('a'));
		myEE.prependOnceListener('foo', () => console.log('b'));
		myEE.emit('foo');
		// Prints:
		//   b
		//   a
		```
	**/
	function once(eventName:ts.AnyOf2<String, js.lib.Symbol>, listener:(args:haxe.extern.Rest<Dynamic>) -> Void):Server;
	/**
		Removes the specified `listener` from the listener array for the event named`eventName`.
		
		```js
		const callback = (stream) => {
		   console.log('someone connected!');
		};
		server.on('connection', callback);
		// ...
		server.removeListener('connection', callback);
		```
		
		`removeListener()` will remove, at most, one instance of a listener from the
		listener array. If any single listener has been added multiple times to the
		listener array for the specified `eventName`, then `removeListener()` must be
		called multiple times to remove each instance.
		
		Once an event is emitted, all listeners attached to it at the
		time of emitting are called in order. This implies that any`removeListener()` or `removeAllListeners()` calls _after_ emitting and _before_ the last listener finishes execution
		will not remove them from`emit()` in progress. Subsequent events behave as expected.
		
		```js
		import { EventEmitter } from 'node:events';
		class MyEmitter extends EventEmitter {}
		const myEmitter = new MyEmitter();
		
		const callbackA = () => {
		   console.log('A');
		   myEmitter.removeListener('event', callbackB);
		};
		
		const callbackB = () => {
		   console.log('B');
		};
		
		myEmitter.on('event', callbackA);
		
		myEmitter.on('event', callbackB);
		
		// callbackA removes listener callbackB but it will still be called.
		// Internal listener array at time of emit [callbackA, callbackB]
		myEmitter.emit('event');
		// Prints:
		//   A
		//   B
		
		// callbackB is now removed.
		// Internal listener array [callbackA]
		myEmitter.emit('event');
		// Prints:
		//   A
		```
		
		Because listeners are managed using an internal array, calling this will
		change the position indices of any listener registered _after_ the listener
		being removed. This will not impact the order in which listeners are called,
		but it means that any copies of the listener array as returned by
		the `emitter.listeners()` method will need to be recreated.
		
		When a single function has been added as a handler multiple times for a single
		event (as in the example below), `removeListener()` will remove the most
		recently added instance. In the example the `once('ping')`listener is removed:
		
		```js
		import { EventEmitter } from 'node:events';
		const ee = new EventEmitter();
		
		function pong() {
		   console.log('pong');
		}
		
		ee.on('ping', pong);
		ee.once('ping', pong);
		ee.removeListener('ping', pong);
		
		ee.emit('ping');
		ee.emit('ping');
		```
		
		Returns a reference to the `EventEmitter`, so that calls can be chained.
	**/
	function removeListener(eventName:ts.AnyOf2<String, js.lib.Symbol>, listener:(args:haxe.extern.Rest<Dynamic>) -> Void):Server;
	/**
		Alias for `emitter.removeListener()`.
	**/
	function off(eventName:ts.AnyOf2<String, js.lib.Symbol>, listener:(args:haxe.extern.Rest<Dynamic>) -> Void):Server;
	/**
		Removes all listeners, or those of the specified `eventName`.
		
		It is bad practice to remove listeners added elsewhere in the code,
		particularly when the `EventEmitter` instance was created by some other
		component or module (e.g. sockets or file streams).
		
		Returns a reference to the `EventEmitter`, so that calls can be chained.
	**/
	function removeAllListeners(?event:ts.AnyOf2<String, js.lib.Symbol>):Server;
	/**
		By default `EventEmitter`s will print a warning if more than `10` listeners are
		added for a particular event. This is a useful default that helps finding
		memory leaks. The `emitter.setMaxListeners()` method allows the limit to be
		modified for this specific `EventEmitter` instance. The value can be set to`Infinity` (or `0`) to indicate an unlimited number of listeners.
		
		Returns a reference to the `EventEmitter`, so that calls can be chained.
	**/
	function setMaxListeners(n:Float):Server;
	/**
		Returns the current max listener value for the `EventEmitter` which is either
		set by `emitter.setMaxListeners(n)` or defaults to {@link defaultMaxListeners}.
	**/
	function getMaxListeners():Float;
	/**
		Returns a copy of the array of listeners for the event named `eventName`.
		
		```js
		server.on('connection', (stream) => {
		   console.log('someone connected!');
		});
		console.log(util.inspect(server.listeners('connection')));
		// Prints: [ [Function] ]
		```
	**/
	function listeners(eventName:ts.AnyOf2<String, js.lib.Symbol>):Array<haxe.Constraints.Function>;
	/**
		Returns a copy of the array of listeners for the event named `eventName`,
		including any wrappers (such as those created by `.once()`).
		
		```js
		import { EventEmitter } from 'node:events';
		const emitter = new EventEmitter();
		emitter.once('log', () => console.log('log once'));
		
		// Returns a new Array with a function `onceWrapper` which has a property
		// `listener` which contains the original listener bound above
		const listeners = emitter.rawListeners('log');
		const logFnWrapper = listeners[0];
		
		// Logs "log once" to the console and does not unbind the `once` event
		logFnWrapper.listener();
		
		// Logs "log once" to the console and removes the listener
		logFnWrapper();
		
		emitter.on('log', () => console.log('log persistently'));
		// Will return a new Array with a single function bound by `.on()` above
		const newListeners = emitter.rawListeners('log');
		
		// Logs "log persistently" twice
		newListeners[0]();
		emitter.emit('log');
		```
	**/
	function rawListeners(eventName:ts.AnyOf2<String, js.lib.Symbol>):Array<haxe.Constraints.Function>;
	/**
		Synchronously calls each of the listeners registered for the event named`eventName`, in the order they were registered, passing the supplied arguments
		to each.
		
		Returns `true` if the event had listeners, `false` otherwise.
		
		```js
		import { EventEmitter } from 'node:events';
		const myEmitter = new EventEmitter();
		
		// First listener
		myEmitter.on('event', function firstListener() {
		   console.log('Helloooo! first listener');
		});
		// Second listener
		myEmitter.on('event', function secondListener(arg1, arg2) {
		   console.log(`event with parameters ${arg1}, ${arg2} in second listener`);
		});
		// Third listener
		myEmitter.on('event', function thirdListener(...args) {
		   const parameters = args.join(', ');
		   console.log(`event with parameters ${parameters} in third listener`);
		});
		
		console.log(myEmitter.listeners('event'));
		
		myEmitter.emit('event', 1, 2, 3, 4, 5);
		
		// Prints:
		// [
		//   [Function: firstListener],
		//   [Function: secondListener],
		//   [Function: thirdListener]
		// ]
		// Helloooo! first listener
		// event with parameters 1, 2 in second listener
		// event with parameters 1, 2, 3, 4, 5 in third listener
		```
	**/
	function emit(eventName:ts.AnyOf2<String, js.lib.Symbol>, args:haxe.extern.Rest<Dynamic>):Bool;
	/**
		Returns the number of listeners listening for the event named `eventName`.
		If `listener` is provided, it will return how many times the listener is found
		in the list of the listeners of the event.
	**/
	function listenerCount(eventName:ts.AnyOf2<String, js.lib.Symbol>, ?listener:haxe.Constraints.Function):Float;
	/**
		Adds the `listener` function to the _beginning_ of the listeners array for the
		event named `eventName`. No checks are made to see if the `listener` has
		already been added. Multiple calls passing the same combination of `eventName`and `listener` will result in the `listener` being added, and called, multiple
		times.
		
		```js
		server.prependListener('connection', (stream) => {
		   console.log('someone connected!');
		});
		```
		
		Returns a reference to the `EventEmitter`, so that calls can be chained.
	**/
	function prependListener(eventName:ts.AnyOf2<String, js.lib.Symbol>, listener:(args:haxe.extern.Rest<Dynamic>) -> Void):Server;
	/**
		Adds a **one-time**`listener` function for the event named `eventName` to the _beginning_ of the listeners array. The next time `eventName` is triggered, this
		listener is removed, and then invoked.
		
		```js
		server.prependOnceListener('connection', (stream) => {
		   console.log('Ah, we have our first user!');
		});
		```
		
		Returns a reference to the `EventEmitter`, so that calls can be chained.
	**/
	function prependOnceListener(eventName:ts.AnyOf2<String, js.lib.Symbol>, listener:(args:haxe.extern.Rest<Dynamic>) -> Void):Server;
	/**
		Returns an array listing the events for which the emitter has registered
		listeners. The values in the array are strings or `Symbol`s.
		
		```js
		import { EventEmitter } from 'node:events';
		
		const myEE = new EventEmitter();
		myEE.on('foo', () => {});
		myEE.on('bar', () => {});
		
		const sym = Symbol('symbol');
		myEE.on(sym, () => {});
		
		console.log(myEE.eventNames());
		// Prints: [ 'foo', 'bar', Symbol(symbol) ]
		```
	**/
	function eventNames():Array<ts.AnyOf2<String, js.lib.Symbol>>;
};