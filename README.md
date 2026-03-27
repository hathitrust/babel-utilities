# Babel Utilities

For now this is just a Ruby interface to manually create Collection transfers.

```
docker compose build
docker compose run --rm test bundle install
```

Trying a variation on the MVC paradigm.
`lib/model` contains Sequel models
`lib/operation` contains controller-ish things that "do something"

Can be run under Docker, or on an HT dev server if database credentials
are provided in `config/env.local`
