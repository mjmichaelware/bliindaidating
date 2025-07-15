import os
import json
import re
import uvicorn
import uuid
from datetime import datetime, timezone
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any

# --- Load environment variables FIRST ---
from dotenv import load_dotenv
load_dotenv() # This MUST be called early to load .env file contents

# --- Python Standard Logging ---
import logging

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# --- Google Generative AI Imports ---
import google.generativeai as genai

# --- Supabase Imports ---
from supabase import create_client, Client

# --- API Key and Supabase Configuration ---
# Retrieve keys from environment variables.
# If not set, they will use the hardcoded values provided by you for convenience.
# IMPORTANT: Ensure your .env file uses GOOGLE_API_KEY, not GEMINI_API_KEY
GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY", "AIzaSyCoiSj_WtEMy8_K9kZZ4C_wkQtHVvrnd6w")
SUPABASE_URL = os.getenv("SUPABASE_URL", "https://kynzpohycwdphorxsnzy.supabase.co")
SUPABASE_SERVICE_ROLE_KEY = os.getenv("SUPABASE_SERVICE_ROLE_KEY", "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt5bnpwb2h5Y3dkcGhvcnhzbnp5Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1MTMxMDI2MiwiZXhwIjoyMDY2ODg2MjYyfQ.V2wH9lEUVYoYtrNlimXtUsMPHvIEwbU4WfBItApH-VA")

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
        genai.configure(api_key=GOOGLE_API_KEY) # Pass the key explicitly
        model = genai.GenerativeModel('gemini-1.5-flash')
        logger.info("Gemini API configured successfully with 'gemini-1.5-flash'.")
    else:
        logger.warning("Gemini API Key is missing. Gemini model will not be initialized.")
except Exception as e:
    logger.error(f"Error configuring Gemini API: {e}")

# Initialize Supabase Client
supabase: Optional[Client] = None
try:
    if SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY:
        supabase = create_client(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)
        logger.info("Supabase client configured successfully (using default schema).")
    else:
        logger.warning("Supabase client not initialized due to missing URL or Service Role Key.")
except Exception as e:
    logger.error(f"Error configuring Supabase client: {e}")

# --- FastAPI App Initialization ---
app = FastAPI(
    title="Dating App AI Backend",
    description="Backend for generating dating profiles, news feed content, and daily prompts.",
    version="0.1.0"
)

# --- Pydantic Models for Request Bodies ---
class GenerateProfileRequest(BaseModel):
    user_data: Dict[str, str]
    prompt_instructions: Optional[str] = None

class GenerateNewsFeedRequest(BaseModel):
    user_profile_summary: str
    recent_activity: List[Dict[str, Any]]
    num_items: int = 3

class GenerateDailyPromptRequest(BaseModel):
    context: Optional[str] = None

class GenerateDummyUsersRequest(BaseModel):
    count: int = Field(5, ge=1, le=50)

