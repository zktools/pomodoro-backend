#include <crow.h>

#include <iostream>

int main() {
  std::cout << "Starting Pomodoro Backend ..." << std::endl;

  crow::SimpleApp app;

  CROW_ROUTE(app, "/")([]() { return "Hello world"; });

  app.port(18080).multithreaded().run();
  return 0;
}
