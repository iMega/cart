--
-- Copyright (C) 2015 iMega ltd Dmitry Gavriloff (email: info@imega.ru),
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program. If not, see <http://www.gnu.org/licenses/>.

local json = require "cjson"
local validation = require "resty.validation"

local function empty(value)
    return value == nil or value == ''
end

local data = ngx.req.get_uri_args()

local validatorItem = validation.new{
    offset = validation.optional.string.tonumber.positive,
    limit  = validation.optional.string.tonumber.positive,
}

local isValid, values = validatorItem(data)
if not isValid then
    ngx.exit(ngx.HTTP_BAD_REQUEST)
end

local validData = values("valid")

local offset = 0
local limit  = 10

if not empty(validData["offset"]) then
    offset = validData["offset"]
end

if not empty(validData["limit"]) then
    limit = validData["limit"]
end

local redis = require "resty.redis"
local db = redis:new()
db:set_timeout(1000)

local ok, err = db:connect(ngx.var.redis_ip, ngx.var.redis_port)
if not ok then
    ngx.say(err)
    ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end

local res, err = db:exists(ngx.var.cart_uuid)
if not res then
    ngx.say(err)
    ngx.exit(ngx.HTTP_NOT_FOUND)
end

local res, err = db:sort(ngx.var.cart_uuid, "by", "nosort", "limit", offset, limit, "get", ngx.var.cart_uuid .. ":*")
if not res then
    ngx.say(err)
    ngx.exit(ngx.HTTP_NOT_FOUND)
end

if 0 == table.getn(res) then
    ngx.exit(ngx.HTTP_NOT_FOUND)
end

ngx.say("[" .. table.concat(res, ",") .. "]")
ngx.exit(ngx.HTTP_OK)
