Amplified server app built using [Shelf](https://pub.dev/packages/shelf),
configured to enable running with [Docker](https://www.docker.com/).

# Running the sample

## Regenerate Envied data

Envied contains constant keys to OpenAI and Pinecone.
The secret information is stored in `.env` file in the root of the project and is not submitted to
the repository. To generate the relevant constant, either the `.env` file needs to exist or the
constants must be defined as environmental variables.

To regenerate the code:

```shell
dart run build_runner build
```

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

You should see the logging printed in the first terminal:
```
2021-05-06T15:47:04.620417  0:00:00.000158 GET     [200] /
2021-05-06T15:47:08.392928  0:00:00.001216 GET     [200] /echo/I_love_Dart
```

# References

[Colab](https://colab.research.google.com/drive/1SnxE3U2vUdGGkexXroPSuNvKjmAmBMX5)
