# main.py
import json
import uuid
import datetime
import random
import os
import asyncio
import httpx
from typing import List, Optional

from fastapi import FastAPI, HTTPException, Query
from pydantic import BaseModel

# --- Data Models ---
# Using pydantic to define the structure of our data.
# This provides automatic data validation and documentation.

class User(BaseModel):
    """Represents a user in the dating app."""
    id: str = str(uuid.uuid4())
    username: str
    email: str
    zip_code: str  # New field for user location
    created_at: str = datetime.datetime.now().isoformat()
    ai_profile_summary: Optional[str] = None
    is_ai_generated: bool = False

class NewsFeedPost(BaseModel):
    """Represents a post in the news feed."""
    id: str = str(uuid.uuid4())
    user_id: str
    content: str
    created_at: str = datetime.datetime.now().isoformat()
    is_ai_generated: bool = False

# --- In-memory "Databases" (for demonstration) ---
# In a real-world application, this data would be stored in a persistent database
# like PostgreSQL, MongoDB, or Firestore.
fake_users_db: List[User] = []
fake_news_feed_db: List[NewsFeedPost] = []

# Dummy zip codes for demonstration purposes.
# In a real app, you would use a real API to get this data.
dummy_zip_codes = {
    "90210": {"city": "Beverly Hills", "state": "CA"},
    "90211": {"city": "Beverly Hills", "state": "CA"},
    "10001": {"city": "New York", "state": "NY"},
    "10002": {"city": "New York", "state": "NY"},
    "60601": {"city": "Chicago", "state": "IL"},
    "60602": {"city": "Chicago", "state": "IL"},
}

# --- FastAPI Application ---
app = FastAPI(
    title="BlindAI Dating App Backend",
    description="A backend service for a dating app with AI logic and user management.",
    version="1.0.0"
)

# --- Gemini API Call Function ---
async def call_gemini_api(prompt: str) -> str:
    """
    Calls the Gemini API to generate text based on a given prompt.
    This function uses an asynchronous API call with exponential backoff for retries.
    """
    # The API key is provided by the canvas environment.
    api_key = os.environ.get("GEMINI_API_KEY", "").strip()
    if not api_key:
        raise ValueError("GEMINI_API_KEY environment variable is not set.")

    api_url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-05-20:generateContent?key={api_key}"

    headers = {
        'Content-Type': 'application/json'
    }

    payload = {
        "contents": [
            {
                "role": "user",
                "parts": [
                    {
                        "text": prompt
                    }
                ]
            }
        ]
    }

    # Implement exponential backoff for API calls
    async with httpx.AsyncClient() as client:
        for i in range(3):
            try:
                response = await client.post(api_url, headers=headers, json=payload)
                response.raise_for_status()
                result = response.json()

                if result.get("candidates") and len(result["candidates"]) > 0:
                    first_candidate = result["candidates"][0]
                    if first_candidate.get("content") and first_candidate["content"].get("parts") and len(first_candidate["content"]["parts"]) > 0:
                        return first_candidate["content"]["parts"][0].get("text", "").strip()
                
                raise ValueError("Unexpected API response structure or no content.")

            except (httpx.HTTPError, ValueError) as e:
                print(f"Attempt {i + 1} failed: {e}")
                if i < 2:
                    await asyncio.sleep(2 ** i)  # Exponential backoff
                else:
                    raise HTTPException(status_code=500, detail=f"All API call retries failed: {e}")
    
    return "" # Should be unreachable

# --- Helper Functions ---

# In a real-world application, this would be an API call to a service like ZipCodeAPI
# to calculate the distance between two zip codes.
def check_radius_for_zip_code(zip_code_a: str, zip_code_b: str, radius: int) -> bool:
    """
    Simulates a radius check for two zip codes.
    For this example, it's a simple check. In a real app, it would use an external
    API to get the distance between the two zip codes and compare it to the radius.
    """
    if zip_code_a in dummy_zip_codes and zip_code_b in dummy_zip_codes:
        # For simplicity, we consider zip codes from the same city to be within a 20-mile radius.
        if dummy_zip_codes[zip_code_a]["city"] == dummy_zip_codes[zip_code_b]["city"]:
            # Hardcoded to be true if they are in the same city.
            # You would replace this logic with an actual distance calculation.
            return True
    return False

# --- API Endpoints ---

