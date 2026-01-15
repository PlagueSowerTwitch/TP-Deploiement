# Stage 1: Builder
FROM python:3.12-slim as builder

WORKDIR /app

# Copier les requirements et installer les dépendances
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Stage 2: Runtime
FROM python:3.12-slim

WORKDIR /app

# Créer un utilisateur non-root pour plus de sécurité
RUN useradd -m -u 1000 appuser

# Copier les dépendances installées du builder
COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Copier l'application
COPY --chown=appuser:appuser app.py .

# Changer vers l'utilisateur non-root
USER appuser

EXPOSE 8080

# Utiliser exec form pour que les signaux soient correctement gérés
CMD ["python", "-u", "app.py"]