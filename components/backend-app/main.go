package main

import (
  "database/sql"
  "fmt"
  "log"
  "net/http"
  _ "github.com/go-sql-driver/mysql"
  "os"
)

var db *sql.DB

func main() {
  mysqlUser := getenv("MYSQL_USER", "root")
  mysqlPass := getenv("MYSQL_PASSWORD", "mypassword")
  mysqlHost := getenv("MYSQL_HOST", "mysql")
  mysqlPort := getenv("MYSQL_PORT", "3306")
  mysqlDB := getenv("MYSQL_DATABASE", "appdb")

  dsn := fmt.Sprintf("%s:%s@tcp(%s:%s)/%s?parseTime=true", mysqlUser, mysqlPass, mysqlHost, mysqlPort, mysqlDB)
  var err error
  db, err = sql.Open("mysql", dsn)
  if err != nil { log.Fatalf("open db: %v", err) }
  if err = db.Ping(); err != nil { log.Fatalf("ping db: %v", err) }

  _, _ = db.Exec(`CREATE TABLE IF NOT EXISTS items (id INT AUTO_INCREMENT PRIMARY KEY, value VARCHAR(255))`)

  http.HandleFunc("/write", writeHandler)
  http.HandleFunc("/read", readHandler)

  log.Println("backend listening :8080")
  log.Fatal(http.ListenAndServe(":8080", nil))
}

func getenv(k, d string) string {
  if v := os.Getenv(k); v != "" { return v }
  return d
}

func writeHandler(w http.ResponseWriter, r *http.Request) {
  v := r.URL.Query().Get("v")
  if v == "" { v = "hello" }
  if _, err := db.Exec("INSERT INTO items (value) VALUES (?)", v); err != nil {
    http.Error(w, err.Error(), 500); return
  }
  fmt.Fprintln(w, "ok")
}

func readHandler(w http.ResponseWriter, r *http.Request) {
  rows, err := db.Query("SELECT id, value FROM items ORDER BY id DESC LIMIT 10")
  if err != nil { http.Error(w, err.Error(), 500); return }
  defer rows.Close()
  for rows.Next() {
    var id int; var v string
    rows.Scan(&id, &v)
    fmt.Fprintf(w, "%d: %s\n", id, v)
  }
}
