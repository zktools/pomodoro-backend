#include <SQLiteCpp/SQLiteCpp.h>
#include <crow.h>

#include <iostream>

int main() {
  std::cout << "Starting Pomodoro Backend ..." << std::endl;

  try {
    // Open a database file in create mode
    SQLite::Database db("test.db",
                        SQLite::OPEN_READWRITE | SQLite::OPEN_CREATE);

    // Create users table
    db.exec(
        "CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY, name TEXT "
        "NOT NULL, email TEXT NOT NULL UNIQUE, password TEXT NOT NULL, role_id "
        "INTEGER NOT NULL, registration_date TIMESTAMP DEFAULT "
        "CURRENT_TIMESTAMP)");

    // Create roles table
    db.exec(
        "CREATE TABLE IF NOT EXISTS roles (id INTEGER PRIMARY KEY, name TEXT "
        "NOT NULL UNIQUE)");

    // Insert roles
    db.exec("INSERT INTO roles (name) VALUES ('admin');");
    db.exec("INSERT INTO roles (name) VALUES ('user');");

    // Insert a fake user
    SQLite::Transaction transaction(db);
    SQLite::Statement query(
        db,
        "INSERT INTO users (name, email, password, role_id, registration_date) "
        "VALUES (?, ?, ?, ?, ?)");
    query.bind(1, "John Doe");
    query.bind(2, "john.doe@example.com");
    query.bind(3, "password123");
    query.bind(4, 1);
    query.bind(5, "2022-01-01 12:00:00");
    query.exec();
    transaction.commit();
  } catch (const std::exception& e) {
    std::cout << "Error: " << e.what() << std::endl;
  }

  crow::SimpleApp app;

  CROW_ROUTE(app, "/")([]() { return "Hello world"; });

  app.port(18080).multithreaded().run();
  return 0;
}
