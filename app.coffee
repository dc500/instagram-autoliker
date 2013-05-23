express = require('express')
app = express()

app.configure ->
  app.set "port", process.env.PORT or 4000

console.log 'Listening on port ' + app.get('port')

app.get('/', (req, res) ->
	res.send('BEEZI SUX') )

app.post('/newimage', (req, res) ->
	res.send('Image updated\nLike registered') )

app.listen(4000)