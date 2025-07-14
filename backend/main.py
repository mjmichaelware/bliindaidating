import os
import json
import re
import uvicorn
from fastapi import FastAPI, Request # Import Request for logging incoming details
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from typing import Optional, List, Dict, Any

# --- Python Standard Logging ---
import logging

# Configure basic logging to console
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# --- Google Generative AI Imports ---
import google.generativeai as genai

# --- API Key Configuration ---
# IMPORTANT: Use environment variables for API keys in production.
# For local development, you can create a .env file in the same directory
# as this main.py file and put `GEMINI_API_KEY="YOUR_ACTUAL_API_KEY"` inside it.
# Then uncomment the `from dotenv import load_dotenv; load_dotenv()` lines.
# from dotenv import load_dotenv
# load_dotenv() # Load environment variables from .env file

API_KEY = os.getenv("GEMINI_API_KEY") # This is the correct way to get the key

if not API_KEY:
    logger.error("GEMINI_API_KEY not set. Please set the environment variable.")
    # In a real application, you might want to exit or raise a more controlled error
    # For now, we'll let it proceed but expect `genai.configure` to fail or lead to issues.
    # raise ValueError("GEMINI_API_KEY not set. Please set the API key.")

try:
    genai.configure(api_key=API_KEY)
    logger.info("Gemini API configured successfully.")
except Exception as e:
    logger.error(f"Error configuring Gemini API: {e}")
    # Handle the error, maybe don't initialize the model if key is bad
    model = None # Set model to None to prevent errors later

# Initialize the Gemini Pro model only if API key was configured
model = genai.GenerativeModel('gemini-pro') if API_KEY else None

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

# --- LLM Utility Function (using Google Gemini API) ---
def generate_text_with_llm(prompt_text: str, max_new_tokens: int = 500) -> Optional[str]:
    """
    Generates text using the Google Gemini Pro model via API.
    """
    if model is None:
        logger.error("Gemini model not initialized due to API key issues. Cannot generate text.")
        return None

    logger.info(f"Sending prompt to Gemini (first 100 chars): '{prompt_text[:100]}...'")
    try:
        response = model.generate_content(
            prompt_text,
            generation_config=genai.types.GenerationConfig(
                candidate_count=1,
                stop_sequences=[],
                max_output_tokens=max_new_tokens,
                temperature=0.7,
                top_p=0.9,
            )
        )

        # Log the full response object for debugging
        # Be careful not to log too much data in production if responses are very large
        logger.debug(f"Full Gemini response: {response}")

        if response.parts:
            generated_text = response.parts[0].text.strip()
            logger.info(f"Gemini generated text (first 100 chars): '{generated_text[:100]}...'")
            return generated_text
        elif response.candidates and response.candidates[0].content and response.candidates[0].content.parts:
            # This is a fallback, typically response.parts is more direct
            generated_text = response.candidates[0].content.parts[0].text.strip()
            logger.info(f"Gemini generated text (from candidates, first 100 chars): '{generated_text[:100]}...'")
            return generated_text
        else:
            logger.warning(f"Gemini API returned an empty or unexpected response structure for prompt: {prompt_text}")
            logger.debug(f"Unexpected response structure: {response}")
            return None
    except Exception as e:
        logger.error(f"Error generating text with Gemini API: {e}", exc_info=True) # exc_info=True to log traceback
        # Check for specific Gemini API errors or rate limits
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

    # Ensuring JSON serialization for the prompt to avoid issues with complex types
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
            # Fallback: try to extract items if JSON parsing fails but content looks list-like
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

# To run this file:
# 1. Save it as main.py (or any_name.py)
# 2. Install dependencies: pip install fastapi uvicorn google-generativeai python-dotenv
# 3. Create a .env file in the same directory with: GEMINI_API_KEY="YOUR_ACTUAL_API_KEY"
# 4. Run from your terminal: uvicorn main:app --reload --port 8000
#    (Or if using a different filename, e.g., my_api.py: uvicorn my_api:app --reload --port 8000)