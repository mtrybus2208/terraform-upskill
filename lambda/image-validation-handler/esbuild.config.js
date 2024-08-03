const esbuild = require("esbuild");
const path = require("path");

esbuild
  .build({
    entryPoints: ["src/index.ts"],
    bundle: true,
    platform: "node",
    target: "node20",
    outdir: "dist",
    external: ["aws-lambda", "@aws-sdk/*"],
    sourcemap: false,
    tsconfig: path.resolve(__dirname, "tsconfig.json"),
    minify: true,
  })
  .catch(() => process.exit(1));
