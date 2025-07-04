// supabase/functions/match-users/index.ts
// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts";

// Define CORS headers for allowing cross-origin requests from your Flutter web app
const corsHeaders = {
  'Access-Control-Allow-Origin': '*', // IMPORTANT: In production, change '*' to your specific Flutter Web domain (e.g., 'https://your-app.com')
  'Access-Control-Allow-Headers': 'authorization, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS', // Allow POST and OPTIONS for preflight requests
};

Deno.serve(async (req) => {
  // Handle CORS preflight requests (OPTIONS method)
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    // 🔥🔥🔥 FIX: Get OpenAI API Key from Supabase Secrets (Environment Variables) 🔥🔥🔥
    // This is the correct way to access your secret.
    const OPENAI_API_KEY = Deno.env.get('OPENAI_API_KEY');

    if (!OPENAI_API_KEY) {
      // Log this error clearly if the secret isn't found
      console.error('Edge Function Error: OPENAI_API_KEY environment variable is not set.');
      throw new Error('OpenAI API key is not configured as a Supabase Secret.');
    }

    // Parse the request body to get the 'prompt_text'
    const { prompt_text } = await req.json();

    if (!prompt_text) {
      throw new Error('prompt_text is required in the request body.');
    }

    // Call the OpenAI Chat Completions API
    const openaiResponse = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${OPENAI_API_KEY}`,
      },
      body: JSON.stringify({
        model: 'gpt-3.5-turbo', // Or 'gpt-4o' for better JSON generation
        messages: [{ role: 'user', content: prompt_text }],
        temperature: 0.7,
        // Increased max_tokens for potentially larger JSON outputs (e.g., multiple newsfeed items/profiles)
        max_tokens: 1000,
        response_format: { type: "json_object" } // Instruct OpenAI to return JSON
      }),
    });

    const openaiData = await openaiResponse.json();

    if (!openaiResponse.ok) {
      console.error('OpenAI API Error:', openaiData);
      throw new Error(`OpenAI API request failed: ${openaiData.error?.message || JSON.stringify(openaiData)}`);
    }

    // OpenAI's response will contain the JSON string within the content.
    // We need to extract that string and return it directly.
    const aiContentString = openaiData.choices[0]?.message?.content;

    if (!aiContentString) {
      throw new Error('No content received from OpenAI.');
    }

    // The AI is instructed to return a JSON array as a string.
    // We will return this string directly to the Flutter app.
    // The Flutter app's _parseAIJsonResponse will then parse this string.
    const responseData = {
      ai_response: aiContentString // This will be the JSON array string
    };

    return new Response(
      JSON.stringify(responseData),
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