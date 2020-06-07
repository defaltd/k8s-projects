package main

import (
	"net/http"
)

// HelloHandler says hello to the requester
func HelloHandler(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("Hello world!"))
	w.WriteHeader(200)
}
 
func main() {
	println("== STARTING SIMPLE HTTP SERVER [:8080] ==")
	http.HandleFunc("/", HelloHandler)
	http.ListenAndServe(":8080", nil)
}
