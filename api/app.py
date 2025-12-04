from flask import Flask, request, jsonify
from flask_cors import CORS
from models import db, User, Medication
import json

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///med_scheduler.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db.init_app(app)
CORS(app)

with app.app_context():
    db.create_all()

# ----------------- User APIs -----------------
@app.route("/signup", methods=["POST"])
def signup():
    data = request.get_json()
    email = data.get("email")
    password = data.get("password")
    name = data.get("name")
    age = data.get("age", 0)
    is_caregiver = data.get("isCaregiver", False)

    if not email or not password or not name:
        return jsonify({"error": "Missing required fields"}), 400

    if User.query.filter_by(email=email).first():
        return jsonify({"error": "User with this email already exists"}), 400

    user = User(
        email=email,
        password=password,
        name=name,
        age=age,
        is_caregiver=is_caregiver
    )
    db.session.add(user)
    db.session.commit()
    return jsonify(user.to_dict()), 201


@app.route("/login", methods=["POST"])
def login():
    data = request.get_json()
    print(data)
    print([u.to_dict() for u in User.query.all()])
    email = data.get("email")
    password = data.get("password")
    is_caregiver = data.get("isCaregiver", False)

    if not email or not password:
        return jsonify({"error": "Missing email or password"}), 400

    user = User.query.filter_by(email=email, password=password, is_caregiver=is_caregiver).first()
    if not user:
        return jsonify({"error": "Invalid credentials"}), 401

    return jsonify(user.to_dict()), 200


@app.route("/caregivers/<caregiver_id>/users", methods=["GET"])
def get_caregiver_users(caregiver_id):
    users = User.query.filter_by(caregiver_id=caregiver_id).all()
    return jsonify([u.to_dict() for u in users]), 200

# Assign existing user to a caregiver
@app.route("/caregivers/<caregiver_id>/users", methods=["POST"])
def add_caregiver_user(caregiver_id):
    data = request.get_json()
    email = data.get("email")

    if not email:
        return jsonify({"error": "Missing email field"}), 400

    # Find existing user
    user = User.query.filter_by(email=email).first()
    if not user:
        return jsonify({"error": "User does not exist"}), 404

    # Assign caregiver
    user.caregiver_id = caregiver_id
    db.session.commit()

    return jsonify({
        "message": "User successfully assigned to caregiver",
        "user": user.to_dict()
    }), 201



# ----------------- Medication APIs -----------------
@app.route("/medications/<user_id>", methods=["GET"])
def get_medications(user_id):
    print(user_id)
    meds = Medication.query.filter_by(user_id=user_id).all()
    print([m.to_dict() for m in meds])
    return jsonify([m.to_dict() for m in meds]), 200


@app.route("/medications/<user_id>", methods=["POST"])
def add_medication(user_id):
    data = request.get_json()
    print(data)

    # basic validation
    required_fields = ["name", "amount", "unit", "time"]
    if not all(field in data and data[field] for field in required_fields):
        return jsonify({"error": "Missing required fields"}), 400

    med = Medication(
        user_id=user_id,
        name=data["name"],
        amount=data["amount"],
        unit=data["unit"],
        time=data["time"],
        days=json.dumps(data.get("days", [])),
        taken=False
    )

    db.session.add(med)
    db.session.commit()
    return jsonify(med.to_dict()), 201


@app.route("/medications/<user_id>/<med_id>", methods=["PUT"])
def update_medication(user_id, med_id):
    med = Medication.query.filter_by(user_id=user_id, id=med_id).first()
    if not med:
        return jsonify({"error": "Medication not found"}), 404

    data = request.get_json()

    # Update only fields provided in request
    med.name = data.get("name", med.name)
    med.amount = data.get("amount", med.amount)
    med.unit = data.get("unit", med.unit)
    med.time = data.get("time", med.time)
    med.days = json.dumps(data.get("days", []))
    med.taken = data.get("taken", med.taken)

    db.session.commit()
    return jsonify(med.to_dict()), 200

@app.route("/medications/<user_id>/<med_id>", methods=["DELETE"])
def delete_medication(user_id, med_id):
    med = Medication.query.filter_by(user_id=user_id, id=med_id).first()
    if not med:
        return jsonify({"error": "Medication not found"}), 404

    db.session.delete(med)
    db.session.commit()
    return '', 204 # Standard successful deletion response (No Content)

@app.route("/medications/<user_id>/<med_id>/taken", methods=["POST"])
def mark_med_taken(user_id, med_id):
    med = Medication.query.get(med_id)
    if not med:
        return {"error": "Medication not found"}, 404

    med.taken = True
    db.session.commit()
    return jsonify(med.to_dict()), 200

if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=8000)
