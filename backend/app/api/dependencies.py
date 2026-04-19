from app.config import get_settings
from app.dao.plaid_dao import PlaidDAO
from app.services.plaid_service import PlaidService


def get_plaid_service() -> PlaidService:
    settings = get_settings()
    settings.validate_plaid_credentials()
    return PlaidService(PlaidDAO(settings))
