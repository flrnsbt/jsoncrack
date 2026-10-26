export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);
    const response = await env.ASSETS.fetch(request);
    
    // If Next.js chunks/assets are requested from root /_next/, serve them from /cdn/_next/
    if (url.pathname.startsWith('/_next/')) {
      const cdnUrl = new URL('/cdn' + url.pathname + url.search, request.url);
      const res = await env.ASSETS.fetch(new Request(cdnUrl, request));
      const headers = new Headers(res.headers);
      headers.set('Access-Control-Allow-Origin', '*');
      headers.set('Cross-Origin-Resource-Policy', 'cross-origin');
      return new Response(res.body, {
        status: res.status,
        statusText: res.statusText,
        headers
      });
    }

    // Only apply conditional logic to the CDN paths
    if (url.pathname.startsWith('/cdn/')) {
      const newHeaders = new Headers(response.headers);
      
      // Always keep CORS and embedding open for the CDN widget
      newHeaders.set('Access-Control-Allow-Origin', '*');
      newHeaders.set('Access-Control-Allow-Methods', 'GET, HEAD, OPTIONS');
      newHeaders.set('Cross-Origin-Resource-Policy', 'cross-origin');
      newHeaders.set('Content-Security-Policy', 'frame-ancestors *');
      
      // Check request context to see where it's being loaded from
      const secFetchSite = request.headers.get('sec-fetch-site');
      const referer = request.headers.get('referer') || '';
      
      // Determine if it's being loaded by your own app
      const isOurApp = secFetchSite === 'same-origin' || referer.includes(url.hostname);
      
      if (isOurApp) {
        // SCENARIO A: Loaded inside your own Flutter app -> Enforce COEP for cross-origin isolation
        newHeaders.set('Cross-Origin-Embedder-Policy', 'require-corp');
      } else {
        // SCENARIO B: Loaded by a third-party website -> Strip isolation policies
        newHeaders.delete('Cross-Origin-Embedder-Policy');
        newHeaders.delete('Cross-Origin-Opener-Policy');
      }
      
      return new Response(response.body, {
        status: response.status,
        statusText: response.statusText,
        headers: newHeaders
      });
    }
    
    return response;
  }
};
