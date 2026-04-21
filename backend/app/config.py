import os
from dataclasses import dataclass

from dotenv import load_dotenv

load_dotenv()


@dataclass(frozen=True)
class Settings:
    plaid_client_id: str
    plaid_secret: str
    plaid_env: str

    @property
    def plaid_api_host(self) -> str:
        return "https://sandbox.plaid.com"

    @classmethod
    def from_env(cls) -> "Settings":
        return cls(
            plaid_client_id=os.getenv("PLAID_CLIENT_ID", "").strip(),
            plaid_secret=os.getenv("PLAID_SECRET", "").strip(),
            plaid_env=os.getenv("PLAID_ENV", "sandbox").strip().lower(),
        )

    def validate_plaid_credentials(self) -> None:
        if not self.plaid_client_id or not self.plaid_secret:
            raise ValueError(
                "Missing PLAID_CLIENT_ID or PLAID_SECRET. "
                "Copy backend/.env.example to backend/.env and fill in keys."
            )


def get_settings() -> Settings:
    return Settings.from_env()
