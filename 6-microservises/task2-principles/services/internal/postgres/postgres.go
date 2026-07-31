package postgres

import (
	"context"
	"fmt"
	"time"

	"github.com/cenkalti/backoff/v4"
	"github.com/jackc/pgx/v5/pgxpool"
)

var (
	createUsersSql = `
	CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
`
)

type DBStorage struct {
	instance *pgxpool.Pool
}

func NewStorage(dsn string) (*DBStorage, error) {
	ctx := context.Background()
	var s DBStorage
	tryCount := 0
	createConn := func() error {
		word := "try"
		if tryCount > 0 {
			word = "retry"
		}
		fmt.Printf("%s to connect to database, probe %d\n", word, tryCount)
		tryCount++

		pool, err := pgxpool.New(ctx, dsn)
		if err != nil {
			return fmt.Errorf("could not connect to database: %v", err)
		}

		err = pool.Ping(ctx)
		if err != nil {
			return fmt.Errorf("could not connect to database: %v", err)
		}

		fmt.Printf("  | -- connected to database %s\n", dsn)
		s.instance = pool

		return nil
	}
	expBackoff := backoff.NewExponentialBackOff()
	expBackoff.MaxElapsedTime = 12 * time.Second
	if err := backoff.Retry(createConn, expBackoff); err != nil {
		return nil, fmt.Errorf("\nfailed to connect to database after retrying %d times: %v", tryCount, err)
	}
	if err := s.initTables(ctx); err != nil {
		return &s, err
	}

	return &s, nil
}

func (s *DBStorage) initTables(ctx context.Context) error {
	conn, err := s.instance.Acquire(ctx)
	if err != nil {
		return err
	}
	defer conn.Release()

	_, err = conn.Query(ctx, createUsersSql)
	return err
}

func (s *DBStorage) Close() {
	s.instance.Close()
}

func (s *DBStorage) Ping(ctx context.Context) error {
	return s.instance.Ping(ctx)
}

func (s *DBStorage) SaveUser(ctx context.Context, username string, hashePswd string) error {
	// Сохраняем в БД
	query := `INSERT INTO users (username, password_hash) VALUES ($1, $2) RETURNING id`
	var userID int
	return s.instance.QueryRow(context.Background(), query, username, string(hashePswd)).Scan(&userID)
}

func (s *DBStorage) GetPasswordHash(ctx context.Context, username string) (int, string, error) {
	var id int
	var passwordHash string
	query := `SELECT id, password_hash FROM users WHERE username = $1`
	err := s.instance.QueryRow(context.Background(), query, username).Scan(&id, &passwordHash)
	return id, passwordHash, err
}

func (s *DBStorage) GetUserInfo(ctx context.Context, userId int) (string, time.Time, error) {
	var username string
	var createdAt time.Time
	query := `SELECT username, created_at FROM users WHERE id = $1`
	err := s.instance.QueryRow(context.Background(), query, userId).Scan(&username, &createdAt)
	return username, createdAt, err
}
