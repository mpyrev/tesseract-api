FROM jitesoft/tesseract-ocr:alpine

# Use root to install packages
USER root

# Install Python, pip, and WebP tools (for some image formats)
RUN apk add --no-cache \
    python3 \
    py3-pip \
    libwebp \
    libwebp-tools

# Drop privileges back to the tesseract user from the base image
USER tesseract

# Create app directory and set permissions for the non-root user provided by base image
WORKDIR /app

# Set up Python virtual environment to avoid PEP 668 externally-managed-environment
ENV VIRTUAL_ENV=/app/.venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Copy only necessary files first to leverage Docker layer caching
COPY pyproject.toml uv.lock ./

# Install Python dependencies into the virtual environment
RUN python -m pip install --no-cache-dir \
    fastapi \
    uvicorn \
    pillow \
    pytesseract \
    python-multipart

# Copy the rest of the application code
COPY . .

ENTRYPOINT []

# Expose the default app port
EXPOSE 8000

# Run the application
CMD ["python3", "main.py"]