# --- LLM Utility Function (using Google Gemini Pro API) ---
def generate_text_with_llm(prompt_text: str, max_new_tokens: int = 500, response_schema: Optional[Dict[str, Any]] = None) -> Optional[str]:
    """
    Generates text using the Google Gemini Pro model via API, optionally with a JSON schema.
    """
    if model is None:
        logger.error("Gemini model not initialized. Cannot generate text.")
        return None

    logger.info(f"Sending prompt to Gemini (first 100 chars): '{prompt_text[:100]}...'")
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
            generation_config_params["response_schema"] = response_schema

        response = model.generate_content(
            prompt_text,
            generation_config=genai.types.GenerationConfig(**generation_config_params)
        )

        logger.debug(f"Full Gemini response: {response}")

        if response_schema and response.candidates and response.candidates[0].content and response.candidates[0].content.parts:
            generated_text = response.candidates[0].content.parts[0].text.strip()
            logger.info(f"Gemini generated JSON (first 100 chars): '{generated_text[:100]}...'")
            return generated_text
        elif response.parts:
            generated_text = response.parts[0].text.strip()
            logger.info(f"Gemini generated text (first 100 chars): '{generated_text[:100]}...'")
            return generated_text
        elif response.candidates and response.candidates[0].content and response.candidates[0].content.parts:
            generated_text = response.candidates[0].content.parts[0].text.strip()
            logger.info(f"Gemini generated text (from candidates, first 100 chars): '{generated_text[:100]}...'")
            return generated_text
        else:
            logger.warning(f"Gemini API returned an empty or unexpected response structure for prompt: {prompt_text}")
            logger.debug(f"Unexpected response structure: {response}")
            return None
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
    logger.debug(f"Request body for /generate-profile/: {request.dict()}")

    user_data_str = ", ".join([f"{k}: {v}" for k, v in request.user_data.items()])

    prompt = f"Create a compelling dating profile bio based on the following user data: {user_data_str}. "
    if request.prompt_instructions:
        prompt += f"Additionally, follow these instructions: {request.prompt_instructions}. "
    prompt += "The profile should be engaging, positive, and highlight unique qualities. Keep it concise."

    logger.info(f"Constructed prompt for profile generation: {prompt}")

    generated_text = generate_text_with_llm(prompt, max_new_tokens=200)

    if generated_text:
        logger.info("Successfully generated profile bio.")
        return JSONResponse(content={"profile_bio": generated_text})
    else:
        logger.error("Failed to generate profile bio. Returning 500 error.")
        return JSONResponse(content={"error": "Failed to generate profile bio"}, status_code=500)

@app.post("/generate-news-feed/")
async def generate_news_feed(request: GenerateNewsFeedRequest, http_request: Request):
    logger.info(f"Received POST request to /generate-news-feed/ from {http_request.client.host}")
    logger.debug(f"Request body for /generate-news-feed/: {request.dict()}")

    recent_activity_json = json.dumps(request.recent_activity)

    prompt = f"Based on the user's profile summary: \"{request.user_profile_summary}\"\n" \
             f"And recent activities: {recent_activity_json}\n" \
             f"Generate {request.num_items} engaging and personalized news feed items. " \
             "Each item should be short, distinct, and relevant to dating app context (e.g., 'X liked Y photo', 'New match with Z', 'A new event nearby'). " \
             "Format as a JSON list of strings, e.g., ['Item 1', 'Item 2']."

    logger.info(f"Constructed prompt for news feed generation (first 100 chars): {prompt[:100]}...")

    generated_json_str = generate_text_with_llm(prompt, max_new_tokens=request.num_items * 50)

    if generated_json_str:
        try:
            news_feed_items = json.loads(generated_json_str)
            if not isinstance(news_feed_items, list):
                logger.warning(f"LLM did not return a JSON list for news feed. Raw response: {generated_json_str}")
                raise ValueError("LLM did not return a JSON list.")
            logger.info(f"Successfully generated and parsed news feed items: {news_feed_items}")
            return JSONResponse(content={"news_feed_items": news_feed_items})
        except json.JSONDecodeError as e:
            logger.error(f"Failed to parse JSON from LLM for news feed: {e}. Raw response: {generated_json_str}", exc_info=True)
            items = re.findall(r"['\"]([^'\"]+)['\"]", generated_json_str)
            if items:
                logger.info(f"Extracted news feed items using regex fallback: {items}")
                return JSONResponse(content={"news_feed_items": items})
            logger.error("Failed to extract any items even with regex fallback for news feed.")
            return JSONResponse(content={"error": "Failed to generate valid news feed items (JSON parse error or malformed)", "raw_response": generated_json_str}, status_code=500)
    else:
        logger.error("Failed to generate news feed items. Returning 500 error.")
        return JSONResponse(content={"error": "Failed to generate news feed items"}, status_code=500)

