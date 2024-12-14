FROM almalinux:8

EXPOSE 8000

COPY . /app
WORKDIR /app

RUN dnf install -y libpq && dnf clean all
RUN curl -LsSf https://astral.sh/uv/install.sh | UV_INSTALL_DIR=/usr/bin sh
RUN uv sync --no-cache

CMD ["uv", "run", "-m", "gunicorn", "project.wsgi"]
