### How to run

```python
pip install -r requirements.txt
```
```docker
docker run -d -p 27017:27017 --name mongo mongo
```
```python
python main.py
```

### ldap
Start the server and mongo
```
# auth success (should return a list of messages)
curl -X POST -d "username=gasper&password=spagnolog" --cookie-jar cookies.txt  http://localhost:5000/login
curl -X GET -b cookies.txt -H "Accept: application/json" http://localhost:5000/messages

# auth failed (should return not logged in)
curl -X POST -d "username=gasper&password=sasdadsaspagnolog" --cookie-jar cookies.txt  http://localhost:5000/login
curl -X GET -b cookies.txt -H "Accept: application/json" http://localhost:5000/messages
```
