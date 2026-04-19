from fastapi import APIRouter, Depends, HTTPException

from app.api.dependencies import get_plaid_service
from app.dto.plaid import (
    ExchangePublicTokenRequestDTO,
    ExchangePublicTokenResponseDTO,
    LinkTokenCreateRequestDTO,
    LinkTokenCreateResponseDTO,
)
from app.services.plaid_service import PlaidService

router = APIRouter(prefix="/api")


@router.post("/create_link_token", response_model=LinkTokenCreateResponseDTO)
def create_link_token(
    body: LinkTokenCreateRequestDTO,
    service: PlaidService = Depends(get_plaid_service),
) -> LinkTokenCreateResponseDTO:
    try:
        return service.create_link_token(body)
    except Exception as e:
        raise HTTPException(status_code=502, detail=str(e)) from e


@router.post("/exchange_public_token", response_model=ExchangePublicTokenResponseDTO)
def exchange_public_token(
    body: ExchangePublicTokenRequestDTO,
    service: PlaidService = Depends(get_plaid_service),
) -> ExchangePublicTokenResponseDTO:
    try:
        return service.exchange_public_token(body)
    except Exception as e:
        raise HTTPException(status_code=502, detail=str(e)) from e
