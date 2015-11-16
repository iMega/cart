local json = require "cjson"

ngx.say(json.encode({ 1, 2, 'fred', {first='mars',second='venus',third='earth'} }))


local redis = require "redis"
local red = redis:new()

red:set_timeout(1000)

local ok, err = red:connect("172.17.0.20", 6379)
if not ok then
    ngx.say("failed to connect: ", err)
    return
end

ok, err = red:set("dog", "an animal")
if not ok then
    ngx.say("failed to set dog: ", err)
    return
end

ngx.say("set result: ", ok)

local res, err = red:get("dog")
if not res then
    ngx.say("failed to get dog: ", err)
    return
end

if res == ngx.null then
    ngx.say("dog not found.")
    return
end

ngx.say("dog: ", res)
