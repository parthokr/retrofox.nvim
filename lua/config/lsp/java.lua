vim.lsp.config["jdtls"] = {
	cmd = { "jdtls" },
	filetypes = { "java" },
	root_markers = {
		".git",
		"pom.xml",
		"build.gradle",
		"settings.gradle",
	},
	settings = {
		java = {
			signatureHelp = {
				enabled = true,
			},
			completion = {
				autoInsert = true,
			},
			contentProvider = {
				preferred = "fernflower",
			},
			-- format = {
			-- 	settings = {
			-- 		url = "file://path/to/your/eclipse-java-google-style.xml",
			-- 		profile = "GoogleStyle",
			-- 	},
			-- },
		},
	},
}

vim.lsp.enable("jdtls")
