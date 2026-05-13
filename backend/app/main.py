import os
import ssl
import certifi

# Fix SSL certificate verification for local development.
# This ensures Python uses the correct certificates when calling Plaid's sandbox.
os.environ['SSL_CERT_FILE'] = certifi.where()
os.environ['REQUESTS_CA_BUNDLE'] = certifi.where()
ssl._create_default_https_context = ssl.create_default_context

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.routes import router as plaid_router


def create_app() -> FastAPI:
    application = FastAPI(title="Tally API", version="0.1.0")
    application.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )
    application.include_router(plaid_router)
    return application


app = create_app()