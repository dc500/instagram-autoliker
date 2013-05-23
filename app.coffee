express = require('express')
app = express()

app.configure ->
  app.set "port", process.env.PORT or 3000

console.log 'Listening on port ' + app.get('port')

app.get('/', (req, res) ->
	res.send('LOVE YOU BEEZI') )

app.post('/newimage', (req, res) ->
	res.send('Image updated\nLike registered') )

app.listen(3000)