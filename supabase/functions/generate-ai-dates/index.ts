// supabase/functions/generate-ai-dates/index.ts
// This function generates creative date ideas using Google Generative AI.

import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

Deno.serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  const authHeader = req.headers.get('Authorization');
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    // --- START OF FIX: Ensure the 401 response includes CORS headers ---
    return new Response(
      JSON.stringify({ error: 'Missing or invalid Authorization header.' }),
      { headers: { 'Content-Type': 'application/json', ...corsHeaders }, status: 401 }
    );
    // --- END OF FIX ---
  }

  try {
    const GOOGLE_API_KEY = Deno.env.get('GOOGLE_AI_STUDIO_API_KEY');
    if (!GOOGLE_API_KEY) {
      throw new Error('Google AI Studio API key is not configured.');
    }

    const { user_preferences } = await req.json();

    if (!user_preferences) {
      throw new Error('user_preferences is required in the request body.');
    }

    const prompt_text = `You are a creative AI date planner. Based on the user's preferences: "${user_preferences}", generate 5 unique and fun date ideas. The ideas should be simple, creative, and suited for a blind date. Return the ideas as a JSON array of strings.`;

    const model_name = 'gemini-pro';
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
    let generated_dates = data.candidates?.[0]?.content?.parts?.[0]?.text || '';

    // The AI is instructed to return JSON, so we attempt to parse it.
    let dates_json = JSON.parse(generated_dates);

    return new Response(
      JSON.stringify({ ai_dates: dates_json }),
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
