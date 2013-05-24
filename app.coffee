express = require 'express'
request = require 'request'
querystring = require 'querystring'
json = require 'JSON'
app = express()

CLIENT_ID = '83f2bc2cf35842dbb45785e5b3efe457'
CLIENT_SECRET = '8602ba3eda234f5cb32a305938943b59'
REDIRECT_URI = 'http://pure-wildwood-8107.herokuapp.com/confirm'
access_token = null

app.configure ->
  app.set "port", process.env.PORT or 4000

console.log 'Listening on port ' + app.get('port')

# Routes
# TODO: put these in a separate file

app.get('/', (req, res) -> 
	res.redirect('/authorize')
)

# redirect user to Instagram login/approval page
app.get('/authorize', (req, res) -> 
	auth_uri = "https://api.instagram.com/oauth/authorize/?
	client_id=#{CLIENT_ID}&
	redirect_uri=#{REDIRECT_URI}&
	response_type=code"
	res.redirect(auth_uri)
)

# endpoint once user allows app
# params: {access token, user: {id, username, full_name, profile_picture} }
app.get('/confirm', (req, res) ->
	if req.query.error
		res.send('error authenticating: ' + req.query.error_description)

	postdata = 
		'client_id': CLIENT_ID 
		'client_secret': CLIENT_SECRET
		'grant_type': 'authorization_code'
		'redirect_uri': REDIRECT_URI
		'code': req.query.auth_code 

	# request the access token
	request.post({
		url: 'https://api.instagram.com/oauth/access_token',
		body: querystring.stringify(postdata)
	}, (err, response, body) ->
		if err
			res.send("error retrieving access token: " + err)
		response = json.parse(body)
		access_token = response.access_token
		res.send('Authentication successful!\naccess_token: ' + access_token)
	)
)

app.get('/newimage', (req, res) ->
	res.send('New image GET')
)

app.post('/newimage', (req, res) ->
	res.send('New image POST') 
)

app.listen(app.get('port'))