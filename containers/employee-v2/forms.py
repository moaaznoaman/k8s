from flask_wtf import FlaskForm
from wtforms import StringField,PasswordField,SubmitField

class SignUpForm(FlaskForm):
    firstname = StringField("Firstname")
    lastname = StringField("Lastname")
    department = StringField("Department")
    email = StringField("Email")
    email = StringField("Comment")
    submit = SubmitField("Sign up")