@app.get("/generate-daily-prompt/")
async def generate_daily_prompt(http_request: Request, context: Optional[str] = None):
    logger.info(f"Received GET request to /generate-daily-prompt/ from {http_request.client.host}")
    logger.debug(f"Request query param for /generate-daily-prompt/: context='{context}'")

    prompt = "Generate a short, engaging, and thought-provoking daily question or prompt for a dating app user to answer. " \
             "It should encourage self-reflection or spark conversation."
    if context:
        prompt += f" Consider the following context: {context}."
    prompt += " Example: 'What's one small thing that always makes your day better?'"

    logger.info(f"Constructed prompt for daily prompt generation: {prompt}")

    generated_text = generate_text_with_llm(prompt, max_new_tokens=50)

    if generated_text:
        logger.info(f"Successfully generated daily prompt: {generated_text}")
        return JSONResponse(content={"daily_prompt": generated_text})
    else:
        logger.error("Failed to generate daily prompt. Returning 500 error.")
        return JSONResponse(content={"error": "Failed to generate daily prompt"}, status_code=500)

# NEW: Endpoint to generate and save dummy user profiles
@app.post("/generate-dummy-users/")
async def generate_dummy_users(request: GenerateDummyUsersRequest, http_request: Request):
    logger.info(f"Received POST request to /generate-dummy-users/ from {http_request.client.host} for {request.count} users.")
    if supabase is None:
        logger.error("Supabase client not initialized. Cannot save dummy users.")
        return JSONResponse(content={"error": "Supabase connection not available"}, status_code=500)

    # Define the JSON schema for the AI to follow, matching your Supabase table
    # IMPORTANT: Use snake_case for keys to match your Supabase table columns
    # Removed 'name' from the schema and required fields
    user_profile_schema = {
        "type": "ARRAY",
        "items": {
            "type": "OBJECT",
            "properties": {
                # "name": {"type": "STRING", "description": "Realistic first name"}, # REMOVED
                "email": {"type": "STRING", "description": "Unique dummy email address"},
                "display_name": {"type": "STRING", "description": "A display name, often same as name"},
                "bio": {"type": "STRING", "description": "A short, engaging bio (2-3 sentences)"},
                "looking_for": {"type": "STRING", "description": "What they are looking for (e.g., 'long-term relationship', 'casual dating', 'friendship')"},
                "profile_picture_url": {"type": "STRING", "description": "Placeholder URL like 'https://placehold.co/150x150/000000/FFFFFF?text=User+ID'"},
                "date_of_birth": {"type": "STRING", "format": "date-time", "description": "Date of birth in YYYY-MM-DD format, for ages 20-40"},
                "phone_number": {"type": "STRING", "description": "Dummy phone number (e.g., '+1-555-123-4567')"},
                "location_zip_code": {"type": "STRING", "description": "Dummy 5-digit US zip code"},
                "sexual_orientation": {"type": "STRING", "enum": ["Straight", "Gay", "Lesbian", "Bisexual", "Pansexual", "Queer", "Asexual", "Demisexual", "Other"]},
                "height_cm": {"type": "NUMBER", "description": "Height in centimeters (e.g., 175.5)"},
                "agreed_to_terms": {"type": "BOOLEAN", "description": "Always true for dummy data"},
                "agreed_to_community_guidelines": {"type": "BOOLEAN", "description": "Always true for dummy data"},
                "full_legal_name": {"type": "STRING", "description": "Dummy full legal name"},
                "gender_identity": {"type": "STRING", "enum": ["Male", "Female", "Non-binary", "Transgender", "Genderfluid", "Agender", "Other"]},
                "ethnicity": {"type": "STRING", "description": "Ethnicity (e.g., 'Caucasian', 'African American', 'Asian', 'Hispanic', 'Mixed')"},
                "languages_spoken": {"type": "ARRAY", "items": {"type": "STRING"}, "description": "List of languages spoken"},
                "desired_occupation": {"type": "STRING", "description": "Dummy occupation"},
                "education_level": {"type": "STRING", "enum": ["High School", "Some College", "Associate's Degree", "Bachelor's Degree", "Master's Degree", "Doctorate"]},
                "hobbies_and_interests": {"type": "ARRAY", "items": {"type": "STRING"}, "description": "List of 3-5 diverse hobbies and interests"},
                "love_languages": {"type": "ARRAY", "items": {"type": "STRING"}, "description": "List of love languages (e.g., 'Words of Affirmation', 'Quality Time')"},
                "favorite_media": {"type": "ARRAY", "items": {"type": "STRING"}, "description": "List of favorite movies, books, music genres"},
                "marital_status": {"type": "STRING", "enum": ["Single", "Divorced", "Widowed", "Separated"]},
                "has_children": {"type": "BOOLEAN"},
                "wants_children": {"type": "BOOLEAN"},
                "relationship_goals": {"type": "STRING", "description": "Goals for a relationship (e.g., 'serious relationship', 'casual fun')"},
                "dealbreakers": {"type": "ARRAY", "items": {"type": "STRING"}, "description": "List of dealbreakers"},
                "religion_or_spiritual_beliefs": {"type": "STRING", "description": "Religious/spiritual beliefs"},
                "political_views": {"type": "STRING", "description": "Political views"},
                "diet": {"type": "STRING", "description": "Dietary preferences (e.g., 'Vegetarian', 'Vegan', 'Omnivore')"},
                "smoking_habits": {"type": "STRING", "enum": ["Never", "Socially", "Regularly", "Trying to quit"]},
                "drinking_habits": {"type": "STRING", "enum": ["Never", "Socially", "Occasionally", "Frequently"]},
                "exercise_frequency_or_fitness_level": {"type": "STRING", "description": "Exercise habits or fitness level"},
                "sleep_schedule": {"type": "STRING", "description": "Sleep schedule (e.g., 'Early bird', 'Night owl', 'Flexible')"},
                "personality_traits": {"type": "ARRAY", "items": {"type": "STRING"}, "description": "List of 3-5 personality traits"},
                "willing_to_relocate": {"type": "BOOLEAN"},
                "monogamy_vs_polyamory_preferences": {"type": "STRING", "enum": ["Monogamous", "Polyamorous", "Open to either"]},
                "astrological_sign": {"type": "STRING", "description": "Astrological sign"},
                "attachment_style": {"type": "STRING", "enum": ["Secure", "Anxious-Preoccupied", "Dismissive-Avoidant", "Fearful-Avoidant"]},
                "communication_style": {"type": "STRING", "description": "Communication style (e.g., 'Direct', 'Passive', 'Thoughtful')"},
                "mental_health_disclosures": {"type": "STRING", "description": "Brief, general mental health disclosure (e.g., 'Open about anxiety', 'Private')"},
                "pet_ownership": {"type": "STRING", "description": "Pet ownership status (e.g., 'Has a dog', 'Loves cats but no pets')"},
                "travel_frequency_or_favorite_destinations": {"type": "STRING", "description": "Travel habits or dream destinations"},
                # Changed to STRING, AI will return JSON string, then Python parses
                "profile_visibility_preferences": {"type": "STRING", "description": "JSON string of visibility preferences, e.g., '{\"email_visible\": true, \"phone_visible\": false}'"},
                "push_notification_preferences": {"type": "STRING", "description": "JSON string of notification preferences, e.g., '{\"new_match\": true, \"message_received\": false}'"},
                "is_phase_1_complete": {"type": "BOOLEAN", "description": "Always true for dummy data"},
                "is_phase_2_complete": {"type": "BOOLEAN", "description": "Always true for dummy data"},
                "questionnaire_answers": {"type": "STRING", "description": "JSON string of dummy answers to a few questionnaire questions, e.g., '{\"q1\": \"answer text\", \"q2\": \"another answer\"}'"},
                "personality_assessment_results": {"type": "STRING", "description": "JSON string of dummy personality assessment scores (e.g., '{\"openness\": 0.7, \"conscientiousness\": 0.8}')"},
            },
            "required": ["email", "display_name", "bio", "profile_picture_url", "date_of_birth", "gender_identity", "hobbies_and_interests"] # REMOVED 'name'
        }
    }

    # Prompt for the AI
    prompt = f"""Generate {request.count} diverse and realistic user profiles for a dating application.
    Each profile should strictly adhere to the provided JSON schema.
    Ensure 'id' and 'email' are unique for each profile.
    For 'id', generate a valid UUID.
    For 'email', generate a unique dummy email (e.g., 'user_name_123@example.com').
    'created_at' and 'updated_at' should be current UTC timestamps in ISO 8601 format.
    'agreed_to_terms', 'agreed_to_community_guidelines', 'is_phase_1_complete', 'is_phase_2_complete' should be true.
    For array fields (e.g., hobbies_and_interests, languages_spoken), provide a list of strings.
    For object fields (e.g., profile_visibility_preferences, questionnaire_answers), provide a JSON string.
    Ensure all string fields have meaningful, varied content.
    """

    try:
        generated_json_str = generate_text_with_llm(prompt, max_new_tokens=request.count * 1000, response_schema=user_profile_schema)

        if not generated_json_str:
            logger.error("AI did not return any generated JSON for dummy users.")
            return JSONResponse(content={"error": "AI failed to generate user data"}, status_code=500)

        raw_profiles = json.loads(generated_json_str)
        if not isinstance(raw_profiles, list):
            logger.error(f"AI returned non-list JSON: {generated_json_str}")
            return JSONResponse(content={"error": "AI returned malformed data (not a list)"}, status_code=500)

        profiles_to_insert = []
        for profile_data in raw_profiles:
            # Generate UUID for 'id' and current timestamps
            profile_data['id'] = str(uuid.uuid4())
            profile_data['created_at'] = datetime.now(timezone.utc).isoformat()
            profile_data['updated_at'] = datetime.now(timezone.utc).isoformat()

            # Ensure 'email' is present and unique for dummy data
            if 'email' not in profile_data or not profile_data['email']:
                 profile_data['email'] = f"dummy_user_{uuid.uuid4().hex[:8]}@example.com"

            # Parse JSON strings back into Python objects for Supabase's jsonb columns
            json_string_fields = [
                "profile_visibility_preferences",
                "push_notification_preferences",
                "questionnaire_answers",
                "personality_assessment_results"
            ]
            for field in json_string_fields:
                if field in profile_data and isinstance(profile_data[field], str):
                    try:
                        profile_data[field] = json.loads(profile_data[field])
                    except json.JSONDecodeError:
                        logger.warning(f"Failed to parse JSON string for field '{field}': {profile_data[field]}. Setting to empty dict.")
                        profile_data[field] = {} # Fallback to empty dict if parsing fails

            # Clean up any extra fields the AI might generate that are not in your schema
            # IMPORTANT: Now 'name' is not in user_profile_schema["items"]["properties"].keys()
            valid_keys = set(user_profile_schema["items"]["properties"].keys())
            valid_keys.update(['id', 'created_at', 'updated_at']) # Add backend-generated keys

            cleaned_profile_data = {k: v for k, v in profile_data.items() if k in valid_keys}

            profiles_to_insert.append(cleaned_profile_data)

        if not profiles_to_insert:
            logger.warning("No valid profiles were parsed from AI response to insert.")
            return JSONResponse(content={"message": "AI generated no valid profiles to insert"}, status_code=200)

        # Insert into Supabase
        logger.info(f"Attempting to insert {len(profiles_to_insert)} profiles into Supabase...")
        response = supabase.table('user_profiles').insert(profiles_to_insert).execute()

        if response.data:
            logger.info(f"Successfully inserted {len(response.data)} dummy users into Supabase.")
            return JSONResponse(content={"message": f"Successfully generated and inserted {len(response.data)} dummy users"}, status_code=200)
        else:
            logger.error(f"Supabase insert failed: {response.error}")
            return JSONResponse(content={"error": f"Failed to insert users into Supabase: {response.error.message}"}, status_code=500)

    except json.JSONDecodeError as e:
        logger.error(f"Failed to parse JSON from LLM for dummy users: {e}. Raw response: {generated_json_str}", exc_info=True)
        return JSONResponse(content={"error": "Failed to parse AI response JSON"}, status_code=500)
    except Exception as e:
        logger.error(f"Error in /generate-dummy-users/ endpoint: {e}", exc_info=True)
        return JSONResponse(content={"error": f"An unexpected error occurred: {e}"}, status_code=500)