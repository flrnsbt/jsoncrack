#!/usr/bin/env sh
set -euo pipefail

TMP_DIR_REL=$1
OUTPUT_DIR_REL=$2
ORIGINAL_DIR=$(pwd)
TMP_DIR="$ORIGINAL_DIR/$TMP_DIR_REL"
OUTPUT_DIR="$ORIGINAL_DIR/$OUTPUT_DIR_REL"

echo "== Cleaning temp folder =="
rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"

echo "== Creating minimal Next.js project =="
cd "$TMP_DIR"

# package.json
cat > package.json <<'EOF'
{
  "name": "jsoncrack-widget",
  "private": true,
  "version": "1.0.0",
  "scripts": {
    "build": "next build",
    "start": "next start"
  }
}
EOF

# next.config.js with export, exportPathMap, and deterministic webpack filenames
# Uses a fixed buildId and deterministic webpack filenames for predictable output
# assetPrefix is set to './' to force relative paths (_next/static/...) instead of
# root-relative paths (/_next/static/...) so the HTML works from Flutter assets,
# file:// URLs, or any web server subpath
cat > next.config.js <<'EOF'
/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'export',
  assetPrefix: './',
  trailingSlash: true,
  reactStrictMode: false,
  generateBuildId: async () => 'jsoncrack-widget',
  compiler: {
    styledComponents: true,
  },
  turbopack: {},
  webpack: (config) => {
    config.resolve.fallback = { fs: false };
    config.output.webassemblyModuleFilename = 'static/wasm/[module].wasm';
    config.output.filename = 'static/chunks/[name].js';
    config.output.chunkFilename = 'static/chunks/[name].js';
    config.experiments = { asyncWebAssembly: true, layers: true };
    return config;
  },
  async exportPathMap() {
    return {
      '/widget': { page: '/widget' },
    };
  },
};

module.exports = nextConfig;
EOF

