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
require "resty.validation.ngx"
local validation = require "resty.validation"

ngx.req.read_body()
local body = ngx.req.get_body_data()

local jsonErrorParse, data = pcall(json.decode, body)
if not jsonErrorParse then
    ngx.status = ngx.HTTP_BAD_REQUEST
    ngx.exit(ngx.status)
end

local validatorItem = validation.new{
    cart_uuid  = validation.string.trim:len(36,36),
    preview    = validation.string.trim,
    price      = validation.number.positive,
    product_id = validation.string.trim:maxlen(36),
    quantity   = validation.number.positive,
    title      = validation.string.trim,
    url        = validation.string.trim
}

local isValid, values = validatorItem(data)
if not isValid then
    ngx.status = ngx.HTTP_BAD_REQUEST
    ngx.exit(ngx.status)
end

local validData = values("valid")

local jsonError, jsonData = pcall(json.encode, validData)
if not jsonError then
    ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
    ngx.exit(ngx.status)
end

local redis = require "resty.redis"
local db = redis:new()
db:set_timeout(1000)

local ok, err = db:connect(ngx.var.redis_ip, ngx.var.redis_port)
if not ok then
    ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
    ngx.say(err)
    ngx.exit(ngx.status)
end

local res, err = db:exists(validData["cart_uuid"] .. ":" .. validData["product_id"])
if 0 == res then
    ngx.status = ngx.HTTP_NOT_FOUND
    ngx.say(err)
    ngx.exit(ngx.status)
end

local ok, err = db:set(validData["cart_uuid"] .. ":" .. validData["product_id"], jsonData)
if not ok then
    ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
    ngx.say(err)
    ngx.exit(ngx.status)
end

ngx.status = ngx.HTTP_OK
ngx.exit(ngx.status)
