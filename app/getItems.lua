local json = require "cjson"

ngx.say(json.encode({ 1, 2, 'fred', {first='mars',second='venus',third='earth'} }))
