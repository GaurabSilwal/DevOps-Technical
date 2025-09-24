FROM python:3.11-slim

RUN groupadd -r worker && useradd -r -g worker worker

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY --chown=worker:worker . .

USER worker

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD python -c "import redis; r=redis.Redis(host='redis'); r.ping()" || exit 1

CMD ["celery", "-A", "worker", "worker", "--loglevel=info"]