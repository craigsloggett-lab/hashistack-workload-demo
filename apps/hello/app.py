"""Hello-world HashiStack demo.

A minimal Flask app that increments a visit counter stored in MongoDB on every
request. Connection string and listen port are provided through the MONGO_URI
and HTTP_PORT environment variables, which the Nomad jobspec populates from
Vault dynamic credentials and the Consul-registered MongoDB service.
"""

import os

from flask import Flask, jsonify
from pymongo import MongoClient

app = Flask(__name__)
client = MongoClient(os.environ["MONGO_URI"])
db = client.get_default_database()


@app.route("/")
def hello():
    db.visits.update_one(
        {"_id": "counter"},
        {"$inc": {"value": 1}},
        upsert=True,
    )
    doc = db.visits.find_one({"_id": "counter"})
    return jsonify(message="Hello from HashiStack Demo!", visits=doc["value"])


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.environ["HTTP_PORT"]))
