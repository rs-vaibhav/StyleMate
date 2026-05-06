import requests
import time
from PIL import Image
import numpy as np

# Create a dummy image
img = Image.fromarray(np.random.randint(0, 255, (100, 100, 3), dtype=np.uint8))
img.save("dummy_front.jpg")

url = "http://127.0.0.1:8000/generate_avatar"

files = {
    'front': open('dummy_front.jpg', 'rb')
}

print("Submitting job...")
response = requests.post(url, files=files)
if response.status_code == 202:
    job_info = response.json()
    job_id = job_info["job_id"]
    print(f"Job queued: {job_id}")
    
    # Poll status
    while True:
        status_url = f"http://127.0.0.1:8000/status/{job_id}"
        status_res = requests.get(status_url)
        if status_res.status_code == 200:
            status_data = status_res.json()
            print(f"Status: {status_data['status']}")
            if status_data['status'] == 'completed':
                print(f"Success! Download URL: {status_data['usdz_url']}")
                break
            elif status_data['status'] == 'failed':
                print(f"Failed: {status_data['error']}")
                break
        time.sleep(2)
else:
    print(f"Error submitting job: {response.text}")
