Amplified server app built using [Shelf](https://pub.dev/packages/shelf),
configured to enable running with [Docker](https://www.docker.com/).

# Running the sample

## Regenerate Envied data

Envied contains constant keys to OpenAI and Pinecone.
The secret information is stored in `.env` file in the root of the project and is not submitted to
the repository.

## Running with the Dart SDK

You can run the example with the [Dart SDK](https://dart.dev/get-dart)
like this:

```
$ dart run
Server listening on port 8080
```

And then from a second terminal:
```
$ curl http://0.0.0.0:8080/?q=tesla
....json...

$ curl http://0.0.0.0:8080/status
OK
```

## Running with Docker

If you have [Docker Desktop](https://www.docker.com/get-started) installed, you
can build and run with the `docker` command:

```
$ docker build . -t myserver
$ docker run -it -p 8080:8080 myserver
Server listening on port 8080
```

# References

[Colab](https://colab.research.google.com/drive/1SnxE3U2vUdGGkexXroPSuNvKjmAmBMX5)
