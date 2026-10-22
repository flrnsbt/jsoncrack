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
  const [jsonInput, setJsonInput] = React.useState<string | object>('{}');
  const [theme, setTheme] = React.useState<'dark' | 'light'>('dark');
  const [layoutDirection, setLayoutDirection] = React.useState<string>('RIGHT');
  const [showGrid, setShowGrid] = React.useState<boolean>(true);

  React.useEffect(() => {
    if (isReady && typeof query?.json === 'string') {
      setJsonInput(query.json);
    }
  }, [isReady, query?.json]);

  // Signal ready to parent so it starts sending data
  React.useEffect(() => {
    if (typeof window !== 'undefined' && window.parent) {
      window.parent.postMessage({ type: 'ready' }, '*');
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
            if (parsed.json) {
              setJsonInput(parsed.json);
              if (parsed.options) {
                const opts = parsed.options;
                if (opts.theme) setTheme(opts.theme);
                setLayoutDirection(opts.layoutDirection);
                if (typeof opts.showGrid === 'boolean') setShowGrid(opts.showGrid);
              }
            }
          } catch {
            // Not JSON, ignore
          }
          return;
        }

        // Handle object message with json property
        if (data.json) {
          setJsonInput(data.json);
        }
        if (data.options) {
          const opts = data.options;
          if (opts.theme) setTheme(opts.theme);
          if (opts.layoutDirection) setLayoutDirection(opts.layoutDirection);
          if (typeof opts.showGrid === 'boolean') setShowGrid(opts.showGrid);
        }
      } catch (error) {
        console.error('jsoncrack widget message error:', error);
      }
    };
    window.addEventListener('message', handler);
    return () => window.removeEventListener('message', handler);
  }, []);

  return (
    <>
      <Head>
        <meta name="robots" content="noindex, nofollow" />
      </Head>
      <div style={{ width: '100vw', height: '100vh' }}>
        <JSONCrack
          json={jsonInput}
          theme={theme}
          layoutDirection={layoutDirection as any}
          showControls={false}
          showGrid={showGrid}
        />
      </div>
    </>
  );
};

export default WidgetPage;
WIDGET_EOF

echo "== Installing dependencies =="
npm install --production next react react-dom jsoncrack-react
npm install --save-dev typescript @types/react @types/react-dom @types/node

echo "== Building project =="
npx next build

echo "== Preparing output folder =="
cd "$ORIGINAL_DIR"
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# Copy only the widget page HTML
# Note: <base href="./"> is intentionally NOT used — browsers interpret it as the origin
# root (/), which breaks relative path resolution. The assetPrefix: './' in next.config.js
# already generates ./_next/static/... paths that resolve correctly relative to the
# HTML file's directory (e.g., assets/packages/jsoncrack/assets/src/_next/...)
cp "$TMP_DIR/out/widget.html" "$OUTPUT_DIR/index.html"

# Copy required assets (_next)
cp -r "$TMP_DIR/out/_next" "$OUTPUT_DIR/"

echo "== Deployment complete! Output in $OUTPUT_DIR =="
