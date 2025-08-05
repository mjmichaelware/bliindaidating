// Corrected code for: supabase/functions/generate-news-feed/index.ts
// This function generates a personalized news feed for a user using Google Generative AI.

import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*', // IMPORTANT: In production, change this to your specific Flutter web domain
  'Access-Control-Allow-Headers': 'authorization, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

Deno.serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  // Extract the JWT from the Authorization header
  const authHeader = req.headers.get('Authorization');
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    // --- START OF FIX: Ensure the 401 response includes CORS headers ---
    return new Response(
      JSON.stringify({ code: 401, message: 'Missing or invalid Authorization header.' }),
      { headers: { 'Content-Type': 'application/json', ...corsHeaders }, status: 401 }
    );
    // --- END OF FIX ---
  }
  const token = authHeader.split(' ')[1];

  // For this example, we will not verify the JWT, but you would
  // typically use a library like 'djwt' to do so.
  // The 'verify_jwt = true' setting in supabase/config.toml handles this.

  try {
    const GOOGLE_API_KEY = Deno.env.get('GOOGLE_AI_STUDIO_API_KEY');

    if (!GOOGLE_API_KEY) {
      throw new Error('Google AI Studio API key is not configured.');
    }

    // This is where you would get user data from the request body or from the JWT
    // For this example, we'll use a placeholder.
    const { user_preferences } = await req.json();

    // --- CORRECTED LINE: Updated prompt_text to request JSON format ---
    const prompt_text = `You are an AI assistant for a blind dating app. Create a short, engaging news feed for a user based on their preferences: ${user_preferences}. Do not mention any user IDs. Focus on personality and interests, as it's a "blind" dating app.

Return the response as a JSON array of objects, with each object having keys: "headline", "summary", and "related_user_id" (a fictional ID).`;
    // --- END OF CORRECTED LINE ---
    
    const model_name = 'gemini-1.5-pro'; // CORRECTED LINE (already done in previous step, but keeping for completeness)
    const BASE_API_URL = 'https://generativelanguage.googleapis.com/v1beta/';
    const url = `${BASE_API_URL}models/${model_name}:generateContent?key=${GOOGLE_API_KEY}`;
    
    const requestBody = {
      contents: [{ role: 'user', parts: [{ text: prompt_text }] }],
    };

    const aiResponse = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(requestBody),
    });

    if (!aiResponse.ok) {
      const errorText = await aiResponse.text();
      console.error('Gemini API Error:', aiResponse.status, errorText);
      throw new Error(`Gemini API error: ${aiResponse.status} - ${errorText}`);
    }

    const data = await aiResponse.json();
    const generated_text = data.candidates?.[0]?.content?.parts?.[0]?.text || 'No content generated.';

    // Attempt to parse the generated_text as JSON, as per the new prompt instructions
    let newsFeedData;
    try {
        newsFeedData = JSON.parse(generated_text);
    } catch (e) {
        console.error('Failed to parse AI response as JSON:', generated_text, e);
        throw new Error('AI did not return valid JSON for newsfeed despite prompt instructions.');
    }

    return new Response(
      JSON.stringify({ news_feed: newsFeedData }), // Return the parsed JSON
      { headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );

  } catch (error) {
    console.error('Edge Function Error:', error.message);
    return new Response(
      JSON.stringify({ error: error.message }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 500 },
    );
  }
});