# Dependencies

Even though Kauppa has a lot of features built from scratch, it needs to depend on third-party services for storage, mailing, payments, shipments, etc. Kauppa exposes a bunch of protocols and types with the exact requirements it needs for achieving its goals. These protocols should be implemented by the user on their own services of choice for use by Kauppa.

`KauppaCore` is a dependency shared by many services. Shared types, protocols and features from third-party dependencies such as web server, client, PRNG, ORM libraries are exposed through `KauppaCore` so that the other services remain loosely coupled.

## Mailing

Some of Kauppa's services (only orders service for now) support mailing to the customer account's verified email addresses. Your mail service of choice should implement the `MailServiceCallable` protocol in `KauppaCore` and it should be set while initializing the dependent service.
