from flask import Blueprint, render_template, redirect, request, url_for, flash
from flask_login import UserMixin, login_user, logout_user, login_required

login_bp = Blueprint("login_bp", __name__)

class User(UserMixin):
    id = "admin"

@login_bp.route("/login", methods=["GET", "POST"])
def login():
    from config import Config
    if request.method == "POST":
        username = request.form.get("username")
        password = request.form.get("password")
        if username == Config.ADMIN_USERNAME and password == Config.ADMIN_PASSWORD:
            user = User()
            login_user(user)
            return redirect(url_for("index"))
        flash("Invalid credentials", "danger")
    return render_template("login.html")

@login_bp.route("/logout")
@login_required
def logout():
    logout_user()
    return redirect(url_for("login_bp.login"))
