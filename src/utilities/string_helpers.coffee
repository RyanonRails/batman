camelize_rx = /(?:^|_|\-)(.)/g
capitalize_rx = /(^|\s)([a-z])/g
underscore_rx1 = /([A-Z]+)([A-Z][a-z])/g
underscore_rx2 = /([a-z\d])([A-Z])/g

Batman.helpers =
  inflector: new Batman.Inflector
  ordinalize: -> Batman.helpers.inflector.ordinalize.apply Batman.helpers.inflector, arguments
  singularize: -> Batman.helpers.inflector.singularize.apply Batman.helpers.inflector, arguments
  pluralize: (count, singular, plural, includeCount = true) ->
    if arguments.length < 2
      Batman.helpers.inflector.pluralize count
    else
      result = if +count is 1 then singular else (plural || Batman.helpers.inflector.pluralize(singular))
      if includeCount
        result = "#{count || 0} " + result
      result

  camelize: (string, firstLetterLower) ->
    string = string.replace camelize_rx, (str, p1) -> p1.toUpperCase()
    if firstLetterLower then string.substr(0,1).toLowerCase() + string.substr(1) else string

  underscore: (string) ->
    string.replace(underscore_rx1, '$1_$2')
          .replace(underscore_rx2, '$1_$2')
          .replace('-', '_').toLowerCase()

  capitalize: (string) -> string.replace capitalize_rx, (m,p1,p2) -> p1 + p2.toUpperCase()

  trim: (string) -> if string then string.trim() else ""

  interpolate: (stringOrObject, keys) ->
    if typeof stringOrObject is 'object'
      string = stringOrObject[keys.count]
      unless string
        string = stringOrObject['other']
    else
      string = stringOrObject

    for key, value of keys
      string = string.replace(new RegExp("%\\{#{key}\\}", "g"), value)
    string

