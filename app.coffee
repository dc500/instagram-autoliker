express = require('express')
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

app.get('/confirm?code=:code', (req, res) ->
	console.log 'req: ' + req
	params = req.params
	console.log 'params: ' + params
	auth_code = req.params.code
	console.log 'code: ' + auth_code
	res.send('Redirect landing page')
	res.send('auth_code: ' + auth_code)
)

app.get('/newimage', (req, res) ->
	res.send('New image GET')
)

app.post('/newimage', (req, res) ->
	res.send('New image POST') 
)

app.listen(app.get('port'))