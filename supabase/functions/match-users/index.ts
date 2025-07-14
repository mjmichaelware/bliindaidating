// supabase/functions/match-users/index.ts
// This function integrates Google Generative AI by making direct REST API calls,
// avoiding the JSR client library to resolve deployment issues.

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
    const GOOGLE_API_KEY = Deno.env.get('GOOGLE_AI_STUDIO_API_KEY');

    if (!GOOGLE_API_KEY) {
      console.error('Edge Function Error: GOOGLE_AI_STUDIO_API_KEY environment variable is not set.');
      throw new Error('Google AI Studio API key is not configured as a Supabase Secret.');
    }

    const {
      prompt_text,
      model_name = 'gemini-pro',       // Default to 'gemini-pro' for text generation
      task_type = 'GENERATE_CONTENT',  // 'GENERATE_CONTENT' or 'EMBED_CONTENT'
      response_format = 'text',        // For GENERATE_CONTENT: 'text' or 'json'. instruct in prompt for json
      output_dimensionality = 768,     // For EMBED_CONTENT: must match your DB column (e.g., 768)
      temperature = 0.7,               // For GENERATE_CONTENT
      max_tokens = 1000                // For GENERATE_CONTENT
    } = await req.json();

    if (!prompt_text) {
      throw new Error('prompt_text is required in the request body.');
    }

    let aiResponseContent; // This will hold the result from Gemini

    const BASE_API_URL = 'https://generativelanguage.googleapis.com/v1beta/';

    if (task_type === 'GENERATE_CONTENT') {
      const url = `${BASE_API_URL}models/${model_name}:generateContent?key=${GOOGLE_API_KEY}`;
      const requestBody = {
        contents: [{ role: 'user', parts: [{ text: prompt_text }] }],
        generationConfig: {
          temperature: temperature,
          maxOutputTokens: max_tokens,
        },
      };

      const aiResponse = await fetch(url, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(requestBody),
      });

      if (!aiResponse.ok) {
        const errorText = await aiResponse.text();
        console.error('Gemini API Error:', aiResponse.status, errorText);
        throw new Error(`Gemini API error: ${aiResponse.status} - ${errorText}`);
      }

      const data = await aiResponse.json();
      // Gemini's generateContent response structure has candidates[0].content.parts[0].text
      aiResponseContent = data.candidates?.[0]?.content?.parts?.[0]?.text || '';

      if (response_format === 'json') {
          try {
              aiResponseContent = JSON.parse(aiResponseContent);
          } catch (e) {
              console.error('Failed to parse AI response as JSON (check Gemini prompt):', aiResponseContent, e);
              throw new Error('AI did not return valid JSON despite request for JSON format.');
          }
      }

    } else if (task_type === 'EMBED_CONTENT') {
      const embeddingModelName = 'text-embedding-004'; // Recommended Google embedding model
      const url = `${BASE_API_URL}models/${embeddingModelName}:embedContent?key=${GOOGLE_API_KEY}`;
      const requestBody = {
        content: { parts: [{ text: prompt_text }] },
        taskType: "SEMANTIC_SIMILARITY",
        outputDimensionality: output_dimensionality,
      };

      const aiResponse = await fetch(url, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(requestBody),
      });

      if (!aiResponse.ok) {
        const errorText = await aiResponse.text();
        console.error('Gemini Embedding API Error:', aiResponse.status, errorText);
        throw new Error(`Gemini Embedding API error: ${aiResponse.status} - ${errorText}`);
      }

      const data = await aiResponse.json();
      // Gemini's embedContent response structure has embedding.values
      aiResponseContent = data.embedding?.values;

      if (!aiResponseContent || !Array.isArray(aiResponseContent)) {
          throw new Error('Invalid embedding response from Gemini API.');
      }

    } else {
      throw new Error('Invalid task_type provided. Must be GENERATE_CONTENT or EMBED_CONTENT.');
    }

    // Return the AI's response
    return new Response(
      JSON.stringify({ ai_response: aiResponseContent }),
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