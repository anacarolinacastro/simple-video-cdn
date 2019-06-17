local load_balancer = {}
local index_reference = 1

local function get_algoritm()
    return os.getenv("LB_ALGORITM")
end

load_balancer.cache = function()
    local cache = load_balancer[os.getenv("LB_ALGORITM")]()

    return ngx.redirect(cache .. ngx.var.uri);
end

function get_health_servers()
    -- ngx.log(ngx.ERR, "teste")
    -- local redis = require 'redis'
    -- local client = redis.connect('172.22.0.100', 6379)
    -- local response = client:ping()

    return {"8090", "8091"}
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
