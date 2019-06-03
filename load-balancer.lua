local load_balancer = {}

local function get_algoritm()
    return os.getenv("LB_ALGORITM")
end


load_balancer.cache = function()
    return load_balancer[os.getenv("LB_ALGORITM")]()
end

load_balancer.round_robin = function()
    return "0.0.0.0:8090"
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
