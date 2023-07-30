Amplified server app built using [Shelf](https://pub.dev/packages/shelf),
configured to enable running with [Docker](https://www.docker.com/).

# Running the sample

## Regenerate Envied data

Envied contains constant keys to OpenAI and Pinecone.
The secret information is stored in `.env` file in the root of the project and is not submitted to
the repository.

## Running locally with the Dart SDK

```shell
$ dart run
```
... prints `Server listening on port 8080`.


And then test the following URL:
`http://0.0.0.0:8080/?q=tesla`

## Running locally with Docker

If you have [Docker Desktop](https://www.docker.com/get-started) installed, you
can build and run with the `docker` command:

```shell
$ docker build . -t amplifyserver
$ docker run -it -p 8080:8080 amplifyserver
```
... prints `Server listening on port 8080`.

## Deploying to Google Cloud
```shell
gcloud run deploy
```

Progress of the build is trackable in Cloud Build:
https://console.cloud.google.com/cloud-build/builds

Logs from running server are trackable in Logs Explorer:
https://console.cloud.google.com/logs/

Alternatively, run the trigger in 
https://console.cloud.google.com/cloud-build/triggers?project=amplifyservertest

# References

[Colab](https://colab.research.google.com/drive/1SnxE3U2vUdGGkexXroPSuNvKjmAmBMX5)
