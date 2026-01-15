from flask import Flask, jsonify
import os

app = Flask(__name__)

@app.route("/")
def home():
    """Page d'accueil"""
    return jsonify({
        "message": "Bienvenue sur la page d'accueil de l'application Flask",
        "version": "1.0"
    })

@app.route("/health")
def health():
    """Endpoint de vérification de santé"""
    return jsonify({
        "status": "healthy",
        "service": "Flask App"
    }), 200

@app.route("/api/info")
def api_info():
    """Endpoint informatif"""
    return jsonify({
        "app_name": "Flask Application",
        "port": os.getenv('PORT', 8080),
        "environment": os.getenv('ENVIRONMENT', 'development')
    })

if __name__ == "__main__":
    port = int(os.getenv('PORT', 8080))
    app.run(host='0.0.0.0', port=port, debug=False)