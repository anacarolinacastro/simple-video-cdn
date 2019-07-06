package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
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

type Status struct {
	Connection Connection `json:"connections"`
}

type Connection struct {
	Active   int `json:"active"`
	Reading  int `json:"reading"`
	Writing  int `json:"writing"`
	Waiting  int `json:"waiting"`
	Accepted int `json:"accepted"`
	Handled  int `json:"handled"`
	Requests int `json:"requests"`
}

func main() {
	firstPort, lastPort := portsRange()
	for {
		for port := firstPort; port <= lastPort; port++ {
			go statusCheck(port)
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

func setLoad(port, value string) {
	key := port
	redisClient.Set(key, value, 15*time.Second)
}

func statusCheck(port int) {
	server := fmt.Sprintf("http://0.0.0.0:%d", port)
	serverUp, status := vtsStatus(server)
	if serverUp {
		setLoad(fmt.Sprint(port), fmt.Sprint(status.Connection.Active))
		// fmt.Printf("Server %s has load %d\n", server, status.Connection.Active)
	}
}

func vtsStatus(server string) (bool, Status) {
	resp, err := http.Get(server + "/status")

	if err == nil && resp.StatusCode == 200 {
		var status Status

		body, _ := ioutil.ReadAll(resp.Body)
		json.Unmarshal(body, &status)

		return true, status
	}
	fmt.Printf("%#v\n", err.Error())

	return false, Status{}
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
