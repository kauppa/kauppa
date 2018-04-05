# Design

All services of Kauppa have been designed in such a way that they're loosely coupled from one another (at least, that's the goal).

## Service-oriented architecture

Individual services of Kauppa have been segregated based on their domain, so that every service can be tested easily by simply mocking the other services, while still maintaining the integrity.
