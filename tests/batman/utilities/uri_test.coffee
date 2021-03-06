QUnit.module 'Batman.URI',
  setup: ->
    @complexURI = "http://james:secret@www.example.com:81/one+two/three%20four/index.html?a+phrase=this+phrase&some%20thing=this%20thing&foo&bar=#blahblah"
    @pathAndQuery = "/foo/bar?num=1"

test "constructs with a full URI string", ->
  uri = new Batman.URI(@complexURI)
  equal uri.source, @complexURI
  equal uri.protocol, 'http'
  equal uri.authority, 'james:secret@www.example.com:81'
  equal uri.userInfo, 'james:secret'
  equal uri.user, 'james'
  equal uri.password, 'secret'
  equal uri.hostname, 'www.example.com'
  equal uri.port, '81'
  equal uri.relative, '/one+two/three%20four/index.html?a+phrase=this+phrase&some%20thing=this%20thing&foo&bar=#blahblah'
  equal uri.path, '/one+two/three%20four/index.html'
  equal uri.directory, '/one+two/three%20four/'
  equal uri.file, 'index.html'
  equal uri.query, 'a+phrase=this+phrase&some%20thing=this%20thing&foo&bar='
  equal uri.hash, 'blahblah'
  deepEqual uri.queryParams(),
    'a phrase': 'this phrase'
    'some thing': 'this thing'
    foo: null
    bar: ''

test "constructs with just a path and query", ->
  uri = new Batman.URI(@pathAndQuery)
  equal uri.source, @pathAndQuery
  equal uri.protocol, ''
  equal uri.authority, ''
  equal uri.userInfo, ''
  equal uri.user, ''
  equal uri.password, ''
  equal uri.hostname, ''
  equal uri.port, ''
  equal uri.relative, '/foo/bar?num=1'
  equal uri.path, '/foo/bar'
  equal uri.directory, '/foo/'
  equal uri.file, 'bar'
  equal uri.query, 'num=1'
  equal uri.hash, ''
  deepEqual uri.queryParams(), num: '1'

test ".paramsFromQuery(query) returns a params object from the given query string", ->
  params = Batman.URI.paramsFromQuery 'a+phrase=this+phrase&some%20thing=this%20thing&foo&bar='

  deepEqual params,
    'a phrase': 'this phrase'
    'some thing': 'this thing'
    foo: null
    bar: ''

test ".queryFromParams(params) returns a query string for the given object", ->
  query = Batman.URI.queryFromParams
    'a phrase': 'this phrase'
    num: 1
    foo: ''
    bar: null
    baz: undefined
    qux: []

  equal query, "a+phrase=this+phrase&num=1&foo=&bar&baz&qux[]"

