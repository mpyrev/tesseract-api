from io import BytesIO

from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.responses import JSONResponse
from PIL import Image, ImageFilter
import pytesseract

app = FastAPI()


@app.post("/solve")
async def solve(file: UploadFile = File(...)):
    try:
        content = await file.read()
        image = Image.open(BytesIO(content))
        # Convert to grayscale to improve OCR on simple captchas
        image = image.convert("L")
        # Denoise: apply a small median filter to remove pepper noise, then binarize
        image = image.filter(ImageFilter.MedianFilter(size=3))
        # Threshold: keep near-white as white, darker as black (tune 180-220 as needed)
        image = image.point(lambda p: 255 if p > 200 else 0)
        # Perform OCR
        text = pytesseract.image_to_string(image)
        # Trim whitespace and newlines
        text = text.strip()
        return JSONResponse({"text": text})
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to process image: {e}")


if __name__ == '__main__':
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
