from typing import Protocol

import httpx
from structlog.contextvars import bind_contextvars, get_contextvars


class Customer(Protocol):
    id: str
    plan: str
    account_age_days: int


class CustomerRepository(Protocol):
    async def get_customer(self, customer_id: str) -> Customer: ...


async def load_customer(
    customer_id: str,
    repository: CustomerRepository,
) -> Customer:
    customer = await repository.get_customer(customer_id)
    bind_contextvars(
        customer={
            "id": customer.id,
            "plan": customer.plan,
            "account_age_days": customer.account_age_days,
        }
    )
    return customer


async def call_inventory(
    client: httpx.AsyncClient,
    url: str,
) -> httpx.Response:
    request_id = get_contextvars().get("request_id")
    headers = {"X-Request-ID": str(request_id)} if request_id else {}
    return await client.get(url, headers=headers)
