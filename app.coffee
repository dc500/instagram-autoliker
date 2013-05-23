express = require('express')
app = express()

app.configure ->
  app.set "port", process.env.PORT or 4000

console.log 'Listening on port ' + app.get('port')

app.get('/', (req, res) ->
	res.send('BEEZI SUX') )

app.get('/confirm', (req, res) ->
	res.send('Redirect landing page') )

app.get('/newimage', (req, res) ->
	res.send('New image GET') )

app.post('/newimage', (req, res) ->
	res.send('New image POST') )

app.listen(app.get('port'))