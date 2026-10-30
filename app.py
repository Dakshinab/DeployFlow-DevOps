from flask import Flask, request, jsonify
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST

app = Flask(__name__)

todos = []

# METRICS: count how many times each route is hit
REQUEST_COUNT = Counter(
    "app_requests_total",
    "Total number of requests",
    ["endpoint"]
)

@app.before_request
def count_request():
    REQUEST_COUNT.labels(endpoint=request.path).inc()

@app.route("/")
def home():
    return """
    <h1>🚀 DeployFlow</h1>
    <p>Add a task: POST /todos {"task": "learn docker"}</p>
    <p>See tasks: GET /todos</p>
    <p>Health check: GET /health</p>
    <p>Metrics: GET /metrics</p>
    """

@app.route("/health")
def health():
    return jsonify(status="ok"), 200

@app.route("/metrics")
def metrics():
    return generate_latest(), 200, {"Content-Type": CONTENT_TYPE_LATEST}

@app.route("/todos", methods=["GET"])
def get_todos():
    return jsonify(todos)

@app.route("/todos", methods=["POST"])
def add_todo():
    task = request.json.get("task")
    if not task:
        return jsonify(error="task is required"), 400
    todos.append(task)
    return jsonify(added=task, total=len(todos)), 201

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
