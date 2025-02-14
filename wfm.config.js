import { defineConfig } from "@whitigol/fivem-compiler";

export default defineConfig({
	// Watch for file changes in the specified directories and subdirectories.
	// This configuration allows targeted builds by specifying different scopes: server, client, or all files.
	// Use these options with build flags such as --skip-server or --skip-client for more control.
	watch: {
		server: ["src/server/**/*.{lua,ts,js}"], // Files specific to the server-side codebase
		client: ["src/client/**/*.{lua,ts,js}"], // Files specific to the client-side codebase
	},

	// Skips moving files defined in the "copy" option during watch mode.
	// This helps speed up build times in development, especially for large files
	// (e.g., assets in the "stream" folder) that you only want to move during a build.
	skipCopyDuringWatch: true,

	//! WARNING: Minification is discouraged and may violate FiveM's Terms of Service. Use at your own risk.
	//* Note: Minification is not supported for Lua files.
	minify: false,

	//! WARNING: Obfuscation is discouraged and may violate FiveM's Terms of Service. Use at your own risk.
	//* Note: Obfuscation is not supported for Lua files.
	obfuscate: false, //? Enabling this option may significantly increase build times.

	// Configuration for the output resource directory.
	resource: {
		// Specify the root output directory for the final built resource.
		//* NOTE: If the "OUTPUT_DIR" environment variable is defined, it will override this value.
		//! DO NOT USE A LEADING SLASH — IT WILL BREAK THE BUILD!
		directory: "FS-Lib",
	},
});
