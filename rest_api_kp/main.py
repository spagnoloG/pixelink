from flask import Flask, request, jsonify, render_template_string
from flask_restful import Resource, Api
from pymongo import MongoClient
from bson.objectid import ObjectId
from faker import Faker
import dicttoxml

app = Flask(__name__)
api = Api(app)

# Create a MongoDB client, change the << MONGODB URL >> to your MongoDB instance URL
mongo_url = 'mongodb://localhost:27017'
client = MongoClient(mongo_url)

db = client['my_database']  # choose your database name

# collections
users = db['users']
messages = db['messages']

# creating Faker instance for data generation
fake = Faker()

def populate_db():
    # clear the collections
    users.delete_many({})
    messages.delete_many({})

    # generate 10 users and 20 messages
    for i in range(10):
        user = {
            'name': fake.name(),
            'email': fake.email()
        }
        user_result = users.insert_one(user)
        
        for _ in range(2):
            message = {
                'user_id': str(user_result.inserted_id),
                'content': fake.sentence(),
            }
            messages.insert_one(message)

class UserAPI(Resource):
    def get(self, user_id=None):
        accept = request.headers.get('Accept', 'application/json')
        if accept == "*/*":
            accept = 'application/json'
        if user_id:
            user = users.find_one({'_id': ObjectId(user_id)})
            if user is None:
                response_data = {'message': 'User not found'}
                if 'application/json' in accept:
                    return response_data, 404
                elif 'application/xml' in accept:
                    return dicttoxml.dicttoxml(response_data).decode(), 404, {'Content-Type': 'application/xml'}
                elif 'text/html' in accept:
                    template = '<html><body><h1>{{ message }}</h1></body></html>'
                    return render_template_string(template, message=response_data['message']), 404, {'Content-Type': 'text/html'}
                else:
                    return {"message": "Unsupported Media Type"}, 415
            user_messages = list(messages.find({'user_id': user_id}))
            for message in user_messages:
                message['_id'] = str(message['_id'])
            user['_id'] = str(user['_id'])
            user['messages'] = user_messages
            if 'application/json' in accept:
                return user
            elif 'application/xml' in accept:
                return dicttoxml.dicttoxml(user).decode(), 200, {'Content-Type': 'application/xml'}
            elif 'text/html' in accept:
                template = '<html><body><h1>User: {{ user["_id"] }}</h1><p>Messages: {{ user["messages"] }}</p></body></html>'
                return render_template_string(template, user=user), 200, {'Content-Type': 'text/html'}
            else:
                return {"message": "Unsupported Media Type"}, 415
        else:
            all_users = list(users.find())
            for user in all_users:
                user['_id'] = str(user['_id'])
                user_messages = list(messages.find({'user_id': str(user['_id'])}))
                for message in user_messages:
                    message['_id'] = str(message['_id'])
                user['messages'] = user_messages
            if 'application/json' in accept:
                return all_users
            elif 'application/xml' in accept:
                return dicttoxml.dicttoxml(all_users).decode(), 200, {'Content-Type': 'application/xml'}
            elif 'text/html' in accept:
                template = '<html><body><h1>All Users</h1><p>{{ users }}</p></body></html>'
                return render_template_string(template, users=all_users), 200, {'Content-Type': 'text/html'}
        return {"message": "Unsupported Media Type"}, 415

    def post(self):
        user = request.get_json()
        result = users.insert_one(user)
        return {'_id': str(result.inserted_id)}

    def put(self, user_id):
        user = request.get_json()
        result = users.update_one({'_id': ObjectId(user_id)}, {"$set": user})
        return {'modified_count': result.modified_count}

    def delete(self, user_id):
        accept = request.headers.get('Accept', 'application/json')
        if accept == "*/*":
            accept = 'application/json'
        result = users.delete_one({'_id': ObjectId(user_id)})
        response_data = {'message': 'User not found'}
        if result.deleted_count == 0:
            if 'application/xml' in accept:
                return dicttoxml.dicttoxml(response_data).decode(), 200, {'Content-Type': 'application/xml'}
            elif 'text/html' in accept:
                template = '<html><body><h1>User not found</h1></body></html>'
                return template, 200, {'Content-Type': 'text/html'}
            else:
                # default to json
                return response_data, 404

        response_data = {'message': 'User deleted'}
        if 'application/xml' in accept:
            return dicttoxml.dicttoxml(response_data).decode(), 200, {'Content-Type': 'application/xml'}
        elif 'text/html' in accept:
            template = '<html><body><h1>User deleted</h1></body></html>'
            return template, 200, {'Content-Type': 'text/html'}
        else:
            # default to json
            return response_data, 200

class MessageAPI(Resource):
    def get(self, message_id=None):
        accept = request.headers.get('Accept', 'application/json')
        if accept == "*/*":
            accept = 'application/json'
        if message_id:
            message = messages.find_one({'_id': ObjectId(message_id)})
            if message is None:
                response_data = {'message': 'Message not found'}
                if 'application/json' in accept:
                    return response_data, 404
                elif 'application/xml' in accept:
                    return dicttoxml.dicttoxml(response_data).decode(), 404, {'Content-Type': 'application/xml'}
                elif 'text/html' in accept:
                    template = '<html><body><h1>{{ message }}</h1></body></html>'
                    return render_template_string(template, message=response_data['message']), 404, {'Content-Type': 'text/html'}
                else:
                    return {"message": "Unsupported Media Type"}, 415
            message['_id'] = str(message['_id'])
            return message
        else:
            all_messages = list(messages.find())
            for message in all_messages:
                message['_id'] = str(message['_id'])
            return all_messages


    def post(self):
        message = request.get_json()
        result = messages.insert_one(message)
        return {'_id': str(result.inserted_id)}

    def put(self, message_id):
        message = request.get_json()
        result = messages.update_one({'_id': ObjectId(message_id)}, {"$set": message})
        return {'modified_count': result.modified_count}

    def delete(self, message_id):
        result = messages.delete_one({'_id': ObjectId(message_id)})
        if result.deleted_count == 0:
            return {'message': 'Message not found'}, 404
        return {'deleted_count': result.deleted_count}

api.add_resource(UserAPI, '/users/<user_id>', '/users')
api.add_resource(MessageAPI, '/messages/<message_id>', '/messages')

if __name__ == '__main__':
    populate_db()
    app.run(debug=True)
