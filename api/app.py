# app.py
from flask import Flask, jsonify, request
from flask_cors import CORS
from models import db, User, Caregiver, Reminder
from datetime import datetime

app = Flask(__name__)
CORS(app)  # allow frontend to call backend easily

# Use SQLite for development
app.config["SQLALCHEMY_DATABASE_URI"] = "sqlite:///seniorsched.db"
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

db.init_app(app)


with app.app_context():
    db.create_all()


# ---------- USER ROUTES ----------
@app.route("/users", methods=["POST"])
def create_user():
    data = request.json
    new_user = User(
        name=data["name"],
        email=data["email"],
        password=data["password"],  # In production, hash this!
    )
    db.session.add(new_user)
    db.session.commit()
    return jsonify(new_user.to_dict()), 201


@app.route("/users", methods=["GET"])
def list_users():
    users = User.query.all()
    return jsonify([u.to_dict() for u in users])


# ---------- CAREGIVER ROUTES ----------
@app.route("/caregivers", methods=["POST"])
def add_caregiver():
    data = request.json
    caregiver = Caregiver(
        name=data["name"],
        email=data["email"],
        user_id=data["user_id"],
    )
    db.session.add(caregiver)
    db.session.commit()
    return jsonify(caregiver.to_dict()), 201


@app.route("/caregivers/<int:user_id>", methods=["GET"])
def get_caregivers(user_id):
    caregivers = Caregiver.query.filter_by(user_id=user_id).all()
    return jsonify([c.to_dict() for c in caregivers])


# ---------- REMINDER ROUTES ----------
@app.route("/reminders", methods=["POST"])
def create_reminder():
    data = request.json
    reminder = Reminder(
        title=data["title"],
        description=data.get("description", ""),
        time=datetime.fromisoformat(data["time"]),
        user_id=data["user_id"],
    )
    db.session.add(reminder)
    db.session.commit()
    return jsonify(reminder.to_dict()), 201


@app.route("/reminders/<int:user_id>", methods=["GET"])
def get_reminders(user_id):
    reminders = Reminder.query.filter_by(user_id=user_id).all()
    return jsonify([r.to_dict() for r in reminders])


@app.route("/reminders/<int:reminder_id>", methods=["PUT"])
def update_reminder(reminder_id):
    reminder = Reminder.query.get_or_404(reminder_id)
    data = request.json
    reminder.title = data.get("title", reminder.title)
    reminder.description = data.get("description", reminder.description)
    reminder.time = datetime.fromisoformat(data.get("time", reminder.time.isoformat()))
    reminder.is_completed = data.get("is_completed", reminder.is_completed)
    db.session.commit()
    return jsonify(reminder.to_dict())


@app.route("/reminders/<int:reminder_id>", methods=["DELETE"])
def delete_reminder(reminder_id):
    reminder = Reminder.query.get_or_404(reminder_id)
    db.session.delete(reminder)
    db.session.commit()
    return jsonify({"message": "Reminder deleted"})


if __name__ == "__main__":
    app.run(debug=True)
