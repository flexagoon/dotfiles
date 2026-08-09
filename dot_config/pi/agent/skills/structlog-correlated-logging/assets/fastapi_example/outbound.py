import httpx
from structlog.contextvars import get_contextvars


async def call_inventory(
    client: httpx.AsyncClient,
    url: str,
) -> httpx.Response:
    request_id = get_contextvars().get("request_id")
    headers = {"X-Request-ID": str(request_id)} if request_id else {}
    return await client.get(url, headers=headers)
