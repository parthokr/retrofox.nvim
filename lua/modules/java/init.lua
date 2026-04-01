-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Module: Java (nvim-jdtls — OS-aware)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if not require("retrofox.module").enabled("java") then return {} end

local os_util = require("retrofox.os")

--- Dynamically find the equinox launcher JAR so Mason updates don't break the config
local function get_jdtls_launcher()
    local jdtls_path = vim.fn.stdpath("data") .. "/mason/packages/jdtls"

    -- Check if JDTLS is installed via Mason
    if vim.fn.isdirectory(jdtls_path) ~= 1 then
        vim.notify(
            "JDTLS not installed. Run :MasonInstall jdtls",
            vim.log.levels.WARN,
            { title = "retrofox/java" }
        )
        return nil
    end

    local launcher_glob = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
    if launcher_glob == "" then
        vim.notify("JDTLS equinox launcher JAR not found!", vim.log.levels.ERROR)
        return nil
    end
    return vim.split(launcher_glob, "\n")[1]
end

local function setup_jdtls()
    local jdtls = require("jdtls")
    local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
    local jdtls_path = vim.fn.stdpath("data") .. "/mason/packages/jdtls"
    local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. project_name

    local launcher_jar = get_jdtls_launcher()
    if not launcher_jar then return end

    -- OS-aware config dir and Java path
    local os_config = os_util.jdtls_config()
    local java_cmd = os_util.java_cmd()

    local config = {
        cmd = {
            java_cmd,
            "-javaagent:" .. jdtls_path .. "/lombok.jar",
            "-Declipse.application=org.eclipse.jdt.ls.core.id1",
            "-Dosgi.bundles.defaultStartLevel=4",
            "-Declipse.product=org.eclipse.jdt.ls.core.product",
            "-Dlog.protocol=true",
            "-Dlog.level=ALL",
            "-Xmx1g",
            "--add-modules=ALL-SYSTEM",
            "--add-opens", "java.base/java.util=ALL-UNNAMED",
            "--add-opens", "java.base/java.lang=ALL-UNNAMED",
            "-jar", launcher_jar,
            "-configuration", jdtls_path .. "/" .. os_config,
            "-data", workspace_dir,
        },

        root_dir = require("jdtls.setup").find_root({
            "pom.xml", "build.gradle", "build.gradle.kts", ".project",
            "settings.gradle", "settings.gradle.kts", "mvnw", "gradlew", ".git",
        }),

        settings = {
            java = {
                imports = {
                    order = { "java", "javax", "jakarta", "org", "com" },
                },
                starThreshold = 5,
                staticStarThreshold = 3,
                saveActions = { organizeImports = true },
                completion = {
                    favoriteStaticMembers = {
                        "org.junit.Assert.*",
                        "org.junit.jupiter.api.Assertions.*",
                        "org.mockito.Mockito.*",
                        "org.mockito.ArgumentMatchers.*",
                        "java.util.Objects.*",
                        "java.util.stream.Collectors.*",
                    },
                    importOrder = { "java", "javax", "jakarta", "org", "com" },
                },
                codeGeneration = {
                    toString = {
                        template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
                    },
                    hashCodeEquals = { useJava7Objects = true, useInstanceof = true },
                    useBlocks = true,
                    generateComments = false,
                },
                sources = {
                    organizeImports = { starThreshold = 5, staticStarThreshold = 3 },
                },
                inlayHints = {
                    parameterNames = { enabled = "all" },
                },
                format = {
                    enabled = true,
                    settings = {
                        url = "https://raw.githubusercontent.com/google/styleguide/gh-pages/eclipse-java-google-style.xml",
                        profile = "GoogleStyle",
                    },
                },
                signatureHelp = { enabled = true, description = { enabled = true } },
                contentProvider = { preferred = "fernflower" },
                referencesCodeLens = { enabled = true },
                implementationsCodeLens = { enabled = true },
            },
        },

        init_options = { bundles = {} },

        on_attach = function(client, bufnr)
            local function map(mode, lhs, rhs, desc)
                vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc, noremap = true, silent = true })
            end
            map("n", "<leader>jo", function() jdtls.organize_imports() end, "[J]ava [O]rganize Imports")
            map("n", "<leader>jev", function() jdtls.extract_variable() end, "[J]ava [E]xtract [V]ariable")
            map("v", "<leader>jev", function() jdtls.extract_variable(true) end, "[J]ava [E]xtract [V]ariable")
            map("n", "<leader>jec", function() jdtls.extract_constant() end, "[J]ava [E]xtract [C]onstant")
            map("v", "<leader>jec", function() jdtls.extract_constant(true) end, "[J]ava [E]xtract [C]onstant")
            map("v", "<leader>jem", function() jdtls.extract_method(true) end, "[J]ava [E]xtract [M]ethod")
            map("n", "<leader>jsi", function() jdtls.super_implementation() end, "[J]ava [S]uper [I]mplementation")
            map("n", "<leader>jts", function()
                vim.lsp.buf.code_action({
                    context = { only = { "source.generate.toString" } },
                    apply = true,
                })
            end, "[J]ava Generate [T]o[S]tring")
            map("n", "<leader>jhe", function()
                vim.lsp.buf.code_action({
                    context = { only = { "source.generate.hashCodeEquals" } },
                    apply = true,
                })
            end, "[J]ava Generate [H]ashCode/[E]quals")
            map("n", "<leader>ju", function() jdtls.update_project_config() end, "[J]ava [U]pdate Project Config")
        end,
    }

    jdtls.start_or_attach(config)
end

-- Register the FileType autocmd for Java (moved from core/user_commands.lua)
vim.api.nvim_create_autocmd("FileType", {
    pattern = "java",
    callback = function()
        setup_jdtls()
    end,
    desc = "Set up Java LSP (JDTLS)",
})

-- Return plugin spec
return {
    "mfussenegger/nvim-jdtls",
    ft = { "java" },
}