# taken from Rack:
#
# https://github.com/rack/rack/blob/master/test/spec_utils.rb
test ".paramsFromQuery(query) parses nested query strings", ->
  deepEqual Batman.URI.paramsFromQuery("foo"),
    foo: null
  deepEqual Batman.URI.paramsFromQuery("foo="),
    foo: ''
  deepEqual Batman.URI.paramsFromQuery("foo=bar"),
    foo: "bar"
  deepEqual Batman.URI.paramsFromQuery("foo=\"bar\""),
    foo: "\"bar\""

  deepEqual Batman.URI.paramsFromQuery("foo=bar&foo=quux"),
    foo: "quux"
  deepEqual Batman.URI.paramsFromQuery("foo&foo="),
    foo: ""
  deepEqual Batman.URI.paramsFromQuery("foo=1&bar=2"),
    foo: "1"
    bar: "2"
  deepEqual Batman.URI.paramsFromQuery("&foo=1&&bar=2"),
    foo: "1"
    bar: "2"
  deepEqual Batman.URI.paramsFromQuery("foo&bar="),
    foo: null
    bar: ""
  deepEqual Batman.URI.paramsFromQuery("foo=bar&baz="),
    foo: "bar"
    baz: ""
  deepEqual Batman.URI.paramsFromQuery("my+weird+field=q1%212%22%27w%245%267%2Fz8%29%3F"),
    "my weird field": "q1!2\"'w$5&7/z8)?"

  deepEqual Batman.URI.paramsFromQuery("a=b&pid%3D1234=1023"),
    "pid=1234": "1023"
    a: "b"

  deepEqual Batman.URI.paramsFromQuery("foo[]"),
    foo: [null]
  deepEqual Batman.URI.paramsFromQuery("foo[]="),
    foo: [""]
  deepEqual Batman.URI.paramsFromQuery("foo[]=bar"),
    foo: ["bar"]

  deepEqual Batman.URI.paramsFromQuery("foo[]=1&foo[]=2"),
    foo: ["1", "2"]
  deepEqual Batman.URI.paramsFromQuery("foo=bar&baz[]=1&baz[]=2&baz[]=3"),
    foo: "bar"
    baz: ["1", "2", "3"]
  deepEqual Batman.URI.paramsFromQuery("foo[]=bar&baz[]=1&baz[]=2&baz[]=3"),
    foo: ["bar"]
    baz: ["1", "2", "3"]

  deepEqual Batman.URI.paramsFromQuery("x[y][z]=1"),
    x: {y: {z: "1"}}
  deepEqual Batman.URI.paramsFromQuery("x[y][z][]=1"),
    x: {y: {z: ["1"]}}
  deepEqual Batman.URI.paramsFromQuery("x[y][z]=1&x[y][z]=2"),
    x: {y: {z: "2"}}
  deepEqual Batman.URI.paramsFromQuery("x[y][z][]=1&x[y][z][]=2"),
    x: {y: {z: ["1", "2"]}}

  deepEqual Batman.URI.paramsFromQuery("x[y][][z]=1"),
    x: {y: [{z: "1"}]}
  deepEqual Batman.URI.paramsFromQuery("x[y][][z][]=1"),
    x: {y: [{z: ["1"]}]}
  deepEqual Batman.URI.paramsFromQuery("x[y][][z]=1&x[y][][w]=2"),
    x: {y: [{z: "1", w: "2"}]}

  deepEqual Batman.URI.paramsFromQuery("x[y][][v][w]=1"),
    x: {y: [{v: {w: "1"}}]}
  deepEqual Batman.URI.paramsFromQuery("x[y][][z]=1&x[y][][v][w]=2"),
    x: {y: [{z: "1", v: {w: "2"}}]}

  deepEqual Batman.URI.paramsFromQuery("x[y][][z]=1&x[y][][z]=2"),
    x: {y: [{z: "1"}, {z: "2"}]}
  deepEqual Batman.URI.paramsFromQuery("x[y][][z]=1&x[y][][w]=a&x[y][][z]=2&x[y][][w]=3"),
    x: {y: [{z: "1", w: "a"}, {z: "2", w: "3"}]}

  raises (-> Batman.URI.paramsFromQuery("x[y]=1&x[y]z=2")), (error) ->
    equal error.message, 'expected Object (got String) for param "y"'
    true

  raises (-> Batman.URI.paramsFromQuery("x[y]=1&x[]=1")), (error) ->
    equal error.message, 'expected Array (got Object) for param "x"'
    true

  raises (-> Batman.URI.paramsFromQuery("x[y]=1&x[y][][w]=2")), (error) ->
    equal error.message, 'expected Array (got String) for param "y"'
    true

# taken from Rack:
#
# https://github.com/rack/rack/blob/master/test/spec_utils.rb
test ".queryFromParams(params) builds nested query strings correctly", ->
  equal Batman.URI.queryFromParams(foo: null), "foo"
  equal Batman.URI.queryFromParams(foo: ""), "foo="
  equal Batman.URI.queryFromParams(foo: "bar"), "foo=bar"

  equal Batman.URI.queryFromParams(foo: "1", bar: "2"), "foo=1&bar=2"

  # original assertion from Rack depends on ruby's more aggressive encoding:
  # equal Batman.URI.queryFromParams("my weird field": "q1!2\"'w$5&7/z8)?"),
  #   "my+weird+field=q1%212%22%27w%245%267%2Fz8%29%3F"
  equal Batman.URI.queryFromParams("my weird field": "q1!2\"'w$5&7/z8)?"),
    "my+weird+field=q1!2%22'w%245%267%2Fz8)%3F"

  equal Batman.URI.queryFromParams(foo: [null]), "foo[]"
  equal Batman.URI.queryFromParams(foo: [""]), "foo[]="
  equal Batman.URI.queryFromParams(foo: ["bar"]), "foo[]=bar"

  objects = [
    {"foo":null,"bar":""}
    {"foo":"bar","baz":""}
    {"foo":["1","2"]}
    {"foo":"bar","baz":["1","2","3"]}
    {"foo":["bar"],"baz":["1","2","3"]}
    {"foo":["1","2"]}
    {"foo":"bar","baz":["1","2","3"]}
    {"x":{"y":{"z":"1"}}}
    {"x":{"y":{"z":["1"]}}}
    {"x":{"y":{"z":["1","2"]}}}
    {"x":{"y":[{"z":"1"}]}}
    {"x":{"y":[{"z":["1"]}]}}
    {"x":{"y":[{"z":"1","w":"2"}]}}
    {"x":{"y":[{"v":{"w":"1"}}]}}
    {"x":{"y":[{"z":"1","v":{"w":"2"}}]}}
    {"x":{"y":[{"z":"1"},{"z":"2"}]}}
    {"x":{"y":[{"z":"1","w":"a"}
    {"z":"2","w":"3"}]}}]

  for params in objects
    query = Batman.URI.queryFromParams(params)
    deepEqual Batman.URI.paramsFromQuery(query), params

  raises ->
    Batman.URI.queryFromParams("foo=bar")