local load_balancer = {}

local function get_algoritm()
    return os.getenv("LB_ALGORITM")
end

load_balancer.cache = function()
    return load_balancer[os.getenv("LB_ALGORITM")]()
end

function get_health_servers()
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
