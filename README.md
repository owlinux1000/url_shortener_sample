# Sample URL Shortener

## Usage

```
$ redis-server
$ main.rb
$ curl -X POST http://localhost:4567/ -d "url=http://url/you/wanna/add"
http://localhost:4567/Here_is_random_string
$ curl -L http://localhost:4567/Here_is_random_string
```

Finally, you can access the URL you registered !
