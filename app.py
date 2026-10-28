from flask import Flask, request, jsonify

app = Flask(__name__)

todos = []

@app.route("/")
def home():
    return """
    <h1>🚀 DeployFlow v2 — deployed by CI/CD!</h1>
    <p>Add a task: POST /todos {"task": "learn docker"}</p>
    <p>See tasks: GET /todos</p>
    <p>Health check: GET /health</p>
    """

@app.route("/health")
def health():
    return jsonify(status="ok"), 200

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
