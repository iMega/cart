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

local validatorItem = validation.new{
    cart_uuid  = validation.string.trim:len(36,36),
    product_id = validation.string.trim:maxlen(36)
}

local data = {
    cart_uuid  = ngx.var.cart_uuid,
    product_id = ngx.var.product_uuid
}

local isValid, values = validatorItem(data)
if not isValid then
    ngx.status = ngx.HTTP_BAD_REQUEST
    ngx.exit(ngx.status)
end

local validData = values("valid")

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
    ngx.exit(ngx.status)
end

local ok, err = db:lrem(validData["cart_uuid"], -1, validData["product_id"])
if not ok then
    ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
    ngx.say(err)
    ngx.exit(ngx.status)
end

local ok, err = db:del(validData["cart_uuid"] .. ":" .. validData["product_id"])
if not ok then
    ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
    ngx.say(err)
    ngx.exit(ngx.status)
end

ngx.status = ngx.HTTP_OK
ngx.exit(ngx.status)
