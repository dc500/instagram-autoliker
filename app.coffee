express = require 'express'
request = require 'request'
http = require 'http'
https = require 'https'
querystring = require 'querystring'
json = require 'JSON'
app = express()

BASE_URL = 'http://pure-wildwood-8107.herokuapp.com'
CLIENT_ID = '83f2bc2cf35842dbb45785e5b3efe457'
CLIENT_SECRET = '8602ba3eda234f5cb32a305938943b59'
REDIRECT_URI = BASE_URL + '/confirm'
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
	response_type=code&
	scope=likes"
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
		'code': req.query.code 


	jsonFeedData = null
	# request the access token
	request.post({
		url: 'https://api.instagram.com/oauth/access_token',
		body: querystring.stringify(postdata)
	}, (err, response, body) ->
		if err
			res.send('error retrieving access token: ' + err)
		body_json = json.parse(body)
		#res.send(response)
		#create_subscription(response.access_token)
		access_token = body_json.access_token
		setTimeout get_user_feed(access_token, res), 5000
		#		console.log '================='
		#		console.log feed
		#		console.log '================='
		#jsonFeedData = json.parse(feed)
	)
)

app.get('/newimage', (req, res) ->
	res.send('New image GET')
)

app.post('/newimage', (req, res) ->
	res.send('New image POST') 
)

app.listen(app.get('port'))


# helper functions
get_user_feed = (access_token, res_out) ->
	feed = ''
	url = 'https://api.instagram.com/v1/users/self/feed?access_token=' + access_token		
	https.get(url, (res) -> 
		body_data = '' 
		res.setEncoding('utf8')
		res.on('data', (d) ->
			body_data += d
		)
		res.on('end', () ->
			get_beezi(JSON.parse(body_data), res_out, access_token)
		)
		res.on('error', (e) -> 
			console.log 'error getting feed: ' + e
		)
	)

get_beezi = (feed, res, access_token) ->
	console.log 'feed type: ' + typeof(feed)
	target_user = 'beezi2'

	posts_to_like = {} 
	posts = (post for post in feed.data when post.user.username == target_user)
	for post in posts when not post.user_has_liked
		#if post.user_has_liked == false
			#console.log 'unliked: ' + post.id
		posts_to_like[post.id] = post.images.standard_resolution
		set_like(post.id, access_token)

	console.log 'posts: ' + posts
	#res.send(beezis)
	res.send(posts)
	#res.send(feed.data)

set_like = (media_id, access_token) ->
	post_url = "https://api.instagram.com/v1/media/#{media_id}/likes"
	console.log 'post to ' + post_url
	request.post({
		url: post_url,
		body: querystring.stringify({'access_token': access_token})
	}, (err, response, body) ->
		if err
			res.send('error setting like: ' + err)
		body_json = json.parse(body)
		console.log 'response\n==============\n' + body
		if body_json.meta.code == 200
			console.log 'Liked media ' + media_id
	)

# currently unused
create_subscription = (access_token) ->
	postdata = 
			'client_id': CLIENT_ID 
			'client_secret': CLIENT_SECRET
			'object': 'user'
			'aspect': 'media'
			'verify_token': access_token
			'callback_url': BASE_URL + '/newimage'

		# POST to create a subscription
		request.post({
			url: 'https://api.instagram.com/v1/subscriptions/',
			body: querystring.stringify(postdata)
		}, (err, response, body) ->
			if err
				res.send("error creating subscription: " + err)
			response = json.parse(body)
			create_subscription(response.access_token)
			res.send('Authentication successful!')
		)