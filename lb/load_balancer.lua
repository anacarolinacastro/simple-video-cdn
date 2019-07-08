local redis = require "resty.redis"

local load_balancer = {}
local index_reference = 1
local redis_timeout = 5000

-- get first and last port from the string range
local function get_first_and_last_ports()
    local ports_range = os.getenv("CACHE_PORTS_RANGE")
    local first = string.sub(ports_range,1,4)
    local last = string.sub(ports_range,6,9)

    return first, last
end


-- list all health servers from redis
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

-- call the method for the decision algoritmn chossed
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

-- TODO --
load_balancer.choose_host_hash = function()
end

-- TODO --
load_balancer.choose_host_consistent_hash = function()
end

-- TODO --
load_balancer.choose_host_consistent_hash_bound_load = function()
end

-- return the load_balancer object
return load_balancer