# tsconfig.json
cat > tsconfig.json <<'EOF'
{
  "compilerOptions": {
    "target": "ES2017",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": false,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [{ "name": "next" }]
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx"],
  "exclude": ["node_modules"]
}
EOF

# next-env.d.ts
cat > next-env.d.ts <<'EOF'
/// <reference types="next" />
/// <reference types="next/image-types/global" />
EOF

# pages directory
mkdir -p pages/public

# pages/_app.tsx — import jsoncrack-react styles for proper node card rendering
cat > pages/_app.tsx <<'EOF'
import type { AppProps } from 'next/app';
import React from 'react';
import 'jsoncrack-react/style.css';

export default function App({ Component, pageProps }: AppProps) {
  return <Component {...pageProps} />;
}
EOF

# pages/widget.tsx — the embeddable widget page using jsoncrack-react
# Listens for postMessage from the parent (jsoncrack.html) to receive JSON data
# and sends a 'ready' message when loaded so the parent knows to send data
cat > pages/widget.tsx <<'WIDGET_EOF'
import React from 'react';
import dynamic from 'next/dynamic';
import Head from 'next/head';
import { useRouter } from 'next/router';

const JSONCrack = dynamic(
  () => import('jsoncrack-react').then((mod) => mod.JSONCrack),
  { ssr: false }
);

interface EmbedMessage {
  data: {
    json?: string;
    options?: {
      theme?: 'light' | 'dark';
      layoutDirection?: string;
      [key: string]: unknown;
    };
  };
}

const WidgetPage: React.FC = () => {
  const { query, isReady } = useRouter();
  const [jsonInput, setJsonInput] = React.useState<string | object | null>(null);
  const [theme, setTheme] = React.useState<'dark' | 'light'>('light');
  const [layoutDirection, setLayoutDirection] = React.useState<string>('RIGHT');
  const [showGrid, setShowGrid] = React.useState<boolean>(true);
  const [showControls, setShowControls] = React.useState<boolean>(false);
  const [centerOnLayout, setCenterOnLayout] = React.useState<boolean>(true);
  const [maxRenderableNodes, setMaxRenderableNodes] = React.useState<number>(1500);
  const [dataReceived, setDataReceived] = React.useState<boolean>(false);

  React.useEffect(() => {
    if (isReady && typeof query?.json === 'string') {
      setJsonInput(query.json);
      setDataReceived(true);
    }
  }, [isReady, query?.json]);

  // Signal ready to parent so it starts sending data
  React.useEffect(() => {
    if (typeof window !== 'undefined' && window.parent) {
      window.parent.postMessage({ type: 'ready' }, '*');
    }else{
      console.error("Couldn't send read message to parent");
    }
  }, []);

  React.useEffect(() => {
    const handler = (event: MessageEvent<EmbedMessage['data']>) => {
      try {
        const data = event.data;
        if (!data) return;

        // Handle JSON string directly (forwarded from jsoncrack.html)
        if (typeof data === 'string') {
          try {
            const parsed = JSON.parse(data);
            if (parsed.json !== undefined) {
              setJsonInput(parsed.json);
              setDataReceived(true);
              if (parsed.options) {
                const opts = parsed.options;
                if (opts.theme) setTheme(opts.theme);
                setLayoutDirection(opts.layoutDirection);
                if (typeof opts.showGrid === 'boolean') setShowGrid(opts.showGrid);
                if (typeof opts.showControls === 'boolean') setShowControls(opts.showControls);
                if (typeof opts.centerOnLayout === 'boolean') setCenterOnLayout(opts.centerOnLayout);
                if (typeof opts.maxRenderableNodes === 'number') setMaxRenderableNodes(opts.maxRenderableNodes);
              }
            }
          } catch {
            // Not JSON, ignore
          }
          return;
        }

        // Handle object message with json property
        if (data.json !== undefined) {
          setJsonInput(data.json);
          setDataReceived(true);
        }
        if (data.options) {
          const opts = data.options;
          if (opts.theme) setTheme(opts.theme);
          if (opts.layoutDirection) setLayoutDirection(opts.layoutDirection);
          if (typeof opts.showGrid === 'boolean') setShowGrid(opts.showGrid);
          if (typeof opts.showControls === 'boolean') setShowControls(opts.showControls);
          if (typeof opts.centerOnLayout === 'boolean') setCenterOnLayout(opts.centerOnLayout);
          if (typeof opts.maxRenderableNodes === 'number') setMaxRenderableNodes(opts.maxRenderableNodes);
        }
      } catch (error) {
        console.error('jsoncrack widget message error:', error);
      }
    };
    window.addEventListener('message', handler);
    return () => window.removeEventListener('message', handler);
  }, []);

  if (!dataReceived || jsonInput === null) {
    return (
      <>
        <Head>
          <meta name="robots" content="noindex, nofollow" />
        </Head>
        <div style={{
          width: '100vw',
          height: '100vh',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          background: theme === 'dark' ? '#1e1e1e' : '#ffffff',
        }}>
          <div style={{
            color: theme === 'dark' ? '#888' : '#999',
            fontSize: 14,
            fontFamily: 'system-ui, sans-serif',
          }}>
            Loading...
          </div>
        </div>
      </>
    );
  }

  return (
    <>
      <Head>
        <meta name="robots" content="noindex, nofollow" />
      </Head>
      <div style={{ width: '100vw', height: '100vh' }}>
        <JSONCrack
          key={1}
          json={jsonInput}
          theme={theme}
          layoutDirection={layoutDirection as any}
          showControls={showControls}
          showGrid={showGrid}
          centerOnLayout={centerOnLayout}
          maxRenderableNodes={maxRenderableNodes}
        />
      </div>
    </>
  );
};

export default WidgetPage;
WIDGET_EOF

echo "== Installing dependencies =="
npm install --omit=dev next react react-dom jsoncrack-react
npm install --save-dev typescript @types/react @types/react-dom @types/node

echo "== Building project =="
npx next build

echo "== Preparing output folder =="
cd "$ORIGINAL_DIR"
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# Copy only the widget page HTML, ensuring base directory is preserved for dynamic chunk loading
# Note: Turbopack runtime automatically resolves chunk paths using assetPrefix ('./_next/').
# The inline otherChunks registry must retain "static/chunks/..." for Turbopack to match them.
BASE_SCRIPT="<script>(function(){var b=document.createElement('base');var p=window.location.pathname;if(!p.endsWith('/')){p=p.substring(0,p.lastIndexOf('/')+1);}b.href=window.location.origin+p;document.head.appendChild(b);})();</script>"
sed "s|<head>|<head>${BASE_SCRIPT}|g" "$TMP_DIR/out/widget/index.html" > "$OUTPUT_DIR/index.html"

# Copy required assets (_next)
cp -r "$TMP_DIR/out/_next" "$OUTPUT_DIR/"


echo "== Deployment complete! Output in $OUTPUT_DIR =="
