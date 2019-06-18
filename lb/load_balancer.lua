local load_balancer = {}
local index_reference = 1

local redis = require "resty.redis"
local red = redis:new()
local ok, err = red:connect("172.22.0.100", 6379)

local function get_algoritm()
    return os.getenv("LB_ALGORITM")
end

local function get_ports_range_from_env()
    return os.getenv("CACHE_PORTS_RANGE")
end

local function get_ports_range()
    local ports_range = get_ports_range_from_env()
    local first = string.sub(ports_range,1,4)
    local last = string.sub(ports_range,6,9)

    return first, last
end

function get_health_servers()
    local first, last = get_ports_range()
    local a = {}

    for i=0, (last-first) do
        local port = first+i
        local conns = red:get(port)

        if conns then
            a[i+1] = math.floor(port)
        end
    end

    return a
end

load_balancer.cache = function()
    local cache = load_balancer[os.getenv("LB_ALGORITM")]()

    return ngx.redirect(cache .. ngx.var.uri);
end

load_balancer.random = function()
    local ports = get_health_servers()
    local port = ports[math.random(1,#ports)]

    return "http://0.0.0.0:" .. port
end

load_balancer.round_robin = function()
    local ports = get_health_servers()
    local port_index = math.fmod(index_reference,#ports) + 1
    local port = ports[port_index]
    local index_reference = index_reference + 1

    return "http://0.0.0.0:" .. port
end

load_balancer.least_conn = function()
end

load_balancer.choose_host_hash = function()
end

load_balancer.choose_host_consistent_hash = function()
end

load_balancer.choose_host_consistent_hash_bound_load = function()
end

return load_balancer
