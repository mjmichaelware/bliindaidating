import os
import json
import re
import uuid
import logging
from datetime import datetime, timezone
from typing import Optional, List, Dict, Any

from fastapi import FastAPI, Request, HTTPException
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv

# --- Load environment variables FIRST ---
load_dotenv()

# --- Python Standard Logging ---
logging.basicConfig(level=logging.DEBUG, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# --- Google Generative AI Imports ---
import google.generativeai as genai

# --- Supabase Imports ---
from supabase import create_client, Client

# --- API Key and Supabase Configuration ---
GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY")
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_SERVICE_ROLE_KEY = os.getenv("SUPABASE_SERVICE_ROLE_KEY")

if not GOOGLE_API_KEY:
    logger.error("GOOGLE_API_KEY not set. Gemini API will not function.")
if not SUPABASE_URL or not SUPABASE_SERVICE_ROLE_KEY:
    logger.error("Supabase URL or Service Role Key not set. Supabase client may not function.")

# Initialize Gemini Model
model = None
try:
    if GOOGLE_API_KEY:
        genai.configure(api_key=GOOGLE_API_KEY)
        model = genai.GenerativeModel('gemini-1.5-flash')
        logger.info("Gemini API configured successfully with 'gemini-1.5-flash'.")
    else:
        logger.warning("Gemini API Key is missing. Gemini model will not be initialized.")
except Exception as e:
    logger.error(f"Error configuring Gemini API: {e}", exc_info=True)

# Initialize Supabase Client
supabase: Optional[Client] = None
try:
    if SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY:
        supabase = create_client(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)
        logger.info("Supabase client configured successfully.")
    else:
        logger.warning("Supabase client not initialized due to missing URL or Service Role Key.")
except Exception as e:
    logger.error(f"Error configuring Supabase client: {e}", exc_info=True)

# --- FastAPI App Initialization ---
app = FastAPI(
    title="Dating App AI Backend",
    description="Backend for generating dating profiles, news feed content, and daily prompts.",
    version="0.1.0"
)

# -----------------------------------------------------------------------------
# CORS Configuration (Nuclear Fix)
# -----------------------------------------------------------------------------
# This configuration is the most permissive possible, allowing all origins, methods, and headers.
# Use this for debugging to confirm CORS is the ONLY issue.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
logger.info("CORS policy set to a permissive wildcard ('*').")
# -----------------------------------------------------------------------------

# --- Pydantic Models for Request Bodies ---
class GenerateProfileRequest(BaseModel):
    user_data: Dict[str, str]
    prompt_instructions: Optional[str] = None

class RecentActivityItem(BaseModel):
    action: str
    profile_name: str

class GenerateNewsFeedRequest(BaseModel):
    user_profile_summary: str
    recent_activity: List[RecentActivityItem]
    num_items: int = 3

class GenerateDailyPromptRequest(BaseModel):
    context: Optional[str] = None

class GenerateDummyUsersRequest(BaseModel):
    count: int = Field(5, ge=1, le=50)

class GenerateMatchesRequest(BaseModel):
    user_profile_summary: str
    num_matches: int = Field(3, ge=1, le=10)

class GenerateDatesRequest(BaseModel):
    user_profile_summary: str
    num_dates: int = Field(3, ge=1, le=10)

# --- LLM Utility Function (using Google Gemini Pro API) ---
def generate_text_with_llm(prompt_text: str, max_new_tokens: int = 500, response_schema: Optional[Dict[str, Any]] = None) -> Optional[str]:
    """
    Generates text using the Google Gemini Pro model via API.
    """
    logger.debug("--- LLM Utility Function Call ---")
    if model is None:
        logger.error("Gemini model not initialized. Cannot generate text.")
        return None

    logger.debug(f"Sending prompt to Gemini (first 200 chars): '{prompt_text[:200]}...'")
    try:
        generation_config_params = {
            "candidate_count": 1,
            "stop_sequences": [],
            "max_output_tokens": max_new_tokens,
            "temperature": 0.7,
            "top_p": 0.9,
        }

        if response_schema:
            generation_config_params["response_mime_type"] = "application/json"
            prompt_text += f"\n\nStrictly adhere to this JSON schema for your response: {json.dumps(response_schema, indent=2)}"

        response = model.generate_content(
            prompt_text,
            generation_config=genai.types.GenerationConfig(**generation_config_params)
        )

        if not response.candidates:
            logger.warning("Gemini API returned no candidates.")
            return None

        generated_text = response.candidates[0].content.parts[0].text.strip()
        logger.info(f"Gemini generated content (first 200 chars): '{generated_text[:200]}...'")

        # Remove markdown code fences
        generated_text = generated_text.strip("` \n")
        if generated_text.startswith("json\n"):
            generated_text = generated_text[5:]
        
        return generated_text
    except Exception as e:
        logger.error(f"Error generating text with Gemini API: {e}", exc_info=True)
        return None

# --- FastAPI Endpoints ---

@app.post("/generate-profile/")
async def generate_profile(request: GenerateProfileRequest, http_request: Request):
    logger.info(f"Received POST request to /generate-profile/ from {http_request.client.host}")
    user_data_str = ", ".join([f"{k}: {v}" for k, v in request.user_data.items()])
    prompt = f"Create a compelling dating profile bio based on the following user data: {user_data_str}. "
    if request.prompt_instructions:
        prompt += f"Additionally, follow these instructions: {request.prompt_instructions}. "
    prompt += "The profile should be engaging, positive, and highlight unique qualities. Keep it concise."
    generated_text = generate_text_with_llm(prompt, max_new_tokens=200)

    if generated_text:
        return JSONResponse(content={"profile_bio": generated_text})
    else:
        raise HTTPException(status_code=500, detail="Failed to generate profile bio")

@app.post("/generate-news-feed/")
async def generate_news_feed(request: GenerateNewsFeedRequest, http_request: Request):
    logger.info(f"Received POST request to /generate-news-feed/ from {http_request.client.host}")
    recent_activity_dicts = [item.dict() for item in request.recent_activity]
    recent_activity_json = json.dumps(recent_activity_dicts)
    prompt = f"Based on the user's profile summary: \"{request.user_profile_summary}\"\n" \
             f"And recent activities: {recent_activity_json}\n" \
             f"Generate {request.num_items} engaging and personalized news feed items. " \
             "Each item should be short, distinct, and relevant to dating app context. " \
             "Format as a JSON list of strings."
    generated_json_str = generate_text_with_llm(prompt, max_new_tokens=request.num_items * 50)

    if generated_json_str:
        try:
            news_feed_items = json.loads(generated_json_str)
            if not isinstance(news_feed_items, list):
                news_feed_items = re.findall(r"['\"]([^'\"]+)['\"]", generated_json_str)
                if not news_feed_items:
                    raise ValueError("LLM did not return a valid JSON list.")
            return JSONResponse(content={"news_feed_items": news_feed_items})
        except (json.JSONDecodeError, ValueError) as e:
            logger.error(f"Failed to parse JSON for news feed: {e}. Raw: {generated_json_str}")
            raise HTTPException(status_code=500, detail="Failed to generate valid news feed items.")
    else:
        raise HTTPException(status_code=500, detail="Failed to generate news feed items.")

@app.post("/generate-daily-prompt/")
async def generate_daily_prompt(request: GenerateDailyPromptRequest, http_request: Request):
    logger.info(f"Received POST request to /generate-daily-prompt/ from {http_request.client.host}")
    prompt = "Generate a short, engaging, and thought-provoking daily question or prompt for a dating app user to answer. " \
             "It should encourage self-reflection or spark conversation."
    if request.context:
        prompt += f" Consider the following context: {request.context}."
    prompt += " Example: 'What's one small thing that always makes your day better?'"
    generated_text = generate_text_with_llm(prompt, max_new_tokens=50)

    if generated_text:
        return JSONResponse(content={"daily_prompt": generated_text})
    else:
        raise HTTPException(status_code=500, detail="Failed to generate daily prompt")

@app.post("/generate-dummy-users/")
async def generate_dummy_users(request: GenerateDummyUsersRequest, http_request: Request):
    logger.info(f"Received POST request to /generate-dummy-users/ from {http_request.client.host} for {request.count} users.")
    if supabase is None:
        raise HTTPException(status_code=500, detail="Supabase connection not available")

    prompt = f"""Generate {request.count} diverse and realistic user profiles for a dating application.
    Each profile should be a JSON object with keys in snake_case to match the Supabase table.
    For 'id', generate a valid UUID.
    For 'email', generate a unique dummy email (e.g., 'user_name_123@example.com').
    'created_at' and 'updated_at' should be current UTC timestamps in ISO 8601 format.
    The response must be a single JSON array of objects.
    """
    
    generated_json_str = generate_text_with_llm(prompt, max_new_tokens=request.count * 1000)

    if not generated_json_str:
        raise HTTPException(status_code=500, detail="AI failed to generate user data")

    try:
        raw_profiles = json.loads(generated_json_str)
        if not isinstance(raw_profiles, list):
            raise ValueError("AI returned malformed data (not a list)")

        profiles_to_insert = []
        for profile_data in raw_profiles:
            profile_data['id'] = str(uuid.uuid4())
            profile_data['created_at'] = datetime.now(timezone.utc).isoformat()
            profile_data['updated_at'] = datetime.now(timezone.utc).isoformat()
            profiles_to_insert.append(profile_data)
        
        response = supabase.table('user_profiles').insert(profiles_to_insert).execute()
        
        if response.data:
            return JSONResponse(content={"message": f"Successfully generated and inserted {len(response.data)} dummy users"}, status_code=200)
        else:
            raise HTTPException(status_code=500, detail=f"Failed to insert users into Supabase: {response.error.message}")
    except (json.JSONDecodeError, ValueError) as e:
        logger.error(f"Error processing AI response for dummy users: {e}. Raw response: {generated_json_str}")
        raise HTTPException(status_code=500, detail="Failed to parse AI response JSON")

@app.post("/generate-ai-matches/")
async def generate_ai_matches(request: GenerateMatchesRequest, http_request: Request):
    logger.info(f"Received POST request to /generate-ai-matches/ from {http_request.client.host}")
    match_schema = {
        "type": "ARRAY",
        "items": {
            "type": "OBJECT",
            "properties": {
                "profile_name": {"type": "STRING"},
                "reason": {"type": "STRING"},
            },
            "required": ["profile_name", "reason"]
        }
    }
    prompt = f"Based on the user's profile summary: \"{request.user_profile_summary}\"\n" \
             f"Generate {request.num_matches} highly compatible, personalized dating matches. " \
             "Provide a name and a compelling, creative reason for each match. " \
             "The response must be a single JSON array of objects, strictly following this schema."
    generated_json_str = generate_text_with_llm(prompt, max_new_tokens=request.num_matches * 100)

    if generated_json_str:
        try:
            matches = json.loads(generated_json_str)
            if not isinstance(matches, list):
                raise ValueError("LLM did not return a JSON list.")
            for match in matches:
                match['match_id'] = str(uuid.uuid4())
            return JSONResponse(content={"matches": matches})
        except (json.JSONDecodeError, ValueError) as e:
            logger.error(f"Failed to parse JSON for matches: {e}. Raw: {generated_json_str}")
            raise HTTPException(status_code=500, detail="Failed to parse AI response JSON for matches")
    else:
        raise HTTPException(status_code=500, detail="Failed to generate AI matches")

@app.post("/generate-ai-dates/")
async def generate_ai_dates(request: GenerateDatesRequest, http_request: Request):
    logger.info(f"Received POST request to /generate-ai-dates/ from {http_request.client.host}")
    date_schema = {
        "type": "ARRAY",
        "items": {
            "type": "OBJECT",
            "properties": {
                "date_idea": {"type": "STRING"},
                "details": {"type": "STRING"},
            },
            "required": ["date_idea", "details"]
        }
    }
    prompt = f"Based on the user's profile summary: \"{request.user_profile_summary}\"\n" \
             f"Generate {request.num_dates} creative and personalized date ideas. " \
             "For each idea, provide a short title and a one-sentence description. " \
             "The response must be a single JSON array of objects, strictly following this schema."
    generated_json_str = generate_text_with_llm(prompt, max_new_tokens=request.num_dates * 100)

    if generated_json_str:
        try:
            dates = json.loads(generated_json_str)
            if not isinstance(dates, list):
                raise ValueError("LLM did not return a JSON list.")
            for date in dates:
                date['date_id'] = str(uuid.uuid4())
            return JSONResponse(content={"dates": dates})
        except (json.JSONDecodeError, ValueError) as e:
            logger.error(f"Failed to parse JSON for dates: {e}. Raw: {generated_json_str}")
            raise HTTPException(status_code=500, detail="Failed to parse AI response JSON for dates")
    else:
        raise HTTPException(status_code=500, detail="Failed to generate AI date ideas")

        