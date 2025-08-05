// supabase/functions/generate-ai-matches/index.ts
// This function generates potential matches for a user using Google Generative AI.

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
    return new Response(
      JSON.stringify({ error: 'Missing or invalid Authorization header.' }),
      { headers: { 'Content-Type': 'application/json' }, status: 401 }
    );
  }

  try {
    const GOOGLE_API_KEY = Deno.env.get('GOOGLE_AI_STUDIO_API_KEY');
    if (!GOOGLE_API_KEY) {
      throw new Error('Google AI Studio API key is not configured.');
    }

    const { user_profile_data } = await req.json();

    if (!user_profile_data) {
      throw new Error('user_profile_data is required in the request body.');
    }
    
    const prompt_text = `You are an AI matchmaker for a blind dating app. The user's profile data is: ${JSON.stringify(user_profile_data)}. Based on this information, generate a short list of 3 fictional user profiles that would be a good match. Do not include any personal identifying information like names or photos. Focus on interests, personality traits, and general life goals. Return the response as a JSON array of objects, with each object having keys: "id" (a unique fake ID), "interests", "personality", and "goals".`;

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
    let generated_matches = data.candidates?.[0]?.content?.parts?.[0]?.text || '';

    // The AI is instructed to return JSON, so we attempt to parse it.
    let matches_json = JSON.parse(generated_matches);

    return new Response(
      JSON.stringify({ ai_matches: matches_json }),
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
