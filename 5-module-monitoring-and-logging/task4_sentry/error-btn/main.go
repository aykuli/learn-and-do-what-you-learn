package main

import (
  "log"
  "time"
  "errors"

  "github.com/getsentry/sentry-go"
)

func main() {
  err := sentry.Init(sentry.ClientOptions{
    Dsn: "http://83d242a69018b638ed5e1f026e2a1162@158.160.226.208:9000/4",
		ServerName: "Aynurs host",
		Release: "0.0.4",
		Environment: "Playground",
  })
  if err != nil {
    log.Fatalf("sentry.Init: %s", err)
  }
  // Flush buffered events before the program terminates.
  defer sentry.Flush(2 * time.Second)

  sentry.CaptureMessage("Не открывайте задание, если не готовы приступить к его ")
	sentry.CaptureException(errors.New("ANOTHER new ERROR 6"))
}