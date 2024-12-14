FROM almalinux:8

EXPOSE 8000

RUN dnf install -y libpq postgresql && dnf clean all
RUN curl -LsSf https://astral.sh/uv/install.sh | UV_INSTALL_DIR=/usr/bin sh

COPY . /app
WORKDIR /app

RUN uv sync --no-cache && uv run -s manage.py collectstatic --noinput

ENTRYPOINT ["/app/entrypoint.sh"]
