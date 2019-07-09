local redis = require "resty.redis"

local load_balancer = {}
local index_reference = 1
local redis_timeout = 5000
local consistency_level = tonumber(os.getenv("CONSISTENCY_LEVEL"))
local replicas_per_cache = tonumber(os.getenv("REPLICAS_PER_CACHE"))

-- get first and last port from the string range
local function get_first_and_last_ports()
    local ports_range = os.getenv("CACHE_PORTS_RANGE")
    local first = string.sub(ports_range,1,4)
    local last = string.sub(ports_range,6,9)

    return first, last
end


-- list all health servers from redis
local function check_server_health(port)
    local red = redis:new()
    red:set_timeout(redis_timeout)
    red:connect("172.22.0.100", 6379)

    local conns, err = red:get(port)
    red:set_keepalive(10000, 100)

    if tonumber(conns) then
        return true
    end

    return false
end

local function get_health_servers()
    local red = redis:new()
    red:set_timeout(redis_timeout)
    red:connect("172.22.0.100", 6379)

    local first, last = get_first_and_last_ports()
    local a = {}

    for i=0, (last-first) do
        local port = first+i
        local conns = red:get(port)

        if conns then
            a[i+1] = math.floor(port)
        end
    end

    red:set_keepalive(10000, 100)
    return a
end

local function get_hash(string)
    local resty_md5 = require "resty.md5"
    local md5 = resty_md5:new()
    md5:update(string)
    local digest = md5:final()

    local str = require "resty.string"
    local digest_hex = str.to_hex(digest)
    local digest_int = tonumber(string.sub(digest_hex, -10), 16)

    return digest_int
end


local function get_hash_key(string)
    local first, last = get_first_and_last_ports()
    local cache_size = last - first + 1
    local hash = get_hash(string)
    local key = hash % consistency_level + 1

    return key
end

local function set_ring()
    ngx.log(ngx.ERR, "Setting up ring") -- remove this, this is only to check how many times this function is being called
    local ring = {}
    for c=1, consistency_level do
        ring[c] = nil
    end

    local first, last = get_first_and_last_ports()
    for i=0, (last-first) do
        local port = first+i
        for r=1, replicas_per_cache do
            local vport = tostring(port) .. tostring(r)
            local key = get_hash_key(vport)
            ring[key] = port
        end
    end

    return ring
end

local ring = set_ring()

-- call the method for the decision algoritmn chosen
load_balancer.cache = function()
    local cache = load_balancer[os.getenv("LB_ALGORITM")]()

    return ngx.redirect(cache .. ngx.var.uri);
end

-- all functions are desions make algoritms till the end of file
load_balancer.random = function()
    local ports = get_health_servers()
    local port = ports[math.random(1,#ports)]

    return "http://0.0.0.0:" .. port
end

load_balancer.round_robin = function()
    local ports = get_health_servers()
    local port_index = math.fmod(index_reference,#ports) + 1
    local port = ports[port_index]
    index_reference = index_reference + 1

    return "http://0.0.0.0:" .. port
end

load_balancer.least_conn = function()
    local red = redis:new()
    red:set_timeout(redis_timeout)
    local ok, err = red:connect("172.22.0.100", 6379)

    if not ok then
        ngx.log(ngx.ERR, "Fail to connect to redis: " ..  err)
        return
    end

    local first, last = get_first_and_last_ports()

    local least_conn_port = first
    local least_conn_conns = tonumber(red:get(first))

    for i=1, (last-first) do
        local port = first+i
        local conns = tonumber(red:get(port))

        if conns == nil then
            ngx.log(ngx.ERR, "Port is nil")
        end

        if least_conn_conns == nil then
            ngx.log(ngx.ERR, "least_conn_conns is nil ")
        end

        if conns < least_conn_conns then
            least_conn_port = port
            least_conn_conns = conns
        end
    end

    red:set_keepalive(10000, 100)

    return "http://0.0.0.0:" .. least_conn_port
end

load_balancer.consistent_hash = function()
    local signal_name = ngx.var.signal
    local key = get_hash_key(signal_name)
    local found = false
    local k = key
    local port
    local flag = false

    while not found do
        port = ring[k]

        if port then
            local health = check_server_health(port)
            if health then
                found = true
            end
        else
            if k == key and flag then -- wrap around
                return
            end
        end

        k = k + 1
        if k > consistency_level then
            k = 1
        end

        flag = true
    end

    return "http://0.0.0.0:" .. port
end

-- TODO --
load_balancer.consistent_hash_bound_load = function()
end

-- returns the load_balancer object
return load_balancer
