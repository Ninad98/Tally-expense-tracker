from app.config import get_settings
from app.dao.plaid_dao import PlaidDAO
from app.services.plaid_service import PlaidService
from app.services.plaid_token_store import PlaidTokenStore


_plaid_service: PlaidService | None = None


def get_plaid_service() -> PlaidService:
    global _plaid_service
    if _plaid_service is None:
        settings = get_settings()
        settings.validate_plaid_credentials()
        _plaid_service = PlaidService(
            PlaidDAO(settings),
            PlaidTokenStore(),
        )
    return _plaid_service
