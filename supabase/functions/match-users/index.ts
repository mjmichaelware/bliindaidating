// supabase/functions/match-users/index.ts

// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts"

// Import the Supabase client if you need to interact with your database from this function.
// For this example, we're just hitting OpenAI, so it's not strictly necessary unless you add DB logic.
// import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

console.log("Hello from Functions! (Now with AI capabilities)")

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
    // Parse the request body to get the 'name' and any other relevant data for AI
    const { name, prompt_text } = await req.json();

    // 🔥🔥🔥 TEMPORARY, INSECURE WORKAROUND - HARDCODED OPENAI API KEY 🔥🔥🔥
    // This is your OpenAI API Key, hardcoded for immediate progress.
    // REPLACE 'YOUR_OPENAI_API_KEY_HERE' with your actual key.
    const OPENAI_API_KEY = 'sk-proj-m1tl77NQ-Qxz2UMBSdqBxDQtgryOGBHX3YnSji25NC7h5tpvn0ApHwgN5iyL6Rkxsq2jPLUy8IT2BlbkFJSO4eyVCsh5Smt6KLPFL3e83K9YXlb5p_LK6fmUX7j7D2ZDUZsQMVGAX8QFictXGv5_bXyhz1wA'; // <= PASTE YOUR ACTUAL KEY HERE
    // 🔥🔥🔥 END OF HARDCODED KEY WORKAROUND 🔥🔥🔥

    if (!OPENAI_API_KEY) {
      throw new Error('OpenAI API key is not configured.');
    }

    // Construct a prompt for OpenAI based on the input
    const aiPrompt = prompt_text || `Tell me something interesting about the name ${name}.`;

    // Call the OpenAI Chat Completions API
    const openaiResponse = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${OPENAI_API_KEY}`,
      },
      body: JSON.stringify({
        model: 'gpt-3.5-turbo', // You can change this to 'gpt-4o' or another model if desired
        messages: [{ role: 'user', content: aiPrompt }],
        temperature: 0.7, // Controls randomness: lower for more deterministic, higher for more creative
        max_tokens: 150, // Maximum number of tokens to generate in the response
      }),
    });

    const openaiData = await openaiResponse.json();

    if (!openaiResponse.ok) {
      console.error('OpenAI API Error:', openaiData);
      throw new Error(`OpenAI API request failed: ${openaiData.error?.message || JSON.stringify(openaiData)}`);
    }

    const aiMessage = openaiData.choices[0]?.message?.content || "No AI response received.";

    // Prepare the response data to send back to the client
    const responseData = {
      greeting: `Hello ${name}!`,
      ai_response: aiMessage,
      // You can include more data here if needed
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

/* To invoke locally:

  1. Run `supabase start` (see: https://supabase.com/docs/reference/cli/supabase-start)
  2. Deploy this function locally (if you haven't already):
     `npx supabase functions deploy match-users --no-verify-jwt`
  3. Make an HTTP request:

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/match-users' \
    --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
    --header 'Content-Type: application/json' \
    --data '{"name":"Functions", "prompt_text": "Tell me a fun fact about Flutter."}'

  Remember to replace 'match-users' in the curl command if you renamed your function.
  The 'prompt_text' field is new and allows you to send a specific AI prompt.
*/