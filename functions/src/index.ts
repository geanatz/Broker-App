import * as functions from 'firebase-functions';
import { initializeApp } from 'firebase-admin/app';
import * as admin from 'firebase-admin';
import fetch from 'node-fetch';

// Initialize Admin SDK
initializeApp();

// Secure config: set via
// firebase functions:config:set gemini.key="YOUR_KEY"
// and access via functions.config().gemini.key

// Prefer environment variable; fallback to legacy functions.config()
const GEMINI_KEY = (process.env.GEMINI_KEY as string | undefined) || (functions.config().gemini?.key as string | undefined);
const MODEL = 'gemini-2.0-flash';

export const llmGenerate = functions
  .region('europe-west1')
  .runWith({ minInstances: 0, maxInstances: 10, timeoutSeconds: 30, memory: '256MB' })
  .https.onRequest(async (req, res) => {
    // CORS basic
    res.set('Access-Control-Allow-Origin', '*');
    res.set('Access-Control-Allow-Methods', 'POST, OPTIONS');
    res.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');
    if (req.method === 'OPTIONS') {
      res.status(204).send('');
      return;
    }

    try {
      if (req.method !== 'POST') {
        res.status(405).json({ error: 'Method not allowed' });
        return;
      }

      if (!GEMINI_KEY) {
        res.status(500).json({ error: 'Server API key not configured' });
        return;
      }

      // Verify Firebase ID token (required)
      const authHeader = req.headers.authorization || '';
      if (!authHeader.startsWith('Bearer ')) {
        res.status(401).json({ error: 'Missing token' });
        return;
      }
      const idToken = authHeader.substring(7);
      try {
        await admin.auth().verifyIdToken(idToken);
      } catch (e) {
        res.status(401).json({ error: 'Invalid token' });
        return;
      }

      const { contents, generationConfig, model } = req.body || {};
      if (!Array.isArray(contents) || contents.length === 0) {
        res.status(400).json({ error: 'Invalid contents' });
        return;
      }

      const endpoint = `https://generativelanguage.googleapis.com/v1/models/${MODEL}:generateContent?key=${GEMINI_KEY}`;
      const payload = {
        contents,
        generationConfig: generationConfig || {},
      };

      const response = await fetch(endpoint, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      });

      const data: any = await response.json();
      if (!response.ok) {
        res.status(response.status).json({ error: (data?.error?.message as string) || 'Upstream error' });
        return;
      }

      const text = (data?.candidates?.[0]?.content?.parts?.[0]?.text as string) ?? '';
      res.json({ text });
      return;
    } catch (e: any) {
      res.status(500).json({ error: e?.message || 'Internal error' });
      return;
    }
  });


