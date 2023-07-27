# WeatherOnRails

## 📦 Requirements

- Ruby
- Redis
- OpenWeatherMap API key: https://openweathermap.org/
- OpenCage API key: https://opencagedata.com/

## ⚡️ Setup

```bash
$ bin/setup
```

Add your OpenWeatherMap API key to the `.env.local` file

```bash
OPEN_WEATHER_API_KEY=REPLACE_ME
```

Add your OpenCage API key to the `.env.local` file

```bash
OPEN_CAGE_API_KEY=REPLACE_ME
```

## 🚀 Running

```bash
$ bin/rails s
```

## 🧪 Testing

```bash
$ bundle exec rspec
```

## 📝 Codestyle

```bash
$ bundle exec rubocop
```

## 💽 Caching

The app uses Redis to cache the weather data per country and zip code. The cache is set to expire after 30 minutes.

By default, caching is disabling in the development environment. To toggle it, run `rails dev:cache`.