@app.get("/", tags=["Home"])
async def read_root():
    """Confirms the API is running."""
    return {"message": "Hello, World! Your FastAPI app is running."}

@app.post("/users/generate-and-create-dummy-user", response_model=User, tags=["Users"])
async def generate_and_create_dummy_user():
    """
    Generates a new dummy user with a random name, email, zip code, and an AI-generated profile summary.
    """
    try:
        # 1. Generate a random username and email
        dummy_names = ["Alex", "Jordan", "Taylor", "Morgan", "Casey", "Sam", "Jamie"]
        username = f"{random.choice(dummy_names)}{uuid.uuid4().hex[:6]}"
        email = f"{username.lower()}@example.com"
        
        # 2. Select a random zip code from our dummy list
        random_zip_code = random.choice(list(dummy_zip_codes.keys()))

        # 3. Define the prompt for the Gemini API
        prompt = f"Write a short, engaging dating profile summary (2-3 sentences) for a person named {username}. The summary should be fun and friendly, but do not mention a name."
        
        # 4. Call the Gemini API to get the profile summary
        ai_summary = await call_gemini_api(prompt)

        # 5. Create a new user object with the generated data
        new_user = User(
            username=username,
            email=email,
            zip_code=random_zip_code,  # Assign the random zip code
            ai_profile_summary=ai_summary.strip(),
            is_ai_generated=True
        )

        # 6. Add the new user to our in-memory database
        fake_users_db.append(new_user)
        return new_user

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to generate user profile: {e}")

@app.get("/users", response_model=List[User], tags=["Users"])
async def get_all_users():
    """Retrieves a list of all existing users."""
    return fake_users_db

@app.post("/news-feed/generate-and-create-post", response_model=NewsFeedPost, tags=["News Feed"])
async def generate_and_create_news_feed_post():
    """
    Generates a new AI-powered news feed post and links it to a random existing user.
    """
    if not fake_users_db:
        raise HTTPException(status_code=400, detail="Cannot create a news feed post, no users exist. Create a user first.")

    try:
        # 1. Select a random user to attribute the post to
        random_user = random.choice(fake_users_db)

        # 2. Define the prompt for the Gemini API
        prompt = f"Generate a single short and lighthearted news feed post (1-2 sentences) from the perspective of a user named {random_user.username}. The post should be about something a person might do on a dating app, like a fun date or a hobby."

        # 3. Call the Gemini API to get the post content
        post_content = await call_gemini_api(prompt)

        # 4. Create a new news feed post object
        new_post = NewsFeedPost(
            user_id=random_user.id,
            content=post_content.strip(),
            is_ai_generated=True
        )

        # 5. Add the post to our in-memory database
        fake_news_feed_db.append(new_post)
        return new_post

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to generate news feed post: {e}")

@app.get("/news-feed", response_model=List[NewsFeedPost], tags=["News Feed"])
async def get_news_feed():
    """Retrieves all news feed posts."""
    return fake_news_feed_db

@app.get("/news-feed/filtered", response_model=List[NewsFeedPost], tags=["News Feed"])
async def get_filtered_news_feed(user_id: str = Query(..., description="The user ID to filter posts for."), radius_in_miles: int = Query(20, description="The radius in miles to filter posts by.")):
    """
    Retrieves all news feed posts, filtered by a specific user's location and a given radius.
    """
    # 1. Find the current user and their zip code
    current_user = next((u for u in fake_users_db if u.id == user_id), None)
    if not current_user:
        raise HTTPException(status_code=404, detail="User not found.")

    # 2. Find all users within the specified radius
    users_in_radius = [
        user.id for user in fake_users_db
        if check_radius_for_zip_code(current_user.zip_code, user.zip_code, radius_in_miles)
    ]
    
    # 3. Filter news feed posts to only include those from users in the radius
    filtered_news_feed = [
        post for post in fake_news_feed_db
        if post.user_id in users_in_radius
    ]

    return filtered_news_feed

@app.get("/ai-service/get-profile-summary", tags=["AI Services"])
async def get_profile_summary_from_ai(user_id: str):
    """
    Retrieves the AI-generated profile summary for a given user.
    """
    user = next((u for u in fake_users_db if u.id == user_id), None)
    if not user:
        raise HTTPException(status_code=404, detail="User not found.")

    return {"user_id": user.id, "ai_profile_summary": user.ai_profile_summary}
