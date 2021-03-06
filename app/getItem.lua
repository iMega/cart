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

local json  = require "cjson"
local redis = require "resty.redis"

local db = redis:new()
db:set_timeout(1000)

local ok, err = db:connect(ngx.var.redis_ip, ngx.var.redis_port)
if not ok then
    ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
    ngx.say(err)
    ngx.exit(ngx.status)
end

local res, err = db:get(ngx.var.cart_uuid .. ":" .. ngx.var.product_uuid)
if not res then
    ngx.status = ngx.HTTP_NOT_FOUND
    ngx.say(err)
    ngx.exit(ngx.status)
end

ngx.status = ngx.HTTP_OK
ngx.say(res)
ngx.exit(ngx.status)
