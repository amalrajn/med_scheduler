from flask_sqlalchemy import SQLAlchemy
# Removed direct import of 'relationship' to ensure consistent use of db.relationship
import uuid
import json
from datetime import datetime

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
    # Relationship for messages sent by this user (Updated to db.relationship)
    sent_messages = db.relationship("Message", back_populates="sender", lazy=True)

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

    # Relationship for chat messages tied to this medication (Updated to db.relationship)
    messages = db.relationship("Message", back_populates="medication", lazy="dynamic")

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

# --- MESSAGE MODEL FOR CHAT ---
class Message(db.Model):
    __tablename__ = 'messages'
    id = db.Column(db.String, primary_key=True, default=lambda: str(uuid.uuid4()))
    
    # Foreign Keys use String to match the UUID types in User and Medication
    medication_id = db.Column(db.String, db.ForeignKey('medications.id'), nullable=False)
    sender_id = db.Column(db.String, db.ForeignKey('users.id'), nullable=False)
    
    content = db.Column(db.String(500), nullable=False)
    timestamp = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)

    # Relationships (Updated to db.relationship)
    medication = db.relationship("Medication", back_populates="messages")
    sender = db.relationship("User", back_populates="sent_messages")

    def to_dict(self):
        return {
            "id": self.id,
            "medication_id": self.medication_id,
            "sender_id": self.sender_id,
            "content": self.content,
            # Use isoformat() for easy parsing in Flutter
            "timestamp": self.timestamp.isoformat() + 'Z', 
        }