package main

import (
	"io/ioutil"
	"net/http"

	"go.uber.org/zap"
)

var logger *zap.SugaredLogger

func event(w http.ResponseWriter, req *http.Request) {
	switch req.Method {
	case "GET":
		logger.Info("GET /event")
	case "POST":
		logger.Info("POST /event")
	}
	body, err := req.GetBody()
	if err != nil {
		logger.With("err", err).Info("error getting body")
		return
	}
	responseBody, err := ioutil.ReadAll(body)
	if err != nil {
		logger.With("error", err).Info("error reading response body")
		return
	}
	logger.With("body", string(responseBody)).Info("got event")
}

func activity(w http.ResponseWriter, req *http.Request) {
	switch req.Method {
	case "GET":
		logger.Info("GET /activity, doing nothing")
	case "POST":
		logger.Info("POST /activity")
		body, err := req.GetBody()
		if err != nil {
			logger.With("error", err).Info("error getting body")
			return
		}
		responseBody, err := ioutil.ReadAll(body)
		if err != nil {
			logger.With("error", err).Info("error reading response body")
			return
		}
		logger.With("body", string(responseBody)).Info("got activity")
	}
}

func main() {

	log, _ := zap.NewProduction()
	logger = log.Sugar()

	http.HandleFunc("/event", event)
	http.HandleFunc("/activity", activity)
	logger.Info("Added Handlers")

	logger.Info("Starting to serve")
	http.ListenAndServe(":8080", nil)
}
