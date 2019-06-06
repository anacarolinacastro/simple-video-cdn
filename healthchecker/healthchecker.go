package main

import (
	"fmt"
	"net/http"
	"os"
	"strconv"
	"strings"
	"time"

	"github.com/go-redis/redis"
)

// PORTS correspond to the cache ports range
var PORTS = getEnv("CACHE_PORTS_RANGE", "8090-8091")
var redisClient = getRedis()

func main() {
	firstPort, lastPort := portsRange()
	for {
		for port := firstPort; port <= lastPort; port++ {
			go healthcheck(port)
		}
		time.Sleep(10 * time.Second)
	}
}

func getRedis() *redis.Client {
	client := redis.NewClient(&redis.Options{
		Addr:     "localhost:6379",
		Password: "",
		DB:       0,
	})

	return client
}

func setHealth(port, health string) {
	redisClient.Set(port, health, 0)
}

func healthcheck(port int) {
	server := fmt.Sprintf("http://0.0.0.0:%d", port)
	_, status := checkhealth(server)
	setHealth(fmt.Sprint(port), status)
	fmt.Printf("Server %s is %s\n", server, status)
}

func checkhealth(server string) (bool, string) {
	resp, err := http.Get(server + "/healthcheck")

	if err == nil && resp.StatusCode == 200 {
		return true, "up"
	}
	fmt.Printf("%#v\n", err.Error())

	return false, "down"
}

func getEnv(key, defaultValue string) string {
	value, found := os.LookupEnv(key)
	if found {
		return value
	}
	return defaultValue
}

func portsRange() (int, int) {
	ports := strings.Split(PORTS, "-")
	firstPort, _ := strconv.Atoi(ports[0])
	lastPort, _ := strconv.Atoi(ports[1])

	return firstPort, lastPort
}
