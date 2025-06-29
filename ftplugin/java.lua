local jdtls = require('jdtls')

local home = os.getenv("HOME")
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
local workspace_dir = home .. '/.local/share/eclipse/' .. project_name

local config = {
	cmd = {
		'jdtls',
		'-data', workspace_dir,
	},
	root_dir = require('jdtls.setup').find_root({
		'.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle',
	}),
	settings = {
		java = {
			signatureHelp = { enabled = true },
			contentProvider = { preferred = 'fernflower' },
		},
	},
}

jdtls.start_or_attach(config)
