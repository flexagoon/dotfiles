import os

from asgi_correlation_id import CorrelationIdMiddleware
from fastapi import FastAPI

from .logging import setup_logging

DEBUG = os.getenv("DEBUG", "").lower() in {"1", "true", "yes"}

app = FastAPI(title="Example API")
setup_logging(app, debug=DEBUG)
app.add_middleware(CorrelationIdMiddleware, header_name="X-Request-ID")
