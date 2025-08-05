// supabase/functions/generate-ai-dates/index.ts

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

  // --- Ensure ALL responses have CORS headers ---
  const headers = {
    'Content-Type': 'application/json',
    ...corsHeaders
  };

  const authHeader = req.headers.get('Authorization');
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return new Response(
      JSON.stringify({ error: 'Missing or invalid Authorization header.' }),
      { headers, status: 401 }
    );
  }

  try {
    const GOOGLE_API_KEY = Deno.env.get('GOOGLE_AI_STUDIO_API_KEY');
    if (!GOOGLE_API_KEY) {
      return new Response(
        JSON.stringify({ error: 'Google AI Studio API key is not configured.' }),
        { headers, status: 500 }
      );
    }

    const { user_preferences } = await req.json();

    // ... your logic to generate newsfeed

    // Example of a successful response
    const newsFeedData = {
        // ... your generated data
    };
    return new Response(
      JSON.stringify(newsFeedData),
      { headers, status: 200 }
    );

  } catch (error) {
    // Catch any other errors and return a proper response with CORS headers
    return new Response(
      JSON.stringify({ error: error.message }),
      { headers, status: 500 }
    );
  }
});