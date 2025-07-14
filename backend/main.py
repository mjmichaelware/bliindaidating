import os
import json
import re
import uvicorn
from fastapi import FastAPI
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from typing import Optional, List, Dict, Any

# --- Google Generative AI Imports ---
import google.generativeai as genai

# --- API Key Configuration ---
# IMPORTANT: Replace "YOUR_GEMINI_API_KEY" with the actual key you copied from Google AI Studio.
# BEST PRACTICE: Use environment variables in production.
# For development, you can put it here temporarily or in a .env file (and load it with python-dotenv).
API_KEY = "AIzaSyCoiSj_WtEMy8_K9kZZ4C_wkQtHVvrnd6w"


# Alternatively, load from an environment variable (recommended)
# API_KEY = os.getenv("GEMINI_API_KEY")
# If using .env file, you'd also need: from dotenv import load_dotenv; load_dotenv()

if not API_KEY:
    raise ValueError("GEMINI_API_KEY not set. Please set the API key.")

genai.configure(api_key=API_KEY)

# Initialize the Gemini Pro model
model = genai.GenerativeModel('gemini-pro')

# --- FastAPI App Initialization ---
app = FastAPI(
    title="Dating App AI Backend",
    description="Backend for generating dating profiles, news feed content, and daily prompts.",
    version="0.1.0"
)

# --- Pydantic Models for Request Bodies ---
class GenerateProfileRequest(BaseModel):
    user_data: Dict[str, str]  # Example: {"name": "John", "age": "30", "hobbies": "hiking, reading"}
    prompt_instructions: Optional[str] = None

class GenerateNewsFeedRequest(BaseModel):
    user_profile_summary: str
    recent_activity: List[Dict[str, Any]] # Example: [{"type": "liked", "item": "photo", "user": "Jane"}, ...]
    num_items: int = 3 # Number of news feed items to generate

class GenerateDailyPromptRequest(BaseModel):
    context: Optional[str] = None # Optional context for the prompt

# --- LLM Utility Function (using Google Gemini API) ---
def generate_text_with_llm(prompt_text: str, max_new_tokens: int = 500) -> Optional[str]:
    """
    Generates text using the Google Gemini Pro model via API.
    """
    try:
        # For pure text generation, model.generate_content is suitable.
        # For multi-turn conversations, you might use model.start_chat()
        response = model.generate_content(
            prompt_text,
            generation_config=genai.types.GenerationConfig(
                candidate_count=1,
                stop_sequences=[], # Can add stop sequences like ["\n\n"] or ["STOP"] if needed
                max_output_tokens=max_new_tokens,
                temperature=0.7, # Adjust for creativity vs. coherence (0.0-1.0)
                top_p=0.9,       # Nucleus sampling (0.0-1.0)
            )
        )

        # Accessing the text from the response
        if response.parts:
            return response.parts[0].text.strip()
        # Fallback for some response structures or if 'parts' is empty
        elif response.candidates and response.candidates[0].content and response.candidates[0].content.parts:
            return response.candidates[0].content.parts[0].text.strip()
        else:
            print(f"Gemini API returned an empty or unexpected response for prompt: {prompt_text}")
            return None
    except Exception as e:
        # More specific error handling might be needed based on Gemini API errors
        print(f"Error generating text with Gemini API: {e}")
        return None

# --- FastAPI Endpoints ---

@app.post("/generate-profile/")
async def generate_profile(request: GenerateProfileRequest):
    user_data_str = ", ".join([f"{k}: {v}" for k, v in request.user_data.items()])

    prompt = f"Create a compelling dating profile bio based on the following user data: {user_data_str}. "
    if request.prompt_instructions:
        prompt += f"Additionally, follow these instructions: {request.prompt_instructions}"
    prompt += " The profile should be engaging, positive, and highlight unique qualities. Keep it concise."

    generated_text = generate_text_with_llm(prompt, max_new_tokens=200) # Adjust token count as needed

    if generated_text:
        return JSONResponse(content={"profile_bio": generated_text})
    else:
        return JSONResponse(content={"error": "Failed to generate profile bio"}, status_code=500)

@app.post("/generate-news-feed/")
async def generate_news_feed(request: GenerateNewsFeedRequest):
    prompt = f"Based on the user's profile summary: \"{request.user_profile_summary}\"\n" \
             f"And recent activities: {json.dumps(request.recent_activity)}\n" \
             f"Generate {request.num_items} engaging and personalized news feed items. " \
             "Each item should be short, distinct, and relevant to dating app context (e.g., 'X liked Y photo', 'New match with Z', 'A new event nearby'). " \
             "Format as a JSON list of strings, e.g., ['Item 1', 'Item 2']."

    generated_json_str = generate_text_with_llm(prompt, max_new_tokens=request.num_items * 50) # Estimate tokens

    if generated_json_str:
        try:
            # Attempt to parse the JSON string. LLMs can sometimes generate imperfect JSON.
            # Use a regex or robust parsing if simple json.loads fails often.
            news_feed_items = json.loads(generated_json_str)
            if not isinstance(news_feed_items, list):
                raise ValueError("LLM did not return a JSON list.")
            return JSONResponse(content={"news_feed_items": news_feed_items})
        except json.JSONDecodeError as e:
            print(f"Failed to parse JSON from LLM: {e}. Raw response: {generated_json_str}")
            # Fallback: try to extract items if JSON parsing fails but content looks list-like
            items = re.findall(r"['\"]([^'\"]+)['\"]", generated_json_str)
            if items:
                return JSONResponse(content={"news_feed_items": items})
            return JSONResponse(content={"error": "Failed to generate valid news feed items (JSON parse error or malformed)", "raw_response": generated_json_str}, status_code=500)
    else:
        return JSONResponse(content={"error": "Failed to generate news feed items"}, status_code=500)

@app.get("/generate-daily-prompt/")
async def generate_daily_prompt(context: Optional[str] = None):
    prompt = "Generate a short, engaging, and thought-provoking daily question or prompt for a dating app user to answer. " \
             "It should encourage self-reflection or spark conversation."
    if context:
        prompt += f" Consider the following context: {context}."
    prompt += " Example: 'What's one small thing that always makes your day better?'"

    generated_text = generate_text_with_llm(prompt, max_new_tokens=50) # Daily prompts should be short

    if generated_text:
        return JSONResponse(content={"daily_prompt": generated_text})
    else:
        return JSONResponse(content={"error": "Failed to generate daily prompt"}, status_code=500)
