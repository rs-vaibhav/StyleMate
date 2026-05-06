import os
import uuid
import asyncio
from typing import List
from fastapi import FastAPI, UploadFile, File, BackgroundTasks, HTTPException
from fastapi.responses import JSONResponse
from pydantic import BaseModel

app = FastAPI(title="StyleMate VTON Backend", version="1.0.0")

# In-memory job store for demo purposes. 
# In production, use Redis or a database.
JOBS = {}

class JobStatus(BaseModel):
    job_id: str
    status: str
    usdz_url: str | None = None
    error: str | None = None

UPLOAD_DIR = "uploads"
OUTPUT_DIR = "outputs"

os.makedirs(UPLOAD_DIR, exist_ok=True)
os.makedirs(OUTPUT_DIR, exist_ok=True)

from pipeline import process_images_pipeline

# Mocked heavy processing function
async def process_images(job_id: str, image_paths: List[str]):
    try:
        JOBS[job_id]["status"] = "processing"
        
        # Call the pipeline
        usdz_path = await process_images_pipeline(job_id, image_paths, OUTPUT_DIR)
        usdz_filename = os.path.basename(usdz_path)
            
        JOBS[job_id]["status"] = "completed"
        JOBS[job_id]["usdz_url"] = f"/download/{usdz_filename}"
        
    except Exception as e:
        JOBS[job_id]["status"] = "failed"
        JOBS[job_id]["error"] = str(e)


@app.post("/generate_avatar", response_model=JobStatus)
async def generate_avatar(
    background_tasks: BackgroundTasks,
    front: UploadFile = File(...),
    back: UploadFile = File(None),
    left: UploadFile = File(None),
    right: UploadFile = File(None)
):
    """
    Accepts up to 4 images (front, back, left, right) and queues a job to generate a 3D avatar.
    Returns a job_id to poll for the result.
    """
    job_id = str(uuid.uuid4())
    
    # Save the uploaded files
    image_paths = []
    for name, file_obj in [("front", front), ("back", back), ("left", left), ("right", right)]:
        if file_obj:
            content = await file_obj.read()
            ext = file_obj.filename.split('.')[-1] if '.' in file_obj.filename else 'jpg'
            path = os.path.join(UPLOAD_DIR, f"{job_id}_{name}.{ext}")
            with open(path, "wb") as f:
                f.write(content)
            image_paths.append(path)
            
    if not image_paths:
        raise HTTPException(status_code=400, detail="At least one image (front) must be provided.")
        
    JOBS[job_id] = {"status": "queued", "job_id": job_id, "usdz_url": None, "error": None}
    
    # Queue the background processing task
    background_tasks.add_task(process_images, job_id, image_paths)
    
    return JSONResponse(status_code=202, content=JOBS[job_id])

@app.get("/status/{job_id}", response_model=JobStatus)
async def get_status(job_id: str):
    """
    Check the status of a previously queued avatar generation job.
    """
    if job_id not in JOBS:
        raise HTTPException(status_code=404, detail="Job not found")
        
    return JOBS[job_id]

@app.get("/download/{filename}")
async def download_file(filename: str):
    """
    Download the generated USDZ file.
    """
    file_path = os.path.join(OUTPUT_DIR, filename)
    if not os.path.exists(file_path):
        raise HTTPException(status_code=404, detail="File not found")
        
    from fastapi.responses import FileResponse
    return FileResponse(path=file_path, filename=filename, media_type="model/vnd.usdz+zip")
