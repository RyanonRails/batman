#!/usr/bin/env node
/* 
 * batman.js
 * 
 * Batman
 * Copyright Shopify, 2011
 */

Batman = require('../lib/batman.js').Batman

Batman.missingArg = function(name) {
	console.log('why so serious? (please provide ' + name + ')')
}

var tasks = {}
var aliases = {}

var task = function(name, description, f) {
	if (typeof description === 'function')
		f = description
	else
		f.description = description
	
	f.name = name
	
	tasks[name] = f
	return f
}

var alias = function(name, original) {
	var f = tasks[original]
	if (!f.aliases)
		f.aliases = []
	
	f.aliases.push(name)
	aliases[name] = f
}

task('server', 'starts the Batman server', function() {
	require('./server.js')
})

alias('s', 'server')

task('gen', 'generate an app or files inside an app', function() {
	require('./generator.js')
})

alias('g', 'gen')

task('framework', 'generate batman.js framework files', function() {
	require('./framework.js')
})

alias('js', 'framework')

task('-T', function() {
	for (var key in tasks) {
		if (key.substr(0,1) === '-')
			continue;
		
		var string = key;
		
		var aliases = tasks[key].aliases
		if (aliases)
			string += ' (' + aliases.join(', ') + ')'
		
		var desc = tasks[key].description;
		if (desc)
				string += ' -- ' + desc
		
		console.log(string)
	}
})

var arg = process.argv[2]
if (arg) {
	var request = tasks[arg] || aliases[arg]
	request ? request() : console.log(arg + ' is not a known task')
} else
	Batman.missingArg('task')
