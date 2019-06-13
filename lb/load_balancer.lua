local load_balancer = {}

local function get_algoritm()
    return os.getenv("LB_ALGORITM")
end

load_balancer.redirect_cache = function()
    cache = load_balancer[os.getenv("LB_ALGORITM")]()
    ngx.redirect("http://".. cache .. ngx.var.request_uri)
end

function get_health_servers()
    local redis = require "redis"

    local redis = require 'redis'
    local client = redis.connect('172.22.0.100', 6379)
    local response = client:ping()  
    
    return {"8090", "8091"}
end

load_balancer.round_robin = function()
    ports = get_health_servers()
    port = ports[math.random(1,#ports)]

    return "0.0.0.0:" .. port
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
