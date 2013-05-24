express = require 'express'
request = require 'request'
querystring = require 'querystring'
app = express()

CLIENT_ID = '83f2bc2cf35842dbb45785e5b3efe457'
CLIENT_SECRET = '8602ba3eda234f5cb32a305938943b59'
REDIRECT_URI = 'http://pure-wildwood-8107.herokuapp.com/confirm'

app.configure ->
  app.set "port", process.env.PORT or 4000

console.log 'Listening on port ' + app.get('port')

# Routes
# TODO: put these in a separate file

app.get('/', (req, res) -> res.send('BEEZI SUX') )

app.get('/authorize', (req, res) -> 
	auth_uri = "https://api.instagram.com/oauth/authorize/?
	client_id=#{CLIENT_ID}&
	redirect_uri=#{REDIRECT_URI}&
	response_type=code"

	console.log('auth_uri: ' + auth_uri)
	res.redirect(auth_uri)
)

app.get('/confirm', (req, res) ->
	if req.query.error
		res.send('error authenticating: ' + req.query.error_description)
	auth_code = req.query.code
	console.log 'code: ' + auth_code

	postdata = 
		'client_id': CLIENT_ID 
		'client_secret': CLIENT_SECRET
		'grant_type': 'authorization_code'
		'redirect_uri': REDIRECT_URI
		'code': auth_code 
	auth_url = 'https://api.instagram.com/oauth/access_token'

	request.post({
		url: auth_url,
		body: querystring.stringify(postdata)
	}, (err, response, body) ->
		if err
			console.log("error from Instagram server")
			res.send("error from Instagram server: " + err)
		access_token = body["access_token"]
		console.log body
		console.log access_token
		res.send(access_token)
	)
)

app.get('/newimage', (req, res) ->
	res.send('New image GET')
)

app.post('/newimage', (req, res) ->
	res.send('New image POST') 
)

app.listen(app.get('port'))