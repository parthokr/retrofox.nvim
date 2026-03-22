local M = {}

--- Dynamically find the equinox launcher JAR so Mason updates don't break the config
local function get_jdtls_launcher()
    local jdtls_path = vim.fn.stdpath("data") .. "/mason/packages/jdtls"
    local launcher_glob = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
    if launcher_glob == "" then
        vim.notify("JDTLS equinox launcher JAR not found!", vim.log.levels.ERROR)
        return nil
    end
    -- glob may return multiple lines; take the first
    return vim.split(launcher_glob, "\n")[1]
end

function M:setup()
    local jdtls = require("jdtls")
    local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
    local jdtls_path = vim.fn.stdpath("data") .. "/mason/packages/jdtls"
    local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. project_name

    local launcher_jar = get_jdtls_launcher()
    if not launcher_jar then
        return
    end

    -- Detect OS for JDTLS config dir
    local os_config = "config_mac_arm"
    if vim.fn.has("linux") == 1 then
        os_config = "config_linux"
    elseif vim.fn.has("win32") == 1 then
        os_config = "config_win"
    end

    local config = {
        cmd = {
            "/usr/bin/java",
            "-javaagent:" .. jdtls_path .. "/lombok.jar",
            "-Declipse.application=org.eclipse.jdt.ls.core.id1",
            "-Dosgi.bundles.defaultStartLevel=4",
            "-Declipse.product=org.eclipse.jdt.ls.core.product",
            "-Dlog.protocol=true",
            "-Dlog.level=ALL",
            "-Xmx1g",
            "--add-modules=ALL-SYSTEM",
            "--add-opens",
            "java.base/java.util=ALL-UNNAMED",
            "--add-opens",
            "java.base/java.lang=ALL-UNNAMED",
            "-jar",
            launcher_jar,
            "-configuration",
            jdtls_path .. "/" .. os_config,
            "-data",
            workspace_dir,
        },

        -- 8. Better root detection
        root_dir = require("jdtls.setup").find_root({
            "pom.xml",
            "build.gradle",
            "build.gradle.kts",
            ".project",
            "settings.gradle",
            "settings.gradle.kts",
            "mvnw",
            "gradlew",
            ".git",
        }),

        -- 4. Rich JDTLS settings
        settings = {
            java = {
                -- Import organisation
                imports = {
                    order = {
                        "java",
                        "javax",
                        "jakarta",
                        "org",
                        "com",
                    },
                },
                -- Static star-import threshold
                starThreshold = 5,
                staticStarThreshold = 3,

                -- Save actions
                saveActions = {
                    organizeImports = true,
                },

                -- Completion favourites
                completion = {
                    favoriteStaticMembers = {
                        "org.junit.Assert.*",
                        "org.junit.jupiter.api.Assertions.*",
                        "org.mockito.Mockito.*",
                        "org.mockito.ArgumentMatchers.*",
                        "java.util.Objects.*",
                        "java.util.stream.Collectors.*",
                    },
                    importOrder = {
                        "java",
                        "javax",
                        "jakarta",
                        "org",
                        "com",
                    },
                },

                -- Code generation preferences
                codeGeneration = {
                    toString = {
                        template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
                    },
                    hashCodeEquals = {
                        useJava7Objects = true,
                        useInstanceof = true,
                    },
                    useBlocks = true,
                    generateComments = false,
                },

                -- Sources
                sources = {
                    organizeImports = {
                        starThreshold = 5,
                        staticStarThreshold = 3,
                    },
                },

                -- Inlay hints
                inlayHints = {
                    parameterNames = {
                        enabled = "all",
                    },
                },

                -- 5. Use JDTLS built-in formatter (Google style)
                format = {
                    enabled = true,
                    settings = {
                        url = "https://raw.githubusercontent.com/google/styleguide/gh-pages/eclipse-java-google-style.xml",
                        profile = "GoogleStyle",
                    },
                },

                -- Signature help
                signatureHelp = {
                    enabled = true,
                    description = { enabled = true },
                },

                -- Content assist
                contentProvider = {
                    preferred = "fernflower",
                },

                -- References code lens
                referencesCodeLens = {
                    enabled = true,
                },

                -- Implementations code lens
                implementationsCodeLens = {
                    enabled = true,
                },
            },
        },

        init_options = {
            bundles = {},
        },

        -- 3. Java-specific keymaps (on_attach)
        on_attach = function(client, bufnr)
            local function map(mode, lhs, rhs, desc)
                vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc, noremap = true, silent = true })
            end

            -- Organise imports
            map("n", "<leader>jo", function() jdtls.organize_imports() end, "[J]ava [O]rganize Imports")

            -- Extract variable / constant / method
            map("n", "<leader>jev", function() jdtls.extract_variable() end, "[J]ava [E]xtract [V]ariable")
            map("v", "<leader>jev", function() jdtls.extract_variable(true) end, "[J]ava [E]xtract [V]ariable")
            map("n", "<leader>jec", function() jdtls.extract_constant() end, "[J]ava [E]xtract [C]onstant")
            map("v", "<leader>jec", function() jdtls.extract_constant(true) end, "[J]ava [E]xtract [C]onstant")
            map("v", "<leader>jem", function() jdtls.extract_method(true) end, "[J]ava [E]xtract [M]ethod")

            -- Pick & action
            map("n", "<leader>jsi", function() jdtls.super_implementation() end, "[J]ava [S]uper [I]mplementation")

            -- Code generation
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

            -- Update project config (useful after editing pom.xml / build.gradle)
            map("n", "<leader>ju", function() jdtls.update_project_config() end, "[J]ava [U]pdate Project Config")
        end,
    }

    jdtls.start_or_attach(config)
end

return M
