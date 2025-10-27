from flask_sqlalchemy import SQLAlchemy
import uuid
import json

db = SQLAlchemy()


class User(db.Model):
    __tablename__ = "users"
    id = db.Column(db.String, primary_key=True, default=lambda: str(uuid.uuid4()))
    email = db.Column(db.String, unique=True, nullable=False)
    name = db.Column(db.String, nullable=False)
    age = db.Column(db.Integer, nullable=False)
    password = db.Column(db.String, nullable=False)
    is_caregiver = db.Column(db.Boolean, default=False)

    caregiver_id = db.Column(db.String, db.ForeignKey("users.id"), nullable=True)
    medications = db.relationship("Medication", backref="user", lazy=True)

    def to_dict(self):
        return {
            "id": self.id,
            "email": self.email,
            "name": self.name,
            "age": self.age,
            "isCaregiver": self.is_caregiver,
            "caregiverId": self.caregiver_id
        }


class Medication(db.Model):
    __tablename__ = "medications"
    id = db.Column(db.String, primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = db.Column(db.String, db.ForeignKey("users.id"), nullable=False)
    name = db.Column(db.String, nullable=False)
    amount = db.Column(db.Float, nullable=False)
    unit = db.Column(db.String, nullable=False)
    time = db.Column(db.String, nullable=False)  # "08:00 AM"
    days = db.Column(db.String, nullable=True)   # comma-separated weekdays
    taken = db.Column(db.Boolean, default=False)

    def to_dict(self):
        return {
            "id": self.id,
            "userId": self.user_id,
            "name": self.name,
            "amount": self.amount,
            "unit": self.unit,
            "time": self.time,
            "days": json.loads(self.days) if self.days else [],
            "taken": self.taken
        }
