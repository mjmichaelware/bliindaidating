import os
import json
import re
import uvicorn
import uuid
from datetime import datetime, timezone
from fastapi import FastAPI, Request, HTTPException
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv

# --- Load environment variables FIRST ---
load_dotenv() # This MUST be called early to load .env file contents

# --- Python Standard Logging ---
import logging

# Configure logging to be very verbose for debugging
logging.basicConfig(level=logging.DEBUG, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# --- Google Generative AI Imports ---
import google.generativeai as genai

# --- Supabase Imports ---
from supabase import create_client, Client

# --- API Key and Supabase Configuration ---
# Retrieve keys from environment variables.
GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY")
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_SERVICE_ROLE_KEY = os.getenv("SUPABASE_SERVICE_ROLE_KEY")

# --- Debugging: Print the key value (for development only, remove in production) ---
logger.info(f"Attempting to configure Gemini with key: {'(key present)' if GOOGLE_API_KEY else '(key missing)'}")

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
        logger.info("Supabase client configured successfully (using default schema).")
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
# CORS Configuration - THIS IS THE FIX
# -----------------------------------------------------------------------------
# This middleware allows your frontend running on one port to make requests
# to this backend on another. You must include your specific Codespaces URLs.
origins = [
    "http://localhost:3000",
    "http://127.0.0.1:3000",
    os.getenv("FRONTEND_URL", "https://fantastic-couscous-r4x67996r9p7cxx9g-3000.app.github.dev"),
    os.getenv("BACKEND_URL", "https://fantastic-couscous-r4x67996r9p7cxx9g-8000.app.github.dev")
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], # Allow all origins for dev environment.
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- Pydantic Models for Request Bodies ---
class GenerateProfileRequest(BaseModel):
    user_data: Dict[str, str]
    prompt_instructions: Optional[str] = None

# ADDED a more specific Pydantic model for the recent activity list items
class RecentActivityItem(BaseModel):
    action: str
    profile_name: str

class GenerateNewsFeedRequest(BaseModel):
    user_profile_summary: str
    # UPDATED the recent_activity field to use the new, more specific model
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
    Generates text using the Google Gemini Pro model via API, optionally with a JSON schema.
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
            # The API's response_schema parameter is for text-to-json generation.
            # Your current implementation in the prompt is for unstructured text followed by JSON.
            # Let's adjust the prompt to explicitly request JSON output.
            prompt_text += f"\n\nStrictly adhere to this JSON schema for your response: {json.dumps(response_schema, indent=2)}"

        logger.debug(f"Final prompt for LLM: {prompt_text}")
        logger.debug(f"Generation config: {generation_config_params}")

        response = model.generate_content(
            prompt_text,
            generation_config=genai.types.GenerationConfig(**generation_config_params)
        )

        logger.debug(f"Full Gemini response object: {response}")

        if not response.candidates:
            logger.warning("Gemini API returned no candidates.")
            return None

        first_candidate = response.candidates[0]
        if not first_candidate.content or not first_candidate.content.parts:
            logger.warning("Gemini API candidate has no content or parts.")
            return None

        generated_text = first_candidate.content.parts[0].text.strip()
        logger.info(f"Gemini generated content (first 200 chars): '{generated_text[:200]}...'")

        # --- NEW CODE START ---
        # Remove markdown code fences if they exist
        if generated_text.startswith("```json"):
            generated_text = generated_text.replace("```json", "", 1)
        if generated_text.endswith("```"):
            generated_text = generated_text.rstrip("```").strip()
        # --- NEW CODE END ---

        return generated_text
    except Exception as e:
        logger.error(f"Error generating text with Gemini API: {e}", exc_info=True)
        if "RESOURCE_EXHAUSTED" in str(e):
            logger.error("Gemini API Rate Limit Exceeded. Please check your quota.")
        elif "PERMISSION_DENIED" in str(e) or "API key not valid" in str(e):
            logger.error("Gemini API Key is invalid or lacks necessary permissions.")
        return None

# --- FastAPI Endpoints ---

@app.post("/generate-profile/")
async def generate_profile(request: GenerateProfileRequest, http_request: Request):
    logger.info(f"Received POST request to /generate-profile/ from {http_request.client.host}")
    logger.debug(f"Request body: {request.dict()}")

    user_data_str = ", ".join([f"{k}: {v}" for k, v in request.user_data.items()])

    prompt = f"Create a compelling dating profile bio based on the following user data: {user_data_str}. "
    if request.prompt_instructions:
        prompt += f"Additionally, follow these instructions: {request.prompt_instructions}. "
    prompt += "The profile should be engaging, positive, and highlight unique qualities. Keep it concise."

    logger.debug(f"Constructed prompt for profile generation: {prompt}")

    generated_text = generate_text_with_llm(prompt, max_new_tokens=200)

    if generated_text:
        logger.info("Successfully generated profile bio.")
        return JSONResponse(content={"profile_bio": generated_text})
    else:
        logger.error("Failed to generate profile bio. Returning 500 error.")
        raise HTTPException(status_code=500, detail="Failed to generate profile bio")

@app.post("/generate-news-feed/")
async def generate_news_feed(request: GenerateNewsFeedRequest, http_request: Request):
    logger.info(f"Received POST request to /generate-news-feed/ from {http_request.client.host}")
    logger.debug(f"Request body: {request.dict()}")

    # The request.recent_activity is now a list of RecentActivityItem objects
    # We need to convert it to a list of dicts for the json.dumps
    recent_activity_dicts = [item.dict() for item in request.recent_activity]
    recent_activity_json = json.dumps(recent_activity_dicts)

    prompt = f"Based on the user's profile summary: \"{request.user_profile_summary}\"\n" \
             f"And recent activities: {recent_activity_json}\n" \
             f"Generate {request.num_items} engaging and personalized news feed items. " \
             "Each item should be short, distinct, and relevant to dating app context (e.g., 'X liked Y photo', 'New match with Z', 'A new event nearby'). " \
             "Format as a JSON list of strings, e.g., ['Item 1', 'Item 2']. The response should only contain the JSON list."

    logger.debug(f"Constructed prompt for news feed generation (first 200 chars): {prompt[:200]}...")

    generated_json_str = generate_text_with_llm(prompt, max_new_tokens=request.num_items * 50)

    if generated_json_str:
        logger.debug(f"Raw JSON string from LLM: {generated_json_str}")
        try:
            news_feed_items = json.loads(generated_json_str)
            if not isinstance(news_feed_items, list):
                logger.warning(f"LLM did not return a JSON list for news feed. Raw response: {generated_json_str}")
                raise ValueError("LLM did not return a JSON list.")
            logger.info(f"Successfully generated and parsed news feed items: {news_feed_items}")
            return JSONResponse(content={"news_feed_items": news_feed_items})
        except json.JSONDecodeError as e:
            logger.error(f"Failed to parse JSON from LLM for news feed: {e}. Raw response: {generated_json_str}", exc_info=True)
            # Regex fallback
            items = re.findall(r"['\"]([^'\"]+)['\"]", generated_json_str)
            if items:
                logger.info(f"Extracted news feed items using regex fallback: {items}")
                return JSONResponse(content={"news_feed_items": items})
            logger.error("Failed to extract any items even with regex fallback for news feed.")
            raise HTTPException(status_code=500, detail="Failed to generate valid news feed items (JSON parse error or malformed)")
    else:
        logger.error("Failed to generate news feed items. Returning 500 error.")
        raise HTTPException(status_code=500, detail="Failed to generate news feed items")


@app.post("/generate-daily-prompt/")
async def generate_daily_prompt(request: GenerateDailyPromptRequest, http_request: Request):
    logger.info(f"Received POST request to /generate-daily-prompt/ from {http_request.client.host}")
    logger.debug(f"Request body: {request.dict()}")

    prompt = "Generate a short, engaging, and thought-provoking daily question or prompt for a dating app user to answer. " \
             "It should encourage self-reflection or spark conversation."
    if request.context:
        prompt += f" Consider the following context: {request.context}."
    prompt += " Example: 'What's one small thing that always makes your day better?'"

    logger.debug(f"Constructed prompt for daily prompt generation: {prompt}")

    generated_text = generate_text_with_llm(prompt, max_new_tokens=50)

    if generated_text:
        logger.info(f"Successfully generated daily prompt: {generated_text}")
        return JSONResponse(content={"daily_prompt": generated_text})
    else:
        logger.error("Failed to generate daily prompt. Returning 500 error.")
        raise HTTPException(status_code=500, detail="Failed to generate daily prompt")


@app.post("/generate-dummy-users/")
async def generate_dummy_users(request: GenerateDummyUsersRequest, http_request: Request):
    logger.info(f"Received POST request to /generate-dummy-users/ from {http_request.client.host} for {request.count} users.")
    logger.debug(f"Request body: {request.dict()}")
    if supabase is None:
        logger.error("Supabase client not initialized. Cannot save dummy users.")
        raise HTTPException(status_code=500, detail="Supabase connection not available")

    user_profile_schema = {
        "type": "ARRAY",
        "items": {
            "type": "OBJECT",
            "properties": {
                "email": {"type": "STRING", "description": "Unique dummy email address"},
                "display_name": {"type": "STRING", "description": "A display name"},
                "bio": {"type": "STRING", "description": "A short, engaging bio"},
                "looking_for": {"type": "STRING"},
                "profile_picture_url": {"type": "STRING"},
                "date_of_birth": {"type": "STRING", "format": "date"},
                "phone_number": {"type": "STRING"},
                "location_zip_code": {"type": "STRING"},
                "sexual_orientation": {"type": "STRING"},
                "height_cm": {"type": "NUMBER"},
                "agreed_to_terms": {"type": "BOOLEAN"},
                "agreed_to_community_guidelines": {"type": "BOOLEAN"},
                "full_legal_name": {"type": "STRING"},
                "gender_identity": {"type": "STRING"},
                "ethnicity": {"type": "STRING"},
                "languages_spoken": {"type": "ARRAY", "items": {"type": "STRING"}},
                "desired_occupation": {"type": "STRING"},
                "education_level": {"type": "STRING"},
                "hobbies_and_interests": {"type": "ARRAY", "items": {"type": "STRING"}},
                "love_languages": {"type": "ARRAY", "items": {"type": "STRING"}},
                "favorite_media": {"type": "ARRAY", "items": {"type": "STRING"}},
                "marital_status": {"type": "STRING"},
                "has_children": {"type": "BOOLEAN"},
                "wants_children": {"type": "BOOLEAN"},
                "relationship_goals": {"type": "STRING"},
                "dealbreakers": {"type": "ARRAY", "items": {"type": "STRING"}},
                "religion_or_spiritual_beliefs": {"type": "STRING"},
                "political_views": {"type": "STRING"},
                "diet": {"type": "STRING"},
                "smoking_habits": {"type": "STRING"},
                "drinking_habits": {"type": "STRING"},
                "exercise_frequency_or_fitness_level": {"type": "STRING"},
                "sleep_schedule": {"type": "STRING"},
                "personality_traits": {"type": "ARRAY", "items": {"type": "STRING"}},
                "willing_to_relocate": {"type": "BOOLEAN"},
                "monogamy_vs_polyamory_preferences": {"type": "STRING"},
                "astrological_sign": {"type": "STRING"},
                "attachment_style": {"type": "STRING"},
                "communication_style": {"type": "STRING"},
                "mental_health_disclosures": {"type": "STRING"},
                "pet_ownership": {"type": "STRING"},
                "travel_frequency_or_favorite_destinations": {"type": "STRING"},
                "profile_visibility_preferences": {"type": "OBJECT"},
                "push_notification_preferences": {"type": "OBJECT"},
                "is_phase_1_complete": {"type": "BOOLEAN"},
                "is_phase_2_complete": {"type": "BOOLEAN"},
                "questionnaire_answers": {"type": "OBJECT"},
                "personality_assessment_results": {"type": "OBJECT"},
            },
            "required": ["email", "display_name", "bio", "profile_picture_url", "date_of_birth", "gender_identity", "hobbies_and_interests"]
        }
    }

    prompt = f"""Generate {request.count} diverse and realistic user profiles for a dating application.
    Each profile should be a JSON object with keys in snake_case to match the Supabase table.
    For 'id', generate a valid UUID.
    For 'email', generate a unique dummy email (e.g., 'user_name_123@example.com').
    'created_at' and 'updated_at' should be current UTC timestamps in ISO 8601 format.
    'agreed_to_terms', 'agreed_to_community_guidelines', 'is_phase_1_complete', 'is_phase_2_complete' should be true.
    For array fields, provide a list of strings.
    For object fields, provide a nested JSON object.
    Ensure all string fields have meaningful, varied content.
    The response must be a single JSON array of objects.
    """

    try:
        generated_json_str = generate_text_with_llm(prompt, max_new_tokens=request.count * 1000)

        if not generated_json_str:
            logger.error("AI did not return any generated JSON for dummy users.")
            raise HTTPException(status_code=500, detail="AI failed to generate user data")

        raw_profiles = json.loads(generated_json_str)
        if not isinstance(raw_profiles, list):
            logger.error(f"AI returned non-list JSON: {generated_json_str}")
            raise HTTPException(status_code=500, detail="AI returned malformed data (not a list)")

        profiles_to_insert = []
        for profile_data in raw_profiles:
            profile_data['id'] = str(uuid.uuid4())
            profile_data['created_at'] = datetime.now(timezone.utc).isoformat()
            profile_data['updated_at'] = datetime.now(timezone.utc).isoformat()
            
            if 'email' not in profile_data or not profile_data['email']:
                 profile_data['email'] = f"dummy_user_{uuid.uuid4().hex[:8]}@example.com"

            # Clean up any extra fields the AI might generate
            valid_keys = set(user_profile_schema["items"]["properties"].keys())
            valid_keys.update(['id', 'created_at', 'updated_at'])
            cleaned_profile_data = {k: v for k, v in profile_data.items() if k in valid_keys}
            profiles_to_insert.append(cleaned_profile_data)
        
        logger.debug(f"Profiles prepared for insertion: {profiles_to_insert}")

        if not profiles_to_insert:
            logger.warning("No valid profiles were parsed from AI response to insert.")
            return JSONResponse(content={"message": "AI generated no valid profiles to insert"}, status_code=200)

        response = supabase.table('user_profiles').insert(profiles_to_insert).execute()
        
        logger.debug(f"Supabase insert response: {response}")

        if response.data:
            logger.info(f"Successfully inserted {len(response.data)} dummy users into Supabase.")
            return JSONResponse(content={"message": f"Successfully generated and inserted {len(response.data)} dummy users"}, status_code=200)
        else:
            logger.error(f"Supabase insert failed: {response.error.message}")
            raise HTTPException(status_code=500, detail=f"Failed to insert users into Supabase: {response.error.message}")

    except json.JSONDecodeError as e:
        logger.error(f"Failed to parse JSON from LLM for dummy users: {e}. Raw response: {generated_json_str}", exc_info=True)
        raise HTTPException(status_code=500, detail="Failed to parse AI response JSON")
    except Exception as e:
        logger.error(f"Error in /generate-dummy-users/ endpoint: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"An unexpected error occurred: {e}")

@app.post("/generate-ai-matches/")
async def generate_ai_matches(request: GenerateMatchesRequest, http_request: Request):
    logger.info(f"Received POST request to /generate-ai-matches/ from {http_request.client.host}")
    logger.debug(f"Request body: {request.dict()}")
    
    match_schema = {
        "type": "ARRAY",
        "items": {
            "type": "OBJECT",
            "properties": {
                "profile_name": {"type": "STRING", "description": "The name of the matched person."},
                "reason": {"type": "STRING", "description": "A short, compelling reason for the match based on the user's profile."},
            },
            "required": ["profile_name", "reason"]
        }
    }
    
    prompt = f"Based on the user's profile summary: \"{request.user_profile_summary}\"\n" \
             f"Generate {request.num_matches} highly compatible, personalized dating matches. " \
             "Provide a name and a compelling, creative reason for each match. " \
             "The response must be a single JSON array of objects, strictly following this schema."
    
    logger.debug(f"Constructed prompt for AI matches: {prompt}")

    generated_json_str = generate_text_with_llm(prompt, max_new_tokens=request.num_matches * 100)

    if generated_json_str:
        logger.debug(f"Raw JSON string from LLM for matches: {generated_json_str}")
        try:
            matches = json.loads(generated_json_str)
            if not isinstance(matches, list):
                logger.warning(f"LLM did not return a JSON list for matches. Raw response: {generated_json_str}")
                raise ValueError("LLM did not return a JSON list.")
            for match in matches:
                match['match_id'] = str(uuid.uuid4())
            logger.info(f"Successfully generated and parsed {len(matches)} AI matches.")
            return JSONResponse(content={"matches": matches})
        except json.JSONDecodeError as e:
            logger.error(f"Failed to parse JSON from LLM for matches: {e}. Raw response: {generated_json_str}", exc_info=True)
            raise HTTPException(status_code=500, detail="Failed to parse AI response JSON for matches")
    else:
        logger.error("Failed to generate AI matches. Returning 500 error.")
        raise HTTPException(status_code=500, detail="Failed to generate AI matches")

@app.post("/generate-ai-dates/")
async def generate_ai_dates(request: GenerateDatesRequest, http_request: Request):
    logger.info(f"Received POST request to /generate-ai-dates/ from {http_request.client.host}")
    logger.debug(f"Request body: {request.dict()}")
    
    date_schema = {
        "type": "ARRAY",
        "items": {
            "type": "OBJECT",
            "properties": {
                "date_idea": {"type": "STRING", "description": "A creative date idea."},
                "details": {"type": "STRING", "description": "A brief, intriguing description of the date idea."},
            },
            "required": ["date_idea", "details"]
        }
    }
    
    prompt = f"Based on the user's profile summary: \"{request.user_profile_summary}\"\n" \
             f"Generate {request.num_dates} creative and personalized date ideas. " \
             "For each idea, provide a short title and a one-sentence description. " \
             "The response must be a single JSON array of objects, strictly following this schema."
    
    logger.debug(f"Constructed prompt for AI dates: {prompt}")
    
    generated_json_str = generate_text_with_llm(prompt, max_new_tokens=request.num_dates * 100)

    if generated_json_str:
        logger.debug(f"Raw JSON string from LLM for dates: {generated_json_str}")
        try:
            dates = json.loads(generated_json_str)
            if not isinstance(dates, list):
                logger.warning(f"LLM did not return a JSON list for dates. Raw response: {generated_json_str}")
                raise ValueError("LLM did not return a JSON list.")
            for date in dates:
                date['date_id'] = str(uuid.uuid4())
            logger.info(f"Successfully generated and parsed {len(dates)} AI date ideas.")
            return JSONResponse(content={"dates": dates})
        except json.JSONDecodeError as e:
            logger.error(f"Failed to parse JSON from LLM for dates: {e}. Raw response: {generated_json_str}", exc_info=True)
            raise HTTPException(status_code=500, detail="Failed to parse AI response JSON for dates")
    else:
        logger.error("Failed to generate AI date ideas. Returning 500 error.")
        raise HTTPException(status_code=500, detail="Failed to generate AI date ideas")